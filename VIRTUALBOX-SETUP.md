# VirtualBox Setup Guide for CustomOS

This guide explains how CustomOS is configured to work perfectly in VirtualBox.

## 🎯 Automatic VirtualBox Detection

CustomOS automatically detects when it's running in VirtualBox and configures itself accordingly!

---

## ✅ What's Configured Automatically

### 1. **VirtualBox Guest Utilities** (Auto-installed)
- Detects VirtualBox environment during installation
- Installs `virtualbox-guest-utils` package
- Enables `vboxservice` systemd service
- Provides clipboard sharing, better graphics, and window resizing

**Location:** `custom-arch-setup/post-install.sh` (lines 127-137)

### 2. **Hyprland Environment Variables** (Multi-layer protection)

#### Layer 1: Shell Profile (`.zprofile`)
Sets environment variables before Hyprland starts:
```bash
export WLR_NO_HARDWARE_CURSORS=1
export WLR_RENDERER_ALLOW_SOFTWARE=1
export WLR_RENDERER=pixman
```

**Location:** `custom-arch-setup/post-install.sh` (lines 200-206)

#### Layer 2: Hyprland Config
Also set directly in Hyprland configuration:
```conf
env = WLR_NO_HARDWARE_CURSORS,1
env = WLR_RENDERER_ALLOW_SOFTWARE,1
env = WLR_RENDERER,pixman
```

**Location:** `custom-arch-setup/dotfiles/hypr/hyprland.conf` (lines 61-63)

---

## 🔧 What These Settings Do

| Setting | Purpose |
|---------|---------|
| `WLR_NO_HARDWARE_CURSORS=1` | Disables hardware cursor (VirtualBox doesn't support it) |
| `WLR_RENDERER_ALLOW_SOFTWARE=1` | Allows software rendering fallback |
| `WLR_RENDERER=pixman` | Forces software renderer (prevents GPU crashes) |

---

## 📋 VirtualBox VM Recommended Settings

### Basic Settings:
- **Type:** Linux
- **Version:** Arch Linux (64-bit)
- **RAM:** 4GB minimum (8GB recommended)
- **CPUs:** 2-4 cores
- **Disk:** 40GB+

### Display Settings:
- **Video Memory:** 128MB
- **Graphics Controller:** VMSVGA or VBoxVGA
- **3D Acceleration:** ❌ **DISABLED** (important!)
- **Scale Factor:** 100%

### System Settings:
- **Enable EFI:** ✅ Enabled
- **Nested Paging:** ✅ Enabled
- **PAE/NX:** ✅ Enabled

---

## 🚀 Installation Process

1. **Create VM** with recommended settings above
2. **Attach ISO** to optical drive
3. **Boot VM**
4. **Run:** `install-arch`
5. **Wait** for installation (15-20 minutes)
6. **Remove ISO** from VM settings
7. **Reboot**
8. **Login** with your user credentials
9. **Hyprland starts automatically!** ✨

---

## ✨ What Works in VirtualBox

### ✅ Fully Working:
- Hyprland compositor
- Waybar status bar
- All keybindings
- Theme switching (all 10 themes)
- Wallpaper changing
- Wofi/Rofi launchers
- Firefox
- Kitty terminal
- File managers
- All custom scripts
- Clipboard integration (with guest additions)
- Window resizing (with guest additions)

### ⚠️ Limited Functionality:
- GPU acceleration (uses software rendering)
- Some visual effects may be slower
- Screen recording might be choppy

### ❌ Not Available:
- Hardware-accelerated video decode
- Some OpenGL features

---

## 🐛 Troubleshooting

### Problem: Hyprland crashes on startup

**Solution 1:** Make sure 3D acceleration is **DISABLED**
```
VM Settings → Display → 3D Acceleration: ❌
```

**Solution 2:** Verify environment variables are set
```bash
# After login, before Hyprland starts:
echo $WLR_RENDERER  # Should show: pixman
```

**Solution 3:** Rebuild ISO with latest fixes
```bash
./build-iso-docker.sh
```

---

### Problem: Cursor not visible

This is normal with `WLR_NO_HARDWARE_CURSORS=1`. The cursor should still work, just might be harder to see.

**Workaround:** Change cursor theme in Hyprland settings

---

### Problem: Screen resolution won't change

**Solution:** Install VirtualBox guest additions
```bash
sudo pacman -S virtualbox-guest-utils
sudo systemctl enable vboxservice
sudo systemctl start vboxservice
reboot
```

This should be automatic if you used our ISO!

---

### Problem: Clipboard sharing doesn't work

**Check:**
1. Guest additions are installed: `pacman -Q virtualbox-guest-utils`
2. Service is running: `systemctl status vboxservice`
3. VM settings: Devices → Shared Clipboard → Bidirectional

---

## 📊 Performance Tips

### For Better Performance:
1. **Increase Video Memory** to 128MB (max for VirtualBox)
2. **Allocate more RAM** (8GB if possible)
3. **Use more CPU cores** (4 cores recommended)
4. **Disable animations** in Hyprland config if too slow
5. **Use lighter themes** (some themes have more effects)

### For Faster Boot:
- Use VirtualBox's snapshot feature
- Create snapshot after installation completes
- Restore from snapshot for quick testing

---

## 🎨 Testing Themes in VirtualBox

All 10 themes work in VirtualBox!

**Try them:**
```bash
# Press: Super + Shift + T
# Or run:
~/.config/hypr/scripts/theme-select.sh
```

**Available themes:**
1. Catppuccin Mocha (default)
2. Catppuccin Latte
3. Catppuccin Frappe
4. Catppuccin Macchiato
5. Nord
6. Gruvbox Dark
7. Gruvbox Light
8. Tokyo Night
9. Dracula
10. Rosé Pine

All themes are optimized to work well even with software rendering!

---

## 🔄 Moving to Real Hardware

When you're ready to install on real hardware:

1. **Test in VirtualBox first** to verify everything works
2. **Create USB bootable** from the same ISO
3. **Boot on real hardware**
4. **Same installation process** (`install-arch`)
5. **Better performance automatically!**
   - Hardware acceleration will be used
   - Environment variables only apply in VMs
   - Full GPU features available

The VirtualBox-specific settings won't affect real hardware because of auto-detection!

---

## 📝 Summary

CustomOS is **fully optimized for VirtualBox** with:

✅ Automatic VirtualBox detection
✅ Auto-install of guest utilities
✅ Software rendering configured
✅ All features working
✅ All themes working
✅ Easy testing before real hardware
✅ Zero manual configuration needed

**Just install and enjoy!** 🎉

---

## 🆘 Need Help?

If Hyprland still crashes:
1. Check VirtualBox settings (3D acceleration OFF!)
2. Verify latest ISO has the fixes (rebuild if needed)
3. Check logs: `journalctl -xe`
4. Check Hyprland log: `~/.local/share/hyprland/hyprland.log`

The VirtualBox compatibility is built-in and automatic! 🚀
