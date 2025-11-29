# How to Start Waybar with Color Watcher

## Important: Don't Start from SSH/CLI!

Waybar needs to run from your actual Hyprland graphical session, not from this terminal.

## Method 1: Use Hyprland Keybind (Easiest)

Press: `SUPER + SHIFT + R`

This will:
- Kill old Waybar and watcher
- Start Waybar with color watcher active
- Colors will match your current wallpaper

## Method 2: From Hyprland Terminal

Open a terminal IN your Hyprland session (not SSH), then run:

```bash
~/.config/waybar/scripts/start-waybar.sh
```

## Method 3: Restart Hyprland

The easiest way is to just log out and log back in, or restart Hyprland:

```bash
hyprctl reload
```

Waybar will start automatically with the watcher.

## Verify It's Working

Once Waybar is visible on your screen:

1. **Check the watcher is running:**
   ```bash
   ps aux | grep watch-wallpaper | grep -v grep
   ```
   Should show one process.

2. **Change wallpaper:**
   Press `SUPER + CTRL + Up` (random wallpaper)

3. **Watch Waybar:**
   - Should disappear briefly
   - Come back with colors matching the new wallpaper
   - Should only restart ONCE

## If Waybar Still Restarts Multiple Times

Kill all old watchers:
```bash
pkill -9 inotifywait
pkill -9 -f watch-wallpaper
```

Then restart Waybar from Hyprland:
Press `SUPER + SHIFT + R`

## Current Status

✅ Scripts are ready and configured
✅ Debouncing is enabled (single restart)
✅ Colors will extract automatically
✅ Hyprland autostart is configured

You just need to start Waybar from your actual Hyprland session!

## Next Login

On your next login, everything will start automatically:
- Hyprland loads
- Runs: `~/.config/waybar/scripts/start-waybar.sh`
- Waybar appears with watcher active
- Wallpaper changes trigger color updates

No manual steps needed!
