#!/bin/bash
# Area screenshot with slurp and grim

SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOT_DIR"

FILENAME="$SCREENSHOT_DIR/$(date +%Y%m%d_%H%M%S).png"

grim -g "$(slurp)" "$FILENAME"

if [ $? -eq 0 ]; then
    wl-copy < "$FILENAME"
    notify-send "Screenshot Saved" "Saved to $FILENAME\nCopied to clipboard" -t 3000
else
    notify-send "Screenshot Failed" "Could not save screenshot" -u critical
fi
