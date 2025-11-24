#!/bin/bash
# Wallpaper fallback script for PBOS
# Priority: kissArch.jpg > other wallpapers > slime green

# Kill any existing swaybg processes
pkill swaybg

WALLPAPER_DIRS=(
    "$HOME/Pictures/wallpapers"
    "$HOME/Pictures"
    "/usr/share/backgrounds"
)

# Color fallback (slime green)
FALLBACK_COLOR="#39FF14"

# Check for kissArch.jpg first
for dir in "${WALLPAPER_DIRS[@]}"; do
    if [ -f "$dir/kissArch.jpg" ]; then
        echo "PBOS Wallpaper: Found kissArch.jpg at $dir/kissArch.jpg"
        exec swaybg -i "$dir/kissArch.jpg" -m fill
    fi
done

# Try to find any wallpaper
for dir in "${WALLPAPER_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        WALLPAPER=$(find "$dir" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) 2>/dev/null | head -1)
        if [ -n "$WALLPAPER" ]; then
            echo "PBOS Wallpaper: Found wallpaper at $WALLPAPER"
            exec swaybg -i "$WALLPAPER" -m fill
        fi
    fi
done

# Final fallback: slime green
echo "PBOS Wallpaper: No wallpaper found, using slime green fallback"
exec swaybg -c "$FALLBACK_COLOR"
