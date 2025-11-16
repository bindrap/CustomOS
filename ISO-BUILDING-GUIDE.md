# CustomOS ISO Building Guide

Complete guide to building a bootable CustomOS ISO that you can take anywhere.

---

## 📋 Table of Contents

1. [Understanding the Build Process](#understanding-the-build-process)
2. [Prerequisites](#prerequisites)
3. [Quick Start](#quick-start)
4. [Detailed Build Process](#detailed-build-process)
5. [Package Management](#package-management)
6. [Creating the USB](#creating-the-usb)
7. [Customizing Your ISO](#customizing-your-iso)
8. [Troubleshooting](#troubleshooting)

---

## 🔍 Understanding the Build Process

### How archiso Works

**You DO NOT need a base Arch Linux ISO!**

The `archiso` tool builds ISOs from scratch using:

1. **Package Repository**: Downloads packages directly from Arch Linux mirrors
2. **Custom Configs**: Your configurations (Hyprland, themes, scripts)
3. **Installation Scripts**: Automated installer scripts
4. **Live Environment**: Minimal bootable system with installer

### Build Stages

```
┌─────────────────────────────────────────────────────┐
│ 1. PREPARATION                                      │
│    - Install archiso tools                         │
│    - Download packages (optional: offline cache)   │
│    - Prepare custom configs                        │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│ 2. ARCHISO PROFILE SETUP                            │
│    - Copy base archiso profile (releng)            │
│    - Add custom packages list                      │
│    - Inject configurations and scripts             │
│    - Configure boot parameters                     │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│ 3. BUILD ISO                                        │
│    - Download packages from mirrors                │
│    - Create squashfs filesystem                    │
│    - Build bootable ISO image                      │
│    - Sign and verify                               │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│ 4. OUTPUT                                           │
│    - Bootable .iso file                            │
│    - Ready to write to USB                         │
│    - Can boot on any x86_64 computer               │
└─────────────────────────────────────────────────────┘
```

---

## ✅ Prerequisites

### System Requirements

**Host System** (where you build the ISO):
- Arch Linux (recommended) or Arch-based distro
- 10GB free disk space
- Internet connection (for downloading packages)
- Root/sudo access

**Target System** (where you'll install):
- x86_64 CPU (Intel/AMD 64-bit)
- 2GB+ RAM
- 20GB+ storage
- UEFI or BIOS boot support

### Install Required Tools

On your **Arch Linux build system**:

```bash
# Install archiso
sudo pacman -S archiso

# Install optional tools
sudo pacman -S git wget rsync
```

---

## 🚀 Quick Start

### Option 1: Online-Only ISO (Fastest)

```bash
# 1. Clone the repository
git clone https://github.com/bindrap/CustomOS.git
cd CustomOS

# 2. Create package
bash package-creator.sh

# 3. Build ISO (10-15 minutes)
bash build-iso.sh

# 4. Find your ISO
ls -lh ~/iso-output/
```

Your ISO will be in `~/iso-output/parteek-arch-YYYY.MM.DD.iso`

### Option 2: Offline-Capable ISO (Recommended)

```bash
# 1. Clone repository
git clone https://github.com/bindrap/CustomOS.git
cd CustomOS

# 2. Download offline packages (~2-3GB, takes 30-60 min)
bash create-offline-cache.sh

# 3. Create package
bash package-creator.sh

# 4. Build ISO (includes offline packages)
bash build-iso.sh

# 5. Find your ISO
ls -lh ~/iso-output/
```

Your ISO will be larger but works without internet!

---

## 📦 Detailed Build Process

### Step 1: Prepare Custom Setup

```bash
# This creates the deployment package
bash package-creator.sh
```

**What it does:**
- Creates `custom-arch-setup/` directory
- Copies all configurations:
  - Hyprland config + 10 themes
  - 13 utility scripts
  - Waybar configs (3 styles)
  - Wofi, Kitty, Mako configs
- Creates installation scripts
- Packages everything into `parteek-custom-arch.tar.gz`

**Output:**
```
custom-arch-setup/
├── dotfiles/
│   ├── hypr/
│   │   ├── hyprland.conf
│   │   ├── themes/ (10 themes)
│   │   └── scripts/ (13 scripts)
│   ├── waybar/
│   │   ├── config
│   │   ├── style.css
│   │   └── styles/ (3 variants)
│   ├── wofi/
│   ├── kitty/
│   └── mako/
├── wallpapers/
└── install.sh
```

### Step 2: Create Offline Cache (Optional)

```bash
# Download ~80 packages (2-3GB)
bash create-offline-cache.sh
```

**What it does:**
- Downloads all required packages from Arch mirrors
- Creates local package cache in `~/offline-packages/`
- Includes: Hyprland, Waybar, swww, themes, dev tools, etc.
- Creates package database for offline installation

**Why offline mode?**
- ✅ Install without internet
- ✅ Faster installation (no downloads)
- ✅ Consistent package versions
- ✅ Works in restricted networks
- ❌ Larger ISO size (~3-4GB vs ~800MB)

### Step 3: Build the ISO

```bash
bash build-iso.sh
```

**What happens:**

1. **Checks dependencies** - Installs archiso if needed
2. **Copies archiso profile** - Uses `/usr/share/archiso/configs/releng`
3. **Injects custom setup** - Adds your configs and scripts
4. **Adds offline packages** - If available
5. **Customizes boot** - Adds welcome message and `install-arch` command
6. **Builds ISO** - Creates bootable image with `mkarchiso`
7. **Outputs ISO** - Saves to `~/iso-output/`

**Build time:**
- Online ISO: 10-15 minutes
- Offline ISO: 15-20 minutes

**ISO Details:**
```
Name: parteek-arch-2025.01.15.iso
Size: 800MB (online) / 3.5GB (offline)
Type: Bootable x86_64 ISO
Boot: UEFI + BIOS compatible
```

---

## 📦 Package Management

### Understanding the Package System

CustomOS uses a **package list file** that makes it easy to add/remove packages.

### Package List Location

```
create-offline-cache.sh   # Main package list (lines 24-142)
```

### Adding Packages

**1. Edit the package list:**

```bash
vim create-offline-cache.sh
```

**2. Add your packages to the array:**

```bash
PACKAGES=(
    # ... existing packages ...

    # YOUR CUSTOM PACKAGES
    your-package-name
    another-package

    # Example: Add gaming tools
    steam
    lutris
    wine

    # Example: Add graphics tools
    gimp
    inkscape
    blender
)
```

**3. Rebuild offline cache:**

```bash
bash create-offline-cache.sh
```

**4. Rebuild ISO:**

```bash
bash build-iso.sh
```

### Removing Packages

**1. Edit the package list:**

```bash
vim create-offline-cache.sh
```

**2. Comment out or delete packages:**

```bash
PACKAGES=(
    # ... packages ...

    # Comment out packages you don't want
    # docker
    # docker-compose

    # Or delete the line completely
)
```

**3. Rebuild:**

```bash
bash create-offline-cache.sh
bash build-iso.sh
```

### Current Package Categories

Your CustomOS includes:

```
Base System (7 packages)
├── base, base-devel
├── linux, linux-firmware
├── vim, networkmanager, sudo, git

Wayland & Hyprland (5 packages)
├── wayland, wayland-protocols
├── hyprland, xorg-xwayland
└── virtualbox-guest-utils (optional)

Hyprland Tools (7 packages)
├── hyprpaper, hyprlock, hypridle
├── swww (wallpaper daemon)
├── waybar, mako
└── wofi, rofi-wayland

Terminal (3 packages)
├── kitty
└── zsh, zsh-completions

File Managers (2 packages)
├── thunar
└── ranger

Audio (7 packages)
├── pipewire, pipewire-pulse, pipewire-alsa
├── wireplumber
├── pamixer, pavucontrol
└── playerctl

Bluetooth (3 packages)
├── bluez, bluez-utils
└── blueman

Screenshots & Recording (7 packages)
├── grim, slurp, hyprpicker
├── wl-clipboard, cliphist
├── wf-recorder
└── imagemagick

System Monitoring (2 packages)
├── btop
└── htop

Utilities (11 packages)
├── brightnessctl
├── curl, wget
├── jq, unzip, zip, tree
└── ... more

Fonts (6 packages)
├── ttf-jetbrains-mono
├── ttf-font-awesome
├── noto-fonts, noto-fonts-emoji
└── ... more

Viewers (3 packages)
├── imv (images)
├── zathura, zathura-pdf-mupdf (PDF)
└── ... more

Development (13 packages)
├── neovim
├── python, python-pip
├── nodejs, npm
├── docker, docker-compose
├── tmux, ripgrep, fd, bat, exa, fzf

Theming (2 packages)
├── python-pywal
└── python-pillow

Eye Candy (2 packages)
├── cava
└── pipes.sh

Total: ~80 packages
```

### Creating a Separate Package List File

For easier management, let's create a dedicated package file:

```bash
# I'll create this for you next
```

---

## 💾 Creating the USB

### Find Your USB Device

```bash
# List all disks
lsblk

# Example output:
# NAME   SIZE TYPE
# sda    1.8T disk    <- Your hard drive
# sdb     16G disk    <- Your USB drive
# └─sdb1  16G part
```

**⚠️ WARNING:** Make sure you identify the correct device! The wrong device will be erased!

### Write ISO to USB

**Method 1: Using dd (Linux/Mac)**

```bash
# Replace /dev/sdX with your USB device
sudo dd if=~/iso-output/parteek-arch-*.iso of=/dev/sdX bs=4M status=progress && sync

# Example:
sudo dd if=~/iso-output/parteek-arch-2025.01.15.iso of=/dev/sdb bs=4M status=progress && sync
```

**Method 2: Using Etcher (All platforms)**

1. Download Etcher: https://www.balena.io/etcher/
2. Select ISO file
3. Select USB drive
4. Click "Flash!"

**Method 3: Using Ventoy (Recommended)**

Ventoy lets you have multiple ISOs on one USB!

```bash
# Install Ventoy once on USB
sudo sh Ventoy2Disk.sh -i /dev/sdX

# Then just copy ISOs to USB
cp ~/iso-output/parteek-arch-*.iso /media/Ventoy/
```

### Boot from USB

1. **Insert USB** into target computer
2. **Reboot** computer
3. **Enter boot menu**:
   - Dell: F12
   - HP: F9 or Esc
   - Lenovo: F12
   - ASUS: F8 or Esc
   - Generic: F12, F8, F10, or Del
4. **Select USB drive**
5. **Boot to CustomOS**

---

## 🎨 Customizing Your ISO

### Add Your Own Wallpapers

```bash
# Add wallpapers before building
mkdir -p custom-arch-setup/wallpapers/catppuccin-mocha
cp ~/my-wallpapers/*.jpg custom-arch-setup/wallpapers/catppuccin-mocha/

# Then build ISO
bash build-iso.sh
```

### Modify Boot Message

Edit the welcome message in `build-iso.sh`:

```bash
vim build-iso.sh

# Find the section around line 104
# Modify the ASCII art and text
```

### Change Default Theme

Edit `hyprland.conf` before building:

```bash
vim hyprland.conf

# Change the default theme in exec-once
exec-once = $scrPath/theme-apply.sh tokyo-night  # Change this
```

### Add Pre-installed Software

Edit the live environment packages:

```bash
vim build-iso.sh

# Around line 158, add packages
cat >> packages.x86_64 << 'EOF'
# Your packages
firefox
vlc
libreoffice
EOF
```

### Customize Installer

Edit `install-auto.sh` to change:
- Default timezone (line 178)
- Default locale (line 182)
- Partition scheme (line 129)
- Additional setup steps

---

## 🔧 Troubleshooting

### Build Errors

**Error: "archiso command not found"**
```bash
# Install archiso
sudo pacman -S archiso
```

**Error: "No space left on device"**
```bash
# Clean up old builds
sudo rm -rf ~/archiso-work
rm -rf ~/iso-output/*.iso

# Free up space
sudo pacman -Scc
```

**Error: "Failed to download packages"**
```bash
# Update mirror list
sudo pacman -Sy

# Or refresh mirrors
sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

### USB Boot Issues

**USB not booting:**
- Check BIOS boot order
- Disable Secure Boot
- Try different USB port
- Recreate USB with different tool

**Boots to black screen:**
- Try adding boot parameter: `nomodeset`
- Press 'e' in GRUB, add to linux line
- For NVIDIA: add `nvidia-drm.modeset=1`

### Installation Issues

**No internet during install:**
- Use offline ISO (include offline cache)
- Or connect ethernet cable
- Or use USB tethering from phone

**Disk not found:**
- Check disk with `lsblk`
- May need different drivers
- Try different USB port for disk

---

## 📊 Build Comparison

| Feature | Online ISO | Offline ISO |
|---------|-----------|-------------|
| Size | ~800MB | ~3.5GB |
| Build Time | 10-15 min | 15-20 min |
| Install Requires Internet | Yes | No |
| Install Time | 15-20 min | 10-15 min |
| Package Updates | Always latest | Fixed versions |
| Use Case | Personal use | Deployment, restricted networks |

---

## 🎯 Complete Workflow

### One-Time Setup (Building Environment)

```bash
# 1. Set up build environment (one time)
sudo pacman -S archiso git

# 2. Clone repository
git clone https://github.com/bindrap/CustomOS.git
cd CustomOS
```

### Every Time You Want to Build

```bash
# Online ISO (quick)
bash package-creator.sh && bash build-iso.sh

# Offline ISO (full-featured)
bash create-offline-cache.sh && bash package-creator.sh && bash build-iso.sh
```

### Using the ISO

```bash
# 1. Write to USB
sudo dd if=~/iso-output/parteek-arch-*.iso of=/dev/sdX bs=4M status=progress && sync

# 2. Boot from USB
# 3. Run: install-arch
# 4. Answer questions
# 5. Wait 15-20 minutes
# 6. Reboot
# 7. Enjoy CustomOS with all Hyde features!
```

---

## 📝 Notes

- **ISO is portable**: Works on any x86_64 computer
- **Reproducible**: Same ISO = same system every time
- **Customizable**: Modify any part before building
- **Updates**: Rebuild ISO monthly for latest packages
- **Sharing**: ISO can be shared with others (same configs)
- **Multi-boot**: Can coexist with other OSes

---

## 🎓 Advanced Topics

### Creating Multiple Variants

```bash
# Gaming variant
vim create-offline-cache.sh  # Add steam, lutris, etc.
bash create-offline-cache.sh
bash build-iso.sh
mv ~/iso-output/*.iso ~/iso-output/customos-gaming.iso

# Development variant
vim create-offline-cache.sh  # Add IDEs, compilers, etc.
bash create-offline-cache.sh
bash build-iso.sh
mv ~/iso-output/*.iso ~/iso-output/customos-dev.iso
```

### Automated Builds

```bash
# Create a build script
cat > build-all.sh << 'EOF'
#!/bin/bash
bash create-offline-cache.sh
bash package-creator.sh
bash build-iso.sh

# Sign ISO
gpg --detach-sign ~/iso-output/*.iso

# Create checksum
sha256sum ~/iso-output/*.iso > ~/iso-output/SHA256SUMS
EOF

chmod +x build-all.sh
```

### CI/CD Integration

Add to GitHub Actions:

```yaml
name: Build ISO
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    container: archlinux
    steps:
      - uses: actions/checkout@v2
      - run: pacman -Syu --noconfirm archiso
      - run: bash build-iso.sh
      - uses: actions/upload-artifact@v2
        with:
          name: customos-iso
          path: ~/iso-output/*.iso
```

---

**Ready to build your portable CustomOS? Start with the Quick Start section! 🚀**
