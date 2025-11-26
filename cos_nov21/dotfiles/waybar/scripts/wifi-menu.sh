#!/usr/bin/env bash
set -euo pipefail

prompt_picker() {
    local prompt="$1"

    if command -v wofi >/dev/null 2>&1; then
        wofi --show dmenu --prompt "$prompt" --allow-markup --width 400
    elif command -v rofi >/dev/null 2>&1; then
        rofi -dmenu -p "$prompt" -theme-str 'window {width: 44%;}'
    else
        echo "No wofi/rofi menu found" >&2
        exit 1
    fi
}

prompt_text() {
    local prompt="$1"

    if command -v wofi >/dev/null 2>&1; then
        wofi --dmenu --prompt "$prompt" --password --width 400
    else
        rofi -dmenu -password -p "$prompt" -theme-str 'window {width: 44%;}'
    fi
}

signal_icon() {
    local strength=${1:-0}
    if (( strength >= 80 )); then
        printf '󰤨'
    elif (( strength >= 60 )); then
        printf '󰤥'
    elif (( strength >= 40 )); then
        printf '󰤢'
    elif (( strength >= 20 )); then
        printf '󰤟'
    else
        printf '󰤯'
    fi
}

list_networks() {
    nmcli -t -f IN-USE,SSID,SECURITY,SIGNAL device wifi list --rescan yes 2>/dev/null | sed '/^$/d'
}

connect_network() {
    local ssid="$1"
    local security="$2"

    if nmcli -g name connection show | grep -Fxq "$ssid"; then
        nmcli connection up "$ssid"
        return
    fi

    if nmcli device wifi connect "$ssid" 2>/tmp/wifi-error.log; then
        rm -f /tmp/wifi-error.log
        return
    fi

    if grep -q "No network with SSID" /tmp/wifi-error.log 2>/dev/null; then
        notify-send "Wi-Fi" "Network '$ssid' not found" -u normal
        rm -f /tmp/wifi-error.log
        exit 1
    fi

    rm -f /tmp/wifi-error.log

    if [[ "$security" != "--" && "$security" != "" ]]; then
        password=$(prompt_text "Password for $ssid")
        [[ -z "$password" ]] && exit 0
        nmcli device wifi connect "$ssid" password "$password"
    else
        nmcli device wifi connect "$ssid"
    fi
}

main() {
    if ! command -v nmcli >/dev/null 2>&1; then
        notify-send "Wi-Fi" "NetworkManager is not available" -u critical
        exit 1
    fi

    mapfile -t networks < <(list_networks)
    if [[ ${#networks[@]} -eq 0 ]]; then
        notify-send "Wi-Fi" "No networks found" -u low
        exit 0
    fi

    choices=()
    for i in "${!networks[@]}"; do
        IFS=':' read -r inuse ssid security signal <<<"${networks[$i]}"
        [[ -z "$ssid" ]] && ssid="<hidden>"
        label_sec="$security"
        [[ -z "$label_sec" || "$label_sec" == "--" ]] && label_sec="Open"
        icon=$(signal_icon "$signal")
        marker=""
        [[ "$inuse" == "*" ]] && marker=" ★"
        choices+=("$(printf "%02d | %s %s [%s] %s%%%s" "$((i+1))" "$icon" "$ssid" "$label_sec" "$signal" "$marker")")
    done

    selection=$(printf "%s\n" "${choices[@]}" | prompt_picker "Wi-Fi")
    [[ -z "$selection" ]] && exit 0

    index=$(cut -d'|' -f1 <<<"$selection" | tr -d ' ')
    if ! [[ "$index" =~ ^[0-9]+$ ]]; then
        exit 1
    fi
    index=$((index-1))
    [[ $index -lt 0 || $index -ge ${#networks[@]} ]] && exit 1

    IFS=':' read -r _ ssid security _ <<<"${networks[$index]}"
    connect_network "$ssid" "$security"
    notify-send "Wi-Fi" "Connecting to $ssid" -u low
}

main "$@"
