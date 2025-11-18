# Quick Reference - ISO Building

## 🚀 Quick Start (Choose Your Platform)

### Windows/WSL
```bash
# First time (recommended):
./build-docker-image.sh      # Creates cached image (2-3 min)
./build-iso-docker.sh         # Builds ISO (3-5 min)

# Or skip caching:
./build-iso-docker.sh         # Builds ISO (10-15 min)
```

### Endeavour OS / Arch Linux
```bash
./build-iso-native.sh         # Builds ISO (5-10 min)
```

---

## 📋 Command Reference

| Script | Purpose | Time | Platform |
|--------|---------|------|----------|
| `build-docker-image.sh` | Create cached Docker image | 2-3 min | WSL only |
| `build-iso-docker.sh` | Build ISO with Docker | 3-15 min | WSL only |
| `build-iso-native.sh` | Build ISO natively | 5-10 min | Endeavour/Arch |

---

## 📁 Important Locations

| Path | Contents |
|------|----------|
| `iso-output/` | Built ISOs |
| `~/.cache/archiso-pkgs/` | Package cache (WSL) |
| `custom-arch-setup/` | Your configs |
| `BUILD-GUIDE.md` | Full documentation |

---

## 🔧 Common Tasks

### Update Docker Image
```bash
./build-docker-image.sh
```

### Clean Package Cache
```bash
rm -rf ~/.cache/archiso-pkgs/*
```

### Clean Old ISOs
```bash
rm iso-output/*.iso
```

### List Built ISOs
```bash
ls -lh iso-output/*.iso
```

---

## ⚡ Performance Tips

1. **Use cached Docker image** (WSL) - 3x faster
2. **Keep package cache** - saves bandwidth
3. **Fast internet** - most time is downloads
4. **Native Linux** - fastest overall

---

## 🐛 Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| Docker not running | Start Docker Desktop |
| Permission denied | `chmod +x build-*.sh` |
| Slow build | Run `./build-docker-image.sh` |
| Out of space | Clean `/tmp`: `sudo rm -rf /tmp/archiso-work` |
| Build fails | Check internet, retry (packages cached) |

---

## 📊 What You Get

- ✅ Custom Arch Linux ISO
- ✅ Hyprland pre-configured
- ✅ 10 themes included
- ✅ One-command installation
- ✅ VirtualBox compatible
- ✅ Online/offline install modes

---

## 🎯 Next Steps After Build

1. Find ISO in `iso-output/`
2. Use in VirtualBox OR write to USB
3. Boot and run: `install-arch`
4. Done! 🎉

---

**For full details:** See `BUILD-GUIDE.md`
