# CachyOS Installation Guide

Step-by-step guide for installing CachyOS Desktop Edition with Niri on the target PC.

## Hardware

| Component | Spec |
|-----------|------|
| CPU | Intel i9 14900KF |
| GPU | NVIDIA GTX 4060 8GB |
| RAM | 64GB DDR5 |
| Storage | 2TB NVMe |
| Bootloader | Limine (modern, themeable, Btrfs snapshot support) |

## Pre-Install

### 1. Download CachyOS ISO

Get the latest Desktop Edition ISO from [cachyos.org](https://cachyos.org). Choose:
- **Desktop Edition** (not base)
- **Niri edition** if available as installer option
- **x86-64-v3** optimized build (matches i9 14900KF which supports x86-64-v3)

### 2. Write ISO to USB

```bash
# On Mac (using dd)
sudo dd if=CachyOS-desktop.iso of=/dev/diskN bs=4M status=progress && sync

# Or use balenaEtcher for a GUI approach
```

### 3. Boot from USB

- Insert USB, reboot PC
- Enter BIOS/UEFI (usually F2 or Del)
- Ensure:
  - UEFI mode enabled (not legacy BIOS)
  - Secure Boot disabled (required for Limine + NVIDIA dkms)
  - Boot order: USB first
- Save and reboot into CachyOS live environment

## Installation

### 4. Run Calamares Installer

CachyOS uses the Calamares graphical installer. Key selections:

| Setting | Choice | Reason |
|---------|--------|--------|
| Desktop | Niri | Scrollable window manager, Wayland-native |
| Partitioning | Automatic (Btrfs) | CachyOS default with Snapper integration |
| Filesystem | Btrfs | Snapshots, compression, rollback via Limine |
| Bootloader | Limine | Modern bootloader with snapper-sync for boot menu snapshots |
| Kernel | linux-cachyos (x86-64-v3) | CPU-optimized kernel for i9 14900KF |
| NVIDIA driver | nvidia-dkms | CachyOS repo includes optimized NVIDIA packages |

#### Manual partitioning (if preferred):

```
/dev/nvme0n1p1  512MB   EFI System Partition (vfat)
/dev/nvme0n1p2  rest    Btrfs root (with @, @home, @cache, @log, @snapshots subvolumes)
```

CachyOS Calamares creates these Btrfs subvolumes by default:
- `@` — root filesystem
- `@home` — home directory
- `@cache` — package cache
- `@log` — system logs
- `@snapshots` — snapper snapshots

### 5. Complete Installation

- Set hostname, username, password
- Wait for installation to complete
- Reboot (remove USB)

## Post-Install

### 6. First Boot Verification

After first boot into CachyOS Niri:

```bash
# Verify kernel
uname -r  # should show linux-cachyos with x86-64-v3

# Verify NVIDIA driver loaded
nvidia-smi  # should show GTX 4060

# Verify Btrfs + subvolumes
btrfs subvolume list /

# Verify Limine bootloader
limine-snapper-sync list
```

### 7. Run arch-config Post-Install

```bash
# Clone the config repo
git clone https://github.com/viryoke/arch-config.git ~/arch-config

# Run the automated post-install
bash ~/arch-config/scripts/cachyos-post-install.sh

# Or skip specific steps:
bash ~/arch-config/scripts/cachyos-post-install.sh --skip-step doom --skip-step tailscale
```

The post-install script handles:
- System basics (snapper, zram, systemd services)
- NVIDIA verification + services
- AUR helper (paru)
- Desktop ecosystem (waybar, rofi, SwayNC, fonts, themes, input method)
- Applications (browsers, messaging, gaming, dev tools)
- nix package manager + flakes
- age + chezmoi dotfile deployment
- LazyVim + Doom Emacs bootstrapping
- Tailscale mesh VPN

### 8. Start Niri Desktop

```bash
# Launch niri (after post-install completes)
niri

# Or if niri is already running (auto-started):
# Press Mod+Return to open ghostty terminal
# Press Mod+D to open rofi app launcher
```

### 9. Verify Desktop

Check these items after launching Niri:
- Waybar appears at top with all modules
- Rofi app launcher works (Mod+D)
- SwayNC notification center (custom/swaync module in waybar)
- fcitx5 input method for Chinese (Ctrl+Space to toggle)
- Theme is Catppuccin Mocha (dark)

### 10. Configure Theme

Toggle between dark/light themes:

```bash
# Via rofi theme switcher (Mod+Shift+T)
# Or command-line quick toggle:
~/.config/rofi-wayland/scripts/themeswitch.sh --toggle
```

### 11. Set Up Dev Environments

```bash
cd ~/arch-config/nix

# Python
nix develop .#python

# Node.js
nix develop .#nodejs

# Rust
nix develop .#rust

# CUDA (Linux only)
nix develop .#cuda

# AI tools
nix develop .#ai
```

### 12. Tailscale Authentication

```bash
tailscale up
# Follow the URL to authenticate with your Tailscale account
```

## Troubleshooting

### NVIDIA issues

```bash
# Verify nvidia-drm.modeset=1 is in kernel params
cat /proc/cmdline

# Rebuild initramfs if NVIDIA modules missing
sudo mkinitcpio -P

# Check NVIDIA services
systemctl status nvidia-persistenced
systemctl status nvidia-powerd
```

### Niri won't start

```bash
# Check niri logs
niri 2>&1 | head -50

# Common issue: missing environment variables
export XDG_CURRENT_DESKTOP=niri
export QT_QPA_PLATFORM=wayland
```

### Waybar not showing

```bash
# Restart waybar
killall waybar && waybar &

# Check waybar config
chezmoi verify ~/.config/waybar/config.jsonc
```

### Btrfs rollback (if system breaks)

```bash
# List snapshots
snapper list

# Rollback to last working snapshot
snapper rollback <number>

# Or boot into snapshot from Limine boot menu
# (limine-snapper-sync adds snapshots to boot menu)
```

### chezmoi issues

```bash
# Re-apply all dotfiles
chezmoi apply --force

# Check what chezmoi manages
chezmoi managed

# Edit a config file
chezmoi edit ~/.config/niri/config.kdl
```