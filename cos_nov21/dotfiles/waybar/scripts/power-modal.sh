#!/bin/bash
# Power modal with left/right navigation (no search)

# Power options
OPTIONS="  Lock
  Sleep
  Screen Off
  Logout
  Suspend
  Hibernate
  Reboot
  Shutdown"

SELECTED=$(echo "$OPTIONS" | rofi \
    -dmenu \
    -i \
    -no-custom \
    -p "Power Options" \
    -theme ~/.config/waybar/scripts/power-modal.rasi)

case "$SELECTED" in
    "  Lock")
        hyprlock
        ;;
    "  Sleep")
        systemctl suspend
        ;;
    "  Screen Off")
        hyprctl dispatch dpms off
        ;;
    "  Logout")
        hyprctl dispatch exit
        ;;
    "  Suspend")
        systemctl suspend
        ;;
    "  Reboot")
        systemctl reboot
        ;;
    "  Shutdown")
        systemctl poweroff
        ;;
    "  Hibernate")
        systemctl hibernate
        ;;
esac
