#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/00-env.sh"
require_root

log INFO "Configuring base system inside chroot"

# Timezone and clock
run ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
run hwclock --systohc

# Locale
if ! grep -q "^$LOCALE" /etc/locale.gen; then
  echo "$LOCALE UTF-8" >> /etc/locale.gen
fi
run locale-gen
printf 'LANG=%s\n' "$LOCALE" > /etc/locale.conf

# Hostname and hosts
printf '%s\n' "$HOSTNAME" > /etc/hostname
cat > /etc/hosts <<EOFHOSTS
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
EOFHOSTS

# Pacman tuning
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
sed -i 's/^ParallelDownloads.*/ParallelDownloads = 10/' /etc/pacman.conf

# Password prompt (avoid storing in config)
if [[ -z "${PASSWORD:-}" ]]; then
  read -rsp "Set password for root and $USERNAME: " PASSWORD
  echo
  read -rsp "Confirm password: " PASSWORD_CONFIRM
  echo
  if [[ "$PASSWORD" != "$PASSWORD_CONFIRM" ]]; then
    log ERR "Passwords do not match"
    exit 1
  fi
fi

echo "root:$PASSWORD" | chpasswd
if ! id "$USERNAME" >/dev/null 2>&1; then
  run useradd -m -s "$SHELL" -G wheel "$USERNAME"
fi
echo "$USERNAME:$PASSWORD" | chpasswd
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Boot mode detection inside chroot
if [[ -d /sys/firmware/efi/efivars ]]; then
  BOOT_MODE="UEFI"
else
  BOOT_MODE="BIOS"
fi
log INFO "Boot mode (chroot): $BOOT_MODE"

ROOT_DEV=$(findmnt -n -o SOURCE /)
ROOT_UUID=$(blkid -s UUID -o value "$ROOT_DEV")
if [[ -z "$ROOT_UUID" ]]; then
  log ERR "Unable to determine root UUID"
  exit 1
fi

if [[ "$BOOT_MODE" == "UEFI" ]]; then
  run bootctl install
  cat > /boot/loader/loader.conf <<'EOFLOADER'
default arch.conf
timeout 5
console-mode keep
editor no
EOFLOADER
  cat > /boot/loader/entries/arch.conf <<EOFENTRY
title   PBOS (linux)
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=UUID=$ROOT_UUID rw quiet splash loglevel=3
EOFENTRY
else
  run pacman -S --noconfirm --needed grub
  run grub-install --target=i386-pc --recheck "$DISK"
  run grub-mkconfig -o /boot/grub/grub.cfg
fi

# Enable services
run systemctl enable NetworkManager
run systemctl enable sshd
