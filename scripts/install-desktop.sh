#!/usr/bin/env bash
# Install desktop ecosystem + fonts + themes + input method
set -euo pipefail

log() { echo "[desktop] $*"; }

PACMAN_PACKAGES=(
    # Window manager + status bar
    niri waybar
    # App launcher + menus
    rofi-wayland
    # Notification center
    swaync
    # Lock + logout
    swaylock wlogout
    # Clipboard
    wl-clipboard cliphist
    # Wallpaper
    swww
    # Night light
    wlsunset
    # Bluetooth
    blueman
    # Screenshots + recording
    slurp grim swappy wf-recorder
    # Input method
    fcitx5 fcitx5-chinese-addons fcitx5-gtk fcitx5-configtool
    # Fonts
    noto-fonts-cjk ttf-jetbrains-mono-nerd
    # Icons + cursor
    papirus-icon-theme bibata-cursor-theme
    # GTK/Qt theme tools
    nwg-look kvantum
    # Audio
    pavucontrol playerctl
    # Terminal
    ghostty
    # File manager
    thunar
    # Modern CLI tools
    eza fd bat ripgrep
)

AUR_PACKAGES=(
    # Emoji picker
    rofi-emoji
    # Catppuccin cursors (if bibata theme not in pacman)
    # Catppuccin GTK theme
    catppuccin-gtk-theme-mocha
    catppuccin-gtk-theme-latte
    # Catppuccin Kv theme for Qt
    catppuccin-kvantum-theme-mocha
    catppuccin-kvantum-theme-latte
)

log "Installing pacman packages: ${PACMAN_PACKAGES[*]}"
pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}"

log "Installing AUR packages: ${AUR_PACKAGES[*]}"
# paru should be installed by install-paru.sh step
paru -S --needed --noconfirm "${AUR_PACKAGES[@]}" || {
    log "WARNING: Some AUR packages failed — check manually"
}

# Set default cursor theme
log "Setting cursor theme to Bibata-Modern-Cursor..."
mkdir -p ~/.icons
if [[ -d /usr/share/icons/Bibata-Modern-Cursor ]]; then
    ln -sf /usr/share/icons/Bibata-Modern-Cursor ~/.icons/default
else
    log "WARNING: Bibata-Modern-Cursor not found in /usr/share/icons"
fi

# Set default icon theme
log "Setting icon theme to Papirus-Dark..."
gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark" 2>/dev/null || true

log "Desktop ecosystem done"