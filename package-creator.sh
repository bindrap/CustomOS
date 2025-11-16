#!/bin/bash

# Quick Package Creator for Custom Arch Setup
# Run this script to package everything for deployment

echo "╔════════════════════════════════════════════╗"
echo "║  Custom Arch Setup - Package Creator      ║"
echo "╚════════════════════════════════════════════╝"
echo ""

# Create directory structure
echo "→ Creating directory structure..."
mkdir -p custom-arch-setup/{dotfiles/{hypr/{scripts,},waybar/{scripts,},kitty,mako},wallpapers}

# Copy install script
echo "→ Copying install script..."
cp /home/claude/install.sh custom-arch-setup/
chmod +x custom-arch-setup/install.sh

# Copy all config files
echo "→ Copying Hyprland configs..."
cp /home/claude/hyprland.conf custom-arch-setup/dotfiles/hypr/hyprland.conf

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
cp /home/claude/power-menu.sh custom-arch-setup/dotfiles/hypr/scripts/
cp /home/claude/weather.sh custom-arch-setup/dotfiles/hypr/scripts/

# Create additional scripts from installation guide
cat > custom-arch-setup/dotfiles/hypr/scripts/keybinds-hint.sh << 'EOF'
#!/bin/bash
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
SUPER + Shift + 1-9 : Move Window
SUPER + Arrow Keys : Move Focus
SUPER + Shift + Arrows : Resize
KEYBINDS
)
echo "$keybinds" | wofi --dmenu --prompt "Keybindings" --width 500 --height 400
EOF

cat > custom-arch-setup/dotfiles/hypr/scripts/wallpaper-next.sh << 'EOF'
#!/bin/bash
WALLPAPER_DIR=~/Pictures/wallpapers
WALLPAPERS=($(ls $WALLPAPER_DIR/*.{jpg,png} 2>/dev/null))
CURRENT=$(hyprctl hyprpaper listloaded | head -1)
INDEX=0
for i in "${!WALLPAPERS[@]}"; do
    [[ "${WALLPAPERS[$i]}" == "$CURRENT" ]] && INDEX=$(( (i + 1) % ${#WALLPAPERS[@]} ))
done
hyprctl hyprpaper unload "$CURRENT"
hyprctl hyprpaper preload "${WALLPAPERS[$INDEX]}"
hyprctl hyprpaper wallpaper ",${WALLPAPERS[$INDEX]}"
EOF

cat > custom-arch-setup/dotfiles/hypr/scripts/wallpaper-prev.sh << 'EOF'
#!/bin/bash
WALLPAPER_DIR=~/Pictures/wallpapers
WALLPAPERS=($(ls $WALLPAPER_DIR/*.{jpg,png} 2>/dev/null))
CURRENT=$(hyprctl hyprpaper listloaded | head -1)
INDEX=0
for i in "${!WALLPAPERS[@]}"; do
    [[ "${WALLPAPERS[$i]}" == "$CURRENT" ]] && INDEX=$(( (i - 1 + ${#WALLPAPERS[@]}) % ${#WALLPAPERS[@]} ))
done
hyprctl hyprpaper unload "$CURRENT"
hyprctl hyprpaper preload "${WALLPAPERS[$INDEX]}"
hyprctl hyprpaper wallpaper ",${WALLPAPERS[$INDEX]}"
EOF

cat > custom-arch-setup/dotfiles/hypr/scripts/wallpaper-select.sh << 'EOF'
#!/bin/bash
WALLPAPER_DIR=~/Pictures/wallpapers
selected=$(ls $WALLPAPER_DIR/*.{jpg,png} 2>/dev/null | xargs -n 1 basename | wofi --dmenu --prompt "Wallpaper")
if [ -n "$selected" ]; then
    CURRENT=$(hyprctl hyprpaper listloaded | head -1)
    hyprctl hyprpaper unload "$CURRENT"
    hyprctl hyprpaper preload "$WALLPAPER_DIR/$selected"
    hyprctl hyprpaper wallpaper ",$WALLPAPER_DIR/$selected"
fi
EOF

cat > custom-arch-setup/dotfiles/hypr/scripts/theme-select.sh << 'EOF'
#!/bin/bash
themes="Catppuccin Mocha\nDecay Green\nCancel"
chosen=$(echo -e "$themes" | wofi --dmenu --prompt "Theme")
case "$chosen" in
    "Catppuccin Mocha")
        sed -i 's/col.active_border = .*/col.active_border = rgba(89b4faff) rgba(cba6f7ff) 45deg/' ~/.config/hypr/hyprland.conf
        sed -i 's/col.inactive_border = .*/col.inactive_border = rgba(313244aa)/' ~/.config/hypr/hyprland.conf
        hyprctl reload && notify-send "Theme" "Switched to Catppuccin Mocha"
        ;;
    "Decay Green")
        sed -i 's/col.active_border = .*/col.active_border = rgba(90ceaaff) rgba(78dba9ff) 45deg/' ~/.config/hypr/hyprland.conf
        sed -i 's/col.inactive_border = .*/col.inactive_border = rgba(242832aa)/' ~/.config/hypr/hyprland.conf
        hyprctl reload && notify-send "Theme" "Switched to Decay Green"
        ;;
esac
EOF

chmod +x custom-arch-setup/dotfiles/hypr/scripts/*.sh

echo "→ Copying Waybar configs..."
cp /home/claude/waybar-config.json custom-arch-setup/dotfiles/waybar/config
cp /home/claude/waybar-style.css custom-arch-setup/dotfiles/waybar/style.css

# Move scripts to waybar
mv custom-arch-setup/dotfiles/hypr/scripts/power-menu.sh custom-arch-setup/dotfiles/waybar/scripts/
mv custom-arch-setup/dotfiles/hypr/scripts/weather.sh custom-arch-setup/dotfiles/waybar/scripts/
chmod +x custom-arch-setup/dotfiles/waybar/scripts/*.sh

echo "→ Creating Kitty config..."
cat > custom-arch-setup/dotfiles/kitty/kitty.conf << 'EOF'
# Catppuccin Mocha
background #1e1e2e
foreground #cdd6f4
font_family JetBrains Mono
font_size 11.0
window_padding_width 4
confirm_os_window_close 0
tab_bar_style powerline
cursor #f5e0dc
cursor_text_color #1e1e2e
selection_foreground #1e1e2e
selection_background #f5e0dc
EOF

echo "→ Creating Mako config..."
cat > custom-arch-setup/dotfiles/mako/config << 'EOF'
font=JetBrains Mono 11
background-color=#1e1e2e
text-color=#cdd6f4
border-color=#89b4fa
border-size=1
border-radius=0
default-timeout=5000
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
