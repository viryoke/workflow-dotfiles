#!/usr/bin/env bash
# Install system apps + dev basics
set -euo pipefail

log() { echo "[apps] $*"; }

PACMAN_PACKAGES=(
    # Browser
    firefox
    # Messaging
    telegram-desktop
    # Media
    mpv
    # Office
    libreoffice-fresh
    # Gaming
    steam gamemode
    # Remote
    mosh
    # Dev basics
    git neovim emacs
    # Audio control (already installed via desktop, but ensure present)
    pavucontrol playerctl
    # Container runtime
    docker podman
    # Calculator (terminal)
    bc
    # Archive tools
    unzip p7zip
    # Disk tools
    btrfs-progs snapper
    # System monitoring
    htop btop
    # Network tools
    curl wget rsync
    # SSH
    openssh
)

AUR_PACKAGES=(
    # Browser
    google-chrome
    # Proxy
    clash-verge-rev-bin
    # Messaging
    wechat-universal-bwrap
    # Editor (GUI)
    vscode-bin
    # Remote desktop
    rustdesk-bin
    # File manager (terminal)
    yazi
    # Terminal multiplexer
    zellij
    # Screen lock helper
    betterlockscreen
)

log "Installing pacman packages: ${PACMAN_PACKAGES[*]}"
pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}"

log "Installing AUR packages: ${AUR_PACKAGES[*]}"
paru -S --needed --noconfirm "${AUR_PACKAGES[@]}" || {
    log "WARNING: Some AUR packages failed — check manually"
}

# Enable docker service
systemctl enable --now docker.service
log "docker enabled"

# Add user to docker group
usermod -aG docker "$(whoami)"
log "User added to docker group (logout required for group to take effect)"

log "Applications done"

# Install Claude Code
log "Installing Claude Code..."
if ! command -v claude &>/dev/null; then
    curl -fsSL https://claude.ai/install.sh | bash
    log "Claude Code installed"
else
    log "Claude Code already installed: $(claude --version 2>/dev/null | head -1)"
fi

# Install Antigravity CLI
log "Installing Antigravity CLI..."
if ! command -v agy &>/dev/null; then
    curl -fsSL https://antigravity.google/cli/install.sh | bash
    log "Antigravity CLI (agy) installed"
else
    log "Antigravity CLI already installed: $(agy --version 2>/dev/null | head -1)"
fi

# Install Antigravity 2.0 (desktop app)
log "Installing Antigravity 2.0..."
ANTIGRAVITY_TMP="$(mktemp -d)"
curl -fsSL "https://storage.googleapis.com/antigravity-public/antigravity-hub/2.0.1-6566078776737792/linux-x64/Antigravity.tar.gz" -o "$ANTIGRAVITY_TMP/Antigravity.tar.gz"
tar -xzf "$ANTIGRAVITY_TMP/Antigravity.tar.gz" -C "$ANTIGRAVITY_TMP"
mkdir -p /opt/antigravity
cp -r "$ANTIGRAVITY_TMP/Antigravity" /opt/antigravity/
ln -sf /opt/antigravity/Antigravity /usr/local/bin/antigravity-hub 2>/dev/null || true
rm -rf "$ANTIGRAVITY_TMP"
log "Antigravity 2.0 installed to /opt/antigravity/"

log "Apps + Antigravity done"