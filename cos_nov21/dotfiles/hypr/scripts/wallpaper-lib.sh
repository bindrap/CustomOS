#!/bin/bash
# Shared wallpaper library functions
# Used by wallpaper-next.sh, wallpaper-prev.sh, etc.

HYPR_DIR="$HOME/.config/hypr"
WALLPAPER_DIR="$HOME/Pictures/wallpapers"

# Get list of available wallpapers
get_wallpaper_list() {
    local THEME_NAME=$(cat "$HYPR_DIR/.current-theme" 2>/dev/null || echo "default")
    local WALLPAPER_LIST=()

    # Check for theme-specific wallpapers
    if [ -d "$WALLPAPER_DIR/$THEME_NAME" ]; then
        WALLPAPER_LIST=($(find "$WALLPAPER_DIR/$THEME_NAME" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) 2>/dev/null))
    fi

    # Fallback to main wallpaper directory
    if [ ${#WALLPAPER_LIST[@]} -eq 0 ]; then
        WALLPAPER_LIST=($(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) 2>/dev/null))
    fi

    if [ ${#WALLPAPER_LIST[@]} -eq 0 ]; then
        return 1
    fi

    # Sort for consistent order
    IFS=$'\n' WALLPAPER_LIST=($(sort <<<"${WALLPAPER_LIST[*]}"))
    unset IFS

    printf '%s\n' "${WALLPAPER_LIST[@]}"
}

# Get current wallpaper
get_current_wallpaper() {
    cat "$HYPR_DIR/.current-wallpaper" 2>/dev/null
}

# Set wallpaper using available backend
set_wallpaper() {
    local WALLPAPER="$1"

    if [ ! -f "$WALLPAPER" ]; then
        notify-send "Wallpaper Error" "File not found: $(basename "$WALLPAPER")" -u critical
        return 1
    fi

    # Try swww first (with fancy transitions)
    if command -v swww >/dev/null 2>&1; then
        swww img "$WALLPAPER" \
            --transition-type grow \
            --transition-pos "$(hyprctl cursorpos 2>/dev/null || echo '0,0')" \
            --transition-fps 60 \
            --transition-duration 0.8
    # Fallback to swaybg
    elif command -v swaybg >/dev/null 2>&1; then
        pkill swaybg
        swaybg -i "$WALLPAPER" -m fill &
    # Fallback to hyprpaper
    elif command -v hyprpaper >/dev/null 2>&1; then
        pkill hyprpaper 2>/dev/null
        echo "preload = $WALLPAPER" > "$HYPR_DIR/hyprpaper.conf"
        echo "wallpaper = ,$WALLPAPER" >> "$HYPR_DIR/hyprpaper.conf"
        hyprpaper &
    else
        notify-send "Wallpaper Error" "No wallpaper backend found (swww/swaybg/hyprpaper)" -u critical
        return 1
    fi

    # Save current wallpaper
    echo "$WALLPAPER" > "$HYPR_DIR/.current-wallpaper"
    notify-send "Wallpaper Changed" "$(basename "$WALLPAPER")" -t 2000 -i "$WALLPAPER"

    return 0
}

# Cycle wallpaper (direction: next or prev)
cycle_wallpaper() {
    local DIRECTION="$1"  # "next" or "prev"

    # Get wallpaper list
    local WALLPAPER_LIST=($(get_wallpaper_list))

    if [ ${#WALLPAPER_LIST[@]} -eq 0 ]; then
        notify-send "No Wallpapers" "No wallpapers found in $WALLPAPER_DIR" -u critical
        return 1
    fi

    # Get current wallpaper
    local CURRENT_WALLPAPER=$(get_current_wallpaper)

    # Find current index
    local CURRENT_INDEX=-1
    for i in "${!WALLPAPER_LIST[@]}"; do
        if [ "${WALLPAPER_LIST[$i]}" = "$CURRENT_WALLPAPER" ]; then
            CURRENT_INDEX=$i
            break
        fi
    done

    # Calculate next index
    local NEXT_INDEX
    if [ "$DIRECTION" = "prev" ]; then
        NEXT_INDEX=$(( (CURRENT_INDEX - 1 + ${#WALLPAPER_LIST[@]}) % ${#WALLPAPER_LIST[@]} ))
    else
        NEXT_INDEX=$(( (CURRENT_INDEX + 1) % ${#WALLPAPER_LIST[@]} ))
    fi

    # Set new wallpaper
    set_wallpaper "${WALLPAPER_LIST[$NEXT_INDEX]}"
}
