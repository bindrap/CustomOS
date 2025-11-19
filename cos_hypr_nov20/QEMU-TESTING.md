# QEMU Testing Guide

Test your Hyprland ISO in QEMU with proper GPU acceleration - much better than VirtualBox!

## Why QEMU?

**QEMU advantages over VirtualBox:**
- ✅ Better Wayland/Hyprland support
- ✅ virtio-gpu has proper DRM
- ✅ Hardware rendering works
- ✅ Faster with KVM acceleration
- ✅ No VirtualBox-specific workarounds needed

## Quick Start - Just Test the ISO

**Simple test (no installation):**
```bash
cd cos_hypr_nov19
bash test-iso-qemu.sh
```

This boots the ISO in QEMU - perfect for testing that it boots correctly.

## Full Installation Test

**Test complete installation to virtual disk:**
```bash
cd cos_hypr_nov19
bash test-iso-qemu-install.sh
```

**First run (install mode):**
1. QEMU boots from ISO
2. Run: `install-arch`
3. Complete installation
4. Close QEMU when done

**Second run (boot installed system):**
1. Script detects existing disk
2. Choose option 1 to boot installed system
3. Test Hyprland on the installed system

## Managing Virtual Disks

**List all virtual disks:**
```bash
cd cos_hypr_nov19
bash list-qemu-disks.sh
```

Shows all virtual disks with their sizes and last modified times.

**Delete all virtual disks:**
```bash
cd cos_hypr_nov19
bash cleanup-qemu.sh
```

This will:
- Show all disks and total size
- Ask for confirmation
- Delete all `.qcow2` files
- Remove the `qemu-disks` directory
- Free up disk space

**Delete single disk (interactive):**
```bash
cd cos_hypr_nov19
bash test-iso-qemu-install.sh
```
Then choose option 3 "Delete disk and exit"

**Where are disks stored:**
- Location: `cos_hypr_nov19/qemu-disks/`
- Files: `*.qcow2` format
- Default: `hyprland-test.qcow2` (50GB virtual size)

## Manual QEMU Commands

**Basic ISO test:**
```bash
qemu-system-x86_64 \
  -enable-kvm \
  -m 4G \
  -smp 4 \
  -cdrom iso-output/hyprland-custom-*.iso \
  -boot d \
  -vga virtio \
  -display sdl,gl=on
```

**With virtual disk:**
```bash
# Create disk
qemu-img create -f qcow2 hyprland.qcow2 50G

# Boot with disk (first run - install from ISO)
qemu-system-x86_64 \
  -enable-kvm \
  -m 4G \
  -smp 4 \
  -drive file=hyprland.qcow2,format=qcow2,if=virtio \
  -cdrom iso-output/hyprland-custom-*.iso \
  -boot d \
  -vga virtio \
  -display sdl,gl=on \
  -netdev user,id=net0 \
  -device virtio-net-pci,netdev=net0

# Boot from disk (after install - no ISO needed)
qemu-system-x86_64 \
  -enable-kvm \
  -m 4G \
  -smp 4 \
  -drive file=hyprland.qcow2,format=qcow2,if=virtio \
  -vga virtio \
  -display sdl,gl=on \
  -netdev user,id=net0 \
  -device virtio-net-pci,netdev=net0
```

## Installing QEMU

**Arch Linux:**
```bash
sudo pacman -S qemu-full
```

**Ubuntu/Debian:**
```bash
sudo apt install qemu-system-x86 qemu-utils
```

**macOS:**
```bash
brew install qemu
```

## Enabling KVM (Linux Only)

KVM provides hardware acceleration for much better performance.

**Check if KVM is available:**
```bash
# Check if CPU supports virtualization
egrep -c '(vmx|svm)' /proc/cpuinfo
# Should return > 0

# Check if KVM module is loaded
lsmod | grep kvm
```

**Enable KVM:**
```bash
# Load KVM module
sudo modprobe kvm
sudo modprobe kvm_intel  # For Intel CPUs
# OR
sudo modprobe kvm_amd    # For AMD CPUs

# Give yourself permission
sudo chmod 666 /dev/kvm
# OR add yourself to kvm group
sudo usermod -a -G kvm $USER
```

## QEMU Settings Explained

| Setting | Purpose |
|---------|---------|
| `-enable-kvm` | Hardware acceleration (Linux only) |
| `-m 4G` | 4GB RAM for the VM |
| `-smp 4` | 4 CPU cores (better performance) |
| `-vga virtio` | virtio-gpu for better graphics |
| `-display sdl,gl=on` | SDL display with OpenGL |
| `-netdev user` | NAT networking |
| `-drive ... if=virtio` | virtio disk (faster than IDE/SATA) |
| `-cdrom ...` | Attach ISO (only for installation) |
| `-boot d` | Boot from CD-ROM first |

## Performance Tips

**Slow without KVM?**
- Enable KVM (Linux only) - 10-100x faster
- On Windows/macOS: Performance will be slower but usable

**Graphics issues?**
- Make sure OpenGL works: `glxinfo | grep OpenGL`
- Try `-display gtk,gl=on` instead of SDL
- Or use `-display default` (no OpenGL)

**Network not working?**
- Default is NAT - works for most cases
- For bridged network, see QEMU networking docs

## Keyboard Shortcuts

- **Ctrl+Alt+G** - Release mouse/keyboard from QEMU window
- **Ctrl+Alt+F** - Toggle fullscreen
- **Ctrl+Alt+1/2** - Switch between monitor and serial console

## Troubleshooting

**"Could not access KVM kernel module"**
```bash
sudo chmod 666 /dev/kvm
```

**"Failed to initialize SDL"**
- Install SDL2: `sudo apt install libsdl2-2.0-0`
- Or try different display: `-display gtk,gl=on`

**"No bootable device"**
- Make sure `-boot d` is specified
- Check ISO path is correct

**Black screen after boot**
- Try `-vga std` instead of `-vga virtio`
- Or `-vga qxl`

## Scripts and Files

| File | Purpose |
|------|---------|
| `test-iso-qemu.sh` | Quick ISO boot test (no installation) |
| `test-iso-qemu-install.sh` | Full installation test with virtual disk |
| `list-qemu-disks.sh` | List all virtual disks and sizes |
| `cleanup-qemu.sh` | Delete all virtual disks (frees space) |
| `qemu-disks/` | Virtual disk storage directory |
| `qemu-disks/*.qcow2` | Virtual disk files (50GB each) |

## Next Steps

After testing in QEMU:
1. ✅ Verify ISO boots
2. ✅ Test installation process
3. ✅ Verify Hyprland starts on installed system
4. ✅ Test all themes and features
5. 🚀 Deploy to real hardware or create USB
