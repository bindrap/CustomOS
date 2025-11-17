#!/bin/bash

# Quick Package Creator for Custom Arch Setup
# Run this script to package everything for deployment

echo "╔════════════════════════════════════════════╗"
echo "║  Custom Arch Setup - Package Creator      ║"
echo "╚════════════════════════════════════════════╝"
echo ""

# Create directory structure
echo "→ Creating directory structure..."
mkdir -p custom-arch-setup/{dotfiles/{hypr/{scripts,themes,},waybar/{scripts,styles,},wofi,kitty,mako},wallpapers}

# Copy install scripts
echo "→ Copying install scripts..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "$SCRIPT_DIR/install.sh" custom-arch-setup/ 2>/dev/null || echo "Warning: install.sh not found"
cp "$SCRIPT_DIR/install-auto.sh" custom-arch-setup/ 2>/dev/null || echo "Warning: install-auto.sh not found"
cp "$SCRIPT_DIR/post-install.sh" custom-arch-setup/ 2>/dev/null || echo "Warning: post-install.sh not found"
chmod +x custom-arch-setup/*.sh 2>/dev/null || true

# Copy all config files
echo "→ Copying Hyprland configs..."
cp hyprland.conf custom-arch-setup/dotfiles/hypr/hyprland.conf

echo "→ Copying Hyprland themes..."
cp hypr-themes/*.conf custom-arch-setup/dotfiles/hypr/themes/

# Create hyprpaper config
cat > custom-arch-setup/dotfiles/hypr/hyprpaper.conf << 'EOF'
preload = ~/Pictures/wallpapers/default.jpg
wallpaper = ,~/Pictures/wallpapers/default.jpg
splash = false
EOF

# Create hyprlock config
cat > custom-arch-setup/dotfiles/hypr/hyprlock.conf << 'EOF'
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

echo "→ Copying Hyprland scripts..."
cp hypr-scripts/*.sh custom-arch-setup/dotfiles/hypr/scripts/
chmod +x custom-arch-setup/dotfiles/hypr/scripts/*.sh

echo "→ Copying Waybar configs..."
cp waybar-config.json custom-arch-setup/dotfiles/waybar/config
cp waybar-style.css custom-arch-setup/dotfiles/waybar/style.css

echo "→ Copying Waybar style variations..."
cp waybar-styles/*.css custom-arch-setup/dotfiles/waybar/styles/

echo "→ Creating Waybar scripts..."
# Power menu script
cat > custom-arch-setup/dotfiles/waybar/scripts/power-menu.sh << 'EOF'
#!/bin/bash
~/.config/hypr/scripts/logout-menu.sh
EOF

# Weather script (placeholder)
cat > custom-arch-setup/dotfiles/waybar/scripts/weather.sh << 'EOF'
#!/bin/bash
echo '{"text": "⛅", "tooltip": "Weather data unavailable"}'
EOF

chmod +x custom-arch-setup/dotfiles/waybar/scripts/*.sh

echo "→ Creating Wofi config..."
cp wofi-style.css custom-arch-setup/dotfiles/wofi/style.css

echo "→ Creating Kitty config..."
cat > custom-arch-setup/dotfiles/kitty/kitty.conf << 'EOF'
# Kitty Configuration - Auto-themed
include current-theme.conf

# Font configuration
font_family JetBrains Mono Nerd Font
bold_font auto
italic_font auto
bold_italic_font auto
font_size 11.0

# Window configuration
window_padding_width 4
confirm_os_window_close 0
background_opacity 0.95

# Tab bar
tab_bar_style powerline
tab_powerline_style slanted

# Performance
repaint_delay 10
input_delay 3
sync_to_monitor yes
EOF

echo "→ Creating Mako config..."
cat > custom-arch-setup/dotfiles/mako/config << 'EOF'
# Mako notification config - Will be auto-themed
font=JetBrains Mono Nerd Font 11
background-color=#1e1e2e
text-color=#cdd6f4
border-color=#89b4fa
border-size=2
border-radius=4
default-timeout=5000
max-visible=5
layer=overlay
anchor=top-right
margin=10
padding=10
width=350
height=150

[urgency=high]
border-color=#f38ba8
default-timeout=0
EOF

echo "→ Adding sample wallpaper..."
echo "Download wallpapers manually to custom-arch-setup/wallpapers/"

echo "→ Creating README..."
cat > custom-arch-setup/README.md << 'EOF'
# Parteek's CustomOS - Hyprland Setup

Complete Hyprland environment with 10 themes, Hyde-inspired customization system.

## 🚀 Installation

### Automatic (Should run on first login)
This script should run automatically when you log in for the first time.

### Manual (If auto-install didn't work)
```bash
cd ~/custom-setup
bash post-install.sh
```

This will:
- Install all packages (Hyprland, Waybar, themes, etc.)
- Copy all configurations
- Apply Catppuccin Mocha theme
- Set up auto-start for Hyprland

**Takes 5-10 minutes with internet connection.**

## ✨ Features After Setup
- Hyprland Wayland Compositor
- 10 Pre-configured Themes
- Complete Waybar with 3 style variants
- Hyde-inspired customization system
- All utility scripts

## ⌨️ Essential Keybinds
- `SUPER + T` - Terminal
- `SUPER + A` - App Launcher
- `SUPER + Shift + T` - Theme Selector (10 themes!)
- `SUPER + Shift + W` - Wallpaper Picker
- `SUPER + /` - Show All Keybindings
- `SUPER + Q` - Close Window
- `SUPER + L` - Lock Screen

## 🎨 Available Themes
1. Catppuccin Mocha (default)
2. Dracula
3. Nord
4. Tokyo Night
5. Gruvbox Dark
6. One Dark
7. Rose Pine
8. Everforest
9. Solarized Dark
10. Decay Green

**Switch themes:** `SUPER + Shift + T`

---

**Created by Parteek** ✨
EOF

# Create package
echo "→ Creating tarball..."
tar -czf parteek-custom-arch.tar.gz custom-arch-setup/

echo ""
echo "✓ Package created successfully!"
echo ""
echo "Files created:"
echo "  📁 custom-arch-setup/     - Full package directory"
echo "  📦 parteek-custom-arch.tar.gz - Compressed package"
echo ""
echo "Next steps:"
echo "  1. Copy to USB: cp parteek-custom-arch.tar.gz /path/to/usb/"
echo "  2. Or push to GitHub: cd custom-arch-setup && git init"
echo "  3. Or include in ISO using archiso"
echo ""
echo "On new system, extract and run:"
echo "  tar -xzf parteek-custom-arch.tar.gz"
echo "  cd custom-arch-setup"
echo "  ./install.sh"
