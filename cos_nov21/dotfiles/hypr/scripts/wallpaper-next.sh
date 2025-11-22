#!/bin/bash
# Cycle to next wallpaper

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/wallpaper-lib.sh"

cycle_wallpaper "next"
