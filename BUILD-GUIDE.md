# Custom Arch Linux ISO - Build Guide

This guide explains how to build your custom Arch Linux ISO with all the improvements.

## 📋 Available Build Methods

### 1. **WSL/Windows (Docker)** - Recommended for Windows users
### 2. **Native Linux** - Recommended for Endeavour OS/Arch users

---

## 🚀 Quick Start

### For WSL/Windows Users:

```bash
# Option A: Fast builds with cached image (recommended)
./build-docker-image.sh      # Run once to create cached image
./build-iso-docker.sh         # Build ISO (3-5 minutes)

# Option B: Without cached image (slower)
./build-iso-docker.sh         # Build ISO (10-15 minutes)
```

### For Endeavour OS/Arch Linux Users:

```bash
./build-iso-native.sh         # Build ISO (5-10 minutes)
```

---

## 🔧 Detailed Instructions

### Method 1: WSL/Windows with Docker (Improved)

**Requirements:**
- WSL 2 (Ubuntu, Debian, etc.)
- Docker Desktop for Windows

**First-time setup (optional but recommended):**

```bash
cd /mnt/c/Users/YourUsername/Documents/CustomOS

# Build the Docker image (run this ONCE)
./build-docker-image.sh
```

This creates a reusable Docker image that speeds up builds significantly:
- **Without cached image:** 10-15 minutes per build
- **With cached image:** 3-5 minutes per build

**Building the ISO:**

```bash
# Build the ISO
./build-iso-docker.sh
```

**Features:**
- ✅ Uses cached Docker image (if available)
- ✅ Persistent package cache between builds
- ✅ Parallel package downloads (10 concurrent)
- ✅ Automatic ISO validation
- ✅ Keeps only last 3 ISOs (auto-cleanup)
- ✅ Better error handling
- ✅ Fast mirrors (US/CA)

**Output:**
- ISO location: `iso-output/parteek-arch-YYYY.MM.DD.iso`
- Package cache: `~/.cache/archiso-pkgs/`
- Windows path shown in output

---

### Method 2: Native Linux (Endeavour OS/Arch)

**Requirements:**
- Endeavour OS, Arch Linux, or Arch-based distribution
- Internet connection

**Building the ISO:**

```bash
cd ~/CustomOS  # Or wherever you cloned the repo

# Build the ISO
./build-iso-native.sh
```

The script will:
1. Check and install dependencies (archiso, git)
2. Enable parallel downloads
3. Build the ISO
4. Validate the result

**Features:**
- ✅ No Docker required
- ✅ Parallel package downloads (10 concurrent)
- ✅ Automatic ISO validation
- ✅ Keeps only last 3 ISOs (auto-cleanup)
- ✅ Better error handling
- ✅ Build time tracking

**Output:**
- ISO location: `iso-output/parteek-arch-YYYY.MM.DD.iso`

---

## 📊 Build Performance Comparison

| Method | First Build | Subsequent Builds | Notes |
|--------|-------------|-------------------|-------|
| WSL (no cache) | 10-15 min | 10-15 min | Downloads everything each time |
| **WSL (cached)** | **12-15 min** | **3-5 min** | **Recommended!** |
| Native Linux | 5-10 min | 5-10 min | Fastest overall |

---

## 🎯 What's Improved?

### 1. **Build Speed**
- Docker layer caching (WSL)
- Persistent package cache
- Parallel downloads (10 concurrent)

### 2. **Reliability**
- Build validation (checks ISO format and size)
- Better error messages
- Error handling at every step

### 3. **Maintenance**
- Auto-cleanup (keeps only last 3 ISOs)
- Backup of old build script
- Clear progress indicators

### 4. **Usability**
- Detects missing dependencies
- Shows build time
- Shows Windows path for WSL builds

---

## 📁 File Structure

```
CustomOS/
├── build-iso-docker.sh          # WSL/Docker build (improved)
├── build-iso-native.sh          # Native Linux build (improved)
├── build-docker-image.sh        # Create cached Docker image
├── Dockerfile.archiso-builder   # Docker image definition
├── build-iso-docker.sh.backup   # Original script (backup)
├── custom-arch-setup/           # Your custom configurations
├── iso-output/                  # Built ISOs go here
└── ~/.cache/archiso-pkgs/       # Package cache (WSL only)
```

---

## 🛠️ Troubleshooting

### WSL/Docker Issues

**"Docker daemon is not running"**
- Start Docker Desktop on Windows
- Wait for it to fully start
- Try again

**"Permission denied"**
```bash
chmod +x build-iso-docker.sh
chmod +x build-docker-image.sh
```

**Build is slow even with cached image**
- Check if package cache is working: `ls ~/.cache/archiso-pkgs/`
- Rebuild Docker image: `./build-docker-image.sh`
- Check internet connection speed

### Native Linux Issues

**"archiso not found"**
- The script will install it automatically
- If it fails, run: `sudo pacman -S archiso`

**"Permission denied"**
```bash
chmod +x build-iso-native.sh
```

**Build fails with "No space left on device"**
- Check space in /tmp: `df -h /tmp`
- Need at least 5GB free
- Clean up: `sudo rm -rf /tmp/archiso-work`

---

## 🔄 Updating the Docker Image

If you want to update the cached Docker image (e.g., to get latest Arch packages):

```bash
./build-docker-image.sh
```

This will rebuild the image with the latest packages.

---

## 📝 Advanced Options

### Disable Package Caching (WSL)

If you want to disable package caching:

```bash
# Edit build-iso-docker.sh and remove this line:
-v "$CACHE_DIR:/var/cache/pacman/pkg" \
```

### Keep More/Fewer Old ISOs

Edit the cleanup line in the build scripts:

```bash
# Keep last 5 ISOs instead of 3
ls -t "$OUTPUT_DIR"/*.iso | tail -n +6 | xargs rm -f
```

### Use Different Mirror Countries

Edit `Dockerfile.archiso-builder` or the build scripts:

```bash
# For UK and Germany mirrors
reflector --country UK,DE --age 12 --protocol https --sort rate
```

---

## ✅ Next Steps After Building

1. **For VirtualBox:**
   - Use ISO at: `C:\Users\YourUsername\Documents\CustomOS\iso-output\parteek-arch-YYYY.MM.DD.iso`
   - Create VM, attach ISO, boot
   - Run: `install-arch`

2. **For USB Installation:**
   ```bash
   sudo dd if=iso-output/parteek-arch-*.iso of=/dev/sdX bs=4M status=progress
   # Replace /dev/sdX with your USB device (e.g., /dev/sdb)
   ```

3. **Test in VM first** before using on real hardware!

---

## 🎉 Summary

- **WSL users:** Use `build-docker-image.sh` once, then `build-iso-docker.sh`
- **Endeavour OS users:** Use `build-iso-native.sh`
- **All builds** now have validation, caching, and better error handling
- **ISO output:** `iso-output/` directory
- **Old scripts:** Backed up as `.backup` files

---

## 📞 Support

If you encounter issues:

1. Check the error message carefully
2. Review the Troubleshooting section above
3. Ensure you have internet connectivity
4. Try rebuilding the Docker image (WSL)
5. Check disk space

Happy building! 🚀
