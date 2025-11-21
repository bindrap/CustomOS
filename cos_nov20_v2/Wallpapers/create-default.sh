#!/bin/bash
# Create a simple default wallpaper if none exist
WALLPAPER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if ImageMagick is installed
if command -v convert &>/dev/null; then
    # Create a simple gradient wallpaper (1920x1080)
    convert -size 1920x1080 gradient:#1e1e2e-#313244 "$WALLPAPER_DIR/default.png"
    echo "Created default gradient wallpaper"
else
    echo "ImageMagick not installed. Skipping wallpaper creation."
fi
