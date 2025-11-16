# CustomOS - Quick Start Guide

**TL;DR:** Build a bootable USB with all your Hyde-themed Hyprland configs in under 30 minutes!

---

## 🚀 Fastest Path to Bootable USB

### Option 1: Online ISO (800MB, Fast)

```bash
# On any Arch Linux machine
sudo pacman -S archiso
git clone https://github.com/bindrap/CustomOS.git
cd CustomOS
bash package-creator.sh
bash build-iso.sh

# Write to USB
sudo dd if=~/iso-output/*.iso of=/dev/sdX bs=4M status=progress && sync
```

**Time:** ~15 minutes total

### Option 2: Offline ISO (3.5GB, Full-Featured)

```bash
bash create-offline-cache.sh  # 30-60 min
bash package-creator.sh
bash build-iso.sh
sudo dd if=~/iso-output/*.iso of=/dev/sdX bs=4M status=progress && sync
```

**Time:** ~60 minutes total

---

## 🎯 What You Get

Your USB will have a **complete, bootable Arch Linux** with:

✅ **10 Pre-configured Themes**
✅ **Hyprland with Hyde features**
✅ **Automated Installer**
✅ **13 Utility Scripts**
✅ **All Configs Ready**

---

## 📦 Quick Package Management

```bash
# Interactive menu
bash manage-packages.sh

# Add packages
bash manage-packages.sh add steam

# Gaming preset
bash manage-packages.sh presets  # Select 2
```

---

## 🔧 Build Process

**You DON'T need a base Arch ISO!**

archiso builds from scratch:
1. Install archiso
2. Downloads packages
3. Bundles configs
4. Creates ISO

---

## 💾 Using the ISO

1. Boot from USB
2. Run: `install-arch`
3. Answer 4 questions
4. Wait 15-20 minutes
5. Reboot → **Done!**

---

**Full guides:**
- `ISO-BUILDING-GUIDE.md` - Complete build documentation
- `CUSTOMIZATION.md` - Theme & customization guide
- `README.md` - Full feature list
