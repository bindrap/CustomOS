#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/00-env.sh"
require_root

log INFO "Pacstrap base system (online only)"
run pacstrap /mnt base base-devel linux linux-headers linux-firmware networkmanager sudo git openssh rsync vim

log INFO "Generating fstab"
run genfstab -U /mnt >> /mnt/etc/fstab
