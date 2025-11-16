# CustomOS Customization Guide
## Hyde-Inspired Features for Hyprland

This guide covers all the customization features in CustomOS, inspired by the Hyde project for Hyprland configurations.

---

## 📋 Table of Contents

1. [Theme System](#theme-system)
2. [Wallpaper Management](#wallpaper-management)
3. [Waybar Customization](#waybar-customization)
4. [Keybindings Reference](#keybindings-reference)
5. [Window Rules](#window-rules)
6. [Performance Tuning](#performance-tuning)
7. [Multi-Monitor Setup](#multi-monitor-setup)
8. [Creating Custom Themes](#creating-custom-themes)

---

## 🎨 Theme System

CustomOS includes a complete theme management system that coordinates colors across all applications.

### Available Themes

- **Catppuccin Mocha** - Soothing pastel theme (default)
- **Decay Green** - Dark with vibrant green accents
- **Nord** - Arctic, north-bluish color palette
- **Dracula** - Dark theme with vibrant colors
- **Gruvbox Dark** - Retro groove color scheme
- **Tokyo Night** - Clean, inspired by Tokyo's night sky
- **One Dark** - Iconic Atom editor theme
- **Rose Pine** - Natural pine with soho vibes
- **Everforest** - Comfortable green forest theme
- **Solarized Dark** - Precision colors

### Switching Themes

**Interactive Selector:**
```bash
# Press Super + Shift + T
# Or run manually:
~/.config/hypr/scripts/theme-select.sh
```

**Command Line:**
```bash
# Apply a specific theme
~/.config/hypr/scripts/theme-apply.sh catppuccin-mocha
~/.config/hypr/scripts/theme-apply.sh dracula
~/.config/hypr/scripts/theme-apply.sh nord
```

### What Gets Themed

When you switch themes, colors are automatically updated for:
- ✅ Hyprland borders and UI
- ✅ Waybar status bar
- ✅ Kitty terminal
- ✅ Wofi app launcher
- ✅ Mako notifications
- ✅ Wallpaper (if theme has dedicated wallpapers)

### Theme Files Location

```
~/.config/hypr/
├── themes/                    # Theme definitions
│   ├── catppuccin-mocha.conf
│   ├── dracula.conf
│   ├── nord.conf
│   └── ...
├── colors.conf                # Current theme colors (auto-generated)
└── .current-theme             # Currently active theme name
```

---

## 🖼️ Wallpaper Management

CustomOS supports dynamic wallpaper management with smooth transitions.

### Wallpaper Structure

```
~/Pictures/Wallpapers/
├── catppuccin-mocha/         # Theme-specific wallpapers
│   ├── wallpaper1.jpg
│   └── wallpaper2.png
├── dracula/
│   └── wallpaper.jpg
└── default.jpg               # Fallback wallpaper
```

### Wallpaper Controls

| Keybinding | Action |
|------------|--------|
| `Super + Alt + Right` | Next wallpaper |
| `Super + Alt + Left` | Previous wallpaper |
| `Super + Shift + W` | Interactive wallpaper picker |
| `Super + Ctrl + W` | Random wallpaper |

### Wallpaper Daemon

CustomOS uses **swww** for smooth animated transitions. If swww is not available, it falls back to hyprpaper.

**swww Features:**
- Animated transitions (fade, wipe, grow, etc.)
- Position-aware transitions (grow from cursor)
- Better performance than hyprpaper

**Manual wallpaper change:**
```bash
swww img /path/to/wallpaper.jpg --transition-type fade
```

---

## 📊 Waybar Customization

### Available Styles

CustomOS includes three Waybar style variations:

1. **Minimal** - Clean and simple (default)
2. **Detailed** - Colorful with more information
3. **Floating** - Separated modules with gaps

### Switching Styles

Edit `~/.config/waybar/style.css`:
```css
/* Change the import to use a different style */
@import "styles/minimal.css";   /* Default */
@import "styles/detailed.css";  /* Detailed */
@import "styles/floating.css";  /* Floating */
```

Then reload Waybar:
```bash
killall waybar; waybar &
```

### Waybar Modules

Current modules displayed (left to right):

**Left:**
- Workspace indicators
- Window title

**Center:**
- Clock with calendar

**Right:**
- Weather (if configured)
- Keybindings help button
- Bluetooth
- Network
- Audio volume
- CPU usage
- Memory usage
- Temperature
- Battery (on laptops)
- System tray
- Power menu

---

## ⌨️ Keybindings Reference

### Applications

| Keybinding | Action |
|------------|--------|
| `Super + T` | Terminal |
| `Super + Alt + T` | Floating terminal |
| `Super + E` | File manager |
| `Super + B` | Browser |
| `Super + C` | VS Code |
| `Super + N` | Notes (Neovim) |
| `Super + O` | Obsidian |
| `Super + M` | Music player |
| `Super + D` | Discord |
| `Super + A` | App launcher |
| `Super + V` | Clipboard history |
| `Ctrl + Shift + Esc` | System monitor |

### Window Management

| Keybinding | Action |
|------------|--------|
| `Super + Q` or `Alt + F4` | Close window |
| `Super + W` | Toggle floating |
| `Super + F` or `Shift + F11` | Toggle fullscreen |
| `Super + Shift + F` | Pin window |
| `Super + J` | Toggle split |
| `Super + Arrow Keys` | Move focus |
| `Super + Shift + Arrows` | Resize window |
| `Super + Shift + Ctrl + Arrows` | Move window |
| `Super + Mouse Left` | Move window |
| `Super + Mouse Right` | Resize window |

### Workspaces

| Keybinding | Action |
|------------|--------|
| `Super + 1-9` | Switch to workspace |
| `Super + Shift + 1-9` | Move window to workspace |
| `Super + Alt + 1-9` | Move window silently |
| `Super + Ctrl + Right` | Next workspace |
| `Super + Ctrl + Left` | Previous workspace |
| `Super + S` | Toggle scratchpad |
| `Super + Shift + S` | Move to scratchpad |

### Screenshots & Recording

| Keybinding | Action |
|------------|--------|
| `Super + P` | Area screenshot |
| `Print` | Fullscreen screenshot |
| `Super + Shift + P` | Color picker |
| `Super + R` | Screen recording (toggle) |

### Theming

| Keybinding | Action |
|------------|--------|
| `Super + Shift + T` | Theme selector |
| `Super + Shift + W` | Wallpaper selector |
| `Super + Alt + Right` | Next wallpaper |
| `Super + Alt + Left` | Previous wallpaper |
| `Super + Ctrl + W` | Random wallpaper |

### System

| Keybinding | Action |
|------------|--------|
| `Super + L` | Lock screen |
| `Super + G` | Toggle game mode |
| `Super + /` | Keybindings help |
| `Super + ,` | Emoji picker |
| `Ctrl + Alt + Del` | Power/logout menu |
| `Super + Delete` | Exit Hyprland |

### Media Keys

| Key | Action |
|-----|--------|
| `XF86AudioMute` | Mute/Unmute |
| `XF86AudioRaiseVolume` | Volume up |
| `XF86AudioLowerVolume` | Volume down |
| `XF86AudioPlay/Pause` | Play/Pause |
| `XF86AudioNext` | Next track |
| `XF86AudioPrev` | Previous track |
| `XF86MonBrightnessUp` | Brightness up (laptop) |
| `XF86MonBrightnessDown` | Brightness down (laptop) |

---

## 🪟 Window Rules

CustomOS includes advanced window rules for better window management.

### Floating Windows

These windows automatically float with centered positioning:
- pavucontrol (Volume control)
- blueman-manager (Bluetooth manager)
- nm-connection-editor (Network editor)
- Picture-in-Picture windows
- File picker dialogs

### Opacity

| Application | Active | Inactive |
|-------------|--------|----------|
| Kitty | 95% | 90% |
| VS Code | 95% | 90% |
| Obsidian | 95% | 90% |
| Thunar | 90% | 85% |

### Custom Window Rules

Add your own in `~/.config/hypr/hyprland.conf`:

```conf
# Float specific applications
windowrulev2 = float, class:(myapp)
windowrulev2 = size 800 600, class:(myapp)
windowrulev2 = center, class:(myapp)

# Assign to specific workspace
windowrulev2 = workspace 2 silent, class:(firefox)

# Set opacity
windowrulev2 = opacity 0.9 0.8, class:(myapp)

# Prevent idle when focused
windowrulev2 = idleinhibit focus, class:(mpv)
```

---

## ⚡ Performance Tuning

### Game Mode

Toggle game mode for maximum performance:

**Keybinding:** `Super + G`

**What it does:**
- ✅ Disables blur
- ✅ Disables animations
- ✅ Removes gaps
- ✅ Optimizes for gaming

**Manual toggle:**
```bash
~/.config/hypr/scripts/gamemode-toggle.sh
```

### Tearing Mode for Games

For competitive gaming with reduced input lag, specific games have tearing enabled:

```conf
windowrulev2 = immediate, class:(steam_app)
windowrulev2 = immediate, class:(cs2)
windowrulev2 = immediate, class:(dota2)
```

Add your games:
```conf
windowrulev2 = immediate, class:(your-game-class)
```

### Animation Tweaking

Edit `~/.config/hypr/hyprland.conf`:

```conf
animations {
    enabled = true  # Set to false to disable all animations

    # Adjust speed (lower = faster)
    animation = windows, 1, 6, wind, slide     # Change 6 to 3
    animation = workspaces, 1, 6, wind, slide  # Change 6 to 3
}
```

---

## 🖥️ Multi-Monitor Setup

### Configuration

Edit `~/.config/hypr/hyprland.conf`:

```conf
# Example: Two monitors
monitor=DP-1,2560x1440@144,0x0,1
monitor=HDMI-A-1,1920x1080@60,2560x0,1

# Workspace per monitor
workspace=1,monitor:DP-1,default:true
workspace=2,monitor:DP-1
workspace=3,monitor:HDMI-A-1,default:true
workspace=4,monitor:HDMI-A-1
```

### Find Monitor Names

```bash
hyprctl monitors
```

### Different Wallpapers per Monitor

```bash
swww img -o DP-1 ~/wallpaper1.jpg
swww img -o HDMI-A-1 ~/wallpaper2.jpg
```

---

## 🎨 Creating Custom Themes

### Step 1: Create Theme File

Create `~/.config/hypr/themes/my-theme.conf`:

```bash
# My Custom Theme
THEME_NAME="My Theme"
THEME_AUTHOR="Your Name"

# Border Colors
ACTIVE_BORDER="rgba(ff0000ff) rgba(00ff00ff) 45deg"
INACTIVE_BORDER="rgba(333333aa)"
SHADOW_COLOR="rgba(00000099)"

# Base Colors
BACKGROUND="#1a1a1a"
FOREGROUND="#ffffff"

# 16 Color Palette
COLOR0="#000000"
COLOR1="#ff0000"
COLOR2="#00ff00"
COLOR3="#ffff00"
COLOR4="#0000ff"
COLOR5="#ff00ff"
COLOR6="#00ffff"
COLOR7="#ffffff"
COLOR8="#808080"
COLOR9="#ff8080"
COLOR10="#80ff80"
COLOR11="#ffff80"
COLOR12="#8080ff"
COLOR13="#ff80ff"
COLOR14="#80ffff"
COLOR15="#ffffff"
```

### Step 2: Apply Your Theme

```bash
~/.config/hypr/scripts/theme-apply.sh my-theme
```

### Step 3: Add Theme Wallpapers (Optional)

```bash
mkdir -p ~/Pictures/Wallpapers/my-theme
cp your-wallpaper.jpg ~/Pictures/Wallpapers/my-theme/
```

### Color Extraction from Images

Use pywal to generate themes from wallpapers:

```bash
# Generate colors from image
wal -i ~/Pictures/Wallpapers/awesome.jpg

# Colors are saved to ~/.cache/wal/colors
# Convert to CustomOS theme format manually
```

---

## 🛠️ Troubleshooting

### Theme not applying

```bash
# Check if theme file exists
ls ~/.config/hypr/themes/

# Manually apply theme
~/.config/hypr/scripts/theme-apply.sh catppuccin-mocha

# Reload Hyprland
hyprctl reload
```

### Wallpaper not changing

```bash
# Check swww daemon
pgrep swww

# Restart swww
killall swww-daemon
swww-daemon &

# Set wallpaper manually
swww img ~/Pictures/Wallpapers/default.jpg
```

### Scripts not working

```bash
# Make scripts executable
chmod +x ~/.config/hypr/scripts/*.sh

# Check script location
echo $scrPath  # Should output: /home/user/.config/hypr/scripts
```

---

## 📚 Additional Resources

- **Hyprland Wiki:** https://wiki.hyprland.org
- **Hyde Project:** https://github.com/prasanthrangan/hyprdots
- **Catppuccin Theme:** https://github.com/catppuccin/catppuccin
- **Waybar Wiki:** https://github.com/Alexays/Waybar/wiki

---

## 💡 Tips & Tricks

1. **Quick theme testing:** Use the theme selector (`Super + Shift + T`) to preview themes
2. **Backup your config:** `cp -r ~/.config/hypr ~/.config/hypr.backup`
3. **Check Hyprland logs:** `cat /tmp/hypr/$(ls -t /tmp/hypr/ | head -n 1)/hyprland.log`
4. **Reload without restart:** Most changes apply with `hyprctl reload`
5. **Custom keybindings:** Add to `~/.config/hypr/hyprland.conf` under keybindings section

---

**Enjoy your customized Hyprland experience! 🎉**
