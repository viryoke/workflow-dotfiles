#!/usr/bin/env bash
# Install paru — AUR helper for CachyOS
set -euo pipefail

log() { echo "[paru] $*"; }

# Check if paru is already installed
if command -v paru &>/dev/null; then
    log "paru already installed: $(paru --version | head -1)"
    exit 0
fi

# Ensure base-devel and git are installed (required to build paru)
log "Installing base-devel and git..."
pacman -S --needed --noconfirm base-devel git

# Clone and build paru
PARU_TMP="$(mktemp -d)"
log "Cloning paru from AUR..."
git clone https://aur.archlinux.org/paru.git "$PARU_TMP"

cd "$PARU_TMP"
log "Building paru..."
makepkg -si --noconfirm --needed

cd /
rm -rf "$PARU_TMP"

# Configure paru — enable AUR, bottom-up review, clean after build
PARU_CONF="/etc/paru.conf"
if [[ -f "$PARU_CONF" ]]; then
    log "Configuring paru..."
    sed -i 's/^#BottomUp$/BottomUp/' "$PARU_CONF"
    sed -i 's/^#CleanAfter$/CleanAfter/' "$PARU_CONF"
    sed -i 's/^#RemoveMake$/RemoveMake/' "$PARU_CONF"
fi

log "paru installed and configured"