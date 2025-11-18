# customIso_nov19 - Custom Arch ISO with Hyprland

This folder builds a **custom Arch Linux ISO** with your full Hyprland setup, themes, and configurations.

## What This Does

Builds on the **proven minimal ISO foundation** and adds:
- ✅ Custom installer (install-auto.sh)
- ✅ Post-install Hyprland setup (post-install.sh)
- ✅ All Hyprland configs and 10 themes
- ✅ All Waybar configs (3 styles)
- ✅ All custom scripts (13 utility scripts)
- ✅ VirtualBox guest additions
- ✅ Auto-installation on first login

## Prerequisites

**Before building**, make sure `custom-arch-setup/` directory exists:

```bash
cd ..
bash package-creator.sh
cd customIso_nov19
```

This syncs all your latest scripts and configs to `custom-arch-setup/`.

## Quick Start

### 1. Build the ISO

```bash
bash build-custom-iso.sh
```

**Time:** 10-15 minutes
**Output:** `iso-output/custom-arch-YYYYMMDD-HHMM.iso`

### 2. Test in VirtualBox

**Create VM:**
- Name: CustomOS
- Type: Linux
- Version: Arch Linux (64-bit)
- RAM: 4GB+ (8GB recommended)
- Disk: 50GB+ (100GB recommended)
- Graphics Controller: VMSVGA
- Video Memory: 128MB
- Enable 3D Acceleration: ✓

**Important Settings:**
- System → Motherboard → Enable EFI: ✓
- System → Processor → CPUs: 2+
- Display → Graphics Controller: VMSVGA
- Network → Adapter 1 → NAT

### 3. Boot and Install

1. **Start VM** with ISO attached
2. **Wait** for live environment to boot
3. At prompt, type: `install-arch`
4. **Follow prompts:**
   - Disk: `sda`
   - Hostname: `customos` (or your choice)
   - Username: `user` (or your choice)
   - Password: (choose one)
5. **Wait** 10-15 minutes for installation
6. **Reboot** when prompted

### 4. First Login - Auto Setup

After reboot:
1. **Login** with your username/password
2. **Wait** - the post-install script runs automatically!
3. This installs:
   - Hyprland
   - All packages (Waybar, Kitty, etc.)
   - All themes and configs
   - Takes 5-10 minutes
4. **Reboot** when complete
5. **Hyprland starts automatically!**

## What Gets Installed

### Phase 1: Base System (during install-arch)
- Base Arch Linux
- Linux kernel
- NetworkManager
- Bootloader (systemd-boot with 3 entries)
- User account with sudo
- Custom setup copied to ~/custom-setup

### Phase 2: Desktop Environment (on first login)
- Hyprland Wayland Compositor
- Waybar (status bar, 3 styles)
- Kitty (terminal)
- Wofi (app launcher)
- Mako (notifications)
- swww (wallpaper daemon)
- Firefox
- All themes and configs

## How It Works

### Installation Flow

```
Boot ISO
  ↓
Run: install-arch
  ↓
Runs: /root/custom-setup/install-auto.sh
  ↓
Installs base Arch Linux
  ↓
Copies custom-setup to ~/custom-setup
  ↓
Sets up auto-run on first login
  ↓
Reboot
  ↓
Login
  ↓
Auto-runs: ~/custom-setup/post-install.sh
  ↓
Installs Hyprland + all packages
  ↓
Copies all configs
  ↓
Applies Catppuccin Mocha theme
  ↓
Sets up Hyprland auto-start
  ↓
Reboot
  ↓
Hyprland starts automatically!
```

### Scripts Used

1. **install-auto.sh** - Base system installer
   - Partitions disk (GPT/UEFI)
   - Installs base packages
   - Configures bootloader
   - Creates user
   - Copies custom-setup

2. **post-install.sh** - Desktop installer
   - Installs Hyprland
   - Installs all packages
   - Copies all configs
   - Applies default theme
   - Sets up auto-start

3. **install.sh** - Simple wrapper
   - Can be run manually if needed

## Keybindings (After Installation)

Once Hyprland is running:

| Keybind | Action |
|---------|--------|
| `Super + T` | Terminal |
| `Super + A` | App launcher |
| `Super + Shift + T` | Theme selector (10 themes!) |
| `Super + Shift + W` | Wallpaper picker |
| `Super + /` | Show all keybindings |
| `Super + Q` | Close window |
| `Super + L` | Lock screen |

## Themes Included

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

Switch themes: `Super + Shift + T`

## Troubleshooting

### Build Issues

**Error: custom-arch-setup not found**
```bash
cd ..
bash package-creator.sh
cd customIso_nov19
bash build-custom-iso.sh
```

**Error: install-auto.sh missing**
```bash
# Make sure scripts exist in root
ls ../install-auto.sh ../post-install.sh
# If missing, they were accidentally deleted
```

### VirtualBox Issues

**ISO won't boot:**
- Enable EFI in System → Motherboard
- Set Graphics Controller to VMSVGA
- Increase RAM to 4GB+

**Installer fails:**
- Check disk name is `sda`
- Ensure internet connection (NAT network)
- Check 50GB+ disk space

**Hyprland doesn't start:**
- Check VirtualBox Guest Additions installed: `lsmod | grep vbox`
- Try reinstalling: `sudo pacman -S virtualbox-guest-utils`
- Enable service: `sudo systemctl enable vboxservice && reboot`

### Post-Install Issues

**Auto-install didn't run:**
```bash
cd ~/custom-setup
bash post-install.sh
```

**Hyprland won't start:**
```bash
# Check what went wrong
cat ~/.hyprland.log

# Try starting manually
Hyprland
```

**No internet after install:**
```bash
sudo systemctl start NetworkManager
sudo systemctl enable NetworkManager
```

## Verification Steps

After successful installation:

```bash
# Check Hyprland is installed
which Hyprland

# Check themes exist
ls ~/.config/hypr/themes/

# Check scripts exist
ls ~/.config/hypr/scripts/

# Check Waybar configs
ls ~/.config/waybar/

# Test theme switcher
~/.config/hypr/scripts/theme-select.sh
```

## File Structure

```
customIso_nov19/
├── build-custom-iso.sh       # ISO builder script
├── README.md                 # This file
└── iso-output/               # Generated ISOs (created after build)
```

## Differences from Minimal ISO

| Feature | Minimal ISO | Custom ISO |
|---------|-------------|------------|
| Base System | ✓ | ✓ |
| Hyprland | ✗ | ✓ |
| Themes | ✗ | ✓ (10 themes) |
| Custom Scripts | ✗ | ✓ (13 scripts) |
| Waybar | ✗ | ✓ (3 styles) |
| Auto-install | ✗ | ✓ |
| ISO Size | ~800MB | ~900MB |

## Next Steps After Installation

### Customize Your System

```bash
# Add more wallpapers
cp /path/to/wallpapers/* ~/Pictures/wallpapers/

# Create custom theme
cp ~/.config/hypr/themes/catppuccin-mocha.conf ~/.config/hypr/themes/my-theme.conf
vim ~/.config/hypr/themes/my-theme.conf

# Modify keybindings
vim ~/.config/hypr/hyprland.conf
```

### Install Additional Software

```bash
# Install AUR helper
sudo pacman -S --needed base-devel git
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

# Install from AUR
yay -S spotify discord
```

## Important Notes

1. **Always run package-creator.sh before building** - This ensures custom-arch-setup has latest scripts
2. **VirtualBox Guest Additions auto-install** - Detected and installed automatically
3. **Internet required** - Post-install downloads packages (or use offline ISO variant)
4. **First login takes time** - Post-install script runs, takes 5-10 minutes
5. **Hyprland auto-starts** - After reboot, Hyprland starts on TTY1

## Comparison to Previous ISO Builders

**This approach:**
- ✅ Based on proven working minimal ISO
- ✅ Simple, single build script
- ✅ Uses existing custom-arch-setup directory
- ✅ Clear separation: base install vs desktop install
- ✅ Easy to debug

**Old approach:**
- ❌ Complex multi-script system
- ❌ Package creator integrated into build
- ❌ Hard to track what's included
- ❌ Difficult to debug failures

## Success Criteria

This ISO is successful if:
- ✅ Boots in VirtualBox
- ✅ `install-arch` command works
- ✅ Base system installs without errors
- ✅ System reboots successfully
- ✅ User can login
- ✅ Post-install script runs automatically
- ✅ Hyprland installs successfully
- ✅ All themes are available
- ✅ Theme switcher works

## Support

If you encounter issues:
1. Check this README's troubleshooting section
2. Check ../VIRTUALBOX-GUIDE.md for detailed VirtualBox help
3. Check ../Basics_Nov19/README.md for minimal ISO reference
4. Verify custom-arch-setup is up to date (run package-creator.sh)

---

**Created:** Nov 19, 2025
**Purpose:** Full CustomOS with Hyprland built on proven minimal base
**Status:** Ready for testing
