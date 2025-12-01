#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/00-env.sh"
require_root

log INFO "Partitioning target: $DISK"

# Allow setting disk at runtime if placeholder/empty
if [[ -z "$DISK" || "$DISK" == "__SET_YOUR_DISK__" ]]; then
  read -rp "Enter target disk (e.g., /dev/nvme0n1 or /dev/sda): " DISK
fi

if [[ ! -b "$DISK" ]]; then
  log ERR "Disk not found: $DISK"
  exit 1
fi

# Unmount anything mounted from target disk
mapfile -t mounts < <(lsblk -rno MOUNTPOINT "$DISK" | grep -v '^$' || true)
for m in "${mounts[@]:-}"; do
  run umount -R "$m"
done

if [[ "${AUTO_PARTITION:-no}" != "yes" ]]; then
  log ERR "AUTO_PARTITION is disabled; manual mode not implemented in this profile"
  exit 1
fi

typed_disk_confirm "$DISK"

# Wipe and create GPT with BIOS+EFI+root layout
run sgdisk -Z "$DISK"
run sgdisk -o "$DISK"
run sgdisk -n1:0:+1M   -t1:ef02 "$DISK"   # BIOS boot
run sgdisk -n2:0:+512M -t2:ef00 "$DISK"   # EFI
run sgdisk -n3:0:0     -t3:8300 "$DISK"   # Root

PFX=$(disk_prefix "$DISK")
EFI_PART="${PFX}2"
ROOT_PART="${PFX}3"

log INFO "Formatting EFI ($EFI_PART) and root ($ROOT_PART)"
run mkfs.fat -F32 "$EFI_PART"
run mkfs.ext4 -F "$ROOT_PART"

printf '%s\n' "$EFI_PART" "$ROOT_PART" > "$SCRIPT_DIR/.parts"
