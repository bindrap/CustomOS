#!/bin/bash

# Simple CPU usage + temperature reporter for Waybar (json)

read_cpu() {
    awk '/^cpu /{print $2,$3,$4,$5,$6,$7,$8}' /proc/stat
}

get_usage() {
    local a=($1) b=($2)
    local idle=$((b[3]-a[3]))
    local total=0 diff=0
    for i in ${a[@]}; do total=$((total+i)); done
    local total2=0
    for i in ${b[@]}; do total2=$((total2+i)); done
    diff=$((total2-total))
    echo $(( (100*(diff-idle)) / diff ))
}

snap1=($(read_cpu))
sleep 0.2
snap2=($(read_cpu))
usage=$(get_usage "${snap1[*]}" "${snap2[*]}")

temp_path="/sys/class/hwmon/hwmon2/temp1_input"
[ -f "$temp_path" ] || temp_path=$(find /sys/class/hwmon -maxdepth 2 -type f -name 'temp1_input' 2>/dev/null | head -n1)

temp_c=""
if [ -n "$temp_path" ] && [ -r "$temp_path" ]; then
    raw=$(cat "$temp_path" 2>/dev/null)
    if [ -n "$raw" ]; then
        temp_c=$((raw/1000))
    fi
fi

text="󰍛 ${usage:-0}%"
[ -n "$temp_c" ] && text+=" • ${temp_c}°C"

printf '{"text": "%s", "tooltip": "CPU %s%% %s"}\n' "$text" "${usage:-0}" "${temp_c:+${temp_c}°C}"
