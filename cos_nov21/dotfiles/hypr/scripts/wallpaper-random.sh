#!/bin/bash
# Set random wallpaper from available wallpapers

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/wallpaper-lib.sh"

# Get wallpaper list
WALLPAPER_LIST=($(get_wallpaper_list))

if [ ${#WALLPAPER_LIST[@]} -eq 0 ]; then
    notify-send "No Wallpapers" "No wallpapers found in $WALLPAPER_DIR" -u critical
    exit 1
fi

# Pick random wallpaper
RANDOM_WALLPAPER="${WALLPAPER_LIST[$RANDOM % ${#WALLPAPER_LIST[@]}]}"

# Set it
set_wallpaper "$RANDOM_WALLPAPER"
