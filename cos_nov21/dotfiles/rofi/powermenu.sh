#!/bin/bash
# Rofi Power Menu Script

# Options
shutdown=" Shutdown"
reboot=" Reboot"
lock=" Lock"
suspend=" Suspend"
logout=" Logout"

# Show options
options="$lock\n$logout\n$suspend\n$reboot\n$shutdown"

selected=$(echo -e "$options" | rofi -dmenu -i -p "Power Menu" -theme-str 'window {width: 300px;}')

case $selected in
    $shutdown)
        systemctl poweroff
        ;;
    $reboot)
        systemctl reboot
        ;;
    $lock)
        swaylock
        ;;
    $suspend)
        systemctl suspend
        ;;
    $logout)
        hyprctl dispatch exit
        ;;
esac
