# 🚀 Quick Start: Create Your Custom Arch Linux ISO

## Complete 3-Step Process

### Step 1: Package Your Setup (5 minutes)

```bash
cd /home/claude

# Make scripts executable
chmod +x *.sh

# Create the package
./package-creator.sh
```

**Output:** `custom-arch-setup/` directory with all your configs

---

### Step 2: Download Offline Packages (15 minutes - Optional)

**Skip this if you only want online installation.**

```bash
# Download all packages for offline installation
./create-offline-cache.sh
```

**Output:** `~/offline-packages/` (~1.5GB of packages)

This enables:
- ✅ Installation without internet
- ✅ Faster installation (no downloads)
- ✅ Same package versions every time

---

### Step 3: Build the ISO (15 minutes)

```bash
# Build the custom ISO
./build-iso.sh
```

**Output:** `~/iso-output/parteek-arch-YYYY.MM.DD.iso`

---

## Write ISO to USB

```bash
# Find your USB device
lsblk

# Write ISO (replace sdX with your USB device!)
sudo dd if=~/iso-output/parteek-arch-*.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

---

## Use Your Custom ISO

### Boot the USB and you'll see:

```
╔══════════════════════════════════════════════╗
║  Parteek's Custom Arch Linux                 ║
║                                              ║
║  AUTOMATED INSTALLATION:                     ║
║                                              ║
║    Run: install-arch                         ║
║                                              ║
╚══════════════════════════════════════════════╝
```

### Installation Process:

```bash
# Just type:
install-arch

# Answer 5 questions:
# 1. Which disk? sda
# 2. Hostname? arch-custom
# 3. Username? parteek
# 4. Password? ********
# 5. Confirm? yes

# Then wait 15-20 minutes...
# Installation complete!
# Reboot
```

### After Reboot:

1. Login as your user
2. Hyprland auto-starts
3. Fully configured system ready to use!

---

## What You Get

### Included in ISO:
- ✅ Arch Linux base system installer
- ✅ Your Hyprland configuration
- ✅ Catppuccin Mocha theme
- ✅ Complete Waybar setup
- ✅ All helper scripts
- ✅ Wallpapers
- ✅ Automated installation script
- ✅ (Optional) Offline package cache

### Installation Features:
- ✅ Auto-detects online/offline mode
- ✅ Automatic disk partitioning
- ✅ Automatic package installation
- ✅ Automatic configuration deployment
- ✅ No manual configuration needed
- ✅ Works on any x86_64 computer

---

## File Locations Reference

```
/home/claude/
├── package-creator.sh          # Creates deployment package
├── create-offline-cache.sh     # Downloads packages for offline
├── build-iso.sh                # Builds the ISO
├── install-auto.sh             # Auto-detect installer
├── install.sh                  # Online installer
├── hyprland.conf              # Your Hyprland config
├── waybar-config.json         # Waybar modules
├── waybar-style.css           # Waybar theme
├── power-menu.sh              # Power menu script
├── weather.sh                 # Weather module
└── ISO-EXPLAINED.md           # Detailed explanation

After running scripts:
~/custom-arch-setup/           # Packaged setup
~/offline-packages/            # Downloaded packages
~/iso-output/                  # Built ISO file
```

---

## Troubleshooting

### "Package not found" during offline install
**Solution:** Run `create-offline-cache.sh` before building ISO

### ISO build fails
**Solution:** 
```bash
# Install archiso
sudo pacman -S archiso

# Clean and retry
sudo rm -rf ~/archiso-work
./build-iso.sh
```

### USB boot doesn't work
**Solution:**
```bash
# Try a different USB write method
sudo cp ~/iso-output/parteek-arch-*.iso /dev/sdX
sync
```

### Installation fails on new computer
**Solution:**
- Check disk name (might be nvme0n1 instead of sda)
- Ensure you have internet if using online mode
- Try offline mode if available

---

## Customization

### Change Colors
Edit `~/custom-arch-setup/dotfiles/hypr/hyprland.conf`
Then rebuild ISO with `./build-iso.sh`

### Add More Packages
Edit `create-offline-cache.sh`, add packages to PACKAGES array
Then re-run `create-offline-cache.sh` and `build-iso.sh`

### Change Wallpapers
Add images to `~/custom-arch-setup/wallpapers/`
Then rebuild ISO

---

## Maintenance

### Update Your ISO

When you make changes to your system:

```bash
# 1. Update package
cd ~/custom-arch-setup
cp ~/.config/hypr/hyprland.conf dotfiles/hypr/
cp ~/.config/waybar/config dotfiles/waybar/
# ... copy other changed files

# 2. Rebuild ISO
cd /home/claude
./build-iso.sh

# 3. New ISO is ready!
```

---

## Deployment Scenarios

### Scenario 1: New Desktop PC (Ethernet)
```
1. Boot USB
2. Run: install-arch
3. Choose online mode (automatic)
4. Wait 20 minutes
5. Reboot - Done!
```

### Scenario 2: Laptop (No WiFi driver in live environment)
```
1. Boot USB
2. Run: install-arch
3. Uses offline packages (automatic)
4. Wait 15 minutes
5. Reboot - Done!
6. Connect to WiFi after boot
```

### Scenario 3: Multiple Computers
```
Use same USB on every computer
Each gets identical setup
15-20 minutes per machine
No configuration needed
```

---

## Complete Timeline

```
Create ISO (one time):
├── Package setup:      5 min
├── Download packages:  15 min (optional)
├── Build ISO:          15 min
└── Write to USB:       5 min
Total:                  20-40 min

Deploy on new machine:
├── Boot USB:           1 min
├── Run installer:      1 min
├── Installation:       15 min (online) or 10 min (offline)
└── First boot:         2 min
Total:                  15-20 min

Manual install:         2-3 hours
Your custom ISO:        15-20 min
Time saved:            85%+ faster!
```

---

## What Makes This Special

### Compared to standard Arch install:
- ❌ Manual: Hours of configuration
- ✅ Your ISO: Minutes, automated

### Compared to other Arch-based distros:
- ❌ Others: Not YOUR exact setup
- ✅ Your ISO: Exactly what you configured

### Compared to EndeavourOS/Manjaro:
- ❌ Their config, their choices
- ✅ Your config, your choices, your workflow

### Compared to dotfiles repo:
- ❌ Still need to install packages manually
- ✅ Everything automated, packages included

---

## Next Steps

Ready to create your ISO? Here's what to do:

```bash
# 1. Package everything
./package-creator.sh

# 2. (Optional) Download offline packages
./create-offline-cache.sh

# 3. Build ISO
./build-iso.sh

# 4. Write to USB
sudo dd if=~/iso-output/parteek-arch-*.iso of=/dev/sdX bs=4M status=progress

# 5. Boot on any computer and run: install-arch
```

**That's it! You now have a professional-grade custom Arch Linux distribution! 🎉**

---

## Advanced: GitHub + ISO Hybrid

For the ultimate setup:

```bash
# 1. Build ISO (for offline/quick installs)
./build-iso.sh

# 2. Push configs to GitHub (for updates)
cd ~/custom-arch-setup
git init
git add .
git commit -m "My custom Arch setup"
git push origin main

# Now you have:
# - ISO for fast deployment
# - GitHub for easy updates
# - Best of both worlds!
```

---

## Support

Created by: Parteek
Purpose: Custom minimal Arch Linux with Hyprland
License: Personal use

Enjoy your custom OS! 🚀
