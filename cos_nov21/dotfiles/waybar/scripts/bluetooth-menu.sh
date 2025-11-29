#!/bin/bash

# Bluetooth picker with quick drop-down + full connect/pair
THEME="$HOME/.config/waybar/styles/popup.rasi"
ROFI_FLAGS=(-dmenu -i -theme "$THEME" -location 3 -yoffset 36 -xoffset -6 -width 38)
MODE="${1:-full}" # full | quick

power_state=$(bluetoothctl show | awk -F': ' '/Powered/ {print $2}')

entries=()
actions=()

add_entry() {
    entries+=("$1")
    actions+=("$2")
}

toggle_label() {
    if [ "$power_state" = "yes" ]; then
        echo "󰂲  Turn Bluetooth off"
    else
        echo "󰂯  Turn Bluetooth on"
    fi
}

add_entry "$(toggle_label)" "toggle_power"
[ "$MODE" = "full" ] && add_entry "󰂞  Open Blueman" "open_manager"

if [ "$power_state" = "yes" ]; then
    # Quick scan for available devices (skip in quick mode if not desired)
    if [ "$MODE" = "full" ]; then
        bluetoothctl --timeout 3 scan on &>/dev/null &
        sleep 1
    fi

    paired=$(bluetoothctl paired-devices)
    devices=$(bluetoothctl devices)
    any_device=false

    while IFS= read -r line; do
        [ -z "$line" ] && continue
        mac=$(echo "$line" | awk '{print $2}')
        name=$(echo "$line" | awk '{print substr($0, index($0,$3))}')

        info=$(bluetoothctl info "$mac")
        connected=$(echo "$info" | awk -F': ' '/Connected/ {print $2}')
        is_paired="no"
        echo "$paired" | grep -q "$mac" && is_paired="yes"

        if [ "$connected" = "yes" ]; then
            label="✓ $name (connected)"
        elif [ "$is_paired" = "yes" ]; then
            label="  $name (paired)"
        else
            [ "$MODE" = "quick" ] && continue
            label="+ $name (available)"
        fi

        add_entry "$label" "device::$mac::$is_paired::$connected"
        any_device=true
    done <<< "$devices"

    $any_device || add_entry "No devices found" "noop"
else
    add_entry "Bluetooth is off" "noop"
fi

choice=$(printf '%s\n' "${entries[@]}" | rofi "${ROFI_FLAGS[@]}" -p "󰂯  Bluetooth" -format i)
rofi_exit=$?
[ "$rofi_exit" -ne 0 ] && exit 0
[ -z "$choice" ] && exit 0

selected_action="${actions[$choice]}"

case "$selected_action" in
    toggle_power)
        if [ "$power_state" = "yes" ]; then
            bluetoothctl power off
        else
            bluetoothctl power on
        fi
        ;;
    open_manager)
        blueman-manager &
        ;;
    device::*)
        IFS='::' read -r _ mac is_paired connected <<< "$selected_action"
        [ -z "$mac" ] && exit 0

        if [ "$connected" = "yes" ]; then
            bluetoothctl disconnect "$mac"
        else
            if [ "$is_paired" = "yes" ]; then
                bluetoothctl connect "$mac"
            else
                bluetoothctl pair "$mac" && bluetoothctl connect "$mac"
            fi
        fi
        ;;
    *)
        ;;
esac

exit 0
