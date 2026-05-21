# Software Selection Reference

Complete list of software managed by arch-config, grouped by category.
Source: design spec dated 2026-05-21.

---

## 1. Desktop Ecosystem (CachyOS)

Core desktop environment for the CachyOS PC (i9 14900KF + GTX 4060).

| Category | Software | Package source |
|----------|----------|---------------|
| Window Manager | Niri | pacman (CachyOS repo) |
| Status bar | Waybar | pacman |
| App launcher | rofi-wayland | pacman |
| Notification daemon | SwayNC | pacman |
| Theme | Catppuccin Mocha / Latte (dark/light toggle) | chezmoi dotfiles |
| Theme engine | wallbash (wallpaper-driven auto-theming) | AUR or scripts |
| GTK/Qt consistency | nwg-look (GTK) + kvantum (Qt) | pacman |
| Icon theme | Papirus-Icons (Catppuccin folder colors) | pacman |
| Cursor theme | Bibata-Modern-Cursor | pacman or AUR |
| Terminal | Ghostty | pacman or AUR |
| Shell | zsh + starship | pacman |
| Input method | fcitx5-rime + fcitx5-chinese-addons (pinyin fallback) | pacman |
| Lock screen | swaylock | pacman |
| Logout menu | wlogout | pacman |
| Screenshots | hyprshot + slurp + grim + swappy (annotation) | pacman |
| Screen recording | wf-recorder | pacman |
| Wallpaper | swww (animated transitions + GIFs) | pacman |
| Clipboard | wl-clipboard + cliphist | pacman |
| Night light | wlsunset | pacman |
| Idle/lock | Niri built-in idle + swaylock | niri config |
| Bluetooth | blueman | pacman |
| Emoji picker | rofi-emoji | AUR |
| Color picker | hyprpicker | pacman |

### Rofi Menu Suite (7 menus)

| Menu | Script | Invocation |
|------|--------|------------|
| App launcher | default rofi drun | `rofi -show drun` |
| Power menu | `powermenu.sh` | logout/reboot/shutdown/suspend/hibernate via wlogout |
| Clipboard history | `clipboard.sh` | `rofi -show clipboard` via cliphist |
| Screenshot menu | `screenshot.sh` | fullscreen/area/window/timed, save-or-clipboard |
| Emoji picker | `emoji.sh` | `rofi -show emoji` via rofi-emoji |
| Wallpaper selector | `wallpaper.sh` | browse/change wallpaper with swww |
| Theme switcher | `themeswitch.sh` | toggle Catppuccin Mocha/Latte + wallbash mode |

### Waybar Modules (17 modules + tray)

| Module | Purpose |
|--------|---------|
| niri/workspaces | workspace indicator |
| niri/window | active window title |
| keyboard | fcitx5 input method indicator |
| cpu | CPU usage |
| memory | RAM usage |
| temperature | CPU/GPU temp |
| disk | disk usage |
| network | WiFi/Ethernet status |
| bluetooth | device pairing/status toggle |
| pulseaudio | volume + media control |
| battery | battery status (if applicable) |
| backlight | brightness |
| idle_inhibitor | prevent auto-lock toggle |
| custom/swaync | notification center toggle |
| custom/cliphist | clipboard manager toggle |
| custom/wlsunset | night light toggle |
| tray | system tray |

---

## 2. Applications

| Category | Software | Package source |
|----------|----------|---------------|
| Editor (terminal) | Neovim (LazyVim) | pacman + LazyVim bootstrap |
| Editor (Emacs) | Doom Emacs | pacman + doom install script |
| Editor (GUI) | VS Code | AUR |
| File manager (terminal) | Yazi | pacman |
| File manager (GUI) | Thunar | pacman |
| Calculator | rofi-calc | AUR |
| Terminal multiplexer | Zellij | pacman |
| Proxy | clash-verge-rev-bin | AUR |
| Messaging | Telegram Desktop | pacman |
| Messaging | WeChat | AUR (wechat-universal-bwrap) |
| AI agent (Google) | Antigravity 2.0 (desktop) + Antigravity CLI (agy) | curl install script / .tar.gz download |
| AI CLI | Claude Code | curl install script |
| Browser | Firefox | pacman |
| Browser | Chrome | pacman |
| Media player | MPV | pacman |
| Audio control | pavucontrol + playerctl | pacman |
| Office | LibreOffice | pacman |
| Mail | Gmail in Chrome | -- |
| Gaming | Steam + DOTA2 | pacman + gamemode |
| Fonts | JetBrainsMono Nerd Font + Noto CJK | pacman |
| Remote shell | Mosh | pacman |
| Remote desktop | Rustdesk (self-hosted) | AUR |
| Mesh VPN | Tailscale | AUR (tailscale-bin) |

---

## 3. System Services

| Category | Software | Package source |
|----------|----------|---------------|
| Containers | Docker + Podman | pacman |
| Encryption | age | pacman |
| Filesystem | Btrfs + Snapper + Limine + limine-snapper-sync | pacman (CachyOS installer) |
| NVIDIA driver | nvidia-dkms | pacman (CachyOS repo) |
| CUDA runtime | cuda | pacman (CachyOS repo) |
| Night light | wlsunset | pacman |
| Bluetooth | blueman | pacman |
| Icon theme | Papirus-Icons | pacman |
| Cursor theme | Bibata-Modern-Cursor | AUR |

---

## 4. Development Tools (nix devShells)

All dev environments are isolated via nix. Activated with `nix develop .#<name>`.

| Category | Software | Managed by |
|----------|----------|------------|
| Python | uv + python3.13 | nix develop `.#python` |
| Node.js | Bun + nodejs_22 | nix develop `.#nodejs` |
| Rust | rustc + cargo + rust-analyzer | nix develop `.#rust` |
| Go | go (latest stable) | nix develop `.#go` |
| C++ | gcc + cmake + clang | nix develop `.#cpp` |
| Java | jdk (latest LTS) + gradle | nix develop `.#java` |
| CUDA toolkit | cudaPackages (latest) | nix develop `.#cuda` |
| AI CLI | Claude Code + Antigravity CLI | nix develop `.#ai` + curl install |

---

## Package Source Summary

| Source | Scope |
|--------|-------|
| pacman (CachyOS repo) | Desktop, drivers, system, most apps |
| pacman (standard Arch) | General packages |
| AUR / paru | Theme tools, niche apps (VS Code, WeChat, Ghostty, rofi-emoji, etc.) |
| chezmoi dotfiles | Config files, theme definitions |
| nix develop | Dev environments only (isolated, non-system) |

**Division principle**: pacman manages everything visible (desktop, drivers, apps). nix manages invisible dev environments only. If nix breaks, only dev shells are affected; the system keeps working. pacman packages are debuggable via Arch Wiki.