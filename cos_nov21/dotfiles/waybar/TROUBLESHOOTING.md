# Waybar Dynamic Colors - Troubleshooting

## Current Status

The automatic color changing system is set up and the watcher is running. However, you mentioned colors aren't changing when you change wallpapers.

## How It Works

1. When you change wallpaper using your scripts (`wallpaper-random.sh`, `wallpaper-next.sh`, etc.), they update `~/.config/hypr/.current-wallpaper`
2. The watcher (`watch-wallpaper.sh`) detects this change
3. Color extraction runs automatically
4. Waybar restarts with new colors

## Testing

### Test 1: Manual Color Update

Run this command after changing your wallpaper:

```bash
~/.config/waybar/scripts/manual-update.sh
```

This will show you:
- What wallpaper the system thinks is current
- Extracted colors
- Whether Waybar restarted

### Test 2: Check if Watcher is Running

```bash
ps aux | grep watch-wallpaper | grep -v grep
```

If nothing shows up, start it:

```bash
~/.config/waybar/scripts/watch-wallpaper.sh > /tmp/waybar-watcher.log 2>&1 &
```

### Test 3: Change Wallpaper Using Your Keybinds

1. Press `SUPER + CTRL + Up` (random wallpaper)
2. Wait 1-2 seconds
3. Waybar should restart automatically with new colors matching your wallpaper

### Test 4: Check Watcher Logs

```bash
tail -f /tmp/waybar-watcher.log
```

Then change wallpaper. You should see:
```
Wallpaper changed (detected via .current-wallpaper), updating Waybar colors...
Waybar colors updated from wallpaper: [filename]
```

## Common Issues

### Issue 1: Wallpaper Changes But Colors Don't

**Symptom:** You change wallpaper but Waybar colors stay the same

**Causes:**
1. Watcher isn't running - start it manually (see Test 2)
2. You're changing wallpaper in a way that doesn't update `.current-wallpaper`
3. Waybar restart is failing

**Solution:**
- Always use the keyboard shortcuts or scripts to change wallpapers
- Run `manual-update.sh` after changing wallpaper to force an update

### Issue 2: .current-wallpaper Doesn't Match Visual Wallpaper

**Symptom:** The file shows one wallpaper but you're seeing a different one

**Cause:** You might be changing wallpapers directly with swww/hyprpaper commands instead of using the wallpaper-lib.sh scripts

**Solution:**
- Always use:
  - `SUPER + CTRL + Up/Left/Right` (keybinds)
  - `SUPER + SHIFT + W` (wallpaper picker)
  - Or run the scripts in `~/.config/hypr/scripts/wallpaper-*.sh`

### Issue 3: Colors Are Wrong

**Symptom:** Colors are extracted but don't look good

**Cause:** The color extraction algorithm might need tweaking for your specific wallpapers

**Solution:**
Edit `~/.config/waybar/scripts/update-colors-from-wallpaper.sh`:
- Line ~40: Adjust background opacity (currently 0.95)
- Line ~35: Change brightness threshold (currently 0.5)

## Force Update Right Now

To manually update Waybar colors to match your current wallpaper:

```bash
# Method 1: Use the manual update script
~/.config/waybar/scripts/manual-update.sh

# Method 2: Update manually then restart waybar
~/.config/waybar/scripts/update-colors-from-wallpaper.sh
pkill waybar && waybar &
```

## Verify Everything is Working

Run these commands:

```bash
# 1. Check if watcher is running
pgrep -f watch-wallpaper && echo "✓ Watcher is running" || echo "✗ Watcher is NOT running"

# 2. Check current wallpaper file
echo "Current wallpaper: $(cat ~/.config/hypr/.current-wallpaper)"

# 3. Check CSS file age
ls -lh ~/.cache/waybar/colors.css

# 4. Test color extraction
~/.config/waybar/scripts/update-colors-from-wallpaper.sh
```

## Still Not Working?

If none of the above works, try a full restart:

```bash
# Kill everything
pkill -f watch-wallpaper
pkill waybar

# Start fresh
~/.config/waybar/scripts/watch-wallpaper.sh > /tmp/waybar-watcher.log 2>&1 &
waybar &

# Change wallpaper using keybind
# SUPER + CTRL + Up
```

Check the log: `tail -f /tmp/waybar-watcher.log`
