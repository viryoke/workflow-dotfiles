#!/usr/bin/env bash
# Bootstrap LazyVim — Neovim distribution
set -euo pipefail

log() { echo "[lazyvim] $*"; }

# Ensure neovim is installed
if ! command -v nvim &>/dev/null; then
    log "neovim not found — installing..."
    pacman -S --needed --noconfirm neovim
fi

log "LazyVim bootstrap: backing up existing nvim config..."
NVIM_DIR=~/.config/nvim
if [[ -d "$NVIM_DIR" ]] && [[ ! -d "$NVIM_DIR/lazy" ]]; then
    BACKUP=~/.config/nvim.bak.$(date +%Y%m%d%H%M%S)
    mv "$NVIM_DIR" "$BACKUP"
    log "Existing config backed up to $BACKUP"
fi

# Clean state directories
rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim

log "Installing LazyVim starter..."
# LazyVim uses a git-based starter template
git clone https://github.com/LazyVim/starter "$NVIM_DIR" --depth 1
rm -rf "$NVIM_DIR/.git"

log "Running initial LazyVim bootstrap (this will install plugins)..."
nvim --headless "+Lazy! sync" +qa 2>/dev/null || true

log "LazyVim installed — run 'nvim' to verify and customize plugins"
log "Custom config goes in: $NVIM_DIR/lua/plugins/"