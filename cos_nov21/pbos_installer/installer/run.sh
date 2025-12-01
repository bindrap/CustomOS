#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for step in 01-checks 02-disk 03-mount 04-bootstrap 05-chroot 08-cleanup; do
  echo "==> Running $step"
  bash "$SCRIPT_DIR/$step.sh"
done
