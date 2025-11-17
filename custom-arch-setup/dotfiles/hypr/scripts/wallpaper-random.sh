#!/bin/bash
# Set random wallpaper from current theme

HYPR_DIR="$HOME/.config/hypr"
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
THEME_NAME=$(cat "$HYPR_DIR/.current-theme" 2>/dev/null || echo "catppuccin-mocha")

# Get list of wallpapers
if [ -d "$WALLPAPER_DIR/$THEME_NAME" ]; then
    WALLPAPER=$(find "$WALLPAPER_DIR/$THEME_NAME" -type f \( -name "*.jpg" -o -name "*.png" \) | shuf -n 1)
else
    WALLPAPER=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -name "*.jpg" -o -name "*.png" \) | shuf -n 1)
fi

if [ -z "$WALLPAPER" ]; then
    notify-send "No Wallpapers" "No wallpapers found" -u critical
    exit 1
fi

# Set wallpaper
if command -v swww >/dev/null 2>&1; then
    swww img "$WALLPAPER" --transition-type random --transition-fps 60
else
    killall hyprpaper 2>/dev/null
    echo "preload = $WALLPAPER" > "$HYPR_DIR/hyprpaper.conf"
    echo "wallpaper = ,$WALLPAPER" >> "$HYPR_DIR/hyprpaper.conf"
    hyprpaper &
fi

echo "$WALLPAPER" > "$HYPR_DIR/.current-wallpaper"
notify-send "Wallpaper Changed" "$(basename "$WALLPAPER")" -t 2000
