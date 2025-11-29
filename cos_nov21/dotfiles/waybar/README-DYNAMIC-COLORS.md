# Waybar Dynamic Colors

Your Waybar is now configured to automatically adapt its colors based on your current wallpaper!

## How It Works

1. **Color Extraction**: The script extracts dominant colors from your wallpaper using ImageMagick
2. **Smart Detection**: Automatically detects if your wallpaper is light or dark and adjusts text colors for readability
3. **Accent Colors**: Finds the most saturated color for accents (active workspace, charging battery, etc.)
4. **Dynamic CSS**: Generates a custom CSS file at `~/.cache/waybar/colors.css`

## Files Created

- `~/.config/waybar/scripts/update-colors-from-wallpaper.sh` - Main color extraction script
- `~/.config/waybar/scripts/watch-wallpaper.sh` - Watches for wallpaper changes
- `~/.cache/waybar/colors.css` - Generated CSS with dynamic colors

## Manual Usage

To manually update colors from your current wallpaper:

```bash
~/.config/waybar/scripts/update-colors-from-wallpaper.sh
```

Then reload Waybar:
```bash
pkill -SIGUSR2 waybar
```

## Automatic Updates

The watcher has been added to your Hyprland autostart configuration!

It monitors `~/.config/hypr/.current-wallpaper` which is updated whenever you change wallpapers using:
- `SUPER + CTRL + Up` (random wallpaper)
- `SUPER + CTRL + Left/Right` (previous/next wallpaper)
- `SUPER + SHIFT + W` (wallpaper picker)

**When you change wallpaper, Waybar colors will automatically update within 1 second!**

### Already Configured

This line has been added to your `~/.config/hypr/hyprland.conf`:

```conf
exec-once = ~/.config/waybar/scripts/watch-wallpaper.sh
```

The watcher will start automatically on next login/reboot.

## Supported Wallpaper Managers

- **swww** (primary) - Watches `~/.cache/swww` for changes
- **hyprpaper** (fallback) - Reads from `~/.config/hypr/hyprpaper.conf`

## Customization

Edit `~/.config/waybar/scripts/update-colors-from-wallpaper.sh` to:
- Adjust background opacity (default: 0.95)
- Change brightness threshold for dark/light detection (default: 0.5)
- Modify accent color selection algorithm
- Tweak border and hover colors

## Troubleshooting

**Colors not updating?**
- Ensure ImageMagick is installed: `magick --version`
- Check if wallpaper path is correct: `swww query` or check hyprpaper.conf
- Manually run the script to see error messages

**Waybar looks wrong?**
- The script creates a fallback using your original style.css if no wallpaper is found
- Check `~/.cache/waybar/colors.css` for the generated colors

**Want to go back to static colors?**
- Remove the `"style"` line from `~/.config/waybar/config`
- Waybar will fall back to `style.css`
