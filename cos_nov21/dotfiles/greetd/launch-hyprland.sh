#!/bin/bash
# PBOS Launch Script - Shows MOTD before starting Hyprland

# Show the dynamic MOTD with ASCII art and philosophy quotes
if [ -x /usr/local/bin/generate-motd.sh ]; then
    /usr/local/bin/generate-motd.sh
else
    echo ""
    echo "Welcome to PBOS (Parteek Bindra Operating System)"
    echo ""
fi

# Wait a moment for user to read
sleep 2

# Launch Hyprland
exec Hyprland
