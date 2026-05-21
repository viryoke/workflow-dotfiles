#!/usr/bin/env bash
# Install age + chezmoi, init from arch-config repo, apply dotfiles
set -euo pipefail

log() { echo "[chezmoi] $*"; }

# Install age (encryption tool for chezmoi)
log "Installing age..."
if ! command -v age &>/dev/null; then
    pacman -S --needed --noconfirm age
fi

# Install chezmoi
log "Installing chezmoi..."
if ! command -v chezmoi &>/dev/null; then
    pacman -S --needed --noconfirm chezmoi
fi

# Check if chezmoi is already initialized
if [[ -d ~/.local/share/chezmoi ]]; then
    log "chezmoi already initialized — re-applying..."
    chezmoi apply --force
    log "Dotfiles re-applied"
    exit 0
fi

# Determine repo URL — prefer HTTPS for first-time setup
REPO_DIR="$(pwd)"
if [[ -d "$REPO_DIR/.git" ]]; then
    log "Using local repo at $REPO_DIR"
    # Init from local copy
    chezmoi init --source "$REPO_DIR" --apply
else
    # Clone from GitHub
    REPO_URL="https://github.com/viryoke/arch-config.git"
    log "Initializing chezmoi from $REPO_URL..."
    chezmoi init --apply "$REPO_URL"
fi

log "Dotfiles applied"

# Verify key configs exist
log "Verifying deployed configs..."
for f in ~/.zshrc ~/.gitconfig ~/.config/ghostty/config; do
    if [[ -f "$f" ]]; then
        log "  OK: $f"
    else
        log "  MISSING: $f"
    fi
done

# Check Linux-only configs
if [[ "$(uname -s)" == "Linux" ]]; then
    for f in ~/.config/niri/config.kdl ~/.config/waybar/config.jsonc ~/.config/waybar/style.css; do
        if [[ -f "$f" ]]; then
            log "  OK: $f"
        else
            log "  MISSING: $f"
        fi
    done
fi

log "chezmoi setup done"