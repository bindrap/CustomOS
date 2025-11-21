# CustomOS v2 - Enhanced Hyprland ISO

CustomOS v2 is a complete, polished Arch Linux ISO featuring Hyprland window manager with full font support, custom wallpapers, and VirtualBox optimizations.

## Features

### Core Components
- **Hyprland** - Modern dynamic tiling Wayland compositor
- **Waybar** - Highly customizable status bar with full icon support
- **Complete Font Stack** - JetBrains Mono, Nerd Fonts, Noto fonts, Font Awesome
- **Custom Wallpapers** - Included desktop wallpapers for personalization
- **VirtualBox Ready** - Optimized rendering with pixman renderer
- **Polished UI** - Catppuccin Mocha theme throughout

### What's New in v2
1. **Enhanced Font Support**
   - JetBrainsMono Nerd Font
   - Complete Noto font family (including CJK and Emoji)
   - Font Awesome icons
   - Ubuntu, Roboto, and GNU Free fonts
   - Custom fontconfig for optimal rendering

2. **Wallpaper System**
   - Pre-included wallpapers in `~/Pictures/wallpapers/`
   - Automatic wallpaper loading on startup
   - Easy to add your own wallpapers before building

3. **Improved Hyprland Config**
   - Auto-start Waybar, Mako, and Polkit
   - Screenshot keybindings (Print key)
   - Better keybindings for window management
   - VirtualBox-specific optimizations

4. **Enhanced Waybar**
   - Full icon support with proper font fallbacks
   - System monitoring (CPU, RAM, Temperature)
   - Network and Bluetooth status
   - Battery indicator
   - Custom power menu

## Quick Start

### Build the ISO

```bash
cd cos_nov20_v2
bash build-hyprland-iso.sh
```

The ISO will be created in `cos_nov20_v2/iso-output/`
- Filename format: `customos-v2-YYYY.MM.DD-x86_64.iso`
- Example: `customos-v2-2025.11.21-x86_64.iso`

### Add Custom Wallpapers (Optional)

Before building, add your wallpaper images to the `Wallpapers/` folder:

```bash
cp /path/to/your/wallpaper.png cos_nov20_v2/Wallpapers/
```

Supported formats: PNG, JPG, JPEG, WebP

### VirtualBox Settings

For best results in VirtualBox:
1. **Type**: Arch Linux (64-bit)
2. **RAM**: 4GB+ (8GB recommended)
3. **Disk**: 50GB+
4. **Graphics**: VMSVGA
5. **Video Memory**: 128MB
6. **EFI**: DISABLED (use BIOS mode)
7. **3D Acceleration**: DISABLED

### Installation

1. Boot the ISO in VirtualBox
2. Run: `install-arch`
3. Follow the installation wizard
4. Reboot and login
5. Hyprland will auto-start with all enhancements

## Keybindings

### Essential (Mod = ALT)
- `ALT + T` - Open terminal (Kitty)
- `ALT + Q` - Close active window
- `ALT + M` - Exit Hyprland
- `ALT + A` - Application launcher (Wofi)
- `ALT + E` - File manager (Thunar)
- `ALT + F` - Toggle fullscreen
- `ALT + Space` - Toggle floating
- `ALT + J` - Toggle split

### Screenshots
- `Print` - Area screenshot (to clipboard)
- `Shift + Print` - Fullscreen screenshot (to clipboard)
- `ALT + Print` - Screenshot to file

### Window Navigation
- `ALT + Arrow Keys` - Move focus
- `ALT + Shift + Number` - Move window to workspace

### Workspaces
- `ALT + 1-0` - Switch to workspace 1-10

### System
- `ALT + Shift + R` - Reload Waybar

## Font Configuration

CustomOS v2 includes comprehensive font support:

### Installed Fonts
- **Monospace**: JetBrainsMono Nerd Font, Roboto Mono
- **Sans-Serif**: Noto Sans, Ubuntu, DejaVu Sans
- **Serif**: Noto Serif, DejaVu Serif
- **Icons**: Font Awesome, Nerd Font Symbols
- **Emoji**: Noto Color Emoji
- **CJK**: Noto Fonts CJK (Chinese, Japanese, Korean)

### Font Rendering
- Antialiasing enabled
- Hinting: slight
- LCD filter: default
- RGBA rendering optimized

## Wallpaper Management

### Default Location
Wallpapers are stored in: `~/Pictures/wallpapers/`

### Set Wallpaper Manually
```bash
swaybg -i ~/Pictures/wallpapers/your-image.png -m fill &
```

### Auto-load on Startup
The Hyprland config automatically loads wallpapers from `~/Pictures/wallpapers/`

## VirtualBox Optimizations

CustomOS v2 includes proven VirtualBox fixes:

### Rendering
- **WLR_RENDERER=pixman** - Software rendering (tested & working)
- **WLR_NO_HARDWARE_CURSORS=1** - Fixes cursor issues
- **WLR_DRM_DEVICES=** - Ignore VirtualBox GPU

### Features
- VirtualBox guest additions auto-installed
- vboxvideo kernel module loaded
- Shared folders support
- Bidirectional clipboard
- Disabled resource-intensive effects (blur, shadows)
- Simplified animations

### Testing Commands
```bash
# Direct Hyprland launch (with VBox optimizations)
hyprland-vbox

# Multi-renderer wrapper with fallback
~/.local/bin/start-hyprland.sh

# Check logs
cat /tmp/hyprland-vbox.log
cat /tmp/hyprland-startup.log
```

## Troubleshooting

### Fonts Not Showing
```bash
# Rebuild font cache
fc-cache -fv

# List available fonts
fc-list | grep -i "jetbrains\|noto\|awesome"
```

### Waybar Icons Missing
```bash
# Check font installation
pacman -Q ttf-font-awesome ttf-jetbrains-mono-nerd

# Restart Waybar
pkill waybar && waybar &
```

### Hyprland Crashes in VirtualBox
```bash
# Use proven working config
hyprland-vbox

# Or try multi-renderer wrapper
~/.local/bin/start-hyprland.sh
```

### Wallpaper Not Loading
```bash
# Check wallpapers exist
ls ~/Pictures/wallpapers/

# Set manually
pkill swaybg
swaybg -i ~/Pictures/wallpapers/your-image.png -m fill &
```

## File Structure

```
cos_nov20_v2/
├── build-hyprland-iso.sh      # Main build script
├── build-hyprland-iso-clean.sh # Clean build script
├── Wallpapers/                 # Custom wallpapers (add yours here!)
│   └── README.md
├── iso-output/                 # Generated ISO files
├── test-iso-qemu.sh           # QEMU testing scripts
└── README.md                   # This file

custom-arch-setup/
└── dotfiles/
    ├── hypr/                   # Enhanced Hyprland config
    ├── waybar/                 # Polished Waybar config
    ├── fontconfig/             # Font configuration
    ├── kitty/                  # Terminal config
    ├── mako/                   # Notification config
    └── wofi/                   # App launcher config
```

## Building for Different Environments

### For Real Hardware
The build includes both VirtualBox optimizations and real hardware support. On real hardware, Hyprland will use hardware acceleration automatically.

### For QEMU/KVM
The same VirtualBox optimizations work well in QEMU with virtio-gpu.

### For VMware
Similar to VirtualBox, the software rendering fallback works in VMware.

## Development

### Customize Before Building
1. Edit configs in `custom-arch-setup/dotfiles/`
2. Add wallpapers to `cos_nov20_v2/Wallpapers/`
3. Modify `build-hyprland-iso.sh` for additional packages
4. Run build script

### Test in QEMU
```bash
bash test-iso-qemu.sh
```

## Credits

Built on:
- Arch Linux
- Hyprland
- Waybar
- Catppuccin theme
- JetBrains Mono font
- Font Awesome

## License

This is a custom Arch Linux distribution. Individual components retain their original licenses.

---

**CustomOS v2** - A polished Hyprland experience with fonts, wallpapers, and VirtualBox support.
