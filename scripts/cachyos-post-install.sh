#!/usr/bin/env bash
# CachyOS post-install automation - arch-config
# Orchestrates all setup steps for a fresh CachyOS Niri desktop
# Usage: bash ~/arch-config/scripts/cachyos-post-install.sh [--skip-step <name>]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/tmp/cachyos-post-install.log"

STEP_LIST=(
    "system:      System basics (snapper, zram, systemd)"
    "nvidia:      NVIDIA driver verification + services"
    "paru:        AUR helper (paru)"
    "desktop:     Desktop ecosystem + fonts + themes + input method"
    "apps:        System apps + dev basics"
    "nix:         nix package manager + flakes"
    "chezmoi:     age + chezmoi + dotfile apply"
    "lazyvim:     LazyVim bootstrap"
    "doom:        Doom Emacs"
    "tailscale:   Tailscale mesh VPN"
)

SKIP_STEPS=()

log() { echo "[$(date '+%H:%M:%S')] $*" | tee -a "$LOG_FILE"; }
err() { log "ERROR: $*" >&2; }

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --skip-step)
                SKIP_STEPS+=("$2")
                shift 2
                ;;
            --help)
                echo "Usage: bash cachyos-post-install.sh [--skip-step <name>]"
                echo ""
                echo "Available steps:"
                for step in "${STEP_LIST[@]}"; do echo "  $step"; done
                echo ""
                echo "Example: bash cachyos-post-install.sh --skip-step doom --skip-step tailscale"
                exit 0
                ;;
            *) err "Unknown argument: $1"; exit 1 ;;
        esac
    done
}

should_skip() {
    local name="$1"
    for skip in "${SKIP_STEPS[@]}"; do
        [[ "$skip" == "$name" ]] && return 0
    done
    return 1
}

run_step() {
    local name="$1"
    local script="$2"
    local desc="$3"

    if should_skip "$name"; then
        log "SKIP: $desc (--skip-step $name)"
        return 0
    fi

    log "START: $desc"
    if [[ -f "$SCRIPT_DIR/$script" ]]; then
        if bash "$SCRIPT_DIR/$script"; then
            log "DONE: $desc"
        else
            err "FAILED: $desc — check $LOG_FILE"
            log "Continuing with remaining steps..."
        fi
    else
        err "Script not found: $SCRIPT_DIR/$script"
    fi
}

main() {
    parse_args "$@"

    log "=== CachyOS Post-Install Start ==="
    log "Log file: $LOG_FILE"

    # Verify we're on CachyOS Linux
    if [[ "$(uname -s)" != "Linux" ]]; then
        err "This script is designed for CachyOS Linux. Current OS: $(uname -s)"
        exit 1
    fi

    # Check for CachyOS-specific markers
    if ! grep -q "cachyos" /etc/os-release 2>/dev/null; then
        log "WARNING: /etc/os-release doesn't mention cachyos — proceeding anyway"
    fi

    log "Steps to run (skipped steps marked with SKIP):"
    for step in "${STEP_LIST[@]}"; do
        local name="${step%%:*}"
        if should_skip "$name"; then
            log "  SKIP: $step"
        else
            log "  RUN:  $step"
        fi
    done
    log ""

    run_step "system"    "setup-system.sh"        "System basics"
    run_step "nvidia"    "install-nvidia.sh"      "NVIDIA setup"
    run_step "paru"      "install-paru.sh"        "AUR helper"
    run_step "desktop"   "install-desktop.sh"     "Desktop ecosystem"
    run_step "apps"      "install-apps.sh"        "Applications"
    run_step "nix"       "install-nix.sh"         "nix package manager"
    run_step "chezmoi"   "setup-chezmoi.sh"       "chezmoi + dotfiles"
    run_step "lazyvim"   "install-lazyvim.sh"     "LazyVim"
    run_step "doom"      "install-doom-emacs.sh"  "Doom Emacs"
    run_step "tailscale" "install-tailscale.sh"   "Tailscale VPN"

    log ""
    log "=== CachyOS Post-Install Complete ==="
    log "Next steps:"
    log "  1. Start niri: niri"
    log "  2. Verify desktop, waybar, rofi menus"
    log "  3. Use dev environments: cd ~/arch-config/nix && nix develop .#python"
    log "  4. Authenticate tailscale: tailscale up"
}

main "$@"