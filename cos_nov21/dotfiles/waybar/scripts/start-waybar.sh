#!/bin/bash

#!/bin/bash

# Minimal Waybar launcher (static translucent theme, no wallpaper-driven colors)

# Kill any existing waybar/watcher processes
pkill -x waybar 2>/dev/null
pkill -f watch-wallpaper.sh 2>/dev/null
sleep 0.3

# Start Waybar with explicit config and style to avoid fallback CSS
waybar -c "$HOME/.config/waybar/config" -s "$HOME/.config/waybar/styles/translucent.css" > /tmp/waybar.log 2>&1 &
WAYBAR_PID=$!

echo "Waybar started (PID: $WAYBAR_PID)"
echo "Logs: /tmp/waybar.log"

# Keep track of PID for easy management
echo "$WAYBAR_PID" > /tmp/waybar.pid
