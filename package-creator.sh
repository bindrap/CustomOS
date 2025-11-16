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

# Copy install script
echo "→ Copying install script..."
cp /home/claude/install.sh custom-arch-setup/
chmod +x custom-arch-setup/install.sh

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
# Parteek's Custom Arch Linux Setup

Automated Hyprland configuration with Catppuccin Mocha theme.

## Quick Install

```bash
chmod +x install.sh
./install.sh
```

## Features
- Minimal Hyprland with Catppuccin Mocha
- Complete Waybar with system monitoring
- Pre-configured keybinds
- One-command installation

## Keybinds
- `SUPER + T` - Terminal
- `SUPER + B` - Browser
- `SUPER + A` - App Launcher
- `SUPER + /` - Keybindings Help
- `SUPER + L` - Lock Screen

Created by Parteek
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
