# PBOS Modular Installer (Hyprland + HyDE, online-only)

This is a fresh, modular rewrite to build and test a PBOS (Arch-based) ISO with Hyprland + HyDE and performance tuning (CachyOS kernel, zram, sysctl). The flow is online-only and split into clear stages.

## Layout
- `installer/00-env.sh` – shared helpers, loads `installer.conf`
- `installer/01-checks.sh` – root, prereqs, network, boot mode
- `installer/02-disk.sh` – typed disk confirmation, GPT (BIOS+EFI), format
- `installer/03-mount.sh` – mount root + EFI
- `installer/04-bootstrap.sh` – pacstrap base system
- `installer/05-chroot.sh` – copy modules into target, run configure/postinstall
- `installer/06-configure.sh` – locale, users, bootloader, pacman tuning
- `installer/07-postinstall.sh` – CachyOS kernel, zram, sysctl, auto-cpufreq, Hyprland + HyDE, gaming
- `installer/08-cleanup.sh` – unmount target
- `installer/run.sh` – execute stages in order
- `installer/installer.conf` – main config (disk, hostname, user, toggles)
- `scripts/` – ISO and QEMU helpers (to be wired)

## Quick start (on Arch ISO)
```bash
cd /root/installer   # when copied from ISO
bash run.sh
```
You’ll be prompted once to type the disk name to confirm wiping. Passwords are prompted during `06-configure.sh` (not stored in config).

## Config
Edit `installer/installer.conf` before running:
- `DISK` – target disk (will be wiped)
- `HOSTNAME`, `USERNAME`, `TIMEZONE`, `LOCALE`
- `INSTALL_CACHY_KERNEL`, `USE_ZRAM`, `INSTALL_GAMING_STACK`, `USE_HYDE`
- `AUTO_PARTITION` – must be `yes` for now (online profile)

## ISO + QEMU pipeline
- `scripts/build-iso.sh` – build PBOS ISO (online, using archiso releng) and embed `installer/`
- `scripts/qemu-install.sh` – create qcow2, boot ISO, and run installer
- `scripts/qemu-run.sh` – boot installed qcow2
- `scripts/qemu-clean.sh` – remove qcow2 artifacts

(ISO/QEMU scripts are provided for local testing; adjust paths if running outside this repo.)
