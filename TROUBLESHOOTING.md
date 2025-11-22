# CustomOS Troubleshooting Guide

Quick fixes for common issues with online ISO and Hyprland.

---

## 🔧 Common Issues & Fixes

### Issue 1: `install-arch` command not found or permission denied

**Symptoms:**
```
zsh: command not found: install-arch
# OR
zsh: permission denied: install-arch
```

**Fix:** Rebuild ISO with latest scripts
```bash
./build-iso-docker.sh
```

The latest build scripts include proper file permissions configuration.

---

### Issue 2: Hyprland crashes on startup in VirtualBox

**Symptoms:**
```
(core dumped) Hyprland
```

**Fix:** Make sure these settings are in VirtualBox:
1. VM Settings → Display → **3D Acceleration: OFF** ✅ MUST BE DISABLED
2. Video Memory: 128MB
3. Graphics Controller: VMSVGA or VBoxVGA

**Then rebuild ISO** to include VirtualBox fixes:
```bash
./build-iso-docker.sh
```

---

###Issue 3: Installation fails with "no internet connection"

**Symptoms:**
```
✗ No internet connection!
Please connect to the internet...
```

**Options:**

**A. Connect to internet:**
```bash
# Check network
ip link

# Start NetworkManager
systemctl start NetworkManager

# Connect to WiFi
nmtui
```

**B. Use offline ISO:**
```bash
# Download packages first (on system with internet)
./download-offline-packages.sh

# Build offline ISO
./build-iso-docker.sh

# ISO will work without internet
```

---

### Issue 4: Hyprland doesn't auto-start after login

**Symptoms:** Logs in but stays at terminal

**Fix:** Check .zprofile was created
```bash
# After logging in:
cat ~/.zprofile

# Should see Hyprland auto-start code
# If missing, manually start:
Hyprland
```

**Permanent fix:** Rebuild ISO with latest post-install.sh

---

### Issue 5: Black screen after Hyprland starts

**Cause:** VirtualBox 3D acceleration is enabled

**Fix:**
1. Power off VM
2. VM Settings → Display → **Uncheck "Enable 3D Acceleration"**
3. Start VM
4. Hyprland should work now

---

### Issue 6: Cannot build ISO - Docker errors

**Symptoms:**
```
✗ Docker daemon is not running!
```

**Fix:**
1. Open Docker Desktop on Windows
2. Wait for it to fully start (whale icon stops animating)
3. Try again: `./build-iso-docker.sh`

---

### Issue 7: Package installation fails during post-install

**Symptoms:**
```
error: failed to prepare transaction (could not satisfy dependencies)
```

**Cause:** Package conflicts or missing dependencies

**Fix:**
```bash
# Update package database
sudo pacman -Sy

# Try installation again
cd ~/custom-setup
./post-install.sh
```

---

### Issue 8: Offline ISO still tries to download packages

**Symptoms:** Installation asks for internet even with offline ISO

**Check:**
```bash
# In live ISO, before installation:
ls /root/custom-setup/packages/*.pkg.tar.zst | wc -l
# Should show 200+ packages

# If 0 or empty:
# - You didn't run download-offline-packages.sh
# - Packages weren't included in ISO build
```

**Fix:** Download packages and rebuild:
```bash
./download-offline-packages.sh
./build-iso-docker.sh
```

---

### Issue 9: Themes don't work

**Symptoms:** Theme switcher opens but themes don't apply

**Fix:**
```bash
# Make sure theme scripts are executable
chmod +x ~/.config/hypr/scripts/*.sh

# Try theme again
Super + Shift + T
```

---

### Issue 10: Cursor is invisible in VirtualBox

**This is normal** with `WLR_NO_HARDWARE_CURSORS=1`

The cursor still works, just hard to see.

**Workaround:**
1. Install a different cursor theme
2. Or accept it (cursor still functions)

---

## 🧪 Testing Your ISO

### Quick Test Checklist:

**In VirtualBox:**
1. ✅ Boot ISO
2. ✅ See welcome message (no errors)
3. ✅ Run: `install-arch` (no permission denied)
4. ✅ Installation completes
5. ✅ Reboot
6. ✅ Login
7. ✅ Hyprland starts automatically
8. ✅ No crashes
9. ✅ Themes work (Super + Shift + T)
10. ✅ Wallpapers work (Super + Shift + W)

---

## 🔍 Diagnostic Commands

### Check if scripts are in ISO:
```bash
# Boot ISO and check:
ls -la /usr/local/bin/install-arch
ls -la /root/custom-setup/
```

### Check if VirtualBox is detected:
```bash
lspci | grep -i virtualbox
systemd-detect-virt
```

### Check Hyprland environment:
```bash
echo $WLR_RENDERER
echo $WLR_NO_HARDWARE_CURSORS
```

### Check logs:
```bash
# System log
journalctl -xe

# Hyprland log
cat ~/.local/share/hyprland/hyprland.log
```

---

## 📝 Validation Script

Run the validation script to check all components:
```bash
./test-iso-scripts.sh
```

This will check:
- All files exist
- Scripts have correct syntax
- Permissions are correct
- All features are configured

---

## 🆘 Still Having Issues?

1. **Run validation:**
   ```bash
   ./test-iso-scripts.sh
   ```

2. **Check specific error messages** and match them to issues above

3. **Rebuild ISO** with latest scripts:
   ```bash
   ./build-iso-docker.sh
   ```

4. **Test in VirtualBox first** before real hardware

5. **Check this guide** for your specific error

---

## ✅ Prevention Checklist

Before building ISO:
- [ ] Run `./test-iso-scripts.sh` - all tests pass
- [ ] VirtualBox settings correct (3D acceleration OFF)
- [ ] Docker is running (for WSL builds)
- [ ] Enough disk space (10GB free)

Before installation:
- [ ] VM has 4GB+ RAM
- [ ] VM has 40GB+ disk
- [ ] Network configured (if online install)
- [ ] ISO is latest build

After installation:
- [ ] Remove ISO from VM
- [ ] VirtualBox 3D acceleration is OFF
- [ ] Reboot cleanly
- [ ] Login with correct credentials

---

## 🎯 Quick Fixes Summary

| Problem | Quick Fix |
|---------|-----------|
| Permission denied | Rebuild ISO |
| Hyprland crashes | Disable 3D acceleration |
| No internet | Use nmtui or offline ISO |
| Can't build | Start Docker |
| Packages fail | Update with `pacman -Sy` |
| Scripts missing | Check file locations |

---

**Most issues are fixed by rebuilding with the latest scripts!**

```bash
./build-iso-docker.sh
```
