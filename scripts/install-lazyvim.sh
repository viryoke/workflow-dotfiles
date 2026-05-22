#!/usr/bin/env bash
# Bootstrap LazyVim — Neovim distribution
# Note: chezmoi already provides custom nvim config (dot_config/nvim/)
# This script only bootstraps the plugin system, does NOT clone the starter
set -euo pipefail

log() { echo "[lazyvim] $*"; }

# Ensure neovim is installed
if ! command -v nvim &>/dev/null; then
    log "neovim not found — installing..."
    pacman -S --needed --noconfirm neovim
fi

# Ensure chezmoi has deployed nvim config
NVIM_DIR="$HOME/.config/nvim"
if [[ ! -d "$NVIM_DIR" ]]; then
    log "No nvim config found — running chezmoi apply first..."
    chezmoi apply
fi

# Clean plugin state directories for fresh bootstrap
rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim

log "Running initial LazyVim bootstrap (this will install plugins)..."
nvim --headless "+Lazy! sync" +qa 2>/dev/null || true

log "LazyVim installed — run 'nvim' to verify"
log "Custom config managed by chezmoi: dot_config/nvim/"