#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/00-env.sh"
require_root

if [[ ! -f "$SCRIPT_DIR/.parts" ]]; then
  log ERR "Partition list not found (.parts). Run 02-disk.sh first."
  exit 1
fi
mapfile -t parts < "$SCRIPT_DIR/.parts"
EFI_PART="${parts[0]}"
ROOT_PART="${parts[1]}"

log INFO "Mounting root ($ROOT_PART) and EFI ($EFI_PART)"
run mount "$ROOT_PART" /mnt
run mkdir -p /mnt/boot
run mount "$EFI_PART" /mnt/boot
