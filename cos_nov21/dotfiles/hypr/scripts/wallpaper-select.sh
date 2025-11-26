#!/bin/bash
# Interactive wallpaper selector with preview - Hyde Style

HYPR_DIR="$HOME/.config/hypr"
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
THEME_NAME=$(cat "$HYPR_DIR/.current-theme" 2>/dev/null || echo "catppuccin-mocha")

# Get list of wallpapers
if [ -d "$WALLPAPER_DIR/$THEME_NAME" ]; then
    WALLPAPER_LIST=("$WALLPAPER_DIR/$THEME_NAME"/*.{jpg,png,jpeg})
else
    WALLPAPER_LIST=("$WALLPAPER_DIR"/*.{jpg,png,jpeg})
fi

# Remove glob patterns if no files found
WALLPAPER_LIST=("${WALLPAPER_LIST[@]}" | grep -v '\*')

if [ ${#WALLPAPER_LIST[@]} -eq 0 ]; then
    notify-send "No Wallpapers" "No wallpapers found in $WALLPAPER_DIR" -u critical
    exit 1
fi

# Create menu entries
MENU_ENTRIES=""
CURRENT_WALLPAPER=$(cat "$HYPR_DIR/.current-wallpaper" 2>/dev/null)
for wallpaper in "${WALLPAPER_LIST[@]}"; do
    if [ "$wallpaper" = "$CURRENT_WALLPAPER" ]; then
        MENU_ENTRIES+="● $(basename "$wallpaper") (current)\n"
    else
        MENU_ENTRIES+="  $(basename "$wallpaper")\n"
    fi
done

# Show menu and get selection (prefer rofi, fallback to wofi)
if command -v rofi >/dev/null 2>&1; then
    SELECTED=$(echo -e "$MENU_ENTRIES" | rofi -dmenu -i -p "󰸉 Select Wallpaper" -theme-str 'window {width: 600px;} listview {lines: 12;}')
else
    SELECTED=$(echo -e "$MENU_ENTRIES" | wofi --dmenu --prompt "󰸉 Select Wallpaper" --width 600 --height 400)
fi

if [ -z "$SELECTED" ]; then
    exit 0
fi

# Extract wallpaper name (remove marker and current indicator)
WALLPAPER_NAME=$(echo "$SELECTED" | sed 's/^[●  ]*//' | sed 's/ (current)$//')

# Find full path
for wallpaper in "${WALLPAPER_LIST[@]}"; do
    if [ "$(basename "$wallpaper")" = "$WALLPAPER_NAME" ]; then
        SELECTED_WALLPAPER="$wallpaper"
        break
    fi
done

# Set wallpaper
if [ -n "$SELECTED_WALLPAPER" ]; then
    if command -v swww >/dev/null 2>&1; then
        swww img "$SELECTED_WALLPAPER" --transition-type fade --transition-fps 60
    else
        killall hyprpaper 2>/dev/null
        echo "preload = $SELECTED_WALLPAPER" > "$HYPR_DIR/hyprpaper.conf"
        echo "wallpaper = ,$SELECTED_WALLPAPER" >> "$HYPR_DIR/hyprpaper.conf"
        hyprpaper &
    fi

    echo "$SELECTED_WALLPAPER" > "$HYPR_DIR/.current-wallpaper"
    notify-send "󰸉 Wallpaper Changed" "$WALLPAPER_NAME" -t 2000
fi
