#!/bin/bash

# Deprecated: HyDE now owns configuration management
# The previous workflow verified VM connectivity for dotfile syncing.
# With the HyDE-based setup, dotfiles are not transferred; HyDE installs and manages configs.
# This script now exits early to avoid using the old dotfile sync pipeline.

echo "[info] VM dotfile-sync verification is no longer needed because HyDE manages configuration."
echo "[info] No checks performed."
exit 0
