#!/bin/bash
# Launch common apps, installing them first when missing.

set -e

notify_missing() {
    local cmd="$1"
    local pkg="$2"
    notify-send "Missing $cmd" "Attempting to install $pkg"
}

pick_installer() {
    if command -v paru >/dev/null 2>&1; then
        echo "paru -S --needed --noconfirm"
    elif command -v yay >/dev/null 2>&1; then
        echo "yay -S --needed --noconfirm"
    elif command -v pacman >/dev/null 2>&1; then
        echo "sudo pacman -S --needed"
    else
        echo ""
    fi
}

run_or_install() {
    local cmd="$1"
    local pkg="$2"
    shift 2
    local args=("$@")

    if command -v "$cmd" >/dev/null 2>&1; then
        exec "$cmd" "${args[@]}"
    fi

    local installer
    installer=$(pick_installer)

    if [ -n "$installer" ]; then
        notify_missing "$cmd" "$pkg"
        kitty -e bash -lc "$installer $pkg" || notify-send "Install $pkg" "Installer closed or failed"
        exec "$cmd" "${args[@]}"
    else
        notify-send "No installer available" "Install $pkg then retry"
        exit 1
    fi
}

case "$1" in
    files)
        run_or_install thunar thunar
        ;;
    nvim)
        run_or_install nvim neovim
        ;;
    browser)
        run_or_install firefox firefox
        ;;
    music)
        run_or_install ncmpcpp ncmpcpp
        ;;
    *)
        notify-send "Unknown launcher target" "$1"
        exit 1
        ;;
esac
