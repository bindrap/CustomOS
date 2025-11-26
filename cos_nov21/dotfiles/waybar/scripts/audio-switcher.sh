#!/usr/bin/env bash
set -euo pipefail

prompt_picker() {
    local prompt="$1"

    if command -v wofi >/dev/null 2>&1; then
        wofi --show dmenu --prompt "$prompt" --allow-markup
    elif command -v rofi >/dev/null 2>&1; then
        rofi -dmenu -p "$prompt" -theme-str 'window {width: 46%;}'
    else
        echo "No wofi/rofi menu found" >&2
        exit 1
    fi
}

# Build a list of sinks/sources in the format:
#   type|id|description|is_default
list_devices() {
    local wanted="$1"
    local section=""

    wpctl status | while IFS= read -r line; do
        case "$line" in
            *"Sinks:"*)
                section="sink"
                continue
                ;;
            *"Sources:"*)
                section="source"
                continue
                ;;
            "")
                section=""
                continue
                ;;
        esac

        [[ "$section" == "$wanted" ]] || continue

        if [[ $line =~ ^[[:space:]]*([\*\ ])?[[:space:]]*([0-9]+)\.\s+(.+)$ ]]; then
            default_mark="${BASH_REMATCH[1]}"
            id="${BASH_REMATCH[2]}"
            desc="${BASH_REMATCH[3]}"
            printf "%s|%s|%s|%s\n" "$section" "$id" "$desc" "${default_mark// }"
        fi
    done
}

select_device() {
    local type="$1" role_label="$2"
    local prompt="$3"

    mapfile -t choices < <(list_devices "$type")
    if [[ ${#choices[@]} -eq 0 ]]; then
        notify-send "Audio switcher" "No ${type}s found" -u low
        exit 0
    fi

    formatted=()
    for entry in "${choices[@]}"; do
        IFS='|' read -r ctype cid cdesc cdefault <<<"$entry"
        marker=""
        [[ "$cdefault" == "*" ]] && marker=" ★"
        formatted+=("${cid} | ${cdesc}${marker}")
    done

    selection=$(printf "%s\n" "${formatted[@]}" | prompt_picker "$prompt")
    [[ -z "$selection" ]] && exit 0

    chosen_id=$(cut -d'|' -f1 <<<"$selection" | xargs)
    chosen_desc=$(cut -d'|' -f2- <<<"$selection" | sed 's/^ //')

    role_args=()
    [[ "$role_label" == "Voice" ]] && role_args=(-r voice)

    wpctl set-default "${role_args[@]}" "$chosen_id"

    notify-send "Audio switcher" "${role_label} ${type^} set to:\n${chosen_desc}" -u low
}

main() {
    if [[ $# -ge 2 ]]; then
        select_device "$1" "$2" "$3"
        exit 0
    fi

    category=$(printf "Volume Output\nVoice Output\nVoice Input" | prompt_picker "Audio Routes")
    case "$category" in
        "Volume Output")
            select_device "sink" "Output" "Output Devices"
            ;;
        "Voice Output")
            select_device "sink" "Voice" "Voice Output"
            ;;
        "Voice Input")
            select_device "source" "Voice" "Voice Input"
            ;;
        *)
            exit 0
            ;;
    esac
}

main "$@"
