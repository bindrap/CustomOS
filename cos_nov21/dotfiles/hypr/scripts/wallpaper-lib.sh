#!/bin/bash
# Shared wallpaper library functions
# Used by wallpaper-next.sh, wallpaper-prev.sh, etc.

HYPR_DIR="${HYPR_DIR:-$HOME/.config/hypr}"
WALLPAPER_PRIMARY_DIR="${WALLPAPER_PRIMARY_DIR:-$HOME/Pictures/wallpapers}"
WALLPAPER_SECONDARY_DIR="${WALLPAPER_SECONDARY_DIR:-$HOME/Pictures/Wallpapers}"

get_wallpaper_roots() {
    local roots=()

    if [ -d "$WALLPAPER_PRIMARY_DIR" ]; then
        roots+=("$WALLPAPER_PRIMARY_DIR")
    fi

    if [ -d "$WALLPAPER_SECONDARY_DIR" ]; then
        roots+=("$WALLPAPER_SECONDARY_DIR")
    fi

    printf '%s\n' "${roots[@]}"
}

# Get list of available wallpapers
get_wallpaper_list() {
    local THEME_NAME=$(cat "$HYPR_DIR/.current-theme" 2>/dev/null || echo "catppuccin-mocha")
    local WALLPAPER_LIST=()
    local ROOT_DIRS=($(get_wallpaper_roots))

    if [ ${#ROOT_DIRS[@]} -eq 0 ]; then
        return 1
    fi

    # Check for theme-specific wallpapers
    for dir in "${ROOT_DIRS[@]}"; do
        if [ -d "$dir/$THEME_NAME" ]; then
            while IFS= read -r file; do
                WALLPAPER_LIST+=("$file")
            done < <(find "$dir/$THEME_NAME" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) 2>/dev/null)
        fi
    done

    # Fallback to main wallpaper directory (recursive to capture nested sets)
    if [ ${#WALLPAPER_LIST[@]} -eq 0 ]; then
        for dir in "${ROOT_DIRS[@]}"; do
            while IFS= read -r file; do
                WALLPAPER_LIST+=("$file")
            done < <(find "$dir" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) 2>/dev/null)
        done
    fi

    if [ ${#WALLPAPER_LIST[@]} -eq 0 ]; then
        return 1
    fi

    # Sort for consistent order
    mapfile -t WALLPAPER_LIST < <(printf '%s\n' "${WALLPAPER_LIST[@]}" | sort -u)

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
        # Get screen center for raindrop effect
        local screen_info=$(hyprctl monitors -j 2>/dev/null | grep -o '"width":[0-9]*,"height":[0-9]*' | head -1)
        local width=$(echo "$screen_info" | grep -o '"width":[0-9]*' | cut -d: -f2)
        local height=$(echo "$screen_info" | grep -o '"height":[0-9]*' | cut -d: -f2)
        local center_x=$((width / 2))
        local center_y=$((height / 2))
        local transition_pos="${center_x:-960},${center_y:-540}"

        swww img "$WALLPAPER" \
            --transition-type grow \
            --transition-pos "$transition_pos" \
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
        notify-send "No Wallpapers" "No wallpapers found in $(get_wallpaper_roots | paste -sd ', ' -)" -u critical
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
