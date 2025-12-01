#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DISK_FILE="$PROJECT_ROOT/qemu/pbos.qcow2"

if [[ ! -f "$DISK_FILE" ]]; then
  echo "Missing qcow2: $DISK_FILE. Run qemu-install.sh first." >&2
  exit 1
fi

KVM=""
if [[ -e /dev/kvm && -r /dev/kvm ]]; then
  KVM="-enable-kvm"
fi

OVMF_CODE=""
for p in /usr/share/OVMF/OVMF_CODE.fd /usr/share/ovmf/OVMF.fd /usr/share/ovmf/x64/OVMF_CODE.fd /usr/share/edk2-ovmf/x64/OVMF_CODE.fd /usr/share/qemu/ovmf-x86_64-code.bin; do
  [[ -f $p ]] && { OVMF_CODE=$p; break; }
done
OVMF_VARS="$PROJECT_ROOT/qemu/OVMF_VARS.fd"

QEMU_ARGS=(
  -m 4G
  -smp 4
  -drive "file=$DISK_FILE,format=qcow2,if=virtio"
  -vga virtio
  -display sdl,gl=on
  -netdev user,id=net0,hostfwd=tcp::2222-:22
  -device virtio-net-pci,netdev=net0
  -name "PBOS Installed"
  -boot c
)

if [[ -n "$KVM" ]]; then
  QEMU_ARGS=("$KVM" "${QEMU_ARGS[@]}")
fi

if [[ -n "$OVMF_CODE" && -f "$OVMF_VARS" ]]; then
  QEMU_ARGS+=(
    -drive "if=pflash,format=raw,readonly=on,file=$OVMF_CODE"
    -drive "if=pflash,format=raw,file=$OVMF_VARS"
  )
fi

echo "Starting QEMU from installed disk (SSH on port 2222)."
exec qemu-system-x86_64 "${QEMU_ARGS[@]}"
