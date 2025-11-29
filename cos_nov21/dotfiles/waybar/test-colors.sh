#!/bin/bash

echo "=== Testing Waybar Color Changes ==="
echo ""
echo "This will cycle through 3 very different wallpapers to test color changes."
echo "Watch your Waybar - the background and text colors should change noticeably."
echo ""

WALLPAPERS=(
    "/home/parteek/Pictures/wallpapers/kissArch.jpg"
    "/home/parteek/Pictures/wallpapers/galaxy.png"
    "/home/parteek/Pictures/wallpapers/windowsXP.jpg"
)

NAMES=("kissArch (LIGHT MODE)" "galaxy (DARK - black)" "windowsXP (DARK - green)")

for i in {0..2}; do
    echo "[$((i+1))/3] Changing to: ${NAMES[$i]}"
    echo "${WALLPAPERS[$i]}" > ~/.config/hypr/.current-wallpaper

    sleep 2

    # Show what was generated
    echo "  Generated: $(head -3 ~/.cache/waybar/colors.css | grep -o 'wallpaper:.*' | head -1)"
    echo "  Background: $(grep '#waybar {' -A3 ~/.cache/waybar/colors.css | grep 'background-color' | tr -s ' ')"
    echo "  Text: $(grep '#waybar {' -A3 ~/.cache/waybar/colors.css | grep '    color:' | tr -s ' ')"
    echo ""

    if [ $i -lt 2 ]; then
        echo "  Waiting 3 seconds before next change..."
        sleep 3
    fi
done

echo "✓ Test complete!"
echo ""
echo "You should have seen Waybar change:"
echo "1. kissArch: Light background, DARK text"
echo "2. galaxy: Dark black background, light text"
echo "3. windowsXP: Dark greenish background, light text"
