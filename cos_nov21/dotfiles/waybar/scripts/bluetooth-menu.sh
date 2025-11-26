#!/usr/bin/env bash
set -euo pipefail

prompt_picker() {
    local prompt="$1"

    if command -v wofi >/dev/null 2>&1; then
        wofi --show dmenu --prompt "$prompt" --allow-markup --width 420
    elif command -v rofi >/dev/null 2>&1; then
        rofi -dmenu -p "$prompt" -theme-str 'window {width: 46%;}'
    else
        echo "No wofi/rofi menu found" >&2
        exit 1
    fi
}

ensure_powered_on() {
    if bluetoothctl show | grep -q "Powered: yes"; then
        return
    fi

    bluetoothctl power on >/dev/null 2>&1 || true
}

list_devices() {
    bluetoothctl devices | while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        # Format: Device AA:BB:CC:DD:EE:FF Name
        address=$(awk '{print $2}' <<<"$line")
        name=${line#*${address} }
        [[ -z "$name" ]] && name="$address"

        info=$(bluetoothctl info "$address")
        connected=$(grep -q "Connected: yes" <<<"$info" && echo "yes" || echo "no")
        paired=$(grep -q "Paired: yes" <<<"$info" && echo "yes" || echo "no")

        printf "%s|%s|%s|%s\n" "$address" "$name" "$connected" "$paired"
    done
}

connect_device() {
    local address="$1" name="$2" paired="$3"

    ensure_powered_on

    if [[ "$paired" != "yes" ]]; then
        bluetoothctl pair "$address" >/dev/null 2>&1 || true
        bluetoothctl trust "$address" >/dev/null 2>&1 || true
    fi

    if bluetoothctl connect "$address" >/dev/null 2>&1; then
        notify-send "Bluetooth" "Connected to $name" -u low
    else
        notify-send "Bluetooth" "Failed to connect to $name" -u normal
    fi
}

disconnect_device() {
    local address="$1" name="$2"
    if bluetoothctl disconnect "$address" >/dev/null 2>&1; then
        notify-send "Bluetooth" "Disconnected from $name" -u low
    else
        notify-send "Bluetooth" "Failed to disconnect $name" -u normal
    fi
}

main() {
    if ! command -v bluetoothctl >/dev/null 2>&1; then
        notify-send "Bluetooth" "bluetoothctl is not available" -u critical
        exit 1
    fi

    ensure_powered_on

    mapfile -t devices < <(list_devices)
    if [[ ${#devices[@]} -eq 0 ]]; then
        notify-send "Bluetooth" "No devices found" -u low
        exit 0
    fi

    choices=()
    for i in "${!devices[@]}"; do
        IFS='|' read -r addr name connected paired <<<"${devices[$i]}"
        marker=""
        [[ "$connected" == "yes" ]] && marker=" (connected)"
        [[ "$paired" != "yes" ]] && marker="$marker (new)"
        choices+=("$(printf "%02d | %s%s" "$((i+1))" "$name" "$marker")")
    done

    selection=$(printf "%s\n" "${choices[@]}" | prompt_picker "Bluetooth")
    [[ -z "$selection" ]] && exit 0

    index=$(cut -d'|' -f1 <<<"$selection" | tr -d ' ')
    if ! [[ "$index" =~ ^[0-9]+$ ]]; then
        exit 1
    fi
    index=$((index-1))
    [[ $index -lt 0 || $index -ge ${#devices[@]} ]] && exit 1

    IFS='|' read -r addr name connected paired <<<"${devices[$index]}"

    if [[ "$connected" == "yes" ]]; then
        disconnect_device "$addr" "$name"
    else
        connect_device "$addr" "$name" "$paired"
    fi
}

main "$@"
