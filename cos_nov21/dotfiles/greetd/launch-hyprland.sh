#!/bin/bash
# PBOS Launch Script - Shows animated intro and system info before starting Hyprland

# Show animated ASCII art intro
if [ -x /usr/local/bin/animated-intro ]; then
    /usr/local/bin/animated-intro
fi

# Show the system info MOTD with ASCII art and philosophy quotes
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
