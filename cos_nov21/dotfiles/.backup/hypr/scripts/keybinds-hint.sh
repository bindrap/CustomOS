#!/bin/bash
# Display keybindings cheat sheet - Hyde Style

KEYBINDS="
╔═══════════════════════════════════════════════════════════════╗
║           CUSTOMOS - HYPRLAND KEYBINDINGS (ALT-based)        ║
╚═══════════════════════════════════════════════════════════════╝

APPLICATIONS
  ALT + T                Terminal (Kitty)
  ALT + E                File Manager (Thunar)
  ALT + A                App Launcher (Wofi)

WINDOW MANAGEMENT
  ALT + Q                Close Window
  ALT + Space            Toggle Floating
  ALT + F                Toggle Fullscreen
  ALT + P                Pseudotile
  ALT + J                Toggle Split
  ALT + M                Exit Hyprland

WINDOW FOCUS
  ALT + Arrow Keys       Move Focus Between Windows

WORKSPACES
  ALT + [1-9,0]          Switch to Workspace 1-10
  ALT + SHIFT + [1-9,0]  Move Window to Workspace 1-10

SCREENSHOTS
  Print                  Area Screenshot (to clipboard)
  SHIFT + Print          Fullscreen Screenshot (to clipboard)
  ALT + Print            Save Screenshot to ~/Pictures

HYDE CUSTOMIZATION 󰀻
  ALT + C                Hyde Menu (All Options)
  ALT + SHIFT + W        Wallpaper Picker
  ALT + SHIFT + T        Theme Selector
  ALT + CTRL + Right     Next Wallpaper
  ALT + CTRL + Left      Previous Wallpaper
  ALT + CTRL + Up        Random Wallpaper
  ALT + H                This Help Menu

SYSTEM
  ALT + SHIFT + R        Reload Waybar
"

# Show using rofi or wofi
if command -v rofi >/dev/null 2>&1; then
    echo "$KEYBINDS" | rofi -dmenu -i -p " Keybindings" -theme-str 'window {width: 700px;} listview {lines: 20;}'
else
    echo "$KEYBINDS" | wofi --dmenu --width 800 --height 600 --prompt " Keybindings"
fi
