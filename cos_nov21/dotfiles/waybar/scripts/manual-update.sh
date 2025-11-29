#!/bin/bash
# Manual waybar color update - run this after changing wallpaper to test

echo "=== Manual Waybar Color Update ==="
echo ""
echo "Current wallpaper according to .current-wallpaper file:"
cat ~/.config/hypr/.current-wallpaper 2>/dev/null || echo "File not found!"
echo ""

echo "Running color extraction..."
~/.config/waybar/scripts/update-colors-from-wallpaper.sh

echo ""
echo "Generated CSS preview:"
head -25 ~/.cache/waybar/colors.css | grep -E "Auto-generated|Brightness|#waybar|background-color|color:"

echo ""
echo "✓ Done! Waybar should have restarted with new colors."
echo "If colors didn't change, your wallpaper manager might not be updating .current-wallpaper"
