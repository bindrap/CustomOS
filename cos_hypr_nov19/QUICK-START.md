# Quick Start - QEMU Testing

## Step 1: Package Scripts

```bash
cd /home/user/CustomOS
bash package-creator.sh
```

## Step 2: Build ISO

```bash
cd cos_hypr_nov19
bash build-hyprland-iso-clean.sh
```

Wait 10-15 minutes for build to complete.

## Step 3: Install to Virtual Disk

```bash
bash test-iso-qemu-install.sh
```

Choose option 2 to create new disk.

**Inside QEMU:**

1. **Wait for boot** (10-20 seconds)
2. **Press ENTER** at boot screen
3. Run: `install-arch`
4. **Internet Detection**: If it says "no internet", answer **"yes"** when asked!
   - QEMU networking works, detection just fails sometimes
5. Follow prompts:
   - Disk: `vda`
   - Hostname: `customos`
   - Username: your choice
   - Password: your choice
6. **Wait for "Installation complete!"** message
7. Shutdown QEMU

## Step 4: Boot Installed System

```bash
bash run-installed-qemu.sh
```

**Inside booted system:**

1. Login with your username/password
2. Run post-install:
   ```bash
   cd ~/custom-setup
   ./post-install.sh
   ```
3. **Internet Detection**: Again, answer **"yes"** if it says no internet!
4. Wait 5-10 minutes for packages to install
5. Reboot: `reboot`

## Step 5: Use Hyprland

After reboot, Hyprland starts automatically!

**Key bindings (ALT = mod key):**
- `ALT + Q` - Close window
- `ALT + Return` - Terminal
- `ALT + D` - Launcher
- `ALT + 1-9` - Workspaces

**QEMU Window Controls:**
- `Ctrl+Alt+G` - Release mouse from QEMU
- Now you can use Alt+Tab, window manager controls normally
- Click on QEMU window to capture mouse again

---

## Troubleshooting

### QEMU Window Won't Move

1. Press `Ctrl+Alt+G` to release mouse/keyboard
2. Now use your window manager (Alt+Tab works)
3. Click QEMU window to re-capture mouse

### "No Internet Detected"

Just answer **"yes"** when asked "Do you have internet connection?"

QEMU provides NAT networking automatically - the connection works, the detection just fails sometimes.

### Boot Hangs at "Booting from Hard Disk"

**Fixed!** The installer now auto-detects BIOS vs UEFI:
- **BIOS mode**: Installs GRUB (works in WSL)
- **UEFI mode**: Installs systemd-boot (if OVMF available)

### Slow Performance

```bash
# Enable KVM acceleration
sudo chmod 666 /dev/kvm
```

Scripts automatically use KVM if available.

---

## What Changed (Latest Fix)

**Problem**: systemd-boot only works with UEFI, but QEMU was running in BIOS mode in WSL.

**Solution**: Installer now detects boot mode and installs appropriate bootloader:
- Detects `/sys/firmware/efi/efivars` to determine UEFI vs BIOS
- UEFI mode → systemd-boot
- BIOS mode → GRUB

GRUB works perfectly in BIOS mode - your system will boot now!

---

## Files

- `run-installed-qemu.sh` - Boot installed system (simple)
- `test-iso-qemu-install.sh` - Full install workflow
- `test-iso-qemu.sh` - Quick ISO test
- `cleanup-qemu.sh` - Delete all disks
- `list-qemu-disks.sh` - List disks
- `inspect-qemu-disk.sh` - Debug disk contents
- `boot-qemu-manual.sh` - Advanced boot options

See `QEMU-WORKFLOW.md` for detailed guide.
