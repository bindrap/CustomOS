#!/bin/bash

# Power Menu Script for Waybar
# Uses wofi for menu display

options="🔒 Lock\n🌙 Sleep\n🔄 Restart\n⏻ Shutdown\n🎨 Change Theme\n🖼️ Change Wallpaper\n❌ Cancel"

chosen=$(echo -e "$options" | wofi --dmenu --prompt "Power Menu" --width 300 --height 300)

case $chosen in
    "🔒 Lock")
        hyprlock
        ;;
    "🌙 Sleep")
        systemctl suspend
        ;;
    "🔄 Restart")
        systemctl reboot
        ;;
    "⏻ Shutdown")
        systemctl poweroff
        ;;
    "🎨 Change Theme")
        ~/.config/hypr/scripts/theme-select.sh
        ;;
    "🖼️ Change Wallpaper")
        ~/.config/hypr/scripts/wallpaper-select.sh
        ;;
    "❌ Cancel")
        exit 0
        ;;
esac
