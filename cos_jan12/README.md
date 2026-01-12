# CustomOS Jan12 - XFCE Lightweight Edition

> **Lightweight Performance**: The Jan12 edition uses XFCE desktop environment, optimized specifically for 4GB RAM laptops and low-spec hardware. Perfect for reviving older machines and light gaming.

CustomOS Jan12 is a streamlined Arch Linux ISO featuring the XFCE desktop environment, optimized for systems with limited resources while maintaining gaming capabilities.

## Philosophy: Light, Fast, Usable

**Performance First** - Every choice made to minimize resource usage:
- XFCE desktop (uses ~400MB RAM vs 1.5GB+ for modern compositors)
- Compositor disabled by default for maximum performance
- Zram swap optimized for 4GB systems
- Gaming mode scripts for enhanced FPS
- No bloat, only essentials

## Quick Start

### 1. Build the ISO

```bash
cd cos_jan12
bash build-xfce-iso.sh
```

The ISO will be created in `iso-output/`

### 2. Test in QEMU

```bash
# Test installation
bash test-iso-qemu-install.sh

# Boot installed system
bash run-installed-qemu.sh
```

### 3. Write to USB and Install

```bash
# Write to USB
sudo dd if=iso-output/pbos-xfce-lite-*.iso of=/dev/sdX bs=4M status=progress

# Boot from USB
# Run: install-arch
# Follow prompts
# After reboot: cd ~/custom-setup && bash post-install.sh
# Reboot again and enjoy!
```

## Features

### Core Components
- **XFCE** - Lightweight, stable desktop environment
- **LightDM** - Fast display manager
- **Firefox** - Web browser (optimized for 4GB RAM)
- **Thunar** - File manager with plugins
- **XFCE Terminal** - Lightweight terminal emulator
- **PulseAudio** - Audio system
- **NetworkManager** - Network management
- **Tailscale** - Secure VPN for easy remote access

### Gaming Support
- **Steam** - Game distribution platform
- **PrismLauncher** - Minecraft launcher (with Java runtime)
- **Wine** - Windows compatibility layer
- **GameMode** - Performance optimization
- **Vulkan** - Modern graphics API
- **Mesa drivers** - OpenGL/Vulkan support

### Performance Optimizations
- **Zram Swap** - Compressed RAM swap (up to 4GB)
- **No Compositor** - Disabled by default for better FPS
- **Firefox Optimization** - Limited to 2 content processes, hardware acceleration enabled
- **Gaming Mode Script** - One-command performance boost
- **Lightweight Tools** - Minimal resource usage

## Performance Tools

### pbos-optimize
Apply system performance optimizations:
```bash
pbos-optimize
```
- Reduces swappiness to 10
- Clears system cache
- Optimizes RAM usage

### gaming-mode
Enable gaming optimizations:
```bash
gaming-mode
```
- Stops unnecessary services
- Sets CPU governor to performance
- Reduces swappiness
- Clears cache

### gaming-mode-off
Disable gaming mode and return to normal:
```bash
gaming-mode-off
```
- Restarts services
- Resets CPU governor
- Restores swappiness

## System Requirements

### Minimum
- **CPU**: 64-bit processor (x86_64)
- **RAM**: 2GB (4GB recommended)
- **Disk**: 20GB free space
- **GPU**: Any with basic graphics support

### Recommended for Gaming
- **CPU**: Dual-core 2.0GHz+
- **RAM**: 4GB
- **Disk**: 50GB+ (for games)
- **GPU**: Integrated graphics or better
- **Internet**: For Steam and game downloads

## File Structure

```
cos_jan12/
├── build-xfce-iso.sh           # Main build script
├── install-auto.sh              # Auto-detect installation
├── install.sh                   # Base system installation
├── post-install.sh              # XFCE desktop setup
├── wifi-setup.sh                # WiFi connection helper
├── partition-helper-safe.sh     # Disk partitioning helper
├── iso-output/                  # Generated ISO files
├── test-iso-qemu-install.sh    # QEMU installation test
├── run-installed-qemu.sh       # Boot installed system
├── cleanup-qemu.sh             # Clean QEMU artifacts
├── list-qemu-disk.sh           # List virtual disks
└── README.md                    # This file
```

## Installation Instructions

### Step 1: Boot from ISO

1. Write ISO to USB drive
2. Boot from USB
3. Wait for PBOS login screen

### Step 2: Connect to WiFi (if needed)

```bash
setup-wifi
# Or manually:
iwctl station wlan0 connect YOUR_SSID
```

### Step 3: Install Base System

```bash
install-arch
```

Follow the prompts:
- Select disk
- Enter username and password
- Wait for installation (5-10 minutes)

### Step 4: Reboot

Remove USB and reboot:
```bash
reboot
```

### Step 5: Complete Desktop Setup

After logging in:
```bash
cd ~/custom-setup
bash post-install.sh
```

Wait for XFCE installation (10-15 minutes)

### Step 6: Final Reboot

```bash
reboot
```

XFCE will start automatically!

## Post-Installation Setup

### Enable Gaming Performance

Before gaming:
```bash
gaming-mode
```

This will:
- Optimize CPU performance
- Free up RAM
- Stop background services

After gaming:
```bash
gaming-mode-off
```

### Install More Software

```bash
# Install applications
sudo pacman -S package-name

# Popular additions:
sudo pacman -S vlc gimp inkscape discord
```

### Customize XFCE

1. Right-click desktop → Desktop Settings
2. Settings Manager → Appearance
3. Settings Manager → Window Manager
4. Settings Manager → Panel

### Setup Tailscale VPN

Tailscale is pre-installed for secure remote access and networking:

1. **Connect to Tailscale:**
   ```bash
   sudo tailscale up
   ```
   This opens a browser to authenticate with your Tailscale account

2. **Check connection status:**
   ```bash
   tailscale status
   ```

3. **Get your Tailscale IP:**
   ```bash
   tailscale ip -4
   ```

4. **Use cases:**
   - Access your laptop remotely from anywhere
   - Play LAN games over the internet (Minecraft, etc.)
   - Secure file sharing between devices
   - Remote desktop to your PBOS system

5. **Disconnect from Tailscale:**
   ```bash
   sudo tailscale down
   ```

For more info: https://tailscale.com/kb/

## Gaming Guide

### Installing Steam Games

1. Open Steam
2. Log in to your account
3. Install games as normal
4. Before playing, run `gaming-mode`

### Playing Minecraft

1. Open PrismLauncher from the applications menu
2. Add your Microsoft account
3. Install Minecraft (Java or Bedrock)
4. For best performance on 4GB RAM:
   - Allocate 2GB RAM maximum in Settings
   - Install OptiFine or Sodium mod
   - Lower render distance to 8-12 chunks
5. Run `gaming-mode` before playing

### Running Windows Games

1. Install game via Steam (Proton)
2. Or use Wine:
   ```bash
   wine game-installer.exe
   ```

### Performance Tips

1. **Disable compositor**: Already disabled by default
2. **Use gaming-mode**: Significant FPS boost
3. **Lower game settings**: Reduce graphics for better FPS
4. **Monitor resources**: Use `htop` to check RAM/CPU usage
5. **Close apps**: Close Firefox and other apps while gaming

## Firefox Optimization Details

Firefox is pre-configured for low RAM systems with these settings:

- **Content processes limited to 2** (default is 8) - Saves ~400-600MB RAM
- **Hardware acceleration enabled** - Uses GPU instead of CPU
- **Prefetching disabled** - Doesn't waste RAM on unvisited pages
- **Reduced history limit** - Keeps only 20,000 pages vs unlimited
- **Telemetry disabled** - Saves background resources

If Firefox feels slow, you can:
1. Type `about:memory` in address bar
2. Click "Minimize memory usage"
3. Close unused tabs (each tab uses ~50-100MB)

To further reduce RAM usage:
1. Type `about:config` in address bar
2. Search for `dom.ipc.processCount`
3. Set to `1` for even less RAM (but slower multitasking)

## Troubleshooting

### System Feels Slow

Run optimization:
```bash
pbos-optimize
```

Check RAM usage:
```bash
htop
# Press F3 and search: RES to sort by RAM
```

### Gaming FPS is Low

1. Enable gaming mode:
   ```bash
   gaming-mode
   ```

2. Check if compositor is disabled:
   ```bash
   xfwm4 --compositor=off
   ```

3. Lower in-game graphics settings

4. Close unnecessary applications

### WiFi Not Working

```bash
# Check WiFi device
ip link

# Connect manually
sudo nmtui

# Or use iwctl
iwctl device list
iwctl station wlan0 scan
iwctl station wlan0 get-networks
iwctl station wlan0 connect SSID
```

### No Sound

```bash
# Unmute audio
amixer sset Master unmute

# Check volume
pavucontrol
```

### Display Issues

```bash
# Check graphics drivers
lspci -k | grep -A 3 VGA

# Install additional drivers if needed
sudo pacman -S xf86-video-intel  # Intel
sudo pacman -S xf86-video-amd    # AMD
sudo pacman -S xf86-video-nouveau # NVIDIA (open source)
```

## Memory Usage Comparison

| Desktop Environment | Idle RAM Usage |
|-------------------|----------------|
| **XFCE (this)** | **~400MB** |
| KDE Plasma | ~600MB |
| GNOME | ~800MB |
| Hyprland/HyDE | ~1.5GB |

## Why Jan12?

CustomOS Jan12 is designed for **real-world usage on older hardware**:

**Target Audience:**
- Users with 4GB RAM laptops
- Students needing a fast, lightweight system
- Gamers on low-spec hardware
- Anyone wanting to revive old laptops

**Key Differences from Nov21 (HyDE edition):**
- XFCE vs Hyprland (400MB vs 1.5GB RAM)
- X11 vs Wayland (better compatibility)
- Simpler, more stable
- Better gaming performance on low-end hardware
- Ideal for laptops with integrated graphics

## Gaming Benchmarks (Expected on 4GB RAM + Intel HD Graphics)

| Game Type | Expected Performance |
|-----------|---------------------|
| **Minecraft** (Vanilla, 12 chunks) | 45-60 FPS |
| **Minecraft** (OptiFine/Sodium, 8 chunks) | 60-90 FPS |
| 2D Games (Terraria, Stardew Valley) | 60+ FPS |
| Indie Games (Hollow Knight, Celeste) | 45-60 FPS |
| Older AAA (Portal 2, Half-Life 2) | 30-60 FPS |
| Modern AAA (lowest settings) | 20-30 FPS |

## Credits

Built on:
- Arch Linux
- XFCE Desktop Environment
- LightDM
- NetworkManager
- Various open-source gaming tools

## License

This is a custom Arch Linux distribution. Individual components retain their original licenses.

---

**CustomOS Jan12** - Lightweight, fast, and gaming-capable for low-spec hardware.
