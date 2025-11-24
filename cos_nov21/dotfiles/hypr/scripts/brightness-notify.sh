#!/bin/bash
# Brightness notification script

get_brightness() {
    brightnessctl -m | cut -d',' -f4 | tr -d '%'
}

send_notification() {
    brightness=$(get_brightness)

    if [ "$brightness" -ge 70 ]; then
        icon="display-brightness-high"
    elif [ "$brightness" -ge 30 ]; then
        icon="display-brightness-medium"
    else
        icon="display-brightness-low"
    fi

    notify-send -h string:x-canonical-private-synchronous:brightness \
                -h int:value:"$brightness" \
                -u low -i "$icon" "Brightness: ${brightness}%"
}

case $1 in
    up)
        brightnessctl set 5%+
        send_notification
        ;;
    down)
        brightnessctl set 5%-
        send_notification
        ;;
    *)
        send_notification
        ;;
esac
