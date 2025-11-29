#!/bin/bash

# Waybar weather module with reliable wttr.in fetch and graceful fallbacks

fallback='{"text": "󰖐", "tooltip": "Weather data unavailable"}'

# Allow overriding the location via env or a small config file
location="${WEATHER_LOCATION:-}"
if [ -z "$location" ] && [ -f "$HOME/.config/waybar/weather_location" ]; then
    location=$(head -n 1 "$HOME/.config/waybar/weather_location")
fi
location=$(echo "$location" | xargs)
location_query=$(printf '%s' "$location" | tr ' ' '+')

base_url="https://wttr.in/${location_query}"
user_agent="Mozilla/5.0 (Waybar)"

# Fast display string (includes emoji + temp)
weather_data=$(curl -fsS -A "$user_agent" --connect-timeout 3 --max-time 5 "${base_url}?format=%c+%t" 2>/dev/null)

# Fallback to a simpler format if the main one fails
if [ -z "$weather_data" ]; then
    weather_data=$(curl -s -A "$user_agent" --connect-timeout 3 --max-time 5 "${base_url}?format=3" 2>/dev/null)
fi

# Detailed forecast for tooltip
forecast=$(curl -s -A "$user_agent" --connect-timeout 4 --max-time 8 "${base_url}?format=j1" 2>/dev/null)

if [ -z "$weather_data" ] && [ -z "$forecast" ]; then
    echo "$fallback"
    exit 0
fi

text=$(echo "$weather_data" | xargs)
current_temp=""
current_feels=""
current_desc=""
current_humid=""
current_wind=""
location_name=""
tooltip="Weather data from wttr.in"

# Build tooltip only if the JSON looks valid
if [ -n "$forecast" ] && echo "$forecast" | jq -e '.current_condition[0]' >/dev/null 2>&1; then
    current_temp=$(echo "$forecast" | jq -r '.current_condition[0].temp_C // empty' 2>/dev/null)
    current_feels=$(echo "$forecast" | jq -r '.current_condition[0].FeelsLikeC // empty' 2>/dev/null)
    current_desc=$(echo "$forecast" | jq -r '.current_condition[0].weatherDesc[0].value // empty' 2>/dev/null)
    current_humid=$(echo "$forecast" | jq -r '.current_condition[0].humidity // empty' 2>/dev/null)
    current_wind=$(echo "$forecast" | jq -r '.current_condition[0].windspeedKmph // empty' 2>/dev/null)
    location_name=$(echo "$forecast" | jq -r '.nearest_area[0].areaName[0].value // empty' 2>/dev/null)
    [ -z "$location_name" ] && [ -n "$location" ] && location_name="$location"

    temp_display=${current_temp:-"--"}
    feels_display=${current_feels:-"--"}
    desc_display=${current_desc:-"N/A"}
    humid_display=${current_humid:-"--"}
    wind_display=${current_wind:-"--"}

    tooltip="<b>Current Conditions</b>
📍 <span color='#89b4fa'>${location_name:-Unknown}</span>
🌡️  ${temp_display}°C (feels ${feels_display}°C)
☁️  ${desc_display}
💧 ${humid_display}% • 💨 ${wind_display}km/h

<b>Next 8 Hours</b>
"

    for i in 0 2 4 6; do
        time_val=$(echo "$forecast" | jq -r ".weather[0].hourly[$i].time // empty" 2>/dev/null)
        temp_val=$(echo "$forecast" | jq -r ".weather[0].hourly[$i].tempC // empty" 2>/dev/null)
        desc_val=$(echo "$forecast" | jq -r ".weather[0].hourly[$i].weatherDesc[0].value // empty" 2>/dev/null)

        [ -z "$time_val" ] && continue
        [ -z "$temp_val" ] && continue

        hour=$((time_val / 100))
        if [ $hour -ge 12 ]; then
            period="PM"
            [ $hour -gt 12 ] && hour=$((hour - 12))
        else
            period="AM"
            [ $hour -eq 0 ] && hour=12
        fi

        tooltip+="<span color='#f9e2af'>${hour}${period}</span>  ${temp_val}°C  ${desc_val}
"
    done

    tooltip+="
<b>Next 7 Days</b>
"

    for i in 1 2 3 4 5 6 7; do
        date_val=$(echo "$forecast" | jq -r ".weather[$i].date // empty" 2>/dev/null)
        max_temp=$(echo "$forecast" | jq -r ".weather[$i].maxtempC // empty" 2>/dev/null)
        min_temp=$(echo "$forecast" | jq -r ".weather[$i].mintempC // empty" 2>/dev/null)
        desc_val=$(echo "$forecast" | jq -r ".weather[$i].hourly[4].weatherDesc[0].value // empty" 2>/dev/null)

        [ -z "$date_val" ] && continue
        [ -z "$max_temp" ] && continue

        day_name=$(date -d "$date_val" +%a 2>/dev/null)
        month_day=$(date -d "$date_val" +"%b %d" 2>/dev/null)

        tooltip+="<span color='#a6e3a1'>${day_name} ${month_day}</span>  ↑${max_temp}° ↓${min_temp}°  ${desc_val}
"
    done
fi

# Build a basic display if the pretty format failed
if [ -z "$text" ] && [ -n "$current_temp" ]; then
    text="${current_temp}°C"
fi

if [ -z "$text" ]; then
    echo "$fallback"
    exit 0
fi

# Escape special characters for JSON and replace newlines
escaped_text=$(echo "$text" | sed 's/\\/\\\\/g; s/"/\\"/g')
escaped_tooltip=$(printf "%s" "$tooltip" | sed ':a;N;$!ba;s/\\/\\\\/g; s/"/\\"/g; s/\n/\\n/g')

printf '{"text": "%s", "tooltip": "%s"}\n' "$escaped_text" "$escaped_tooltip"
