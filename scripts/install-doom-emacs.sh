#!/usr/bin/env bash
# Install Doom Emacs
set -euo pipefail

log() { echo "[doom] $*"; }

# Ensure emacs is installed
if ! command -v emacs &>/dev/null; then
    log "emacs not found — installing..."
    pacman -S --needed --noconfirm emacs
fi

# Check if Doom is already installed
if [[ -d ~/.config/emacs ]]; then
    log "Doom Emacs already installed — syncing..."
    ~/.config/emacs/bin/doom sync
    log "Doom synced"
    exit 0
fi

log "Cloning Doom Emacs..."
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs

log "Installing Doom Emacs..."
~/.config/emacs/bin/doom install

log "Doom Emacs installed — run 'emacs' to verify"
log "Custom modules go in: ~/.config/doom/init.el"