#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/00-env.sh"
require_root

log INFO "Syncing installer into target /root/installer"
run mkdir -p /mnt/root/installer
run cp -a "$SCRIPT_DIR"/. /mnt/root/installer/

log INFO "Entering chroot to configure system"
run arch-chroot /mnt /bin/bash -c "cd /root/installer && bash 06-configure.sh && bash 07-postinstall.sh"
