#!/bin/bash

# Screenshot script for Hyprland
# Offers options to save, edit, or copy screenshot

SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOT_DIR"

# Generate filename with date and time
FILENAME="$SCREENSHOT_DIR/screenshot_$(date +%Y%m%d_%H%M%S).png"

# Take screenshot to temporary file first
TEMP_FILE="/tmp/screenshot_$(date +%s).png"
grim "$TEMP_FILE"

# Check if screenshot was taken successfully
if [ ! -f "$TEMP_FILE" ]; then
    notify-send "Screenshot Failed" "Could not capture screenshot"
    exit 1
fi

# Show menu with options using wofi (or rofi as fallback)
if command -v wofi &> /dev/null; then
    CHOICE=$(echo -e "Save\nEdit\nCopy\nCancel" | wofi --dmenu --prompt "Screenshot captured. What would you like to do?")
elif command -v rofi &> /dev/null; then
    CHOICE=$(echo -e "Save\nEdit\nCopy\nCancel" | rofi -dmenu -p "Screenshot captured. What would you like to do?")
else
    # Fallback: just save it
    CHOICE="Save"
fi

case "$CHOICE" in
    "Save")
        mv "$TEMP_FILE" "$FILENAME"
        notify-send "Screenshot Saved" "$FILENAME"
        ;;
    "Edit")
        # Check if swappy is installed
        if command -v swappy &> /dev/null; then
            swappy -f "$TEMP_FILE" -o "$FILENAME"
            rm -f "$TEMP_FILE"
            notify-send "Screenshot" "Edited screenshot saved to $FILENAME"
        else
            # Fallback to save if swappy not installed
            mv "$TEMP_FILE" "$FILENAME"
            notify-send "Swappy not installed" "Screenshot saved to $FILENAME instead"
        fi
        ;;
    "Copy")
        wl-copy < "$TEMP_FILE"
        rm -f "$TEMP_FILE"
        notify-send "Screenshot Copied" "Screenshot copied to clipboard"
        ;;
    "Cancel"|*)
        rm -f "$TEMP_FILE"
        notify-send "Screenshot Cancelled" "Screenshot discarded"
        ;;
esac
