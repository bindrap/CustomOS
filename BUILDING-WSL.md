# Building CustomOS ISO from WSL (Windows)

This guide explains how to build the CustomOS ISO from Windows Subsystem for Linux (WSL) using Docker.

## Why Docker?

The standard `build-iso.sh` requires Arch Linux tools (`pacman`, `archiso`) which aren't available in WSL. The Docker-based approach:

- ✅ Runs a real Arch Linux environment inside a container
- ✅ Mounts your Windows filesystem so the ISO is accessible
- ✅ No need for a full VM
- ✅ Clean and isolated build environment

## Prerequisites

### 1. Install Docker Desktop for Windows

**Download and Install:**
1. Go to: https://www.docker.com/products/docker-desktop
2. Download Docker Desktop for Windows
3. Run the installer
4. Restart your computer when prompted

**Enable WSL 2 Integration:**
1. Open Docker Desktop
2. Go to Settings → Resources → WSL Integration
3. Enable integration with your WSL distribution (e.g., Ubuntu)
4. Click "Apply & Restart"

**Verify Installation:**
```bash
# In WSL terminal
docker --version
docker info
```

If you see version info and no errors, Docker is ready!

### 2. Verify Your Project Structure

Make sure you have these files in your CustomOS directory:

```
CustomOS/
├── build-iso-docker.sh          ← New Docker-based builder
├── build-iso.sh                 ← Original (requires Arch Linux)
├── package-creator.sh
├── create-offline-cache.sh
├── install.sh
├── install-auto.sh
├── custom-arch-setup/           ← Should exist (created by package-creator.sh)
│   ├── hyprland.conf
│   ├── hypr-themes/
│   └── ... (other config files)
└── offline-packages/            ← Optional (for offline ISO)
    └── *.pkg.tar.zst
```

## Building the ISO

### Option 1: Online ISO (Requires Internet During Installation)

This creates a smaller ISO that downloads packages during installation:

```bash
cd /mnt/c/Users/bindrap/Documents/CustomOS
./build-iso-docker.sh
```

**When prompted:**
- Type `yes` to continue
- Wait 10-15 minutes for the build

**Output:**
- ISO file: `./iso-output/parteek-arch-YYYY.MM.DD.iso`
- Size: ~800MB - 1.2GB

### Option 2: Offline ISO (Works Without Internet)

This creates a larger ISO with all packages pre-downloaded:

**Step 1: Create Package Cache**

⚠️ **Important:** This step MUST be done on an Arch Linux system or in Docker:

```bash
# Method 1: If you have Arch Linux VM or system
./create-offline-cache.sh

# Method 2: Using Docker (recommended for WSL)
docker run --rm --privileged \
    -v "$(pwd):/workspace" \
    -w /workspace \
    archlinux:latest \
    bash create-offline-cache.sh
```

This downloads ~3-5GB of packages to `./offline-packages/`

**Step 2: Build ISO with Offline Packages**

```bash
./build-iso-docker.sh
```

The script will automatically detect the `offline-packages/` directory and include it.

**Output:**
- ISO file: `./iso-output/parteek-arch-YYYY.MM.DD.iso`
- Size: ~4-6GB (includes all packages)

## Using the ISO in VirtualBox

### 1. Create a New Virtual Machine

1. Open **VirtualBox** on Windows
2. Click **New**
3. Configure:
   - **Name:** CustomOS
   - **Type:** Linux
   - **Version:** Arch Linux (64-bit)
   - **RAM:** 4096 MB (minimum 2048 MB)
   - **Hard Disk:** Create virtual hard disk (40GB+)

### 2. Attach the ISO

1. Select your VM → Click **Settings**
2. Go to **Storage**
3. Click the **Empty** CD drive under "Controller: IDE"
4. Click the **disk icon** → **Choose a disk file**
5. Navigate to: `C:\Users\bindrap\Documents\CustomOS\iso-output\`
6. Select the ISO file (e.g., `parteek-arch-2025.11.17.iso`)
7. Click **OK**

### 3. Configure VM Settings (Optional but Recommended)

**Display:**
- Video Memory: 128 MB
- Enable 3D Acceleration

**System:**
- Enable EFI (if you want UEFI boot)
- Processors: 2+ CPUs

**Network:**
- Adapter 1: NAT or Bridged (for internet access)

### 4. Start the VM and Install

1. Click **Start** on your VM
2. Wait for the ISO to boot (you'll see the Arch Linux boot menu)
3. When you see the welcome message, run:
   ```bash
   install-arch
   ```
4. Follow the prompts:
   - Select your disk (usually `/dev/sda`)
   - Enter username
   - Set password
   - Choose hostname
5. Wait 15-20 minutes for installation
6. When complete, type `reboot`
7. **Remove the ISO** from VM settings before rebooting

### 5. First Boot

After reboot:
1. Login with your username/password
2. You'll be in Hyprland with the default Catppuccin Mocha theme
3. Press `Super + /` to see all keybindings
4. Press `Super + Shift + T` to change themes

## Troubleshooting

### Docker Issues

**"docker: command not found"**
- Install Docker Desktop for Windows (see Prerequisites)
- Make sure Docker Desktop is running
- Enable WSL integration in Docker Desktop settings

**"Cannot connect to the Docker daemon"**
- Start Docker Desktop on Windows
- Wait for it to fully start (icon turns solid)
- Try the command again

**"permission denied while trying to connect to the Docker daemon"**
```bash
# Add your user to the docker group (in WSL)
sudo usermod -aG docker $USER
# Log out and log back in to WSL
```

### Build Issues

**"custom-arch-setup directory not found"**
- Run `./package-creator.sh` first to create the setup files
- Or the Docker script will create a minimal setup automatically

**"No space left on device"**
- Free up disk space on Windows (need ~10-15GB free)
- Clean up old Docker images: `docker system prune -a`

**Build takes forever / hangs**
- The build can take 10-20 minutes on first run
- Docker needs to download Arch Linux image (~400MB)
- Building the ISO involves downloading packages (~1-2GB)
- Be patient!

### VirtualBox Issues

**"ISO won't boot"**
- Make sure you selected "Arch Linux (64-bit)" as the OS type
- Try enabling/disabling EFI in System settings
- Increase RAM to at least 2GB

**"Black screen after boot"**
- Wait a minute - Hyprland might be loading
- Try Ctrl+Alt+F2 to switch to TTY
- Check if installation completed successfully

**"No internet in VM"**
- Change Network Adapter to "Bridged Adapter" in VM settings
- Or keep as NAT and restart VM

## What Gets Built?

The ISO includes:

**Pre-installed:**
- Arch Linux base system
- Hyprland Wayland compositor
- 10 pre-configured themes (Catppuccin, Dracula, Nord, etc.)
- Complete Hypr config with all scripts
- Waybar (3 style variants)
- Kitty terminal, Firefox, development tools

**During Installation:**
- User account creation
- Network setup
- Bootloader (GRUB)
- Display manager
- All packages (from ISO cache or internet)

## File Locations

**In WSL/Linux:**
- Build script: `/mnt/c/Users/bindrap/Documents/CustomOS/build-iso-docker.sh`
- Output ISO: `/mnt/c/Users/bindrap/Documents/CustomOS/iso-output/`

**In Windows:**
- Build script: `C:\Users\bindrap\Documents\CustomOS\build-iso-docker.sh`
- Output ISO: `C:\Users\bindrap\Documents\CustomOS\iso-output\`

VirtualBox can use either Windows or WSL paths!

## Advanced Usage

### Custom Packages

Edit `create-offline-cache.sh` to add/remove packages:

```bash
PACKAGES=(
    # Add your packages here
    firefox
    git
    neovim
    # ...
)
```

Then rebuild the offline cache and ISO.

### Testing Without VirtualBox

Use QEMU (install in WSL):
```bash
sudo apt install qemu-system-x86
qemu-system-x86_64 -enable-kvm -m 4G -cdrom ./iso-output/parteek-arch-*.iso
```

Note: KVM acceleration might not work in WSL2.

### Cleaning Up

Remove Docker build artifacts:
```bash
docker system prune -a -f
```

Remove old ISOs:
```bash
rm -rf ./iso-output/*.iso
```

## Quick Reference

```bash
# Build online ISO (small, needs internet)
./build-iso-docker.sh

# Build offline ISO (large, works offline)
# 1. Create package cache first:
docker run --rm --privileged -v "$(pwd):/workspace" -w /workspace archlinux:latest bash create-offline-cache.sh
# 2. Build ISO:
./build-iso-docker.sh

# Check Docker status
docker info

# List Docker images
docker images

# Clean up Docker
docker system prune -a
```

## Need Help?

- **Docker Issues:** https://docs.docker.com/desktop/troubleshoot/overview/
- **VirtualBox Issues:** https://www.virtualbox.org/wiki/Documentation
- **Arch Linux:** https://wiki.archlinux.org/
- **Hyprland:** https://hyprland.org/

---

**Built with ❤️ for WSL users**
