#!/bin/bash

# Watch for wallpaper changes and update Waybar colors automatically
# This watches swww cache, .current-wallpaper, or hyprpaper config for changes

UPDATE_SCRIPT="$HOME/.config/waybar/scripts/update-colors-from-wallpaper.sh"
CURRENT_WALLPAPER_FILE="$HOME/.config/hypr/.current-wallpaper"
LAST_WALLPAPER=""
DEBOUNCE_TIME=1

# Run once on startup to set initial colors
"$UPDATE_SCRIPT"
LAST_WALLPAPER=$(cat "$CURRENT_WALLPAPER_FILE" 2>/dev/null)

# Primary method: watch .current-wallpaper file (works with all backends)
if [ -f "$CURRENT_WALLPAPER_FILE" ]; then
    echo "Watching .current-wallpaper for changes..."

    # Watch the file for modifications (only close_write to avoid multiple triggers)
    inotifywait -m -e close_write "$CURRENT_WALLPAPER_FILE" |
    while read -r directory events filename; do
        # Read the new wallpaper
        NEW_WALLPAPER=$(cat "$CURRENT_WALLPAPER_FILE" 2>/dev/null)

        # Only update if wallpaper actually changed (debouncing)
        if [ "$NEW_WALLPAPER" != "$LAST_WALLPAPER" ]; then
            echo "Wallpaper changed: $(basename "$NEW_WALLPAPER")"

            # Wait a moment to ensure file operations are complete
            sleep 0.3

            # Update colors
            "$UPDATE_SCRIPT"

            # Remember this wallpaper
            LAST_WALLPAPER="$NEW_WALLPAPER"
        fi
    done
else
    # Fallback: Watch swww cache directory
    SWWW_CACHE="$HOME/.cache/swww"

    if command -v swww >/dev/null 2>&1; then
        echo "Watching swww cache for wallpaper changes..."

        # Create cache dir if it doesn't exist yet
        mkdir -p "$SWWW_CACHE"

        # Watch for changes
        inotifywait -m -e modify,create,close_write "$SWWW_CACHE" |
        while read -r directory events filename; do
            echo "Wallpaper changed (detected via swww cache), updating Waybar colors..."
            sleep 1  # Give swww time to finish writing
            "$UPDATE_SCRIPT"
        done
    else
        # Last resort: watch hyprpaper config
        echo "Watching hyprpaper config for wallpaper changes..."

        HYPRPAPER_CONF="$HOME/.config/hypr/hyprpaper.conf"

        inotifywait -m -e modify,close_write "$HYPRPAPER_CONF" |
        while read -r directory events filename; do
            echo "Wallpaper changed (detected via hyprpaper.conf), updating Waybar colors..."
            sleep 1
            "$UPDATE_SCRIPT"
        done
    fi
fi
