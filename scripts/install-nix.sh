#!/usr/bin/env bash
# Install nix package manager with flakes enabled
set -euo pipefail

log() { echo "[nix] $*"; }

# Check if nix is already installed
if command -v nix &>/dev/null; then
    log "nix already installed: $(nix --version)"
    exit 0
fi

log "Installing nix via official installer..."
# Multi-user installation (recommended for CachyOS)
sh <(curl -L https://nixos.org/nix/install) --daemon

# Source nix profile
if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# Enable flakes and nix-command (experimental but essential)
log "Enabling flakes + nix-command experimental features..."
mkdir -p ~/.config/nix
cat > ~/.config/nix/nix.conf << 'NIXCONF'
experimental-features = nix-command flakes
auto-optimise-store = true
keep-outputs = true
keep-derivations = true
NIXCONF

# Also set system-wide if possible
if [[ -d /etc/nix ]]; then
    if ! grep -q "experimental-features" /etc/nix/nix.conf 2>/dev/null; then
        echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf
    fi
fi

# Verify nix works
log "Verifying nix installation..."
nix --version
nix run nixpkgs#hello --quiet 2>/dev/null && log "nix run test passed" || log "WARNING: nix run test failed — check nix.conf"

log "nix installed and configured"