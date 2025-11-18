# CustomOS

A custom Arch Linux-based operating system featuring a modern, minimal desktop environment with Hyprland Wayland compositor, Hyde-inspired theming system, and comprehensive customization options.

## Overview

CustomOS is a carefully curated Linux distribution built on top of Arch Linux, designed for developers and power users who want a clean, efficient, and highly customizable desktop experience. It combines the power and flexibility of Arch Linux with a modern Wayland-based desktop environment and a complete Hyde-inspired theming ecosystem.

## Features

### Core Components
- **Base System**: Arch Linux
- **Display Server**: Wayland
- **Window Manager**: Hyprland (Dynamic tiling Wayland compositor)
- **Shell**: Zsh with modern enhancements
- **Editor**: Neovim with optimized configuration

### Key Highlights
- 🚀 **Fast & Lightweight**: Minimal resource usage with maximum performance
- 🎨 **Modern UI**: Beautiful, customizable Wayland-native environment
- ⌨️ **Developer-Focused**: Pre-configured development tools and workflows
- 🔧 **Highly Customizable**: Easily modifiable configurations
- 📦 **Curated Software**: Hand-picked applications and tools
- 🔒 **Secure**: Modern security practices and minimal attack surface

### 🎨 Hyde-Inspired Features (NEW!)
- **10 Pre-configured Themes**: Catppuccin Mocha, Dracula, Nord, Tokyo Night, Gruvbox, One Dark, Rose Pine, Everforest, Solarized, Decay Green
- **Dynamic Theme Switching**: Change entire system theme with one keybind (`Super+Shift+T`)
- **Coordinated App Theming**: Themes apply to Hyprland, Waybar, Kitty, Wofi, and Mako simultaneously
- **Advanced Wallpaper Management**: Smooth transitions with swww, theme-specific wallpapers, interactive picker
- **Multiple Waybar Styles**: Minimal, Detailed, and Floating layout options
- **Complete Script Suite**: 13 utility scripts for screenshots, theming, wallpapers, recording, and more
- **Game Mode**: Toggle performance mode for gaming (`Super+G`)
- **Enhanced Animations**: Smooth, Hyde-inspired window animations and effects
- **Custom Theme Creation**: Easy-to-use theme template system

## System Requirements

### Minimum Requirements
- **CPU**: x86_64 architecture
- **RAM**: 2GB (4GB recommended)
- **Storage**: 20GB free space (40GB recommended)
- **Graphics**: Any GPU with Wayland support

### Recommended Requirements
- **CPU**: Multi-core x86_64 processor
- **RAM**: 8GB or more
- **Storage**: 60GB+ SSD
- **Graphics**: Modern GPU with proper Wayland drivers

## Installation

### Prerequisites
- UEFI system (recommended, BIOS also supported)
- Secure Boot disabled (if enabled)
- Internet connection (or use offline ISO)
- USB drive (8GB+) or VirtualBox for testing

### Testing in VirtualBox (Recommended First!)

**Want to try CustomOS without installing on real hardware?**

CustomOS works great in VirtualBox! This is the safest way to test:

```bash
# 1. Build or download the ISO
# 2. Create a new VirtualBox VM
# 3. Boot the ISO and run: install-arch
```

**See the complete guide:** [VIRTUALBOX-GUIDE.md](VIRTUALBOX-GUIDE.md)

**Recommended VM Settings:**
- RAM: 4GB+
- CPUs: 2+ cores
- Disk: 50GB+
- Graphics: VMSVGA with 3D acceleration
- VirtualBox Guest Additions: Auto-installed ✓

### Quick Start
```bash
# Download the latest ISO
curl -L -o customos.iso https://github.com/bindrap/CustomOS/releases/latest/download/customos.iso

# Create bootable USB (replace /dev/sdX with your USB device)
sudo dd if=customos.iso of=/dev/sdX bs=4M status=progress && sync
```

### Installation Steps
1. Boot from the CustomOS USB drive (or VirtualBox)
2. Run the auto-installer: `install-arch`
3. Follow the guided prompts
4. Configure user account and system settings
5. Reboot and enjoy your new system

## Default Software

### Desktop Environment
- **Hyprland**: Modern Wayland compositor with dynamic tiling
- **Waybar**: Status bar with system information (3 style variants)
- **Wofi**: Application launcher (themed)
- **Rofi (Wayland)**: Alternative launcher
- **Mako**: Notification daemon (themed)
- **Hyprlock**: Screen locker
- **swww**: Animated wallpaper daemon
- **hyprpaper**: Fallback wallpaper daemon

### Development Tools
- **Neovim**: Modern Vim-based editor with LSP support
- **Git**: Version control system
- **Base-devel**: Essential development packages
- **Docker**: Containerization platform
- **Node.js & npm**: JavaScript runtime and package manager
- **Python & pip**: Python programming

### System Utilities
- **Zsh**: Modern shell with Oh My Zsh
- **Tmux**: Terminal multiplexer
- **Btop**: System monitor
- **Ranger**: File manager
- **Firefox**: Web browser
- **Grim/Slurp**: Screenshot tools
- **wf-recorder**: Screen recording
- **hyprpicker**: Color picker
- **cliphist**: Clipboard manager

### Media & Graphics
- **MPV**: Media player
- **Imagemagick**: Image manipulation
- **imv**: Image viewer
- **Zathura**: PDF viewer

### Theming & Customization
- **python-pywal**: Color scheme generator
- **10 Pre-installed Themes**: Ready to use
- **Custom Theme System**: Easy theme creation
- **Complete Utility Scripts**: Theme, wallpaper, screenshot management

## Configuration

### Hyprland
Configuration files located in `~/.config/hypr/`
- `hyprland.conf`: Main configuration
- `themes/`: Theme definitions (10 presets)
- `colors.conf`: Current theme colors (auto-generated)
- `scripts/`: 13 utility scripts

### Waybar
Located in `~/.config/waybar/`
- `config`: Module configuration
- `style.css`: Main styling (auto-themed)
- `styles/`: 3 style variants (minimal, detailed, floating)
- `colors.css`: Current theme colors (auto-generated)

### Neovim
Configuration in `~/.config/nvim/`
- Pre-configured with popular plugins
- LSP support for multiple languages
- Custom keybindings and themes

### Zsh
- Oh My Zsh with custom theme
- Useful plugins pre-installed
- Custom aliases and functions

## Customization

CustomOS includes a complete Hyde-inspired customization system!

### Theme Switching (Interactive)
```bash
# Open theme selector with keybind
Super + Shift + T

# Or run manually
~/.config/hypr/scripts/theme-select.sh
```

### Available Themes
1. **Catppuccin Mocha** - Soothing pastel theme (default)
2. **Decay Green** - Dark with vibrant green accents
3. **Nord** - Arctic, north-bluish color palette
4. **Dracula** - Dark theme with vibrant colors
5. **Gruvbox Dark** - Retro groove color scheme
6. **Tokyo Night** - Clean, inspired by Tokyo's night sky
7. **One Dark** - Iconic Atom editor theme
8. **Rose Pine** - Natural pine with soho vibes
9. **Everforest** - Comfortable green forest theme
10. **Solarized Dark** - Precision colors

### Custom Themes
```bash
# Create your own theme
cp ~/.config/hypr/themes/catppuccin-mocha.conf ~/.config/hypr/themes/my-theme.conf
vim ~/.config/hypr/themes/my-theme.conf

# Apply it
~/.config/hypr/scripts/theme-apply.sh my-theme
```

### Wallpaper Management
```bash
# Next/Previous wallpaper
Super + Alt + Right/Left

# Random wallpaper
Super + Ctrl + W

# Interactive picker
Super + Shift + W
```

### Package Management
```bash
# Install packages with pacman
sudo pacman -S package-name

# Install AUR packages with yay
yay -S aur-package-name

# Update system
sudo pacman -Syu
```

**Full customization guide:** See [CUSTOMIZATION.md](CUSTOMIZATION.md)

## Keyboard Shortcuts

### Essential Shortcuts
- `Super + T`: Terminal
- `Super + A`: Application launcher
- `Super + E`: File manager
- `Super + B`: Web browser
- `Super + Q`: Close window
- `Super + L`: Lock screen
- `Super + /`: Keybindings help (full list)

### Theme & Wallpaper (NEW!)
- `Super + Shift + T`: Theme selector
- `Super + Shift + W`: Wallpaper picker
- `Super + Alt + Right/Left`: Next/Previous wallpaper
- `Super + Ctrl + W`: Random wallpaper

### Screenshots & Recording
- `Super + P`: Area screenshot
- `Print`: Full screenshot
- `Super + Shift + P`: Color picker
- `Super + R`: Screen recording toggle

### Workspaces
- `Super + [1-9]`: Switch workspace
- `Super + Shift + [1-9]`: Move window to workspace
- `Super + Ctrl + Right/Left`: Navigate workspaces

### Utilities
- `Super + G`: Toggle game mode
- `Super + ,`: Emoji picker
- `Ctrl + Alt + Del`: Power menu
- `Ctrl + Shift + Esc`: System monitor

**See full keybindings:** Press `Super + /` or check [CUSTOMIZATION.md](CUSTOMIZATION.md)

## Troubleshooting

### Common Issues

#### Display Issues
```bash
# Check Wayland session
echo $XDG_SESSION_TYPE

# Restart Hyprland
hyprctl reload
```

#### Theme Not Applying
```bash
# Check theme files
ls ~/.config/hypr/themes/

# Manually apply theme
~/.config/hypr/scripts/theme-apply.sh catppuccin-mocha

# Reload Hyprland
hyprctl reload
```

#### Audio Problems
```bash
# Check audio devices
pactl list short sinks

# Restart audio service
systemctl --user restart pipewire
```

#### Network Connectivity
```bash
# Check network status
nmcli device status

# Restart NetworkManager
sudo systemctl restart NetworkManager
```

### Getting Help
- Check logs: `journalctl -f`
- Hyprland wiki: [hyprland.org](https://hyprland.org)
- Arch Wiki: [wiki.archlinux.org](https://wiki.archlinux.org)
- CustomOS Docs: See CUSTOMIZATION.md and INSTALLATION.md

## Contributing

We welcome contributions! Here's how you can help:

### Development
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### Bug Reports
- Use GitHub Issues
- Include system information
- Provide reproduction steps
- Attach relevant logs

### Feature Requests
- Open a GitHub Issue
- Describe the feature clearly
- Explain the use case
- Consider implementation complexity

## Building from Source

### On Arch Linux

**Prerequisites:**
```bash
# Install build dependencies
sudo pacman -S archiso git make
```

**Build Process:**
```bash
# Clone repository
git clone https://github.com/bindrap/CustomOS.git
cd CustomOS

# Download offline packages (optional, for offline ISO)
bash create-offline-cache.sh

# Build ISO
bash build-iso.sh

# Test in VirtualBox (recommended)
# See VIRTUALBOX-GUIDE.md for complete instructions

# Or test in QEMU (quick test)
qemu-system-x86_64 -enable-kvm -m 4G -cdrom ~/iso-output/parteek-arch-*.iso
```

### On Windows (WSL) or Non-Arch Systems

If you're building from Windows WSL or another Linux distribution, use the Docker-based builder:

**Prerequisites:**
- Docker Desktop for Windows (with WSL integration enabled)
- Or Docker on Linux

**Build Process:**
```bash
# Clone repository
git clone https://github.com/bindrap/CustomOS.git
cd CustomOS

# Build ISO using Docker
bash build-iso-docker.sh

# ISO will be in: ./iso-output/parteek-arch-YYYY.MM.DD.iso
```

**Full WSL/Docker Guide:** See [BUILDING-WSL.md](BUILDING-WSL.md) for detailed instructions.

## Project Structure

```
CustomOS/
├── hyprland.conf              # Main Hyprland config
├── hypr-themes/               # 10 pre-configured themes
│   ├── catppuccin-mocha.conf
│   ├── dracula.conf
│   ├── nord.conf
│   └── ... (7 more)
├── hypr-scripts/              # 13 utility scripts
│   ├── theme-apply.sh
│   ├── theme-select.sh
│   ├── wallpaper-*.sh (4 scripts)
│   ├── screenshot-*.sh (2 scripts)
│   ├── screen-record.sh
│   ├── keybinds-hint.sh
│   ├── emoji-picker.sh
│   ├── logout-menu.sh
│   └── gamemode-toggle.sh
├── waybar-config.json         # Waybar configuration
├── waybar-style.css           # Waybar styling (auto-themed)
├── waybar-styles/             # 3 style variations
│   ├── minimal.css
│   ├── detailed.css
│   └── floating.css
├── wofi-style.css             # Wofi theming
├── package-creator.sh         # Package generator
├── create-offline-cache.sh    # Offline package downloader
├── build-iso.sh               # ISO builder
├── install-auto.sh            # Auto-installer
├── README.md                  # This file
├── CUSTOMIZATION.md           # Full customization guide
├── INSTALLATION.md            # Installation guide
└── BUILDING.md                # Build instructions
```

## Roadmap

### Version 1.0 ✅ (Complete)
- [x] Base Arch Linux system
- [x] Hyprland Wayland compositor
- [x] Essential development tools
- [x] Custom configurations

### Version 1.5 ✅ (Current - Hyde-Inspired)
- [x] 10 Pre-configured themes
- [x] Dynamic theme switching system
- [x] Wallpaper management with swww
- [x] Complete utility script suite (13 scripts)
- [x] Multiple Waybar layouts (3 variants)
- [x] Game mode optimization
- [x] Enhanced window rules & animations
- [x] Coordinated app theming (Hyprland, Waybar, Kitty, Wofi, Mako)

### Version 2.0 (Planned)
- [ ] pywal integration for auto-theming from wallpapers
- [ ] Theme preview before applying
- [ ] Dotfiles backup/restore system
- [ ] Community theme repository
- [ ] GUI theme/wallpaper manager
- [ ] Per-monitor wallpaper management

### Version 2.5 (Future)
- [ ] Automated installer GUI
- [ ] Hardware-specific ISOs
- [ ] Custom package repository
- [ ] Cloud sync for configurations
- [ ] Mobile device support

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- **Arch Linux**: The foundation of our system
- **Hyprland**: Amazing Wayland compositor
- **Hyde Project (prasanthrangan/hyprdots)**: Inspiration for theming system
- **Catppuccin**: Beautiful color schemes
- **Neovim**: Modern text editing
- **Oh My Zsh**: Shell enhancement framework
- All the open-source contributors who make this possible

## Support

- 📧 **Email**: support@customos.dev
- 💬 **Discord**: [Join our community](https://discord.gg/customos)
- 🐛 **Issues**: [GitHub Issues](https://github.com/bindrap/CustomOS/issues)
- 📖 **Wiki**: [Project Wiki](https://github.com/bindrap/CustomOS/wiki)

---

**CustomOS** - *Crafted for developers, designed for everyone. Now with Hyde-inspired theming!*

Made with ❤️ by the CustomOS team
