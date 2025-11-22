# Final Checklist - Before Building ISO

**Use this checklist before building your CustomOS ISO**

---

## ✅ Pre-Build Verification

Run this to verify all fixes are in place:

```bash
cd /mnt/c/Users/bindrap/Documents/CustomOS
./test-iso-scripts.sh
```

All checks should pass.

---

## ✅ VirtualBox Configuration (CRITICAL!)

**Before testing the ISO, configure VirtualBox:**

- [ ] VM is powered OFF
- [ ] Settings → Display opened
- [ ] **3D Acceleration is UNCHECKED** ← MOST IMPORTANT!
- [ ] Video Memory set to 128MB
- [ ] Graphics Controller set to VMSVGA
- [ ] Settings saved (clicked OK)

**If you skip this, Hyprland WILL crash!**

---

## ✅ Build Process

### Step 1: Choose Your Build Method

**On WSL/Windows (Recommended):**
```bash
cd /mnt/c/Users/bindrap/Documents/CustomOS
./build-iso-docker.sh
```

**On Native Arch/Endeavour OS:**
```bash
cd ~/Documents/CustomOS
./build-iso-native.sh
```

**Emergency Backup:**
```bash
./build-iso-WORKING-BACKUP.sh
```

### Step 2: Wait for Build

- [ ] Build started successfully
- [ ] No error messages during build
- [ ] ISO created in `output/` directory
- [ ] ISO name format: `CustomOS-2025.11.17-HHMM.iso`

**Build time:** ~10-20 minutes (first time), ~5 minutes (cached)

---

## ✅ ISO Testing

### Step 1: Mount ISO in VirtualBox

- [ ] VirtualBox opened
- [ ] VM Settings → Storage
- [ ] ISO mounted to optical drive
- [ ] VM started

### Step 2: Boot and Install

- [ ] ISO boots successfully
- [ ] Welcome message appears
- [ ] NO `/root/.automated_script.sh` error
- [ ] `install-arch` command available
- [ ] Run: `install-arch`
- [ ] NO permission denied error
- [ ] Installation completes successfully

### Step 3: Post-Installation

- [ ] System reboots successfully
- [ ] Login prompt appears
- [ ] Login with created user account
- [ ] Hyprland auto-starts (or run `start-hyprland`)
- [ ] Waybar appears at top
- [ ] Desktop is functional

### Step 4: Test Hyprland

- [ ] Terminal opens with `Super + T`
- [ ] Application launcher works `Super + A`
- [ ] Theme selector works `Super + Shift + T`
- [ ] Can switch between themes
- [ ] Wallpaper picker works `Super + Shift + W`
- [ ] Windows can be moved/resized
- [ ] No crashes or core dumps

---

## ✅ Verification Commands

Once Hyprland is running, verify environment:

```bash
# Check VirtualBox detection
lspci | grep -i virtualbox
systemd-detect-virt

# Check environment variables
env | grep WLR
# Should show:
# WLR_NO_HARDWARE_CURSORS=1
# WLR_RENDERER_ALLOW_SOFTWARE=1
# WLR_RENDERER=pixman

# Test basic commands
Super + T          # Terminal
Super + A          # App launcher
Super + Shift + T  # Theme selector
Super + /          # Keybindings
```

---

## ✅ Expected Results

### ISO Boot:
- ✅ CustomOS welcome banner
- ✅ Clean boot (no automated script errors)
- ✅ `install-arch` command works

### Installation:
- ✅ Interactive installation
- ✅ User account creation
- ✅ Base system installation
- ✅ Hyprland installation
- ✅ All packages installed

### Post-Install:
- ✅ System boots
- ✅ Hyprland auto-starts
- ✅ VirtualBox compatibility automatic
- ✅ All themes working
- ✅ All keybindings functional

---

## ❌ Common Issues & Fixes

### Issue: ISO won't boot
**Fix:** Rebuild with latest scripts
```bash
./build-iso-docker.sh
```

### Issue: Permission denied on install-arch
**Fix:** Already fixed - rebuild ISO
```bash
./build-iso-docker.sh
```

### Issue: Hyprland crashes/core dumps
**Fixes:**
1. **Check VirtualBox 3D acceleration is OFF!** (90% of crashes)
2. Run manual starter: `~/start-hypr.sh`
3. Check environment: `env | grep WLR`
4. See: `EMERGENCY-HYPRLAND-FIX.md`

### Issue: Hyprland doesn't auto-start
**Fix:** Manual start
```bash
start-hyprland
# or
~/start-hypr.sh
```

### Issue: Black screen after login
**Fix:** VirtualBox 3D acceleration is likely ON
1. Power OFF VM
2. Settings → Display
3. UNCHECK 3D acceleration
4. Restart VM

---

## 📋 All Fixes Included

Your build scripts include all these fixes:

- ✅ **ISO Boot Fix** - Quote escaping in .zlogin (build-iso-docker.sh:266)
- ✅ **Permission Fix** - file_permissions array (build-iso-docker.sh:177-185)
- ✅ **Hyprland Fix** - VirtualBox environment variables (hyprland.conf:59-74)
- ✅ **Auto-start Fix** - Wrapper script with detection (post-install.sh:257-287)
- ✅ **Automated Script Fix** - Removed default script
- ✅ **Naming Fix** - Date + time in filename
- ✅ **Build Improvements** - All 8 improvements
- ✅ **Offline Support** - Complete offline capability

---

## 🚀 Ready to Build?

**Pre-flight checklist:**
- [ ] Read START-HERE.md
- [ ] VirtualBox settings configured
- [ ] Build method chosen
- [ ] Ready to wait 10-20 minutes

**Build command:**
```bash
cd /mnt/c/Users/bindrap/Documents/CustomOS
./build-iso-docker.sh
```

**After build:**
- [ ] ISO in `output/` directory
- [ ] Follow testing checklist above
- [ ] Report any issues

---

## 📚 Documentation

**Essential:**
- START-HERE.md - Quick start
- CURRENT-STATUS.md - All fixes
- This file - Testing checklist

**Detailed:**
- BUILD-GUIDE.md - Complete build guide
- VIRTUALBOX-SETUP.md - VirtualBox setup
- TROUBLESHOOTING.md - Common issues
- EMERGENCY-HYPRLAND-FIX.md - Emergency fixes

---

## ✅ Success Criteria

**Your ISO is successful when:**
1. ✅ Boots without errors
2. ✅ `install-arch` works
3. ✅ Installation completes
4. ✅ System reboots
5. ✅ Hyprland starts
6. ✅ Desktop is functional
7. ✅ Themes work
8. ✅ No crashes

**When all above are ✅, you have a working CustomOS ISO!**

---

**Ready? Run: `./build-iso-docker.sh`**
