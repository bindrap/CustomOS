# 🚀 START HERE - Quick Build & Test Guide

**All fixes applied. Ready to build and test!**

---

## ⚠️ CRITICAL: Do This FIRST!

### Configure VirtualBox Settings

**Before anything else, configure your VirtualBox VM:**

1. **Power OFF your VM**
2. **Right-click VM → Settings → Display**
3. **UNCHECK "Enable 3D Acceleration"** ← This prevents Hyprland crashes!
4. **Set Video Memory: 128MB**
5. **Graphics Controller: VMSVGA**
6. **Click OK**

**If you skip this, Hyprland WILL crash!**

---

## 🏗️ Build the ISO

### On WSL (Windows):
```bash
cd /mnt/c/Users/bindrap/Documents/CustomOS
./build-iso-docker.sh
```

### On Native Arch/Endeavour OS:
```bash
cd ~/Documents/CustomOS
./build-iso-native.sh
```

**Build time:** ~10-20 minutes (first build), ~5 minutes (subsequent builds with cache)

**Output:** `output/CustomOS-2025.11.17-HHMM.iso`

---

## 🧪 Test the ISO

1. **In VirtualBox:** Settings → Storage → Add ISO
2. **Boot VM**
3. **Wait for welcome message**
4. **Type:** `install-arch`
5. **Follow installation prompts**
6. **Reboot when done**
7. **Login** (username you created)
8. **Hyprland should auto-start**

---

## ✅ What Should Happen

### On ISO Boot:
- ✅ CustomOS welcome banner appears
- ✅ Instructions shown
- ✅ No `/root/.automated_script.sh` error
- ✅ `install-arch` command available

### After Installation:
- ✅ System reboots successfully
- ✅ Login prompt appears
- ✅ Hyprland auto-starts on login
- ✅ Waybar appears at top
- ✅ Super+T opens terminal

---

## 🐛 If Something Goes Wrong

### ISO won't boot:
```bash
# Rebuild with backup script:
./build-iso-WORKING-BACKUP.sh
```

### Permission denied on install-arch:
```bash
# Rebuild - the fix is in place
./build-iso-docker.sh
```

### Hyprland crashes:
1. **First:** Double-check VirtualBox 3D acceleration is OFF!
2. **Try manual start:**
   ```bash
   ~/start-hypr.sh
   ```
3. **Check environment:**
   ```bash
   env | grep WLR
   ```
4. **Read:** `EMERGENCY-HYPRLAND-FIX.md`

---

## 📋 Quick Commands

### Inside Hyprland:
- `Super + T` - Open terminal
- `Super + A` - Application launcher
- `Super + Shift + T` - Theme selector
- `Super + Q` - Close window
- `Super + /` - Show all keybindings

### Hyprland Manual Start:
```bash
# If auto-start fails:
start-hyprland

# Or with diagnostics:
~/start-hypr.sh
```

---

## 📚 More Documentation

- **Build guide:** `BUILD-GUIDE.md`
- **Offline ISO:** `OFFLINE-ISO-GUIDE.md`
- **VirtualBox setup:** `VIRTUALBOX-SETUP.md`
- **Troubleshooting:** `TROUBLESHOOTING.md`
- **Emergency fixes:** `EMERGENCY-HYPRLAND-FIX.md`
- **Current status:** `CURRENT-STATUS.md`

---

## 🎯 Expected Result

**A working CustomOS ISO that:**
- Boots successfully
- Installs without errors
- Runs Hyprland in VirtualBox
- Has all 10 themes working
- Includes all customizations

---

## 🚀 Ready to Start

**Your command:**
```bash
cd /mnt/c/Users/bindrap/Documents/CustomOS
./build-iso-docker.sh
```

**That's it! Everything is fixed and ready to go.**

---

**Files you have:**
- ✅ `build-iso-docker.sh` - Main WSL builder (ALL FIXES APPLIED)
- ✅ `build-iso-native.sh` - Native Linux builder (ALL FIXES APPLIED)
- ✅ `build-iso-WORKING-BACKUP.sh` - Emergency backup
- ✅ `test-iso-scripts.sh` - Validation script

**All fixes included:**
- ✅ ISO boot failure fix (quote escaping)
- ✅ Permission denied fix (file_permissions array)
- ✅ Hyprland crash fix (VirtualBox compatibility)
- ✅ Automated script error fix
- ✅ ISO naming fix (date + time)
- ✅ All build improvements
- ✅ Offline ISO support

**Everything is ready. Just run the build command!**
