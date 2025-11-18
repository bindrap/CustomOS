# Offline ISO Build Guide - Complete Internet-Free Installation

This guide shows you how to create a **fully offline ISO** that installs CustomOS without any internet connection.

---

## 🎯 What is an Offline ISO?

An offline ISO includes all packages embedded inside it, so you can:
- ✅ Install on machines without internet
- ✅ Install faster (no downloads needed)
- ✅ Install on air-gapped systems
- ✅ Install in locations with poor connectivity
- ✅ Save bandwidth on multiple installations

**Trade-off:** ISO size increases from ~1.5GB to ~4-5GB

---

## 📋 Prerequisites

You need **ONE system with internet** to download packages:
- Endeavour OS (recommended)
- Arch Linux
- Any Arch-based distribution
- OR WSL with access to Arch repositories

---

## 🚀 Step-by-Step: Building an Offline ISO

### Step 1: Download All Packages

**On a system with internet (Endeavour OS recommended):**

```bash
cd /path/to/CustomOS

# Run the package downloader
./download-offline-packages.sh
```

This will:
- Download ~3-4 GB of packages
- Save them to `offline-packages/` directory
- Create a package database
- Take 10-30 minutes depending on your connection

**Output:**
```
offline-packages/
├── base-3.0-1-any.pkg.tar.zst
├── linux-6.17.8-1-x86_64.pkg.tar.zst
├── hyprland-0.45.0-1-x86_64.pkg.tar.zst
├── ... (hundreds more)
├── custom.db.tar.gz
├── package-list.txt
└── README.txt
```

---

### Step 2: Build the Offline ISO

**Option A: On the same system (Endeavour OS/Arch):**

```bash
# Build ISO natively
./build-iso-native.sh
```

**Option B: On WSL/Windows:**

```bash
# Build ISO with Docker
./build-iso-docker.sh
```

The build script will:
- ✅ Detect `offline-packages/` directory
- ✅ Copy all packages into the ISO
- ✅ Set offline mode flag
- ✅ Create larger ISO (~4-5 GB)

**Build output will show:**
```
→ Copying offline package cache...
  ✓ Custom setup files copied

...

ISO Details:
  File: parteek-arch-2025.11.17-1234.iso
  Size: 4.2G
  Offline support: yes    ← This confirms offline mode!
```

---

### Step 3: Test the Offline ISO

**In VirtualBox (or any VM):**

1. Create VM with the offline ISO
2. **Disconnect network** (important for testing!)
   - VM Settings → Network → Uncheck "Enable Network Adapter"
3. Boot the ISO
4. Run: `install-arch`
5. Installation should proceed **without internet**!

---

## 🔍 How Offline Installation Works

### During Base System Install (install-auto.sh):

1. **Detects** no internet connection
2. **Looks** for `/root/custom-setup/packages/`
3. **Copies** packages to `/mnt/var/cache/pacman/pkg/`
4. **Installs** base system from local cache
5. **Success** without downloading anything!

### During Post-Install (post-install.sh):

1. **Detects** no internet connection
2. **Finds** offline packages in `~/custom-setup/packages/`
3. **Creates** local pacman repository
4. **Configures** pacman to use local repo
5. **Installs** all packages (Hyprland, apps, fonts, etc.)
6. **Success** - fully configured system offline!

---

## 📊 Size Comparison

| ISO Type | Size | Download Time | Install Time | Internet Required |
|----------|------|---------------|--------------|-------------------|
| **Online ISO** | 1.5 GB | Minimal | 15-20 min | ✅ Required |
| **Offline ISO** | 4-5 GB | Full download | 10-15 min | ❌ Not needed |

**Offline ISO is bigger but installs faster!**

---

## 🎯 Use Cases for Offline ISO

### Perfect for:
- 🏢 **Enterprise deployments** - Install on many machines
- 🌍 **Remote locations** - Poor or no internet
- 🔒 **Secure environments** - Air-gapped systems
- 🎓 **Labs/Classrooms** - No need for network setup
- 💾 **USB installations** - Install anywhere
- 🚀 **Fast deployments** - No waiting for downloads

---

## 📁 What's Included in Offline Packages

### Base System:
- Linux kernel + firmware
- Base packages
- Development tools

### Desktop Environment:
- Hyprland compositor
- Waybar, Mako, Wofi
- All window manager tools

### Applications:
- Firefox browser
- Kitty terminal
- File managers (Thunar, Ranger)
- Text editors (Neovim)

### Utilities:
- Audio (PipeWire stack)
- Bluetooth (Bluez)
- Network tools
- Screenshot tools
- System monitors

### Theming:
- All 10 themes
- PyWal
- All fonts
- Icons

### Development:
- Git
- Build tools
- Python
- Zsh

**Total: ~150-200 packages**

---

## 🛠️ Customizing Package List

Edit `download-offline-packages.sh` to add/remove packages:

```bash
PACKAGES=(
    # Add your packages here
    docker
    docker-compose
    code  # VSCode

    # Or remove packages you don't need
    # (Comment out lines you don't want)
)
```

Then re-run:
```bash
./download-offline-packages.sh
./build-iso-docker.sh
```

---

## 🔄 Updating Offline Packages

To update packages for a new ISO:

```bash
# Delete old cache
rm -rf offline-packages/

# Download fresh packages
./download-offline-packages.sh

# Build new ISO
./build-iso-docker.sh
```

---

## ❓ FAQ

### Q: Can I mix online and offline installation?

**A:** Yes! The scripts auto-detect:
- If internet available → uses internet
- If no internet → uses offline packages
- Best of both worlds!

### Q: What if I'm missing a package offline?

**A:** The installation will fail. Make sure to download ALL packages you need before building the ISO.

### Q: Can I share the offline-packages folder?

**A:** Yes! You can:
1. Download once on one machine
2. Copy `offline-packages/` to USB drive
3. Use on another machine to build ISO
4. Share with others (same Arch version!)

### Q: Do offline packages expire?

**A:** Packages are version-specific. After a few months, you might need to re-download newer versions.

### Q: How do I verify offline mode works?

**A:** During installation, check output:
```
→ Detecting installation mode...
! No internet - Using offline packages (247 packages)
```

If you see this, offline mode is working!

### Q: What's the minimum disk space needed?

**A:**
- For building: ~10 GB free
  - 4-5 GB for offline-packages/
  - 4-5 GB for ISO file
  - 2-3 GB for build process
- For installation: 20 GB minimum (40 GB recommended)

---

## 🚨 Troubleshooting

### Problem: Package download fails

**Solution:**
```bash
# Clear cache and retry
rm -rf offline-packages/
./download-offline-packages.sh
```

### Problem: ISO build can't find packages

**Check:**
```bash
ls offline-packages/*.pkg.tar.zst | wc -l
# Should show 200+ packages
```

**Fix:**
```bash
# Re-download packages
./download-offline-packages.sh
```

### Problem: Installation says "package not found"

**Cause:** Package list in `download-offline-packages.sh` doesn't match `post-install.sh`

**Solution:** Make sure both scripts have the same package lists.

### Problem: Offline install fails partway through

**Check:**
1. All packages were copied to ISO:
   ```bash
   # In live ISO, before installation:
   ls /root/custom-setup/packages/*.pkg.tar.zst | wc -l
   ```

2. Package database exists:
   ```bash
   ls /root/custom-setup/packages/custom.db.tar.gz
   ```

---

## 📝 Summary

**To create offline ISO:**
1. ✅ Run `./download-offline-packages.sh` (with internet)
2. ✅ Run `./build-iso-docker.sh` or `./build-iso-native.sh`
3. ✅ Get 4-5 GB ISO with all packages included
4. ✅ Install anywhere without internet!

**Features:**
- Automatic mode detection
- Works with or without internet
- Faster installation (no downloads)
- Perfect for air-gapped systems
- Same user experience

---

## 🎉 Ready to Go!

Your offline ISO will work **exactly like the online version**, but without needing internet!

Build it once, install it anywhere! 🚀

---

**Next Steps:**

1. Download packages: `./download-offline-packages.sh`
2. Build offline ISO: `./build-iso-docker.sh`
3. Test in VirtualBox (with network disabled)
4. Use on any machine!
