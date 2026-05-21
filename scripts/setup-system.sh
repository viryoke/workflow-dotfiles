#!/usr/bin/env bash
# System basics for CachyOS - snapper, zram, systemd services
set -euo pipefail

log() { echo "[system] $*"; }

log "Configuring snapper for Btrfs snapshots..."

# CachyOS installer already creates snapper config for root subvolume
# Verify it exists and enable timeline + cleanup
if [[ -f /etc/snapper/configs/root ]]; then
    log "Snapper root config found — enabling timeline snapshots"
    sed -i 's/TIMELINE_CREATE="no"/TIMELINE_CREATE="yes"/' /etc/snapper/configs/root
    sed -i 's/TIMELINE_CLEANUP="no"/TIMELINE_CLEANUP="yes"/' /etc/snapper/configs/root
    systemctl enable --now snapper-timeline.timer
    systemctl enable --now snapper-cleanup.timer
    log "Snapper timeline + cleanup enabled"
else
    log "WARNING: No snapper root config found — skipping snapper setup"
fi

# Enable limine-snapper-sync for boot menu snapshot entries
if command -v limine-snapper-sync &>/dev/null; then
    systemctl enable --now limine-snapper-sync.timer
    log "limine-snapper-sync timer enabled"
else
    log "WARNING: limine-snapper-sync not found — install it for boot menu snapshots"
fi

log "Configuring zram..."
# CachyOS usually sets up zram via systemd-zram-setup@zram0.service
if systemctl list-unit-files | grep -q "systemd-zram-setup@zram0.service"; then
    systemctl enable --now systemd-zram-setup@zram0.service
    log "zram enabled"
else
    log "Creating zram swap (4GB)..."
    modprobe zram
    echo "lz4" > /sys/block/zram0/comp_algorithm
    echo "4G" > /sys/block/zram0/disksize
    mkswap /dev/zram0
    swapon -p 100 /dev/zram0
    log "zram swap activated (temporary — add systemd-zram-setup for persistence)"
fi

log "Enabling essential systemd services..."
services=(NetworkManager bluetooth systemd-timesyncd)
for svc in "${services[@]}"; do
    if systemctl list-unit-files "${svc}.service" &>/dev/null; then
        systemctl enable --now "$svc"
        log "Enabled: $svc"
    else
        log "WARNING: $svc not available"
    fi
done

# Set timezone to UTC (adjust if needed)
timedatectl set-timezone UTC
timedatectl set-ntp true
log "Timezone set to UTC, NTP enabled"

log "System basics done"