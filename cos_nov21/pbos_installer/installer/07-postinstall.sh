#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/00-env.sh"
require_root

log INFO "Post-install: performance + Hyprland/HyDE + gaming"

require_net() {
  if ping -c1 -W3 1.1.1.1 >/dev/null 2>&1 || ping -c1 -W3 archlinux.org >/dev/null 2>&1; then
    return 0
  fi
  log ERR "Network unavailable"
  exit 1
}

setup_chaotic() {
  if grep -q '^\[chaotic-aur\]' /etc/pacman.conf; then
    log INFO "Chaotic-AUR already configured"
    return
  fi
  local key_id="3056513887B78AEB"
  local primary_keyring="https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst"
  local primary_mirrorlist="https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst"
  local backup_keyring="https://repo.kitsuna.net/chaotic-aur/chaotic-keyring.pkg.tar.zst"
  local backup_mirrorlist="https://repo.kitsuna.net/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst"

  run pacman -Sy --noconfirm --needed archlinux-keyring gnupg
  pacman-key --recv-key "$key_id" || pacman-key --keyserver hkps://keyserver.ubuntu.com --recv-key "$key_id"
  pacman-key --lsign-key "$key_id"

  if ! pacman -U --noconfirm --needed "$primary_keyring" "$primary_mirrorlist"; then
    run pacman -U --noconfirm --needed "$backup_keyring" "$backup_mirrorlist"
  fi

  cat >> /etc/pacman.conf <<'EOFCHAOTIC'
[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOFCHAOTIC
  run pacman -Sy --noconfirm
}

require_net
setup_chaotic
run pacman -Syu --noconfirm

if [[ "${INSTALL_CACHY_KERNEL:-yes}" == "yes" ]]; then
  log INFO "Installing CachyOS kernel"
  run pacman -S --noconfirm --needed linux-cachyos linux-cachyos-headers
  ROOT_DEV=$(findmnt -n -o SOURCE /)
  ROOT_UUID=$(blkid -s UUID -o value "$ROOT_DEV")
  if [[ -d /boot/loader/entries ]]; then
    cat > /boot/loader/entries/arch-cachyos.conf <<EOFENTRY
title   PBOS (linux-cachyos)
linux   /vmlinuz-linux-cachyos
initrd  /initramfs-linux-cachyos.img
options root=UUID=$ROOT_UUID rw quiet splash loglevel=3
EOFENTRY
    sed -i 's/^default .*/default arch-cachyos.conf/' /boot/loader/loader.conf
  elif [[ -x /usr/bin/grub-mkconfig ]]; then
    run grub-mkconfig -o /boot/grub/grub.cfg
  fi
fi

if [[ "${USE_ZRAM:-yes}" == "yes" ]]; then
  log INFO "Configuring zram"
  run pacman -S --noconfirm --needed zram-generator
  cat > /etc/systemd/zram-generator.conf <<'EOFZRAM'
[zram0]
zram-size = ram/2
compression-algorithm = zstd
EOFZRAM
  run systemctl enable systemd-zram-setup@zram0.service
fi

log INFO "Applying sysctl performance tuning"
cat > /etc/sysctl.d/99-performance.conf <<'EOFSYSCTL'
vm.swappiness=10
kernel.sched_latency_ns=6000000
kernel.sched_min_granularity_ns=750000
EOFSYSCTL

log INFO "Installing CPU governor helper"
run pacman -S --noconfirm --needed auto-cpufreq
run systemctl enable auto-cpufreq

log INFO "Installing GPU/base multimedia stack"
run pacman -S --noconfirm --needed mesa vulkan-radeon amdvlk pipewire pipewire-pulse wireplumber

log INFO "Installing Hyprland desktop bits"
run pacman -S --noconfirm --needed hyprland hyprpaper hyprutils xdg-desktop-portal-hyprland waybar eww kitty wofi mako thunar pavucontrol grim slurp wl-clipboard firefox

if [[ "${USE_HYDE:-yes}" == "yes" ]]; then
  require_net
  HYDE_DIR="/home/$USERNAME/HyDE"
  run pacman -S --noconfirm --needed git base-devel qt5-base qt5-wayland mangohud hyprpicker ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji ttf-font-awesome
  run rm -rf "$HYDE_DIR"
  run sudo -u "$USERNAME" git clone --depth 1 https://github.com/HyDE-Project/HyDE "$HYDE_DIR"
  pushd "$HYDE_DIR/Scripts" >/dev/null
  export HYDE_BAR="waybar"
  sudo -u "$USERNAME" env HYDE_BAR="$HYDE_BAR" yes '' | ./install.sh
  popd >/dev/null
fi

if [[ "${INSTALL_GAMING_STACK:-yes}" == "yes" ]]; then
  log INFO "Installing gaming stack"
  run pacman -S --noconfirm --needed gamemode gamescope mangohud lutris heroic-games-launcher-bin wine-ge-custom proton-ge-custom
  sudo -u "$USERNAME" systemctl --user enable gamemoded 2>/dev/null || true
fi

log INFO "Post-install complete"
