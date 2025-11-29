#!/bin/bash
# Microphone notification script

is_muted() {
    pamixer --default-source --get-mute
}

get_volume() {
    pamixer --default-source --get-volume
}

send_notification() {
    muted=$(is_muted)
    volume=$(get_volume)

    if [ "$muted" == "true" ]; then
        icon="microphone-sensitivity-muted"
        notify-send -h string:x-canonical-private-synchronous:microphone \
                    -u low -i "$icon" "Microphone: Muted"
    else
        icon="microphone-sensitivity-high"
        notify-send -h string:x-canonical-private-synchronous:microphone \
                    -h int:value:"$volume" \
                    -u low -i "$icon" "Microphone: ${volume}%"
    fi
}

case $1 in
    toggle)
        pamixer --default-source -t
        send_notification
        ;;
    up)
        pamixer --default-source -i 5
        send_notification
        ;;
    down)
        pamixer --default-source -d 5
        send_notification
        ;;
    *)
        send_notification
        ;;
esac
