#!/bin/bash
# Power/Logout menu

MENU="🔒 Lock
🚪 Logout
🔄 Reboot
⏻ Shutdown
💤 Suspend
😴 Hibernate"

SELECTED=$(echo "$MENU" | wofi --dmenu --width 300 --height 250 --prompt "Power Menu")

case "$SELECTED" in
    "🔒 Lock")
        hyprlock
        ;;
    "🚪 Logout")
        hyprctl dispatch exit
        ;;
    "🔄 Reboot")
        systemctl reboot
        ;;
    "⏻ Shutdown")
        systemctl poweroff
        ;;
    "💤 Suspend")
        systemctl suspend
        ;;
    "😴 Hibernate")
        systemctl hibernate
        ;;
esac
