#!/bin/bash
# Display keybindings cheat sheet

KEYBINDS="
╔═══════════════════════════════════════════════════════════════╗
║                  HYPRLAND KEYBINDINGS                         ║
╚═══════════════════════════════════════════════════════════════╝

APPLICATIONS
  Super + T              Terminal
  Super + Alt + T        Floating Terminal
  Super + E              File Manager
  Super + B              Browser
  Super + C              VS Code
  Super + N              Notes (Neovim)
  Super + O              Obsidian
  Super + M              Music Player
  Super + D              Discord
  Super + A              App Launcher
  Super + V              Clipboard History
  Ctrl + Shift + Esc     System Monitor

WINDOW MANAGEMENT
  Super + Q              Close Window
  Alt + F4               Close Window
  Super + W              Toggle Floating
  Super + F              Toggle Fullscreen
  Super + Shift + F      Pin Window
  Super + J              Toggle Split
  Super + L              Lock Screen

WINDOW FOCUS
  Super + Arrow Keys     Move Focus
  Alt + Tab              Cycle Windows

WINDOW RESIZE
  Super + Shift + Arrows Resize Active Window

WINDOW MOVE
  Super + Shift + Ctrl + Arrows   Move Window

WORKSPACES
  Super + [1-9]          Switch to Workspace
  Super + Shift + [1-9]  Move Window to Workspace
  Super + Alt + [1-9]    Move Window Silently
  Super + Ctrl + Right   Next Workspace
  Super + Ctrl + Left    Previous Workspace
  Super + S              Scratchpad Toggle

SCREENSHOTS
  Super + P              Area Screenshot
  Super + Shift + P      Color Picker
  Print                  Fullscreen Screenshot

MEDIA
  XF86AudioMute          Mute/Unmute
  XF86AudioRaise         Volume Up
  XF86AudioLower         Volume Down
  XF86AudioPlay          Play/Pause
  XF86AudioNext          Next Track
  XF86AudioPrev          Previous Track

THEMING
  Super + Shift + T      Theme Selector
  Super + Shift + W      Wallpaper Selector
  Super + Alt + Right    Next Wallpaper
  Super + Alt + Left     Previous Wallpaper

UTILITIES
  Super + /              This Help
  Super + ,              Emoji Picker
  Ctrl + Alt + Del       Logout Menu

SYSTEM
  Super + Delete         Exit Hyprland
"

echo "$KEYBINDS" | wofi --dmenu --width 800 --height 600 --prompt "Keybindings"
