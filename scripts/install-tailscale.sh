#!/usr/bin/env bash
# Install and configure Tailscale mesh VPN
set -euo pipefail

log() { echo "[tailscale] $*"; }

# Install tailscale (AUR package)
if ! command -v tailscale &>/dev/null; then
    log "Installing tailscale-bin from AUR..."
    paru -S --needed --noconfirm tailscale-bin || {
        log "WARNING: tailscale-bin install failed — try manually: paru -S tailscale-bin"
        exit 1
    }
fi

# Enable tailscaled service
log "Enabling tailscaled service..."
systemctl enable --now tailscaled.service

log "Tailscale installed and service enabled"
log "To authenticate: tailscale up"
log "This will open a browser to log in to your Tailscale account"
log ""
log "Optional: tailscale up --advertise-tags=tag:pc --hostname=cachyos"