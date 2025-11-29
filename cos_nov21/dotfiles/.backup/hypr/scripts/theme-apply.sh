#!/bin/bash
# Theme Application Script - Core logic for applying themes across all applications

THEME_NAME="$1"
HYPR_DIR="$HOME/.config/hypr"
THEMES_DIR="$HYPR_DIR/themes"
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

# Source theme configuration
if [ -z "$THEME_NAME" ]; then
    THEME_NAME=$(cat "$HYPR_DIR/.current-theme" 2>/dev/null || echo "catppuccin-mocha")
fi

THEME_FILE="$THEMES_DIR/$THEME_NAME.conf"

if [ ! -f "$THEME_FILE" ]; then
    echo "Theme not found: $THEME_NAME"
    exit 1
fi

# Save current theme
echo "$THEME_NAME" > "$HYPR_DIR/.current-theme"

echo "Applying theme: $THEME_NAME"

# Source theme colors
source "$THEME_FILE"

# Generate Hyprland colors
cat > "$HYPR_DIR/colors.conf" << EOF
# Auto-generated colors from theme: $THEME_NAME
# Do not edit manually - use theme-select.sh instead

general {
    col.active_border = $ACTIVE_BORDER
    col.inactive_border = $INACTIVE_BORDER
}

decoration {
    shadow {
        color = $SHADOW_COLOR
    }
}

# Theme color variables
\$background = $BACKGROUND
\$foreground = $FOREGROUND
\$color0 = $COLOR0
\$color1 = $COLOR1
\$color2 = $COLOR2
\$color3 = $COLOR3
\$color4 = $COLOR4
\$color5 = $COLOR5
\$color6 = $COLOR6
\$color7 = $COLOR7
\$color8 = $COLOR8
\$color9 = $COLOR9
\$color10 = $COLOR10
\$color11 = $COLOR11
\$color12 = $COLOR12
\$color13 = $COLOR13
\$color14 = $COLOR14
\$color15 = $COLOR15
EOF

# Generate Waybar CSS
mkdir -p "$HOME/.config/waybar"
cat > "$HOME/.config/waybar/colors.css" << EOF
/* Auto-generated from theme: $THEME_NAME */
@define-color background $BACKGROUND;
@define-color foreground $FOREGROUND;
@define-color color0 $COLOR0;
@define-color color1 $COLOR1;
@define-color color2 $COLOR2;
@define-color color3 $COLOR3;
@define-color color4 $COLOR4;
@define-color color5 $COLOR5;
@define-color color6 $COLOR6;
@define-color color7 $COLOR7;
@define-color color8 $COLOR8;
@define-color color9 $COLOR9;
@define-color color10 $COLOR10;
@define-color color11 $COLOR11;
@define-color color12 $COLOR12;
@define-color color13 $COLOR13;
@define-color color14 $COLOR14;
@define-color color15 $COLOR15;
EOF

# Generate Kitty theme
mkdir -p "$HOME/.config/kitty"
cat > "$HOME/.config/kitty/current-theme.conf" << EOF
# Auto-generated from theme: $THEME_NAME
background $BACKGROUND
foreground $FOREGROUND
cursor $FOREGROUND
selection_background $COLOR4
selection_foreground $BACKGROUND

color0 $COLOR0
color1 $COLOR1
color2 $COLOR2
color3 $COLOR3
color4 $COLOR4
color5 $COLOR5
color6 $COLOR6
color7 $COLOR7
color8 $COLOR8
color9 $COLOR9
color10 $COLOR10
color11 $COLOR11
color12 $COLOR12
color13 $COLOR13
color14 $COLOR14
color15 $COLOR15
EOF

# Generate Wofi colors
mkdir -p "$HOME/.config/wofi"
cat > "$HOME/.config/wofi/colors.css" << EOF
/* Auto-generated from theme: $THEME_NAME */
* {
    --background: $BACKGROUND;
    --foreground: $FOREGROUND;
    --accent: $COLOR4;
    --urgent: $COLOR1;
}
EOF

# Generate Mako config
mkdir -p "$HOME/.config/mako"
cat > "$HOME/.config/mako/config" << EOF
# Auto-generated from theme: $THEME_NAME
background-color=$BACKGROUND
text-color=$FOREGROUND
border-color=$COLOR4
border-size=2
border-radius=0
default-timeout=5000
ignore-timeout=1

[urgency=high]
border-color=$COLOR1
EOF

# Set wallpaper for this theme
if [ -d "$WALLPAPER_DIR/$THEME_NAME" ]; then
    WALLPAPER=$(find "$WALLPAPER_DIR/$THEME_NAME" -type f \( -name "*.jpg" -o -name "*.png" \) | shuf -n 1)
    if [ -n "$WALLPAPER" ]; then
        if command -v swww >/dev/null 2>&1; then
            swww img "$WALLPAPER" --transition-type wipe --transition-fps 60
        else
            killall hyprpaper 2>/dev/null
            echo "preload = $WALLPAPER" > "$HYPR_DIR/hyprpaper.conf"
            echo "wallpaper = ,$WALLPAPER" >> "$HYPR_DIR/hyprpaper.conf"
            hyprpaper &
        fi
        echo "$WALLPAPER" > "$HYPR_DIR/.current-wallpaper"
    fi
fi

# Reload applications
hyprctl reload
killall waybar 2>/dev/null; waybar &
killall mako 2>/dev/null; mako &

notify-send "󰉼 Theme Applied" "Successfully switched to $THEME_NAME" -t 3000

echo "Theme applied successfully!"
