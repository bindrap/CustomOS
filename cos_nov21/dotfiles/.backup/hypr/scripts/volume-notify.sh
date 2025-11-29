#!/bin/bash
# Volume notification script with visual feedback

get_volume() {
    pamixer --get-volume
}

is_muted() {
    pamixer --get-mute
}

send_notification() {
    volume=$(get_volume)
    muted=$(is_muted)

    if [ "$muted" == "true" ]; then
        icon="audio-volume-muted"
        notify-send -h string:x-canonical-private-synchronous:volume \
                    -u low -i "$icon" "Volume: Muted"
    else
        if [ "$volume" -ge 70 ]; then
            icon="audio-volume-high"
        elif [ "$volume" -ge 30 ]; then
            icon="audio-volume-medium"
        else
            icon="audio-volume-low"
        fi

        notify-send -h string:x-canonical-private-synchronous:volume \
                    -h int:value:"$volume" \
                    -u low -i "$icon" "Volume: ${volume}%"
    fi
}

case $1 in
    up)
        pamixer -i 5
        send_notification
        ;;
    down)
        pamixer -d 5
        send_notification
        ;;
    mute)
        pamixer -t
        send_notification
        ;;
    *)
        send_notification
        ;;
esac
