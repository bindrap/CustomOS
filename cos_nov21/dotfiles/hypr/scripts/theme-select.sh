#!/bin/bash
# Interactive theme selector - Hyde Style

HYPR_DIR="$HOME/.config/hypr"
THEMES_DIR="$HYPR_DIR/themes"
CURRENT_THEME=$(cat "$HYPR_DIR/.current-theme" 2>/dev/null || echo "catppuccin-mocha")

# Get list of available themes
THEMES=()
for theme_file in "$THEMES_DIR"/*.conf; do
    if [ -f "$theme_file" ]; then
        theme_name=$(basename "$theme_file" .conf)
        THEMES+=("$theme_name")
    fi
done

if [ ${#THEMES[@]} -eq 0 ]; then
    notify-send "No Themes" "No themes found in $THEMES_DIR" -u critical
    exit 1
fi

# Create menu entries with current theme marked
MENU_ENTRIES=""
for theme in "${THEMES[@]}"; do
    if [ "$theme" = "$CURRENT_THEME" ]; then
        MENU_ENTRIES+="● $theme (current)\n"
    else
        MENU_ENTRIES+="  $theme\n"
    fi
done

# Show menu and get selection (prefer rofi, fallback to wofi)
if command -v rofi >/dev/null 2>&1; then
    SELECTED=$(echo -e "$MENU_ENTRIES" | rofi -dmenu -i -p "󰉼 Select Theme" -theme-str 'window {width: 400px;} listview {lines: 10;}')
else
    SELECTED=$(echo -e "$MENU_ENTRIES" | wofi --dmenu --prompt "󰉼 Select Theme" --width 400 --height 500)
fi

if [ -z "$SELECTED" ]; then
    exit 0
fi

# Extract theme name (remove marker and current indicator)
THEME_NAME=$(echo "$SELECTED" | sed 's/^[●  ]*//' | sed 's/ (current)$//')

# Apply theme
"$HYPR_DIR/scripts/theme-apply.sh" "$THEME_NAME"
