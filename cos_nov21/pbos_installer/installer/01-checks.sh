#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/00-env.sh"
require_root

log INFO "Starting checks (online-only mode)"

# Verify architecture
arch=$(uname -m)
if [[ "$arch" != "x86_64" ]]; then
  log ERR "Unsupported architecture: $arch"
  exit 1
fi

# Verify required commands exist
required=(sgdisk mkfs.fat mkfs.ext4 pacstrap arch-chroot genfstab sfdisk)
missing=()
for cmd in "${required[@]}"; do
  command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
done
if (( ${#missing[@]} > 0 )); then
  log ERR "Missing commands: ${missing[*]}"
  exit 1
fi

# Network check (online required)
if ping -c1 -W3 1.1.1.1 >/dev/null 2>&1 || ping -c1 -W3 archlinux.org >/dev/null 2>&1; then
  log INFO "Network OK"
else
  log ERR "Network unavailable; online install required"
  exit 1
fi

# Boot mode
if [[ -d /sys/firmware/efi/efivars ]]; then
  BOOT_MODE="UEFI"
else
  BOOT_MODE="BIOS"
fi
log INFO "Boot mode: $BOOT_MODE"

echo "$BOOT_MODE" > "$SCRIPT_DIR/.bootmode"
