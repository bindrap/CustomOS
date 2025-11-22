#!/bin/bash
# Cycle to next wallpaper

HYPR_DIR="$HOME/.config/hypr"
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
THEME_NAME=$(cat "$HYPR_DIR/.current-theme" 2>/dev/null || echo "catppuccin-mocha")

# Get current wallpaper
CURRENT_WALLPAPER=$(cat "$HYPR_DIR/.current-wallpaper" 2>/dev/null)

# Get list of wallpapers for current theme
if [ -d "$WALLPAPER_DIR/$THEME_NAME" ]; then
    WALLPAPER_LIST=("$WALLPAPER_DIR/$THEME_NAME"/*.{jpg,png})
else
    WALLPAPER_LIST=("$WALLPAPER_DIR"/*.{jpg,png})
fi

# Remove glob patterns if no files found
WALLPAPER_LIST=("${WALLPAPER_LIST[@]}" | grep -v '\*')

if [ ${#WALLPAPER_LIST[@]} -eq 0 ]; then
    notify-send "No Wallpapers" "No wallpapers found" -u critical
    exit 1
fi

# Find current index
CURRENT_INDEX=-1
for i in "${!WALLPAPER_LIST[@]}"; do
    if [ "${WALLPAPER_LIST[$i]}" = "$CURRENT_WALLPAPER" ]; then
        CURRENT_INDEX=$i
        break
    fi
done

# Get next wallpaper
NEXT_INDEX=$(( (CURRENT_INDEX + 1) % ${#WALLPAPER_LIST[@]} ))
NEXT_WALLPAPER="${WALLPAPER_LIST[$NEXT_INDEX]}"

# Set wallpaper
if command -v swww >/dev/null 2>&1; then
    swww img "$NEXT_WALLPAPER" --transition-type grow --transition-pos "$(hyprctl cursorpos)" --transition-fps 60
else
    killall hyprpaper 2>/dev/null
    echo "preload = $NEXT_WALLPAPER" > "$HYPR_DIR/hyprpaper.conf"
    echo "wallpaper = ,$NEXT_WALLPAPER" >> "$HYPR_DIR/hyprpaper.conf"
    hyprpaper &
fi

echo "$NEXT_WALLPAPER" > "$HYPR_DIR/.current-wallpaper"
notify-send "Wallpaper Changed" "$(basename "$NEXT_WALLPAPER")" -t 2000
