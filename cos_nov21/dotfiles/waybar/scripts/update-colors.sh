#!/bin/bash

# Get the current wallpaper from hyprpaper.conf
WALLPAPER=$(grep "^preload" ~/.config/hypr/hyprpaper.conf | head -1 | cut -d'=' -f2 | xargs)
WALLPAPER="${WALLPAPER/#\~/$HOME}"

# Check if wallpaper exists
if [[ ! -f "$WALLPAPER" ]]; then
    echo "Wallpaper not found: $WALLPAPER"
    exit 1
fi

# Create cache directory
CACHE_DIR="$HOME/.cache/waybar"
mkdir -p "$CACHE_DIR"

# Extract dominant colors using ImageMagick
# Get 8 most dominant colors
COLORS=$(magick "$WALLPAPER" -resize 100x100 -colors 8 -unique-colors -format "%c" histogram:info: | \
    sed -n 's/.*\(#[0-9A-F]\{6\}\).*/\1/p' | head -8)

# Convert to array
readarray -t COLOR_ARRAY <<< "$COLORS"

# Calculate average brightness to determine if wallpaper is light or dark
BRIGHTNESS=$(magick "$WALLPAPER" -colorspace Gray -format "%[fx:mean]" info:)
IS_DARK=$(awk -v b="$BRIGHTNESS" 'BEGIN { print (b < 0.5) ? 1 : 0 }')

# Set base colors based on brightness
if [[ $IS_DARK -eq 1 ]]; then
    # Dark wallpaper - use light text
    BG_COLOR="rgba(17, 17, 27, 0.95)"
    TEXT_COLOR="#e0e0e0"
    TEXT_COLOR_DIM="rgba(224, 224, 224, 0.7)"
    BORDER_COLOR="rgba(255, 255, 255, 0.1)"
    HOVER_BG="rgba(255, 255, 255, 0.12)"
else
    # Light wallpaper - use dark text
    BG_COLOR="rgba(240, 240, 245, 0.95)"
    TEXT_COLOR="#2a2a2a"
    TEXT_COLOR_DIM="rgba(42, 42, 42, 0.7)"
    BORDER_COLOR="rgba(0, 0, 0, 0.15)"
    HOVER_BG="rgba(0, 0, 0, 0.08)"
fi

# Get accent color (most saturated color from the palette)
ACCENT_COLOR="${COLOR_ARRAY[0]}"

# Find the most saturated color for accent
for color in "${COLOR_ARRAY[@]}"; do
    if [[ -n "$color" ]]; then
        # Convert hex to RGB and calculate saturation
        R=$((16#${color:1:2}))
        G=$((16#${color:3:2}))
        B=$((16#${color:5:2}))

        MAX=$(( R > G ? (R > B ? R : B) : (G > B ? G : B) ))
        MIN=$(( R < G ? (R < B ? R : B) : (G < B ? G : B) ))

        if [[ $MAX -gt 0 ]]; then
            SAT=$(( (MAX - MIN) * 100 / MAX ))
            if [[ $SAT -gt ${BEST_SAT:-0} ]]; then
                BEST_SAT=$SAT
                ACCENT_COLOR="$color"
            fi
        fi
    fi
done

# Convert accent color to rgba with alpha
ACCENT_R=$((16#${ACCENT_COLOR:1:2}))
ACCENT_G=$((16#${ACCENT_COLOR:3:2}))
ACCENT_B=$((16#${ACCENT_COLOR:5:2}))
ACCENT_RGBA="rgba($ACCENT_R, $ACCENT_G, $ACCENT_B, 0.3)"

# Generate dynamic CSS
cat > "$CACHE_DIR/dynamic-colors.css" << EOF
/* Auto-generated from wallpaper: $WALLPAPER */
/* Generated at: $(date) */

* {
    font-family: "SF Pro Display", "JetBrainsMono Nerd Font", "Font Awesome 6 Free";
    font-size: 13px;
    font-weight: 500;
    min-height: 0;
}

window#waybar {
    background: transparent;
}

#waybar {
    background-color: $BG_COLOR;
    border-radius: 0;
    color: $TEXT_COLOR;
    border-bottom: 1px solid $BORDER_COLOR;
}

/* Launcher */
#custom-launcher {
    background-color: transparent;
    color: $TEXT_COLOR;
    padding: 0 12px;
    margin: 0 4px;
    font-size: 15px;
    border-radius: 8px;
    transition: all 0.2s ease;
}

#custom-launcher:hover {
    background-color: $HOVER_BG;
    box-shadow: inset 0 0 20px rgba(255, 255, 255, 0.05);
}

/* Workspaces */
#workspaces {
    background-color: transparent;
    margin: 0 8px;
    padding: 0 4px;
}

#workspaces button {
    color: $TEXT_COLOR_DIM;
    border-radius: 50%;
    padding: 0 4px;
    margin: 0 2px;
    transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
    background-color: transparent;
}

#workspaces button.active {
    color: $TEXT_COLOR;
    background-color: $ACCENT_RGBA;
}

#workspaces button.urgent {
    color: #f38ba8;
    background-color: rgba(243, 139, 168, 0.2);
}

#workspaces button:hover {
    color: $TEXT_COLOR;
    background-color: $HOVER_BG;
}

/* Window title */
#window {
    background-color: transparent;
    padding: 0 16px;
    margin: 0;
    color: $TEXT_COLOR_DIM;
    font-weight: 500;
}

/* Clock */
#clock {
    background-color: transparent;
    padding: 0 16px;
    margin: 0;
    color: $TEXT_COLOR;
    font-weight: 500;
    border-radius: 8px;
    transition: all 0.2s ease;
}

#clock:hover {
    background-color: $HOVER_BG;
    box-shadow: inset 0 0 20px rgba(255, 255, 255, 0.05);
}

/* Weather */
#custom-weather {
    background-color: transparent;
    padding: 0 12px;
    margin: 0 8px;
    color: $TEXT_COLOR;
    font-weight: 500;
    border-radius: 8px;
    transition: all 0.2s ease;
}

#custom-weather:hover {
    background-color: $HOVER_BG;
    box-shadow: inset 0 0 20px rgba(255, 255, 255, 0.05);
}

tooltip#custom-weather {
    background-color: $BG_COLOR;
    border: 1px solid $ACCENT_RGBA;
    border-radius: 12px;
    padding: 12px;
}

tooltip#custom-weather label {
    font-size: 11px;
    font-family: "JetBrainsMono Nerd Font", monospace;
    color: $TEXT_COLOR;
}

/* CPU */
#cpu {
    background-color: transparent;
    padding: 0 8px;
    margin: 0 2px;
    color: $TEXT_COLOR;
    font-weight: 600;
    border-radius: 8px;
    transition: all 0.2s ease;
}

#cpu:hover {
    background-color: $HOVER_BG;
    box-shadow: inset 0 0 20px rgba(255, 255, 255, 0.05);
}

/* Temperature */
#temperature {
    background-color: transparent;
    padding: 0 8px;
    margin: 0 2px;
    color: $TEXT_COLOR;
    font-weight: 600;
    border-radius: 8px;
    transition: all 0.2s ease;
}

#temperature:hover {
    background-color: $HOVER_BG;
    box-shadow: inset 0 0 20px rgba(255, 255, 255, 0.05);
}

#temperature.critical {
    color: #f38ba8;
}

/* Backlight */
#backlight {
    background-color: transparent;
    padding: 0 8px;
    margin: 0 2px;
    color: $TEXT_COLOR;
    font-weight: 600;
    border-radius: 8px;
    transition: all 0.2s ease;
}

#backlight:hover {
    background-color: $HOVER_BG;
    box-shadow: inset 0 0 20px rgba(255, 255, 255, 0.05);
}

/* Battery */
#battery {
    background-color: transparent;
    padding: 0 8px;
    margin: 0 2px;
    color: $TEXT_COLOR;
    font-weight: 600;
    border-radius: 8px;
    transition: all 0.2s ease;
}

#battery:hover {
    background-color: $HOVER_BG;
    box-shadow: inset 0 0 20px rgba(255, 255, 255, 0.05);
}

#battery.charging {
    color: $ACCENT_COLOR;
}

#battery.warning:not(.charging) {
    color: #f9e2af;
}

#battery.critical:not(.charging) {
    color: #f38ba8;
    animation: blink 0.5s linear infinite alternate;
}

/* Network */
#network {
    background-color: transparent;
    padding: 0 8px;
    margin: 0 2px;
    color: $TEXT_COLOR;
    font-weight: 600;
    border-radius: 8px;
    transition: all 0.2s ease;
}

#network:hover {
    background-color: $HOVER_BG;
    box-shadow: inset 0 0 20px rgba(255, 255, 255, 0.05);
}

#network.disconnected {
    color: rgba(243, 139, 168, 0.7);
}

/* Bluetooth */
#bluetooth {
    background-color: transparent;
    padding: 0 8px;
    margin: 0 2px;
    color: $TEXT_COLOR;
    font-weight: 600;
    border-radius: 8px;
    transition: all 0.2s ease;
}

#bluetooth:hover {
    background-color: $HOVER_BG;
    box-shadow: inset 0 0 20px rgba(255, 255, 255, 0.05);
}

/* Pulseaudio */
#pulseaudio {
    background-color: transparent;
    padding: 0 8px;
    margin: 0 2px;
    color: $TEXT_COLOR;
    font-weight: 600;
    border-radius: 8px;
    transition: all 0.2s ease;
}

#pulseaudio:hover {
    background-color: $HOVER_BG;
    box-shadow: inset 0 0 20px rgba(255, 255, 255, 0.05);
}

#pulseaudio.muted {
    color: rgba(243, 139, 168, 0.7);
}

/* Tray */
#tray {
    background-color: transparent;
    padding: 0 8px;
    margin: 0 2px;
}

#tray > .passive {
    -gtk-icon-effect: dim;
}

#tray > .needs-attention {
    -gtk-icon-effect: highlight;
}

/* Power button */
#custom-power {
    background-color: transparent;
    color: $TEXT_COLOR;
    padding: 0 12px;
    margin: 0 4px;
    font-size: 14px;
    font-weight: 600;
    border-radius: 8px;
    transition: all 0.2s ease;
}

#custom-power:hover {
    background-color: $HOVER_BG;
    box-shadow: inset 0 0 20px rgba(255, 255, 255, 0.05);
    color: #f38ba8;
}

/* Blink animation */
@keyframes blink {
    to {
        opacity: 0.5;
    }
}
EOF

echo "Colors extracted from wallpaper:"
echo "  Background: $BG_COLOR"
echo "  Text: $TEXT_COLOR"
echo "  Accent: $ACCENT_COLOR"
echo "  Brightness: $BRIGHTNESS ($([ $IS_DARK -eq 1 ] && echo 'dark' || echo 'light'))"

# Reload Waybar
killall -SIGUSR2 waybar 2>/dev/null || pkill -SIGUSR2 waybar 2>/dev/null

echo "Waybar colors updated!"
