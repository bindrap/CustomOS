# CustomOS Nov21 - Simplified Hyprland ISO

> **HyDE transition:** The Nov21 flow now installs the upstream HyDE desktop environment directly. The old dotfile-sync workflow (local `dotfiles/`, rsync push/pull, VM verification) is no longer used. HyDE manages configuration during installation, so skip dotfile transfers when using this profile.

CustomOS Nov21 is a streamlined, easy-to-customize Arch Linux ISO featuring Hyprland window manager. All configuration files are pre-built and easily editable before ISO creation.

## Philosophy: Simple & Editable

**Everything is a file** - No complex heredocs, no embedded scripts. Just edit the files directly:
- `install-auto.sh` - Main installation script (handles disk partitioning)
- `install.sh` - Base system installation
- `post-install.sh` - Hyprland and desktop environment setup
- `dotfiles/` - All Hyprland, Waybar, and application configs
- `build-hyprland-iso.sh` - Simple ISO builder that copies these files

## Quick Start

### 1. Build the ISO

```bash
cd cos_nov21
bash build-hyprland-iso.sh
```

The ISO will be created in `iso-output/`

### Re-run post-install without rebuilding the ISO

You can run the HyDE post-install script directly on an existing Arch install (or the system you installed from this ISO) without rebuilding:

```bash
sudo pacman -S --needed git
git clone https://github.com/HyDE-Project/CustomOS.git ~/CustomOS
cd ~/CustomOS/cos_nov21
chmod +x post-install.sh
./post-install.sh
```

> Tip: If you already have this repo on the installed system (e.g., copied from the ISO), you can simply `cd /path/to/cos_nov21` and run `./post-install.sh` again. The script is idempotent and will refresh HyDE/Chaotic-AUR if needed.

> Missing dependency warnings (e.g., `qt5-base`, `mangohud`, `hyprpicker`) during HyDE setup are now auto-installed by `post-install.sh`. If you saw those messages in a previous run, just rerun `./post-install.sh` and it will pull in the packages before invoking the HyDE installer.

> HyDE UI fixes: `post-install.sh` now installs the HyDE font stack (JetBrains Mono Nerd Font, Noto, Font Awesome) and sets the bar selection to Waybar before running the installer to avoid the "hyprland-unknown-bar-service" startup error. Rerun the script if you previously saw missing fonts or that service failure.

> Performance extras: the post-install now installs the CachyOS kernel (`linux-cachyos` + headers) and enables a zram swap device (zstd, up to 8GB or half of RAM) for smoother Wayland multitasking.

### 2. Test in QEMU

```bash
# Test installation
bash test-iso-qemu-install.sh

# Boot installed system
bash run-installed-qemu.sh
```

### 3. Customize Before Building

Want to change something? Just edit the files:

```bash
# Edit Hyprland config
vim dotfiles/hypr/hyprland.conf

# Edit post-install script
vim post-install.sh

# Add wallpapers
cp ~/my-wallpaper.png wallpapers/

# Rebuild ISO
bash build-hyprland-iso.sh
```

## Features

### Core Components
- **Hyprland** - Modern dynamic tiling Wayland compositor
- **Waybar** - Customizable status bar
- **Kitty** - GPU-accelerated terminal
- **Wofi** - Application launcher
- **Mako** - Notification daemon
- **Complete Font Stack** - JetBrains Mono Nerd Font, Noto fonts, Font Awesome

### Keybindings (Mod = ALT)

**Essential:**
- `ALT + T` - Open terminal (Kitty)
- `ALT + Q` - Close active window
- `ALT + M` - Exit Hyprland
- `ALT + A` - Application launcher (Wofi)
- `ALT + E` - File manager (Thunar)
- `ALT + F` - Toggle fullscreen
- `ALT + Space` - Toggle floating

**Screenshots:**
- `Print` - Area screenshot (to clipboard)
- `Shift + Print` - Fullscreen screenshot (to clipboard)
- `ALT + Print` - Screenshot to file

**Window Navigation:**
- `ALT + Arrow Keys` - Move focus
- `ALT + Shift + Number` - Move window to workspace

**Workspaces:**
- `ALT + 1-0` - Switch to workspace 1-10

**System:**
- `ALT + Shift + R` - Reload Waybar

## File Structure

```
cos_nov21/
├── build-hyprland-iso.sh      # Main build script
├── install-auto.sh             # Auto-detect online/offline installation
├── install.sh                  # Base system installation
├── post-install.sh             # Desktop environment setup
├── dotfiles/                   # All configuration files
│   ├── hypr/                   # Hyprland config
│   │   └── hyprland.conf       # Main Hyprland config (edit freely!)
│   ├── waybar/                 # Waybar config & styles
│   │   ├── config              # Waybar configuration
│   │   └── style.css           # Waybar styling
│   ├── fontconfig/             # Font configuration
│   │   └── fonts.conf
│   ├── kitty/                  # Terminal config
│   │   └── kitty.conf
│   ├── mako/                   # Notification config
│   │   └── config
│   └── wofi/                   # App launcher config
│       └── style.css
├── wallpapers/                 # Custom wallpapers (add yours!)
│   └── README.md
├── iso-output/                 # Generated ISO files
├── test-iso-qemu-install.sh   # QEMU installation test
├── run-installed-qemu.sh      # Boot installed system
├── cleanup-qemu.sh            # Clean up QEMU disks
├── list-qemu-disk.sh          # List virtual disks
└── README.md                   # This file
```

## QEMU Testing Scripts

### test-iso-qemu-install.sh
Test the ISO installation in QEMU:
- Creates a 50GB virtual disk
- Boots from ISO
- Allows full installation testing
- Can boot installed system after installation

```bash
bash test-iso-qemu-install.sh
```

### run-installed-qemu.sh
Quick boot of the installed system:
- SSH access on port 2222
- Shared folder support
- Faster than reinstalling each time

```bash
bash run-installed-qemu.sh
```

### list-qemu-disk.sh
List all virtual disks and their sizes:

```bash
bash list-qemu-disk.sh
```

### cleanup-qemu.sh
Delete all virtual disks and test artifacts:

```bash
bash cleanup-qemu.sh
```

## Customization Guide

### Change Keybindings

Edit `dotfiles/hypr/hyprland.conf`:

```bash
# Find the keybindings section (around line 117)
bind = $mod, T, exec, $terminal

# Change to whatever you want:
bind = $mod, Return, exec, $terminal
```

### Change Theme Colors

Edit `dotfiles/waybar/style.css` for Waybar colors:

```css
* {
    /* Change colors here */
}
```

Edit `dotfiles/hypr/hyprland.conf` for border colors:

```
col.active_border = rgba(89b4faee)
col.inactive_border = rgba(595959aa)
```

### Add More Packages

Edit `post-install.sh` and add to the `PACKAGES` array:

```bash
PACKAGES=(
    # ... existing packages ...
    "firefox"
    "your-package-here"
)
```

### Add Wallpapers

Simply copy wallpapers to the `wallpapers/` folder before building:

```bash
cp ~/Downloads/*.png wallpapers/
bash build-hyprland-iso.sh
```

### Change Terminal

Edit `dotfiles/hypr/hyprland.conf`:

```bash
$terminal = kitty  # Change to: alacritty, foot, etc.
```

Don't forget to add the terminal package to `post-install.sh`!

## Installation Instructions

### In VirtualBox

1. **Create VM:**
   - Type: Arch Linux (64-bit)
   - RAM: 4GB+ (8GB recommended)
   - Disk: 50GB+
   - Graphics: VMSVGA
   - Video Memory: 128MB
   - **EFI: DISABLED** (use BIOS mode)
   - **3D Acceleration: DISABLED**

2. **Boot ISO:**
   - Attach the ISO to the VM
   - Start the VM

3. **Install:**
   ```bash
   install-arch
   ```

4. **Follow prompts:**
   - Select disk
   - Enter username and password
   - Wait for installation to complete

5. **Reboot:**
   - Remove ISO
   - Reboot
   - Login
   - Hyprland will auto-start

### In QEMU

Use the provided test scripts:

```bash
bash test-iso-qemu-install.sh
```

### On Real Hardware

1. **Write ISO to USB:**
   ```bash
   sudo dd if=iso-output/customos-nov21-*.iso of=/dev/sdX bs=4M status=progress
   ```

2. **Boot from USB**

3. **Run:**
   ```bash
   install-arch
   ```

## Troubleshooting

### ALT+T Not Working

Check `dotfiles/hypr/hyprland.conf`:

```bash
$mod = ALT  # Make sure this is set correctly

bind = $mod, T, exec, $terminal  # Make sure this binding exists
```

### No Wallpaper

Add wallpapers to `wallpapers/` folder before building:

```bash
cp ~/my-wallpaper.png wallpapers/
```

Or set manually after installation:

```bash
swaybg -i ~/Pictures/wallpapers/your-image.png &
```

### Fonts Not Showing

Rebuild font cache:

```bash
fc-cache -fv
```

### Hyprland Won't Start

Check logs:

```bash
cat /tmp/hypr/$(ls -t /tmp/hypr/ | head -1)/hyprland.log
```

### ISO Build Fails

Make sure Docker is running:

```bash
sudo systemctl start docker
docker info
```

## Development Workflow

1. **Edit configs:**
   ```bash
   vim dotfiles/hypr/hyprland.conf
   vim post-install.sh
   ```

2. **Test in QEMU:**
   ```bash
   bash build-hyprland-iso.sh
   bash test-iso-qemu-install.sh
   ```

3. **Iterate:**
   - Make changes to files
   - Rebuild ISO
   - Test again
   - No need to clean up - scripts handle everything

## Why Nov21?

CustomOS Nov21 is a **complete rewrite** focused on simplicity:

**Before (cos_nov20_v2):**
- Complex heredocs within heredocs
- Embedded scripts in build files
- Hard to edit without breaking syntax
- Syntax errors from special characters

**After (cos_nov21):**
- Everything is a separate file
- Easy to edit with any text editor
- No heredoc issues
- No syntax surprises
- Clear separation of concerns

**Goal:** Make it easy to customize and maintain without losing any functionality.

## Git Workflow

All development is on the `claude/cos-nov20-v2-iso-01EWMpEE2HUFHYEiRLKmksbQ` branch.

To commit changes:

```bash
cd /home/user/CustomOS
git add cos_nov21/
git commit -m "CustomOS Nov21: Simplified build structure"
git push -u origin claude/cos-nov20-v2-iso-01EWMpEE2HUFHYEiRLKmksbQ
```

## Credits

Built on:
- Arch Linux
- Hyprland
- Waybar
- Catppuccin theme
- JetBrains Mono Nerd Font
- Font Awesome

## License

This is a custom Arch Linux distribution. Individual components retain their original licenses.

---

**CustomOS Nov21** - Simple, clean, and easy to customize.
