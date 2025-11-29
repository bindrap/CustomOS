#!/bin/bash

# Wi-Fi picker with quick menu + full search/connect/forget
THEME="$HOME/.config/waybar/styles/popup.rasi"
ROFI_FLAGS=(-dmenu -i -theme "$THEME" -location 3 -yoffset 36 -xoffset -6 -width 36)
MODE="${1:-full}" # full | quick

wifi_iface=$(nmcli -t -f DEVICE,TYPE device status | awk -F: '$2=="wifi"{print $1; exit}')
wifi_state=$(nmcli radio wifi)
current_ssid=$(nmcli -t -f ACTIVE,SSID dev wifi list | awk -F: '$1=="yes"{print $2; exit}')
current_conn=$(nmcli -t -f NAME,TYPE connection show --active | awk -F: '$2=="802-11-wireless"{print $1; exit}')

entries=()
actions=()

add_entry() {
    entries+=("$1")
    actions+=("$2")
}

toggle_label() {
    if [ "$wifi_state" = "enabled" ]; then
        echo "󰤭  Turn Wi-Fi off"
    else
        echo "󰤨  Turn Wi-Fi on"
    fi
}

# Quick actions first
add_entry "$(toggle_label)" "toggle"
if [ "$wifi_state" = "enabled" ] && [ -n "$current_ssid" ]; then
    add_entry "󰣈  Disconnect from $current_ssid" "disconnect"
    add_entry "󰙧  Forget $current_ssid" "forget"
fi
add_entry "⟳  Rescan" "rescan"
[ "$MODE" = "full" ] && add_entry "󰈹  Launch nm-connection-editor" "open_editor"

# Populate networks when Wi-Fi is on
if [ "$wifi_state" = "enabled" ]; then
    network_added=false
    networks=$(nmcli -t -f ACTIVE,SSID,SECURITY,SIGNAL device wifi list | sort -t: -k4 -nr)
    while IFS=: read -r active ssid security signal; do
        [ -z "$ssid" ] && continue
        [ "$ssid" = "--" ] && continue

        # Strength icon
        if [ "$signal" -ge 75 ]; then
            icon="󰤨"
        elif [ "$signal" -ge 50 ]; then
            icon="󰤥"
        elif [ "$signal" -ge 25 ]; then
            icon="󰤢"
        else
            icon="󰤟"
        fi

        [ -n "$security" ] && lock=" 󰌾" || lock=""
        status=""
        [ "$active" = "yes" ] && status="  (connected)"

        entries+=("$icon  $ssid$lock$status")
        ssid_b64=$(printf '%s' "$ssid" | base64 -w0)
        secured="no"
        [ -n "$security" ] && secured="yes"
        actions+=("connect::$ssid_b64::$secured")
        network_added=true
    done <<< "$networks"

    $network_added || add_entry "󰤪  No networks found" "noop"
fi

choice=$(printf '%s\n' "${entries[@]}" | rofi "${ROFI_FLAGS[@]}" -p "󰤨  Wi-Fi" -format i)
rofi_exit=$?
[ "$rofi_exit" -ne 0 ] && exit 0
[ -z "$choice" ] && exit 0

selected_action="${actions[$choice]}"

case "$selected_action" in
    toggle)
        if [ "$wifi_state" = "enabled" ]; then
            nmcli radio wifi off
        else
            nmcli radio wifi on
        fi
        ;;
    disconnect)
        [ -n "$wifi_iface" ] && nmcli device disconnect "$wifi_iface"
        ;;
    forget)
        [ -n "$current_conn" ] && nmcli connection delete "$current_conn"
        ;;
    rescan)
        nmcli device wifi rescan
        exec "$0" "$MODE"
        ;;
    open_editor)
        nm-connection-editor &
        ;;
    connect::*)
        IFS='::' read -r _ encoded_ssid secured <<< "$selected_action"
        ssid=$(printf '%s' "$encoded_ssid" | base64 -d 2>/dev/null)
        [ -z "$ssid" ] && exit 0

        if [ "$secured" = "yes" ]; then
            password=$(rofi -dmenu -password -p "Password for $ssid" "${ROFI_FLAGS[@]}")
            [ -z "$password" ] && exit 0
            nmcli device wifi connect "$ssid" password "$password"
        else
            nmcli device wifi connect "$ssid"
        fi
        ;;
    *)
        ;;
esac

exit 0
