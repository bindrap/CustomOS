# Quick Start - Building CustomOS ISO on WSL

## TL;DR

```bash
cd /mnt/c/Users/bindrap/Documents/CustomOS
./build-iso-docker.sh
```

Wait 10-15 minutes → Get ISO in `./iso-output/` → Use in VirtualBox

---

## Prerequisites Checklist

- [ ] Docker Desktop installed on Windows
- [ ] Docker Desktop is running (check system tray)
- [ ] WSL integration enabled in Docker Desktop settings

**Install Docker:** https://www.docker.com/products/docker-desktop

---

## Build ISO (Online Mode - Small ISO)

```bash
# Navigate to project
cd /mnt/c/Users/bindrap/Documents/CustomOS

# Build ISO
./build-iso-docker.sh

# Type 'yes' when prompted
# Wait 10-15 minutes
```

**Output:** `./iso-output/parteek-arch-YYYY.MM.DD.iso` (~800MB-1.2GB)

**Note:** This ISO requires internet during installation

---

## Build ISO (Offline Mode - Large ISO with all packages)

```bash
# Step 1: Download packages (one-time, ~3-5GB)
cd /mnt/c/Users/bindrap/Documents/CustomOS

docker run --rm --privileged \
    -v "$(pwd):/workspace" \
    -w /workspace \
    archlinux:latest \
    bash create-offline-cache.sh

# Step 2: Build ISO with packages included
./build-iso-docker.sh
```

**Output:** `./iso-output/parteek-arch-YYYY.MM.DD.iso` (~4-6GB)

**Note:** This ISO works without internet

---

## Use in VirtualBox

### 1. Create VM
- Name: CustomOS
- Type: Linux → Arch Linux (64-bit)
- RAM: 4096 MB (min 2048 MB)
- Disk: 40GB+

### 2. Attach ISO
- Settings → Storage → Empty CD drive
- Click disk icon → Browse
- Select: `C:\Users\bindrap\Documents\CustomOS\iso-output\parteek-arch-*.iso`

### 3. Start VM
- Boot from ISO
- Run: `install-arch`
- Follow prompts
- Wait 15-20 minutes
- Reboot

---

## Troubleshooting

**"docker: command not found"**
→ Install Docker Desktop, enable WSL integration

**"Cannot connect to Docker daemon"**
→ Start Docker Desktop on Windows

**Build fails with "custom-arch-setup not found"**
→ Normal! Script creates minimal setup automatically
→ Or run `./package-creator.sh` first on Arch Linux

**Build takes forever**
→ First build downloads ~1-2GB, takes 10-20 minutes
→ Be patient!

---

## File Locations

**WSL Path:** `/mnt/c/Users/bindrap/Documents/CustomOS/iso-output/`

**Windows Path:** `C:\Users\bindrap\Documents\CustomOS\iso-output\`

(Both work in VirtualBox!)

---

## What You Get

After installation, your VM will have:
- Arch Linux base system
- Hyprland Wayland compositor
- 10 pre-configured themes
- Complete development environment
- Firefox, terminal, file manager, etc.

**Switch themes:** `Super + Shift + T`

**See all keybinds:** `Super + /`

---

## Full Documentation

- **Detailed WSL Guide:** [BUILDING-WSL.md](BUILDING-WSL.md)
- **Main README:** [README.md](README.md)
- **Customization Guide:** [CUSTOMIZATION.md](CUSTOMIZATION.md)

---

**Questions? Check [BUILDING-WSL.md](BUILDING-WSL.md) for complete troubleshooting guide!**
