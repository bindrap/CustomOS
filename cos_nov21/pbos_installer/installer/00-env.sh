#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF_FILE="${CONF_FILE:-$SCRIPT_DIR/installer.conf}"
LOG_FILE="${LOG_FILE:-/tmp/pbos-installer.log}"

# shellcheck disable=SC1090
if [[ -f "$CONF_FILE" ]]; then
  # shellcheck disable=SC1091
  source "$CONF_FILE"
else
  echo "Missing config: $CONF_FILE" >&2
  exit 1
fi

log() {
  local level="$1"; shift
  local msg="$*"
  printf '[%s] %s\n' "$level" "$msg" | tee -a "$LOG_FILE"
}

run() {
  "$@"
  local status=$?
  if [[ $status -ne 0 ]]; then
    log "ERR" "command failed ($status): $*"
    exit $status
  fi
}

require_root() {
  if [[ $EUID -ne 0 ]]; then
    log "ERR" "must run as root"
    exit 1
  fi
}

typed_disk_confirm() {
  local disk="$1"
  read -rp "Type the disk name to confirm wipe (e.g., ${disk#/dev/}): " typed
  if [[ "$typed" != "${disk#/dev/}" && "$typed" != "$disk" ]]; then
    log "ERR" "disk name mismatch; aborting"
    exit 1
  fi
}

# Utility to decide partition suffix (nvme/mmc use p)
disk_prefix() {
  local disk="$1"
  if [[ "$disk" == *nvme* || "$disk" == *mmcblk* ]]; then
    printf '%sp' "$disk"
  else
    printf '%s' "$disk"
  fi
}
