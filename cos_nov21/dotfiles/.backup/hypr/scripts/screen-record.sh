#!/bin/bash
# Screen recorder using wf-recorder

RECORDING_DIR="$HOME/Videos/Recordings"
mkdir -p "$RECORDING_DIR"

PIDFILE="/tmp/wf-recorder.pid"

if [ -f "$PIDFILE" ]; then
    # Stop recording
    PID=$(cat "$PIDFILE")
    kill -INT "$PID"
    rm "$PIDFILE"
    notify-send "Recording Stopped" "Saved to $RECORDING_DIR" -t 3000
else
    # Start recording
    FILENAME="$RECORDING_DIR/$(date +%Y%m%d_%H%M%S).mp4"

    # Get area selection
    GEOMETRY=$(slurp)

    if [ -n "$GEOMETRY" ]; then
        wf-recorder -g "$GEOMETRY" -f "$FILENAME" &
        echo $! > "$PIDFILE"
        notify-send "Recording Started" "Press Super+R to stop" -t 3000
    fi
fi
