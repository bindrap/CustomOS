#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DISK_DIR="$PROJECT_ROOT/qemu"

if [[ -d "$DISK_DIR" ]]; then
  rm -rf "$DISK_DIR"
  echo "Removed $DISK_DIR"
else
  echo "No qemu directory to clean"
fi
