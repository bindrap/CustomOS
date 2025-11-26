#!/bin/bash
# Interactive wallpaper selector with preview - Hyde Style

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/wallpaper-lib.sh"

HYPR_DIR="${HYPR_DIR:-$HOME/.config/hypr}"

mapfile -t WALLPAPER_LIST < <(get_wallpaper_list)
mapfile -t WALLPAPER_ROOTS < <(get_wallpaper_roots)

if [ ${#WALLPAPER_LIST[@]} -eq 0 ]; then
    notify-send "No Wallpapers" "No wallpapers found in $(get_wallpaper_roots | paste -sd ', ' -)" -u critical
    exit 1
fi

# Build a readable name that shows folder context for similarly named files
format_wallpaper_label() {
    local path="$1"
    local shortened="$path"

    for root in "${WALLPAPER_ROOTS[@]}"; do
        case "$path" in
            "$root"/*)
                shortened="${path#"$root"/}"
                break
                ;;
        esac
    done

    echo "$shortened"
}

# Create menu entries with deterministic indices so selection always resolves
MENU_ENTRIES=""
CURRENT_WALLPAPER=$(get_current_wallpaper)
for i in "${!WALLPAPER_LIST[@]}"; do
    wallpaper="${WALLPAPER_LIST[$i]}"
    marker="  "
    [ "$wallpaper" = "$CURRENT_WALLPAPER" ] && marker="● "

    MENU_ENTRIES+="$i||$marker$(format_wallpaper_label "$wallpaper")\n"
done

# Show menu and get selection (prefer rofi, fallback to wofi)
if command -v rofi >/dev/null 2>&1; then
    SELECTED=$(echo -e "$MENU_ENTRIES" | rofi -dmenu -i -p "󰸉 Select Wallpaper" -theme-str 'window {width: 720px;} listview {lines: 12;}')
else
    SELECTED=$(echo -e "$MENU_ENTRIES" | wofi --dmenu --prompt "󰸉 Select Wallpaper" --width 720 --height 440)
fi

if [ -z "$SELECTED" ]; then
    exit 0
fi

# Resolve selection via stable index prefix (format: index||label)
SELECTED_INDEX=$(echo "$SELECTED" | cut -d '|' -f1)

if [[ "$SELECTED_INDEX" =~ ^[0-9]+$ ]] && [ "$SELECTED_INDEX" -lt ${#WALLPAPER_LIST[@]} ]; then
    set_wallpaper "${WALLPAPER_LIST[$SELECTED_INDEX]}"
fi
