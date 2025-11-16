#!/bin/bash

# Weather Script for Waybar
# Fetches weather from wttr.in
# Change LOCATION to your city

LOCATION="Windsor,ON"  # Change this to your location

# Fetch weather data
weather_data=$(curl -s "wttr.in/${LOCATION}?format=%C+%t")

# If curl fails, show error
if [ -z "$weather_data" ]; then
    echo '{"text": "  N/A", "tooltip": "Unable to fetch weather"}'
    exit 0
fi

# Parse condition and temperature
condition=$(echo "$weather_data" | awk '{print $1}')
temp=$(echo "$weather_data" | awk '{print $2}')

# Map weather conditions to icons
case "$condition" in
    *Clear*|*Sunny*) icon="" ;;
    *Cloud*|*Overcast*) icon="" ;;
    *Rain*|*Drizzle*) icon="" ;;
    *Snow*|*Sleet*) icon="" ;;
    *Thunder*|*Storm*) icon="" ;;
    *Fog*|*Mist*) icon="" ;;
    *) icon="" ;;
esac

# Output JSON for Waybar
echo "{\"text\": \"$icon $temp\", \"tooltip\": \"$weather_data in $LOCATION\"}"
