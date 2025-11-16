# CustomOS

A custom Arch Linux-based operating system featuring a modern, minimal desktop environment with Hyprland Wayland compositor, Neovim, and Zsh.

## Overview

CustomOS is a carefully curated Linux distribution built on top of Arch Linux, designed for developers and power users who want a clean, efficient, and highly customizable desktop experience. It combines the power and flexibility of Arch Linux with a modern Wayland-based desktop environment.

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
- UEFI system (recommended)
- Secure Boot disabled (if enabled)
- Internet connection
- USB drive (8GB+)

### Quick Start
```bash
# Download the latest ISO
curl -L -o customos.iso https://github.com/bindrap/CustomOS/releases/latest/download/customos.iso

# Create bootable USB (replace /dev/sdX with your USB device)
sudo dd if=customos.iso of=/dev/sdX bs=4M status=progress && sync
```

### Installation Steps
1. Boot from the CustomOS USB drive
2. Follow the guided installer
3. Configure user account and system settings
4. Reboot and enjoy your new system

## Default Software

### Desktop Environment
- **Hyprland**: Modern Wayland compositor with dynamic tiling
- **Waybar**: Status bar with system information
- **Wofi**: Application launcher
- **Mako**: Notification daemon
- **Swaylock**: Screen locker

### Development Tools
- **Neovim**: Modern Vim-based editor with LSP support
- **Git**: Version control system
- **Base-devel**: Essential development packages
- **Docker**: Containerization platform
- **Node.js & npm**: JavaScript runtime and package manager

### System Utilities
- **Zsh**: Modern shell with Oh My Zsh
- **Tmux**: Terminal multiplexer
- **Btop**: System monitor
- **Ranger**: File manager
- **Firefox**: Web browser

### Media & Graphics
- **MPV**: Media player
- **Imagemagick**: Image manipulation
- **GIMP**: Image editor (optional)

## Configuration

### Hyprland
Configuration files located in `~/.config/hypr/`
- `hyprland.conf`: Main configuration
- `keybinds.conf`: Keyboard shortcuts
- `startup.conf`: Startup applications

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

### Themes
```bash
# Change Hyprland theme
hyprctl keyword general:col.active_border "rgb(ff6b6b)"

# Update Waybar theme
vim ~/.config/waybar/style.css
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

### Adding Software
```bash
# Essential development tools
sudo pacman -S code rust golang python

# Media tools
sudo pacman -S obs-studio blender

# Gaming
sudo pacman -S steam lutris
```

## Keyboard Shortcuts

### Hyprland Default Bindings
- `Super + Return`: Open terminal
- `Super + D`: Application launcher
- `Super + Q`: Close window
- `Super + M`: Exit Hyprland
- `Super + V`: Toggle floating
- `Super + F`: Toggle fullscreen
- `Super + [1-9]`: Switch workspace
- `Super + Shift + [1-9]`: Move window to workspace

### Custom Shortcuts
- `Super + E`: File manager
- `Super + B`: Web browser
- `Super + L`: Lock screen
- `Print`: Screenshot

## Troubleshooting

### Common Issues

#### Display Issues
```bash
# Check Wayland session
echo $XDG_SESSION_TYPE

# Restart Hyprland
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

### Prerequisites
```bash
# Install build dependencies
sudo pacman -S archiso git make
```

### Build Process
```bash
# Clone repository
git clone https://github.com/bindrap/CustomOS.git
cd CustomOS

# Build ISO
sudo make build

# Test in VM (optional)
make test-vm
```

## Project Structure

```
CustomOS/
├── airootfs/           # Root filesystem overlay
├── packages/           # Package lists
├── configs/            # Configuration files
│   ├── hyprland/      # Hyprland configs
│   ├── neovim/        # Neovim configs
│   └── zsh/           # Zsh configs
├── scripts/            # Installation and setup scripts
├── docs/              # Documentation
├── Makefile           # Build automation
└── README.md          # This file
```

## Roadmap

### Version 1.0 (Current)
- [x] Base Arch Linux system
- [x] Hyprland Wayland compositor
- [x] Essential development tools
- [x] Custom configurations

### Version 1.1 (Planned)
- [ ] Automated installer GUI
- [ ] Additional themes
- [ ] Gaming optimizations
- [ ] Hardware-specific ISOs

### Version 2.0 (Future)
- [ ] Custom package repository
- [ ] System update mechanism
- [ ] Cloud sync for dotfiles
- [ ] Mobile device support

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- **Arch Linux**: The foundation of our system
- **Hyprland**: Amazing Wayland compositor
- **Neovim**: Modern text editing
- **Oh My Zsh**: Shell enhancement framework
- All the open-source contributors who make this possible

## Support

- 📧 **Email**: support@customos.dev
- 💬 **Discord**: [Join our community](https://discord.gg/customos)
- 🐛 **Issues**: [GitHub Issues](https://github.com/bindrap/CustomOS/issues)
- 📖 **Wiki**: [Project Wiki](https://github.com/bindrap/CustomOS/wiki)

---

**CustomOS** - *Crafted for developers, designed for everyone.*

Made with ❤️ by the CustomOS team