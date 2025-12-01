#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ISO_DIR="$PROJECT_ROOT/iso-output"
DISK_DIR="$PROJECT_ROOT/qemu"
DISK_FILE="$DISK_DIR/pbos.qcow2"
DISK_SIZE="50G"

mkdir -p "$DISK_DIR"

ISO=$(ls -t "$ISO_DIR"/*.iso 2>/dev/null | head -1 || true)
if [[ -z "$ISO" ]]; then
  echo "No ISO found in $ISO_DIR. Build one with scripts/build-iso.sh" >&2
  exit 1
fi

echo "Using ISO: $(basename "$ISO")"

if [[ ! -f "$DISK_FILE" ]]; then
  qemu-img create -f qcow2 "$DISK_FILE" "$DISK_SIZE"
  echo "Created disk $DISK_FILE ($DISK_SIZE)"
fi

KVM=""
if [[ -e /dev/kvm && -r /dev/kvm ]]; then
  KVM="-enable-kvm"
fi

OVMF_CODE=""
for p in /usr/share/OVMF/OVMF_CODE.fd /usr/share/ovmf/OVMF.fd /usr/share/ovmf/x64/OVMF_CODE.fd /usr/share/edk2-ovmf/x64/OVMF_CODE.fd /usr/share/qemu/ovmf-x86_64-code.bin; do
  [[ -f $p ]] && { OVMF_CODE=$p; break; }
done

OVMF_VARS="$DISK_DIR/OVMF_VARS.fd"
if [[ -n "$OVMF_CODE" && ! -f "$OVMF_VARS" ]]; then
  cp "$OVMF_CODE" "$OVMF_VARS"
fi

QEMU_ARGS=(
  -m 4G
  -smp 4
  -drive "file=$DISK_FILE,format=qcow2,if=virtio"
  -vga virtio
  -display sdl,gl=on
  -netdev user,id=net0
  -device virtio-net-pci,netdev=net0
  -name "PBOS Installer"
  -boot d
  -cdrom "$ISO"
)

if [[ -n "$KVM" ]]; then
  QEMU_ARGS=("$KVM" "${QEMU_ARGS[@]}")
fi

if [[ -n "$OVMF_CODE" ]]; then
  QEMU_ARGS+=(
    -drive "if=pflash,format=raw,readonly=on,file=$OVMF_CODE"
    -drive "if=pflash,format=raw,file=$OVMF_VARS"
  )
fi

echo "Starting QEMU (install). Run 'install-arch' inside the live ISO to launch the modular installer."
exec qemu-system-x86_64 "${QEMU_ARGS[@]}"
