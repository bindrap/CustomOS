#!/bin/bash
# Toggle gaming mode (disable animations, gaps, blur for performance)

HYPR_DIR="$HOME/.config/hypr"
GAMEMODE_FILE="$HYPR_DIR/.gamemode"

if [ -f "$GAMEMODE_FILE" ]; then
    # Disable game mode
    hyprctl keyword decoration:blur:enabled true
    hyprctl keyword animations:enabled true
    hyprctl keyword general:gaps_in 2
    hyprctl keyword general:gaps_out 4
    hyprctl keyword decoration:rounding 0
    rm "$GAMEMODE_FILE"
    notify-send "Game Mode" "Disabled - Normal mode restored" -t 2000
else
    # Enable game mode
    hyprctl keyword decoration:blur:enabled false
    hyprctl keyword animations:enabled false
    hyprctl keyword general:gaps_in 0
    hyprctl keyword general:gaps_out 0
    hyprctl keyword decoration:rounding 0
    touch "$GAMEMODE_FILE"
    notify-send "Game Mode" "Enabled - Maximum performance" -t 2000
fi
