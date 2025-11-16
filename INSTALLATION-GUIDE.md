# Installing Your Custom Hyprland Configuration

## Step 1: Install Required Packages

```bash
# Essential packages you may not have yet
sudo pacman -S \
    hyprpaper \
    hyprlock \
    brightnessctl \
    pamixer \
    playerctl \
    bluez bluez-utils blueman \
    networkmanager network-manager-applet \
    grim slurp \
    hyprpicker \
    cliphist \
    wl-clipboard \
    btop \
    curl jq
```

## Step 2: Create Directory Structure

```bash
# Create necessary directories
mkdir -p ~/.config/hypr
mkdir -p ~/.config/waybar/scripts
mkdir -p ~/.config/hypr/scripts
mkdir -p ~/Pictures/Screenshots
mkdir -p ~/Pictures/wallpapers
mkdir -p ~/Documents/Notes
```

## Step 3: Install Configuration Files

```bash
# Copy the Hyprland config
cp ~/hyprland.conf ~/.config/hypr/hyprland.conf

# Copy Waybar config and style
cp ~/waybar-config.json ~/.config/waybar/config
cp ~/waybar-style.css ~/.config/waybar/style.css

# Copy scripts
cp ~/power-menu.sh ~/.config/waybar/scripts/power-menu.sh
cp ~/weather.sh ~/.config/waybar/scripts/weather.sh

# Make scripts executable
chmod +x ~/.config/waybar/scripts/*.sh
```

## Step 4: Configure Hyprpaper (Wallpaper)

```bash
# Create hyprpaper config
cat > ~/.config/hypr/hyprpaper.conf << 'EOF'
preload = ~/Pictures/wallpapers/default.jpg
wallpaper = ,~/Pictures/wallpapers/default.jpg

splash = false
EOF

# Download a default wallpaper (or add your own)
curl -L "https://images.unsplash.com/photo-1557683316-973673baf926" -o ~/Pictures/wallpapers/default.jpg
```

## Step 5: Configure Kitty Terminal (Optional)

```bash
mkdir -p ~/.config/kitty

cat > ~/.config/kitty/kitty.conf << 'EOF'
# Catppuccin Mocha Theme for Kitty
background #1e1e2e
foreground #cdd6f4

# Font
font_family JetBrains Mono
font_size 11.0

# Window
window_padding_width 4
confirm_os_window_close 0

# Tab bar
tab_bar_style powerline
tab_powerline_style slanted

# Colors
color0  #45475a
color8  #585b70
color1  #f38ba8
color9  #f38ba8
color2  #a6e3a1
color10 #a6e3a1
color3  #f9e2af
color11 #f9e2af
color4  #89b4fa
color12 #89b4fa
color5  #cba6f7
color13 #cba6f7
color6  #94e2d5
color14 #94e2d5
color7  #bac2de
color15 #cdd6f4

# Cursor
cursor #f5e0dc
cursor_text_color #1e1e2e

# Selection
selection_foreground #1e1e2e
selection_background #f5e0dc
EOF
```

## Step 6: Create Essential Helper Scripts

### Keybinds Hint Script
```bash
cat > ~/.config/hypr/scripts/keybinds-hint.sh << 'EOF'
#!/bin/bash
# Display keybindings in wofi

keybinds=$(cat << 'KEYBINDS'
SUPER + T : Terminal
SUPER + B : Browser
SUPER + E : File Manager
SUPER + A : App Launcher
SUPER + N : Notes (Neovim)
SUPER + Q : Close Window
SUPER + L : Lock Screen
SUPER + P : Screenshot
SUPER + V : Clipboard
SUPER + 1-9 : Switch Workspace
SUPER + Shift + 1-9 : Move Window to Workspace
SUPER + Arrow Keys : Move Focus
SUPER + Shift + Arrow Keys : Resize Window
KEYBINDS
)

echo "$keybinds" | wofi --dmenu --prompt "Keybindings" --width 500 --height 400
EOF

chmod +x ~/.config/hypr/scripts/keybinds-hint.sh
```

### Wallpaper Scripts
```bash
# Next wallpaper
cat > ~/.config/hypr/scripts/wallpaper-next.sh << 'EOF'
#!/bin/bash
WALLPAPER_DIR=~/Pictures/wallpapers
CURRENT=$(hyprctl hyprpaper listloaded | head -1)
WALLPAPERS=($(ls $WALLPAPER_DIR/*.{jpg,png} 2>/dev/null))
INDEX=0

for i in "${!WALLPAPERS[@]}"; do
    if [[ "${WALLPAPERS[$i]}" == "$CURRENT" ]]; then
        INDEX=$(( (i + 1) % ${#WALLPAPERS[@]} ))
        break
    fi
done

hyprctl hyprpaper unload "$CURRENT"
hyprctl hyprpaper preload "${WALLPAPERS[$INDEX]}"
hyprctl hyprpaper wallpaper ",${WALLPAPERS[$INDEX]}"
EOF

# Previous wallpaper
cat > ~/.config/hypr/scripts/wallpaper-prev.sh << 'EOF'
#!/bin/bash
WALLPAPER_DIR=~/Pictures/wallpapers
CURRENT=$(hyprctl hyprpaper listloaded | head -1)
WALLPAPERS=($(ls $WALLPAPER_DIR/*.{jpg,png} 2>/dev/null))
INDEX=0

for i in "${!WALLPAPERS[@]}"; do
    if [[ "${WALLPAPERS[$i]}" == "$CURRENT" ]]; then
        INDEX=$(( (i - 1 + ${#WALLPAPERS[@]}) % ${#WALLPAPERS[@]} ))
        break
    fi
done

hyprctl hyprpaper unload "$CURRENT"
hyprctl hyprpaper preload "${WALLPAPERS[$INDEX]}"
hyprctl hyprpaper wallpaper ",${WALLPAPERS[$INDEX]}"
EOF

# Wallpaper selector
cat > ~/.config/hypr/scripts/wallpaper-select.sh << 'EOF'
#!/bin/bash
WALLPAPER_DIR=~/Pictures/wallpapers

selected=$(ls $WALLPAPER_DIR/*.{jpg,png} 2>/dev/null | xargs -n 1 basename | wofi --dmenu --prompt "Select Wallpaper")

if [ -n "$selected" ]; then
    CURRENT=$(hyprctl hyprpaper listloaded | head -1)
    hyprctl hyprpaper unload "$CURRENT"
    hyprctl hyprpaper preload "$WALLPAPER_DIR/$selected"
    hyprctl hyprpaper wallpaper ",$WALLPAPER_DIR/$selected"
fi
EOF

chmod +x ~/.config/hypr/scripts/wallpaper-*.sh
```

### Theme Selector Script
```bash
cat > ~/.config/hypr/scripts/theme-select.sh << 'EOF'
#!/bin/bash

themes="Catppuccin Mocha\nDecay Green\nCancel"

chosen=$(echo -e "$themes" | wofi --dmenu --prompt "Select Theme")

case "$chosen" in
    "Catppuccin Mocha")
        # Update hyprland.conf with Catppuccin colors
        sed -i 's/col.active_border = .*/col.active_border = rgba(89b4faff) rgba(cba6f7ff) 45deg/' ~/.config/hypr/hyprland.conf
        sed -i 's/col.inactive_border = .*/col.inactive_border = rgba(313244aa)/' ~/.config/hypr/hyprland.conf
        hyprctl reload
        notify-send "Theme Changed" "Switched to Catppuccin Mocha"
        ;;
    "Decay Green")
        # Update hyprland.conf with Decay Green colors
        sed -i 's/col.active_border = .*/col.active_border = rgba(90ceaaff) rgba(78dba9ff) 45deg/' ~/.config/hypr/hyprland.conf
        sed -i 's/col.inactive_border = .*/col.inactive_border = rgba(242832aa)/' ~/.config/hypr/hyprland.conf
        hyprctl reload
        notify-send "Theme Changed" "Switched to Decay Green"
        ;;
esac
EOF

chmod +x ~/.config/hypr/scripts/theme-select.sh
```

## Step 7: Configure Services

```bash
# Enable Bluetooth
sudo systemctl enable bluetooth
sudo systemctl start bluetooth

# Enable NetworkManager (should already be enabled)
sudo systemctl enable NetworkManager
```

## Step 8: Restart Hyprland

```bash
# Either:
# 1. Logout and log back in
# 2. Or reload config: SUPER + Shift + C (not working yet? Just restart)

# Exit current session
SUPER + Delete

# Or from terminal:
hyprctl reload
```

## Step 9: Test Everything

### Test Keybinds:
- `SUPER + T` - Open terminal
- `SUPER + B` - Open Firefox
- `SUPER + A` - Open app launcher
- `SUPER + /` - Show keybindings
- `SUPER + 1-9` - Switch workspaces

### Test Waybar:
- Click on power icon - should show menu
- Click on keybinds icon - should show hints
- Click on volume - should open pavucontrol
- Click on network - should open network settings

### Test Screenshots:
- `SUPER + P` - Area screenshot
- `Print` - Full screenshot

## Step 10: Customize to Your Liking

### Change Weather Location:
```bash
vim ~/.config/waybar/scripts/weather.sh
# Change LOCATION="Windsor,ON" to your city
```

### Add More Wallpapers:
```bash
# Just add images to ~/Pictures/wallpapers/
cp /path/to/your/wallpaper.jpg ~/Pictures/wallpapers/
```

### Tweak Colors:
```bash
# Edit Hyprland config
vim ~/.config/hypr/hyprland.conf
# Look for color variables or uncomment Decay Green section

# Edit Waybar colors
vim ~/.config/waybar/style.css
```

## Troubleshooting

### Waybar not showing:
```bash
killall waybar
waybar &
```

### Wallpaper not loading:
```bash
killall hyprpaper
hyprpaper &
```

### Scripts not working:
```bash
# Make sure they're executable
chmod +x ~/.config/hypr/scripts/*.sh
chmod +x ~/.config/waybar/scripts/*.sh
```

### Weather not showing:
```bash
# Test the script
bash ~/.config/waybar/scripts/weather.sh
# Make sure you have internet connection
```

## Optional Enhancements

### Install Notification Daemon Theme:
```bash
mkdir -p ~/.config/mako
cat > ~/.config/mako/config << 'EOF'
font=JetBrains Mono 11
background-color=#1e1e2e
text-color=#cdd6f4
border-color=#89b4fa
border-size=1
border-radius=0
default-timeout=5000
EOF
```

### Install Hyprlock Theme:
```bash
mkdir -p ~/.config/hypr
cat > ~/.config/hypr/hyprlock.conf << 'EOF'
general {
    grace = 0
    hide_cursor = true
}

background {
    monitor =
    path = ~/Pictures/wallpapers/default.jpg
    blur_passes = 2
    blur_size = 3
}

input-field {
    monitor =
    size = 300, 50
    outline_thickness = 1
    dots_size = 0.2
    dots_spacing = 0.2
    outer_color = rgba(89b4faff)
    inner_color = rgba(1e1e2eff)
    font_color = rgba(cdd6f4ff)
    position = 0, -200
    halign = center
    valign = center
}

label {
    monitor =
    text = cmd[update:1000] echo "$(date +"%H:%M")"
    color = rgba(cdd6f4ff)
    font_size = 100
    font_family = JetBrains Mono
    position = 0, 200
    halign = center
    valign = center
}

label {
    monitor =
    text = Hi $USER
    color = rgba(cdd6f4ff)
    font_size = 25
    font_family = JetBrains Mono
    position = 0, 80
    halign = center
    valign = center
}
EOF
```

## You're Done! 🎉

Your minimal custom Hyprland setup is now complete with:
- ✅ Catppuccin Mocha theme
- ✅ Minimal animations and design
- ✅ Comprehensive keybinds
- ✅ Full-featured Waybar
- ✅ Wallpaper management
- ✅ Theme switching
- ✅ All your requested features

Enjoy your custom OS!
