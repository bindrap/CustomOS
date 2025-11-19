# Complete QEMU Testing Workflow

This guide shows the complete workflow for building and testing the Hyprland ISO in QEMU.

## Prerequisites

```bash
# Install required packages
sudo apt install qemu-system-x86 qemu-utils docker.io

# Enable KVM for better performance (optional but recommended)
sudo chmod 666 /dev/kvm
```

---

## Complete Workflow

### Step 1: Package the Installation Scripts

First, package the base installation scripts into the ISO:

```bash
cd /home/user/CustomOS
bash package-creator.sh
```

**What this does:**
- Packages `install-auto.sh` and `post-install.sh` into `custom-arch-setup.tar.gz`
- This archive gets embedded in the ISO
- Scripts become available during installation

---

### Step 2: Build the ISO

```bash
cd cos_hypr_nov19
bash build-hyprland-iso-clean.sh
```

**Build time:** 10-15 minutes
**Output:** `iso-output/HYPR_YYMMDD.iso`

**What gets built:**
- Base Arch Linux system
- Hyprland compositor with pixman renderer (VirtualBox compatible)
- ALT key as mod key (instead of Super/Windows key)
- All themes and dotfiles
- Installation scripts packaged in ISO

---

### Step 3: Test ISO Installation

```bash
bash test-iso-qemu-install.sh
```

**First run creates virtual disk:**
- 50GB qcow2 disk created in `qemu-disks/`
- Boots from ISO
- Installation mode

**Inside QEMU:**

1. **Wait for boot** (QEMU window might take 10-20 seconds to appear)

2. **Press ENTER** when you see the boot screen

3. **Run the installer:**
   ```bash
   install-arch
   ```

4. **Internet Detection:**
   - Auto-detects by pinging 8.8.8.8, 1.1.1.1, archlinux.org
   - Also tries curl as fallback
   - If all fail, prompts: "Do you have internet connection? (yes/no)"
   - Answer "yes" if you have internet (QEMU networking works)
   - Answer "no" for offline mode (requires offline packages)

5. **Follow installation prompts:**
   - Select disk: `vda`
   - Enter hostname: `customos` (or your choice)
   - Enter username: your username
   - Enter password: your password

6. **Wait for installation to complete:**
   - Watch for "Installation complete!" message
   - Installation logs saved to `/var/log/installation.log`
   - **DO NOT CLOSE QEMU until you see "Installation complete!"**

7. **Shutdown QEMU** after installation completes

---

### Step 4: Boot Installed System

Now boot from the installed system (without ISO):

```bash
bash run-installed-qemu.sh
```

**OR** using the full test script:

```bash
bash test-iso-qemu-install.sh
# Choose option 1: Use existing disk (boot installed system)
```

**What happens:**
- Boots from virtual disk
- No ISO attached
- Starts the installed Hyprland system
- Window title shows "Hyprland - Installed System"

**Inside the booted system:**

1. **Login** with the username/password you created

2. **Run post-install customization:**
   ```bash
   cd ~/custom-setup
   ./post-install.sh
   ```

3. **Internet Detection (Fixed!):**
   - Tries multiple methods:
     - ping 8.8.8.8 (Google DNS)
     - ping 1.1.1.1 (Cloudflare DNS)
     - ping archlinux.org
     - curl http://archlinux.org
   - If all fail, asks: "Do you have internet connection? (yes/no)"
   - Answer "yes" to override and continue

4. **Post-install runs:**
   - Updates system packages
   - Installs Hyprland and all dependencies
   - Configures Waybar, Kitty, Wofi
   - Installs all themes
   - Takes 5-10 minutes

5. **Reboot:**
   ```bash
   reboot
   ```

---

### Step 5: Use Hyprland

After reboot, Hyprland starts automatically!

**Key bindings (ALT is mod key):**
- `ALT + Q` - Close window
- `ALT + Return` - Terminal (Kitty)
- `ALT + D` - Launcher (Wofi)
- `ALT + Shift + E` - Exit Hyprland
- `ALT + Left/Right/Up/Down` - Move focus
- `ALT + 1-9` - Switch workspaces

**QEMU window controls:**
- `Ctrl+Alt+G` - Release mouse/keyboard from QEMU
- `Alt+Tab` - Switch windows (use after releasing with Ctrl+Alt+G)

---

## Available Scripts

All scripts are in `/home/user/CustomOS/cos_hypr_nov19/`:

### Primary Scripts

**`run-installed-qemu.sh`** ⭐ RECOMMENDED
- Simple one-command boot
- Boots the installed system directly
- Enables KVM automatically
- Shows clear error if no installation found

```bash
bash run-installed-qemu.sh
```

**`test-iso-qemu-install.sh`**
- Full installation workflow
- First run: Creates disk + installs from ISO
- Second run: Options to boot/reinstall/cleanup
- Smart disk detection

```bash
bash test-iso-qemu-install.sh
```

**`test-iso-qemu.sh`**
- Quick ISO live boot test
- No installation
- Tests if ISO boots properly

```bash
bash test-iso-qemu.sh
```

### Utility Scripts

**`boot-qemu-manual.sh`**
- Manual boot with 3 modes
- Option 1: Boot installed system
- Option 2: Boot with ISO (rescue mode)
- Option 3: Show all troubleshooting commands

```bash
bash boot-qemu-manual.sh
```

**`cleanup-qemu.sh`**
- Deletes all virtual disks
- Frees up space
- Shows total space to be freed

```bash
bash cleanup-qemu.sh
```

**`list-qemu-disks.sh`**
- Lists all virtual disks
- Shows sizes and modification times

```bash
bash list-qemu-disks.sh
```

**`inspect-qemu-disk.sh`**
- Mounts virtual disk for inspection
- Checks bootloader installation
- Verifies boot entries and kernel files

```bash
bash inspect-qemu-disk.sh
```

---

## Troubleshooting

### Problem: No Internet in QEMU

**During install-arch:**
- If auto-detection fails, answer "yes" when asked "Do you have internet?"
- QEMU provides NAT networking automatically (virtio-net)

**During post-install.sh:**
- Script now tries 4 methods: ping 8.8.8.8, 1.1.1.1, archlinux.org, and curl
- If all fail, it asks for manual confirmation
- QEMU networking should work - answer "yes" if you're connected to internet on host

**Manual network check:**
```bash
# Inside QEMU
ping 8.8.8.8
ip link show
```

### Problem: "Booting from Hard Disk" Hangs

This was a BIOS/EFI mismatch issue. Fixed in current scripts.

**Solution:**
```bash
# Delete old disk and reinstall
bash cleanup-qemu.sh
bash test-iso-qemu-install.sh
```

### Problem: QEMU Window Doesn't Appear

- Wait 10-20 seconds (QEMU might be loading)
- Check if QEMU is running: `ps aux | grep qemu`
- Try without OpenGL: Edit script and change `-display sdl,gl=on` to `-display sdl`

### Problem: Slow Performance

```bash
# Enable KVM acceleration
sudo chmod 666 /dev/kvm

# Verify KVM is enabled
ls -la /dev/kvm

# Scripts auto-enable KVM if available
```

### Problem: Want to Start Fresh

```bash
# Delete all virtual disks
bash cleanup-qemu.sh

# Rebuild ISO (if needed)
bash build-hyprland-iso-clean.sh

# Fresh installation
bash test-iso-qemu-install.sh
```

### Problem: Need to Fix Bootloader

```bash
# Boot with ISO attached
bash boot-qemu-manual.sh
# Choose option 2

# Press ESC during boot, select CD-ROM

# Inside live environment:
mount /dev/vda3 /mnt
mount /dev/vda1 /mnt/boot
arch-chroot /mnt
bootctl install
bootctl update
ls -la /boot/loader/entries/
exit
reboot
```

---

## Disk Management

### Virtual Disk Location

All virtual disks are stored in `qemu-disks/`:

```bash
qemu-disks/
├── hyprland-test.qcow2    # Main virtual disk (50GB)
└── OVMF_VARS.fd           # UEFI firmware variables (if using UEFI)
```

### Disk Operations

**Check disk size:**
```bash
du -h qemu-disks/hyprland-test.qcow2
```

**List all disks:**
```bash
bash list-qemu-disks.sh
```

**Inspect disk contents:**
```bash
bash inspect-qemu-disk.sh
```

**Delete all disks:**
```bash
bash cleanup-qemu.sh
```

---

## Network in QEMU

QEMU provides NAT networking automatically via `virtio-net`:

- **Inside QEMU:** Gets IP via DHCP (usually 10.0.2.15)
- **Internet access:** Yes (through host)
- **Port forwarding:** Not configured by default
- **DNS:** Uses host DNS

No additional network configuration needed!

---

## Performance Tips

### Enable KVM (10-100x faster)

```bash
# One-time setup
sudo chmod 666 /dev/kvm

# Scripts automatically use KVM if available
```

### Increase Resources

Edit the script and modify:

```bash
-m 4G      # RAM (increase to 8G if you have it)
-smp 4     # CPU cores (increase if you have more)
```

### Use virtio Devices

Already configured:
- virtio disk (faster disk I/O)
- virtio network (faster networking)
- virtio graphics (better GPU performance)

---

## File Locations Inside Installed System

After installation, these files are available:

```bash
~/custom-setup/                    # Installation scripts
├── install-auto.sh                # Base installer
└── post-install.sh                # Hyprland customization

~/.config/hypr/                    # Hyprland config
├── hyprland.conf                  # Main config (ALT as mod key)
├── themes/                        # All themes
└── scripts/                       # Utility scripts

/var/log/installation.log          # Installation log
```

---

## Quick Reference

### Fresh Installation

```bash
cd /home/user/CustomOS
bash package-creator.sh
cd cos_hypr_nov19
bash build-hyprland-iso-clean.sh
bash test-iso-qemu-install.sh
# Inside QEMU: install-arch → shutdown
bash run-installed-qemu.sh
# Inside system: cd ~/custom-setup && ./post-install.sh → reboot
```

### Boot Existing System

```bash
cd /home/user/CustomOS/cos_hypr_nov19
bash run-installed-qemu.sh
```

### Start Over

```bash
bash cleanup-qemu.sh
bash test-iso-qemu-install.sh
```

---

## Differences: VirtualBox vs QEMU

| Feature | VirtualBox | QEMU |
|---------|-----------|------|
| Renderer | pixman (software) | pixman (software) |
| Boot Mode | BIOS only | BIOS (current scripts) |
| Performance | Slower | Faster (with KVM) |
| GPU | Limited Wayland | Better virtio-gpu |
| Network | NAT (manual setup) | NAT (automatic) |
| Mod Key | ALT | ALT |
| ISO Builder | `build-hyprland-iso.sh` | `build-hyprland-iso-clean.sh` |

Both use pixman renderer for compatibility, but QEMU has better performance and simpler networking.

---

## Support

**See detailed troubleshooting:** `TROUBLESHOOTING.md`

**Get manual commands:**
```bash
bash boot-qemu-manual.sh
# Choose option 3
```

**Check disk contents:**
```bash
bash inspect-qemu-disk.sh
```

**For network issues:** Answer "yes" when scripts ask about internet - QEMU networking works automatically!

---

**Last Updated:** Nov 19, 2025
**Purpose:** Complete QEMU testing workflow for Hyprland ISO
**Status:** Production ready with robust internet detection
