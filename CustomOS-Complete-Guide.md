# CustomOS - Complete Installation Guide
**Tags:** #arch #linux #uefi #systemd-boot #minimal
---

Getting basic stuff installed on barebones Arch Linux
Part One of starting to build custom OS

## Prerequisites
- VirtualBox VM with EFI enabled
- Arch Linux ISO (2025.11.01)
- VM Settings: 4GB RAM, 4 CPUs, 128MB Video Memory, 40GB disk

---

## Phase 1: Base Installation (40 minutes)

### Pre-Installation Checks

```bash
# Verify UEFI mode (should list files)
ls /sys/firmware/efi/efivars

# Test internet connection
ping -c 3 archlinux.org

# Update system clock
timedatectl set-ntp true
```

### Step 1: Check Current Situation

```bash
# See all disks and partitions
lsblk

# Check what's currently mounted
df -h
```

### Step 2: Unmount Everything (if needed)

```bash
# Unmount everything under /mnt
umount -R /mnt
```

### Step 3: Create Partitions (Fresh Start)

```bash
# Start partitioning tool
cfdisk /dev/sda

# If it asks, choose: gpt
```

**In cfdisk, create these partitions:**
1. New → Size: `512M` → Type: `EFI System` (becomes /dev/sda1)
2. New → Size: `4G` → Type: `Linux swap` (becomes /dev/sda2)
3. New → Size: `(remaining space)` → Type: `Linux filesystem` (becomes /dev/sda3)
4. **Write** → type `yes` → **Quit**

### Step 4: Format the Partitions

```bash
# Format EFI partition as FAT32
mkfs.fat -F32 /dev/sda1

# Setup swap
mkswap /dev/sda2
swapon /dev/sda2

# Format root partition as ext4
mkfs.ext4 /dev/sda3
```

### Step 5: Mount Correctly (CRITICAL FOR SYSTEMD-BOOT)

```bash
# Mount root partition FIRST
mount /dev/sda3 /mnt

# Create boot directory (NOT boot/efi!)
mkdir -p /mnt/boot

# Mount EFI partition at /mnt/boot (systemd-boot requirement)
mount /dev/sda1 /mnt/boot
```

**⚠️ IMPORTANT:** For systemd-boot, mount EFI at `/mnt/boot` NOT `/mnt/boot/efi`

### Step 6: Verify Before Installing

```bash
# Check mounts - should show:
# /dev/sda3 on /mnt
# /dev/sda1 on /mnt/boot
lsblk

# Should look like:
# NAME   SIZE  TYPE MOUNTPOINT
# sda     40G  disk
# ├─sda1 512M  part /mnt/boot
# ├─sda2   4G  part [SWAP]
# └─sda3  35G  part /mnt
```

### Step 7: Install Base System

```bash
# Install base packages (NO grub or efibootmgr for systemd-boot)
pacstrap /mnt base base-devel linux linux-firmware \
    vim networkmanager sudo git
```

**Packages explained:**
- `base` - Minimal Arch installation
- `base-devel` - Build tools (gcc, make, etc.)
- `linux` - Kernel
- `linux-firmware` - Hardware firmware
- `vim` - Text editor
- `networkmanager` - Network management
- `sudo` - Run commands as root
- `git` - Version control (needed for AUR)

### Step 8: Generate Filesystem Table

```bash
# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Verify fstab looks correct
cat /mnt/etc/fstab
```

### Step 9: Chroot into New System

```bash
# Enter the new system
arch-chroot /mnt
```

---

## Phase 2: System Configuration (Inside chroot)

### Step 10: Set Timezone

```bash
# Set timezone to Toronto (adjust for your location)
ln -sf /usr/share/zoneinfo/America/Toronto /etc/localtime

# Set hardware clock
hwclock --systohc
```

### Step 11: Configure Locale

```bash
# Enable US English locale
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen

# Generate locale
locale-gen

# Set system language
echo "LANG=en_US.UTF-8" > /etc/locale.conf
```

### Step 12: Set Hostname

```bash
# Set hostname (change to your preference)
echo "arch-minimal" > /etc/hostname

# Configure hosts file
cat >> /etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   arch-minimal.localdomain arch-minimal
EOF
```

Or one-liner:
```bash
echo -e "127.0.0.1   localhost\n::1         localhost\n127.0.1.1   arch-minimal" >> /etc/hosts
```

### Step 13: Set Root Password

```bash
# Set root password (you'll be prompted)
passwd
```

---

## Phase 3: Install Bootloader (systemd-boot)

### Step 14: Install systemd-boot

```bash
# Install bootloader to EFI partition
bootctl install
```

**Why systemd-boot?**
- ✅ Already included in systemd (no extra packages)
- ✅ Minimal and fast
- ✅ Simple text-based configuration
- ✅ UEFI native

**Alternatives considered:**
- GRUB2 (more complex, but more compatible)
- rEFInd (graphical, heavier)

### Step 15: Configure Bootloader

```bash
# Create loader configuration
cat > /boot/loader/loader.conf << EOF
default arch.conf
timeout 3
console-mode max
editor no
EOF
```

**Settings explained:**
- `default arch.conf` - Default boot entry
- `timeout 3` - 3 second boot menu
- `console-mode max` - Best text resolution
- `editor no` - Disable kernel parameter editing (security)

### Step 16: Create Boot Entry

```bash
# Get root partition UUID automatically
ROOT_UUID=$(blkid -s UUID -o value /dev/sda3)

# Create boot entry
cat > /boot/loader/entries/arch.conf << EOF
title   Arch Linux Minimal
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=UUID=$ROOT_UUID rw
EOF

# Verify boot entry
cat /boot/loader/entries/arch.conf
```

**Manual method if needed:**
```bash
# Get UUID manually
blkid -s UUID -o value /dev/sda3

# Create entry (replace YOUR-UUID with actual UUID)
cat > /boot/loader/entries/arch.conf << EOF
title   Arch Linux Minimal
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=UUID=YOUR-UUID-HERE rw
EOF
```

---

## Phase 4: User Setup & Final Steps

### Step 17: Enable NetworkManager

```bash
# Enable NetworkManager to start on boot
systemctl enable NetworkManager
```

### Step 18: Create User Account

```bash
# Create user and add to wheel group
useradd -m -G wheel -s /bin/bash parteek

# Set user password
passwd parteek
```

### Step 19: Enable Sudo for User

```bash
# Enable sudo for wheel group
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
```

Or manually:
```bash
EDITOR=vim visudo
# Uncomment line: %wheel ALL=(ALL:ALL) ALL
```

### Step 20: Exit and Reboot

```bash
# Exit chroot environment
exit

# Unmount all partitions
umount -R /mnt

# Reboot system
reboot
```

---

## Post-Installation Steps

### After Reboot:

1. **Remove ISO from VirtualBox:**
   - VM Settings → Storage → Optical Drive → Remove Disk
   
2. **Start VM** - should boot directly into Arch Linux

3. **Login** with your user (parteek)

### First Boot Verification:

```bash
# Test internet
ping -c 3 archlinux.org

# Update system
sudo pacman -Syu

# Install AUR helper (yay)
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ~

# Check system info
neofetch  # Install with: sudo pacman -S neofetch
```

### Take Snapshot!

**VirtualBox → Machine → Take Snapshot → "Layer 0 - Base System"**

This is your baseline! You can always revert to this clean state.

---

## Phase 5: Layer 1 - Terminal Enhancement (Optional)

```bash
# Better shell
sudo pacman -S zsh zsh-completions

# Change default shell
chsh -s /usr/bin/zsh

# Terminal multiplexer
sudo pacman -S tmux

# Better CLI tools
sudo pacman -S htop btop ranger fzf ripgrep fd bat exa
```

**Take Snapshot: "Layer 1 - Enhanced Terminal"**

---

## Phase 6: Layer 2 - GUI Foundation

```bash
# Display server
sudo pacman -S xorg-server xorg-xinit

# VirtualBox guest additions
sudo pacman -S virtualbox-guest-utils

# Enable guest additions
sudo systemctl enable vboxservice
```

**Take Snapshot: "Layer 2 - Display Server"**

---

## Phase 7: Layer 3 - Window Manager (i3)

```bash
# Install i3 window manager
sudo pacman -S i3-wm i3status i3lock dmenu

# Terminal emulator
sudo pacman -S alacritty

# Create .xinitrc
echo "exec i3" > ~/.xinitrc

# Start X
startx
```

**i3 Quick Keys:**
- `Mod+Enter` - Open terminal (Mod = Windows key)
- `Mod+d` - Open dmenu (app launcher)
- `Mod+Shift+q` - Close window
- `Mod+Shift+e` - Exit i3

**Take Snapshot: "Layer 3 - i3 Window Manager"**

---

## Phase 8: Layer 4 - Essential GUI Apps

```bash
# Web browser
sudo pacman -S firefox

# File manager
sudo pacman -S pcmanfm

# Image viewer
sudo pacman -S feh

# Fonts
sudo pacman -S ttf-dejavu ttf-liberation ttf-jetbrains-mono noto-fonts
```

**Take Snapshot: "Layer 4 - Essential Apps"**

---

## Phase 9: Layer 5 - Audio

```bash
# PipeWire audio system
sudo pacman -S pipewire pipewire-pulse pipewire-alsa

# Volume controls
sudo pacman -S pamixer pavucontrol

# Enable PipeWire
systemctl --user enable --now pipewire pipewire-pulse
```

**Take Snapshot: "Layer 5 - Audio System"**

---

## Phase 10: Layer 6 - Development Environment

```bash
# Neovim
sudo pacman -S neovim

# Terminal multiplexer
sudo pacman -S tmux

# Python development
sudo pacman -S python python-pip ipython

# Docker
sudo pacman -S docker docker-compose
sudo systemctl enable docker
sudo usermod -aG docker parteek

# Node.js
sudo pacman -S nodejs npm

# Modern CLI tools
sudo pacman -S ripgrep fd bat exa fzf tree

# Git configuration
git config --global user.name "Parteek"
git config --global user.email "your-email@example.com"
```

**Take Snapshot: "Layer 6 - Development Tools"**

---

## Phase 11: Layer 7 - Polish & Customization

```bash
# Better app launcher
sudo pacman -S rofi

# Compositor (transparency, shadows)
sudo pacman -S picom

# Screenshot tool
sudo pacman -S maim

# Notification daemon
sudo pacman -S dunst

# GTK theme
sudo pacman -S arc-gtk-theme papirus-icon-theme
```

**Configure i3 to use rofi:**
```bash
# Edit i3 config
vim ~/.config/i3/config

# Change dmenu line to:
bindsym $mod+d exec --no-startup-id rofi -show drun
```

**Take Snapshot: "Layer 7 - Polished System"**

---

## System Maintenance

### Package Management

```bash
# Update system
sudo pacman -Syu

# Install package
sudo pacman -S package-name

# Remove package
sudo pacman -R package-name

# Remove with dependencies
sudo pacman -Rns package-name

# Search packages
pacman -Ss search-term

# List installed packages
pacman -Qq
```

### AUR with yay

```bash
# Install from AUR
yay -S package-name

# Update system + AUR
yay -Syu

# Search AUR
yay -Ss search-term
```

### Clean Up

```bash
# Remove orphaned packages
sudo pacman -Rns $(pacman -Qtdq)

# Clear package cache
sudo pacman -Sc

# Check package list
pacman -Qqe > ~/pkglist.txt
```

---

## Troubleshooting

### Can't Boot After Installation

**Check:**
1. EFI enabled in VirtualBox settings
2. ISO removed from optical drive
3. Boot order: Hard Disk first

**Fix:**
```bash
# Boot from ISO, mount partitions
mount /dev/sda3 /mnt
mount /dev/sda1 /mnt/boot
arch-chroot /mnt

# Reinstall bootloader
bootctl install
```

### No Internet After Boot

```bash
# Check NetworkManager status
systemctl status NetworkManager

# Start if not running
sudo systemctl start NetworkManager

# Enable for boot
sudo systemctl enable NetworkManager

# Check connection
nmcli device status
```

### Forgot Root Password

```bash
# Boot from ISO
mount /dev/sda3 /mnt
arch-chroot /mnt
passwd  # Set new password
```

---

## Package Count Goals

- **Minimal bootable (Layer 0)**: ~150-200 packages
- **With i3 + basic GUI (Layer 3-4)**: ~300-400 packages
- **With development tools (Layer 6)**: ~500-600 packages
- **Fully polished (Layer 7)**: ~600-700 packages

Compare to:
- EndeavourOS default: ~800-1000 packages
- Full KDE Plasma: 1500+ packages

---

## Key Learnings & Notes

### systemd-boot vs GRUB

**Chose systemd-boot because:**
- Simpler configuration (plain text files)
- Faster boot times
- Already included in systemd
- UEFI native
- Perfect for minimal builds

**GRUB might be better if:**
- Need dual-boot with Windows
- Need BIOS compatibility
- Need advanced boot features

### Mount Point Matters!

**For systemd-boot:** EFI partition at `/boot`
**For GRUB:** EFI partition at `/boot/efi`

This caught us once - don't forget!

### VirtualBox Snapshots Are Essential

Take snapshots after each major layer. Makes experimentation safe and easy to revert.

---

## Next Steps & Ideas

### Future Customizations:

1. **Hyprland**: Replace i3 with Wayland compositor
2. **Custom Kernel**: Compile your own kernel
3. **Dotfiles Management**: Use GNU Stow or bare git repo
4. **Custom Scripts**: Automate your workflow
5. **Build Packages**: Create your own PKGBUILDs
6. **ISO Creation**: Build custom installation ISO
7. **Init System**: Explore alternatives (runit, s6)

### Learning Resources:

- Arch Wiki: https://wiki.archlinux.org
- r/unixporn: For inspiration
- Your EndeavourOS setup: Reference for features you want

---

## Summary

You now have a **minimal, custom Arch Linux system** that:
- ✅ Boots with UEFI + systemd-boot
- ✅ Has i3 window manager
- ✅ Includes development tools
- ✅ Is fully documented
- ✅ Can be customized layer by layer

**Total install time**: ~1-2 hours
**System knowledge gained**: Immense!

---

**Created:** 2025-11-14
**Last Updated:** 2025-11-14
**Status:** Complete Base Installation ✅
