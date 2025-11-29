#!/bin/bash

# Smart now playing script: tries playerctl first, falls back to mpc.
# Supports actions: toggle, next, prev

PLAYERS="mpd,spotify,vlc,mpv,chromium,brave,firefox,chrome"

action="$1"

run_playerctl() {
    local cmd="$1"
    if command -v playerctl >/dev/null 2>&1; then
        playerctl --player="$PLAYERS" $cmd >/dev/null 2>&1 && return 0
    fi
    return 1
}

run_mpc() {
    local cmd="$1"
    if command -v mpc >/dev/null 2>&1; then
        # Prefer user socket if it exists, otherwise localhost
        local sock="/run/user/$(id -u)/mpd/socket"
        if [ -S "$sock" ]; then
            MPD_HOST="$sock" MPD_PORT=0 mpc $cmd >/dev/null 2>&1 && return 0
        else
            mpc $cmd >/dev/null 2>&1 && return 0
        fi
    fi
    return 1
}

if [ -n "$action" ]; then
    case "$action" in
        toggle) run_playerctl play-pause || run_mpc toggle ;;
        next)   run_playerctl next || run_mpc next ;;
        prev)   run_playerctl previous || run_mpc prev ;;
    esac
    exit 0
fi

# Query status/title/artist
status=""; title=""; artist=""

if command -v playerctl >/dev/null 2>&1; then
    info=$(playerctl --player="$PLAYERS" metadata --format '{{status}}|{{title}}|{{artist}}' 2>/dev/null | head -n1)
    status=$(echo "$info" | cut -d'|' -f1)
    title=$(echo "$info" | cut -d'|' -f2)
    artist=$(echo "$info" | cut -d'|' -f3)
fi

# Fallback to mpc if nothing
if [ -z "$status" ] && command -v mpc >/dev/null 2>&1; then
    sock="/run/user/$(id -u)/mpd/socket"
    if [ -S "$sock" ]; then
        status=$(MPD_HOST="$sock" MPD_PORT=0 mpc status 2>/dev/null | head -n2 | tail -n1 | awk '{print $1}' | tr -d '[]')
        title=$(MPD_HOST="$sock" MPD_PORT=0 mpc current -f "%title%" 2>/dev/null)
        artist=$(MPD_HOST="$sock" MPD_PORT=0 mpc current -f "%artist%" 2>/dev/null)
    else
        status=$(mpc status 2>/dev/null | head -n2 | tail -n1 | awk '{print $1}' | tr -d '[]')
        title=$(mpc current -f "%title%" 2>/dev/null)
        artist=$(mpc current -f "%artist%" 2>/dev/null)
    fi
fi

# No data -> hide module
if [ -z "$status" ] || [ "$status" = "stopped" ] || [ "$status" = "Stopped" ]; then
    echo '{"text": "", "tooltip": ""}'
    exit 0
fi

# Normalize
[ "$status" = "Playing" ] && status="playing"
[ "$status" = "Paused" ] && status="paused"

[ -z "$title" ] && [ -z "$artist" ] && { echo '{"text": "", "tooltip": ""}'; exit 0; }
[ -z "$title" ] && title="Track Title"
[ -z "$artist" ] && artist=""

# Truncate helper
truncate() {
    local str="$1" max="$2"
    local len=${#str}
    if [ "$len" -le "$max" ]; then
        echo "$str"
    else
        echo "${str:0:$((max-1))}…"
    fi
}

title=$(truncate "$title" 20)
artist=$(truncate "$artist" 16)

icon="󰐊"
[ "$status" = "paused" ] && icon="󰏤"

sep=" — "
[ -z "$artist" ] && sep=""

text="󰒮  $icon  󰒭  $title$sep$artist"
tooltip="$artist - $title"

printf '{"text": "%s", "tooltip": "%s"}\n' "$text" "$tooltip"
