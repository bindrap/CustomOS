#!/bin/bash

# Deprecated: HyDE now owns configuration management
# This script formerly synced dotfiles from the VM to your local development environment.
# With the HyDE-based setup, dotfiles are not transferred; HyDE installs and manages configs.
# The script now exits early to avoid accidental use of the old workflow.

echo "[info] Dotfile sync is disabled because HyDE manages configuration now."
echo "[info] No action taken."
exit 0
