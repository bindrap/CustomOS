#!/bin/bash

# Get current wallpaper - try multiple sources in order of priority
# 1. .current-wallpaper file (set by wallpaper-lib.sh)
WALLPAPER=$(cat ~/.config/hypr/.current-wallpaper 2>/dev/null)

# 2. swww query
if [ -z "$WALLPAPER" ] || [ ! -f "$WALLPAPER" ]; then
    WALLPAPER=$(swww query 2>/dev/null | grep -oP 'image: \K.*' | head -1)
fi

# 3. hyprpaper config
if [ -z "$WALLPAPER" ] || [ ! -f "$WALLPAPER" ]; then
    WALLPAPER=$(grep "^preload" ~/.config/hypr/hyprpaper.conf 2>/dev/null | head -1 | cut -d'=' -f2 | xargs)
    WALLPAPER="${WALLPAPER/#\~/$HOME}"
fi

# 4. Find any wallpaper as last resort
if [ -z "$WALLPAPER" ] || [ ! -f "$WALLPAPER" ]; then
    WALLPAPER=$(find ~/Pictures/wallpapers -type f \( -iname "*.jpg" -o -iname "*.png" \) 2>/dev/null | head -1)
fi

# Exit if no wallpaper found
if [ -z "$WALLPAPER" ] || [ ! -f "$WALLPAPER" ]; then
    echo "No wallpaper found"
    # Create fallback CSS with default catppuccin colors
    CACHE_DIR="$HOME/.cache/waybar"
    mkdir -p "$CACHE_DIR"
    cp ~/.config/waybar/style.css "$CACHE_DIR/colors.css" 2>/dev/null || true
    exit 1
fi

# Create cache directory
CACHE_DIR="$HOME/.cache/waybar"
mkdir -p "$CACHE_DIR"

# Extract dominant colors using ImageMagick
if ! command -v magick &> /dev/null; then
    echo "ImageMagick not installed"
    exit 1
fi

# Get palette of 10 colors for better selection
COLORS=$(magick "$WALLPAPER" -resize 150x150 -colors 10 -unique-colors txt:- 2>/dev/null | grep -oE '#[0-9A-F]{6}' | head -10)

# Parse colors into array
IFS=$'\n' read -d '' -r -a COLOR_ARRAY <<< "$COLORS"

# Calculate average brightness to determine if wallpaper is light or dark
BRIGHTNESS=$(magick "$WALLPAPER" -colorspace Gray -format "%[fx:mean]" info:)
IS_DARK=$(awk -v b="$BRIGHTNESS" 'BEGIN { print (b < 0.5) ? 1 : 0 }')

# Set base colors based on brightness
if [[ $IS_DARK -eq 1 ]]; then
    # Dark wallpaper - use light text with semi-transparent dark background
    BG_BASE="${COLOR_ARRAY[0]:-#11111b}"
    TEXT_COLOR="#e0e0e0"
    TEXT_COLOR_DIM="rgba(224, 224, 224, 0.7)"
    BORDER_COLOR="rgba(255, 255, 255, 0.1)"
    HOVER_BG="rgba(255, 255, 255, 0.12)"
else
    # Light wallpaper - use dark text with semi-transparent light background
    BG_BASE="${COLOR_ARRAY[0]:-#f0f0f5}"
    TEXT_COLOR="#2a2a2a"
    TEXT_COLOR_DIM="rgba(42, 42, 42, 0.7)"
    BORDER_COLOR="rgba(0, 0, 0, 0.15)"
    HOVER_BG="rgba(0, 0, 0, 0.08)"
fi

# Convert background base to rgba
BG_R=$((16#${BG_BASE:1:2}))
BG_G=$((16#${BG_BASE:3:2}))
BG_B=$((16#${BG_BASE:5:2}))
BG_COLOR="rgba($BG_R, $BG_G, $BG_B, 0.95)"

# Find most saturated color for accent
ACCENT_COLOR="${COLOR_ARRAY[3]:-#89b4fa}"
BEST_SAT=0

for color in "${COLOR_ARRAY[@]}"; do
    if [[ -n "$color" ]]; then
        # Convert hex to RGB
        R=$((16#${color:1:2}))
        G=$((16#${color:3:2}))
        B=$((16#${color:5:2}))

        # Calculate saturation
        MAX=$(( R > G ? (R > B ? R : B) : (G > B ? G : B) ))
        MIN=$(( R < G ? (R < B ? R : B) : (G < B ? G : B) ))

        if [[ $MAX -gt 0 ]]; then
            SAT=$(( (MAX - MIN) * 100 / MAX ))
            # Also consider brightness - we want vibrant but not too dark
            BRIGHT=$(( (R + G + B) / 3 ))

            # Prefer colors that are both saturated and reasonably bright
            SCORE=$(( SAT + BRIGHT / 3 ))

            if [[ $SCORE -gt $BEST_SAT ]]; then
                BEST_SAT=$SCORE
                ACCENT_COLOR="$color"
            fi
        fi
    fi
done

# Convert accent to rgba
ACCENT_R=$((16#${ACCENT_COLOR:1:2}))
ACCENT_G=$((16#${ACCENT_COLOR:3:2}))
ACCENT_B=$((16#${ACCENT_COLOR:5:2}))
ACCENT_RGBA="rgba($ACCENT_R, $ACCENT_G, $ACCENT_B, 0.3)"

# Generate dynamic CSS
cat > "$CACHE_DIR/colors.css" << EOF
/* Auto-generated from wallpaper: $(basename "$WALLPAPER") */
/* Generated: $(date '+%Y-%m-%d %H:%M:%S') */
/* Brightness: $BRIGHTNESS ($([ $IS_DARK -eq 1 ] && echo 'dark mode' || echo 'light mode')) */

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
    background-color: transparent;
    border-radius: 0;
    color: $TEXT_COLOR;
    border-bottom: none;
}

/* Launcher */
#custom-launcher {
    background-color: transparent;
    color: $TEXT_COLOR;
    padding: 0 12px;
    margin: 0;
    font-size: 15px;
}

/* Workspaces */
#workspaces {
    background-color: transparent;
    margin: 0 8px;
    padding: 0;
}

#workspaces button {
    color: $TEXT_COLOR_DIM;
    border-radius: 50%;
    padding: 0 6px;
    margin: 0;
    background-color: transparent;
    border: none;
}

#workspaces button.active {
    color: $ACCENT_COLOR;
    background-color: transparent;
}

#workspaces button.urgent {
    color: #f38ba8;
    background-color: transparent;
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
    padding: 0 10px;
    margin: 0;
    color: $TEXT_COLOR;
    font-weight: 500;
}

/* Temperature */
#temperature {
    background-color: transparent;
    padding: 0 10px;
    margin: 0;
    color: $TEXT_COLOR;
    font-weight: 500;
}

#temperature.critical {
    color: #f38ba8;
}

/* Backlight */
#backlight {
    background-color: transparent;
    padding: 0 10px;
    margin: 0;
    color: $TEXT_COLOR;
    font-weight: 500;
}

/* Battery */
#battery {
    background-color: transparent;
    padding: 0 10px;
    margin: 0;
    color: $TEXT_COLOR;
    font-weight: 500;
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
    padding: 0 10px;
    margin: 0;
    color: $TEXT_COLOR;
    font-weight: 500;
}

#network.disconnected {
    color: rgba(243, 139, 168, 0.7);
}

/* Bluetooth */
#bluetooth {
    background-color: transparent;
    padding: 0 10px;
    margin: 0;
    color: $TEXT_COLOR;
    font-weight: 500;
}

/* Pulseaudio */
#pulseaudio {
    background-color: transparent;
    padding: 0 10px;
    margin: 0;
    color: $TEXT_COLOR;
    font-weight: 500;
}

#pulseaudio.muted {
    color: rgba(243, 139, 168, 0.7);
}

/* Tray */
#tray {
    background-color: transparent;
    padding: 0 10px;
    margin: 0;
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
    padding: 0 10px;
    margin: 0;
    font-size: 14px;
    font-weight: 500;
}

/* Blink animation */
@keyframes blink {
    to {
        opacity: 0.5;
    }
}
EOF

echo "Waybar colors updated from wallpaper: $(basename "$WALLPAPER")"
echo "  Mode: $([ $IS_DARK -eq 1 ] && echo 'Dark' || echo 'Light')"
echo "  Background: $BG_COLOR"
echo "  Text: $TEXT_COLOR"
echo "  Accent: $ACCENT_COLOR"

# Reload Waybar - unfortunately SIGUSR2 doesn't reliably reload external CSS
# So we do a quick restart (kill + immediate start)
if pgrep -x waybar >/dev/null; then
    # Get the Wayland display from the existing waybar process
    WAYBAR_PID=$(pgrep -x waybar)
    if [ -n "$WAYBAR_PID" ]; then
        # Extract environment from running waybar
        export WAYLAND_DISPLAY=$(cat /proc/$WAYBAR_PID/environ 2>/dev/null | tr '\0' '\n' | grep "^WAYLAND_DISPLAY=" | cut -d= -f2)
        export XDG_RUNTIME_DIR=$(cat /proc/$WAYBAR_PID/environ 2>/dev/null | tr '\0' '\n' | grep "^XDG_RUNTIME_DIR=" | cut -d= -f2)
    fi

    # Kill waybar
    pkill -x waybar 2>/dev/null
    sleep 0.1

    # Restart with proper environment
    waybar >/dev/null 2>&1 &
fi

exit 0
