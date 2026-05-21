#!/usr/bin/env bash
# NVIDIA driver setup for CachyOS - verify + enable services
set -euo pipefail

log() { echo "[nvidia] $*"; }

# CachyOS installer includes nvidia-dkms — verify it's working
log "Verifying NVIDIA driver..."

if pacman -Q nvidia-dkms &>/dev/null; then
    log "nvidia-dkms installed: $(pacman -Q nvidia-dkms)"
else
    log "nvidia-dkms NOT found — installing..."
    pacman -S --needed --noconfirm nvidia-dkms
fi

# Load nvidia modules
log "Loading NVIDIA kernel modules..."
modprobe nvidia 2>/dev/null || true
modprobe nvidia_modeset 2>/dev/null || true
modprobe nvidia_uvm 2>/dev/null || true
modprobe nvidia_drm 2>/dev/null || true

# Verify GPU is detected
if lspci -k | grep -A3 "VGA" | grep -q "NVIDIA"; then
    log "NVIDIA GPU detected: $(lspci | grep VGA)"
else
    log "WARNING: No NVIDIA GPU found in lspci"
fi

# Enable nvidia-persistenced (keeps GPU initialized for faster wake)
if command -v nvidia-persistenced &>/dev/null; then
    systemctl enable --now nvidia-persistenced.service
    log "nvidia-persistenced enabled"
fi

# Enable nvidia-powerd (dynamic power management for GTX 4060)
if systemctl list-unit-files | grep -q "nvidia-powerd.service"; then
    systemctl enable --now nvidia-powerd.service
    log "nvidia-powerd enabled"
else
    log "nvidia-powerd not available (may not exist on all systems)"
fi

# DRM KMS modification for niri/wayland — ensure nvidia-drm.modeset=1
log "Checking kernel parameters for nvidia-drm.modeset=1..."
if grep -q "nvidia-drm.modeset=1" /etc/cmdline.d/*.conf 2>/dev/null || \
   grep -q "nvidia-drm.modeset=1" /proc/cmdline 2>/dev/null; then
    log "nvidia-drm.modeset=1 already set"
else
    log "Adding nvidia-drm.modeset=1 to kernel parameters..."
    # CachyOS uses Limine bootloader with cmdline.d directory
    echo "nvidia-drm.modeset=1" >> /etc/cmdline.d/nvidia.conf
    log "Kernel parameter added — reboot required for full effect"
fi

log "NVIDIA setup done"