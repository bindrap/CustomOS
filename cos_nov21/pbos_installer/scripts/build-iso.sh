#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
OUTPUT_DIR="$PROJECT_ROOT/iso-output"
ISO_NAME="pbos-hyde"
ISO_VERSION=$(date +%Y%m%d-%H%M)
IMAGE="archlinux:latest"

mkdir -p "$OUTPUT_DIR"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is required" >&2
  exit 1
fi

cat <<INFO
Building ISO in Docker
  Name: $ISO_NAME
  Version: $ISO_VERSION
  Output: $OUTPUT_DIR
INFO

docker run --rm -i --privileged \
  -v "$PROJECT_ROOT:/workspace" \
  -w /workspace \
  "$IMAGE" bash -s <<'EOS'
set -euo pipefail
ISO_NAME="pbos-hyde"
ISO_VERSION=$(date +%Y%m%d-%H%M)
WORK=/tmp/pbos-archiso
PROFILE="$WORK/profile"
OUT=/workspace/iso-output

pacman -Sy --noconfirm reflector archiso
reflector --country US,CA --protocol https --age 12 --sort rate --save /etc/pacman.d/mirrorlist
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf

rm -rf "$WORK"
mkdir -p "$WORK" "$OUT"
cp -r /usr/share/archiso/configs/releng "$PROFILE"
cd "$PROFILE"

# live extras
cat >> packages.x86_64 <<'PKG'
vim
neovim
git
htop
PKG

# custom branding
sed -i "s/iso_name=\"archlinux\"/iso_name=\"$ISO_NAME\"/" profiledef.sh
sed -i "s/iso_version=\"[0-9.]*\"/iso_version=\"$ISO_VERSION\"/" profiledef.sh

# drop automated login stub
rm -f airootfs/root/.automated_script.sh
sed -i '/automated_script/d' airootfs/root/.zlogin 2>/dev/null || true

mkdir -p airootfs/root/installer
cp -a /workspace/installer/* airootfs/root/installer/
chmod -R 755 airootfs/root/installer

mkarchiso -v -w "$WORK/work" -o "$OUT" "$PROFILE"
EOS

ls -lh "$OUTPUT_DIR"/*.iso
