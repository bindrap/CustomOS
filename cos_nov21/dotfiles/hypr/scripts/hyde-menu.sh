#!/bin/bash
# Hyde-style Customization Menu
# Quick access to all customization options

HYPR_DIR="$HOME/.config/hypr"
SCRIPTS_DIR="$HYPR_DIR/scripts"

# Menu options with icons
OPTIONS="󰸉 Wallpaper Picker
󰸉 Next Wallpaper
󰸉 Previous Wallpaper
󰸉 Random Wallpaper
󰉼 Theme Selector
 Keybindings Help
 Logout Menu
 Emoji Picker
 Game Mode Toggle"

# Show menu and get selection
if command -v rofi >/dev/null 2>&1; then
    SELECTED=$(echo -e "$OPTIONS" | rofi -dmenu -i -p "󰀻 Hyde Customization" -theme-str 'window {width: 400px;} listview {lines: 9;}')
else
    SELECTED=$(echo -e "$OPTIONS" | wofi --dmenu --prompt "󰀻 Hyde Customization" --width 400 --height 500)
fi

# Execute based on selection
case "$SELECTED" in
    "󰸉 Wallpaper Picker")
        "$SCRIPTS_DIR/wallpaper-select.sh"
        ;;
    "󰸉 Next Wallpaper")
        "$SCRIPTS_DIR/wallpaper-next.sh"
        ;;
    "󰸉 Previous Wallpaper")
        "$SCRIPTS_DIR/wallpaper-prev.sh"
        ;;
    "󰸉 Random Wallpaper")
        "$SCRIPTS_DIR/wallpaper-random.sh"
        ;;
    "󰉼 Theme Selector")
        "$SCRIPTS_DIR/theme-select.sh"
        ;;
    " Keybindings Help")
        "$SCRIPTS_DIR/keybinds-hint.sh"
        ;;
    " Logout Menu")
        "$SCRIPTS_DIR/logout-menu.sh"
        ;;
    " Emoji Picker")
        "$SCRIPTS_DIR/emoji-picker.sh"
        ;;
    " Game Mode Toggle")
        "$SCRIPTS_DIR/gamemode-toggle.sh"
        ;;
esac
