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