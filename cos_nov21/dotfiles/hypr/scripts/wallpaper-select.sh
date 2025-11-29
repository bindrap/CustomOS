#!/bin/bash
# Interactive wallpaper selector with grid layout - Frosted Glass Design

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

    # Get just the filename without extension for cleaner display
    basename "$shortened" | sed 's/\.[^.]*$//'
}

# Create menu entries for rofi with images
MENU_ENTRIES=""
CURRENT_WALLPAPER=$(get_current_wallpaper)
for i in "${!WALLPAPER_LIST[@]}"; do
    wallpaper="${WALLPAPER_LIST[$i]}"
    label=$(format_wallpaper_label "$wallpaper")
    
    # Add marker for current wallpaper
    if [ "$wallpaper" = "$CURRENT_WALLPAPER" ]; then
        label="● $label"
    fi
    
    # Format: index||label for parsing later
    MENU_ENTRIES+="$i||$label\n"
done

# Show rofi with grid layout
SELECTED=$(printf "%b" "$MENU_ENTRIES" | while IFS= read -r line; do
    idx="${line%%||*}"
    label="${line#*||}"
    wp_path="${WALLPAPER_LIST[$idx]}"
    # Rofi format: label \0icon\x1f path
    printf "%s\0icon\x1f%s\n" "$label" "$wp_path"
done | rofi -dmenu -i -p "󰸉  Wallpaper" \
    -theme ~/.config/rofi/wallpaper.rasi \
    -show-icons)

if [ -z "$SELECTED" ]; then
    exit 0
fi

# Extract index from selection (remove marker if present)
SELECTED_CLEAN=$(echo "$SELECTED" | sed 's/^● //')

# Find matching wallpaper
for i in "${!WALLPAPER_LIST[@]}"; do
    label=$(format_wallpaper_label "${WALLPAPER_LIST[$i]}")
    if [ "$label" = "$SELECTED_CLEAN" ] || [ "● $label" = "$SELECTED" ]; then
        set_wallpaper "${WALLPAPER_LIST[$i]}"
        exit 0
    fi
done
