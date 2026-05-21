# arch-config Project Design Spec

**Date**: 2026-05-21
**Status**: Approved by user

## Overview

`arch-config` is a chezmoi-based dotfile management project + CachyOS post-install automation + nix dev environments. It manages configuration for two machines: a CachyOS Linux PC (i9 14900KF + GTX 4060) and a macOS MacBook Air M2.

## OS and Tooling Decisions

| Decision | Choice | Reason |
|----------|--------|--------|
| OS (PC) | CachyOS Desktop Edition (Niri, x86-64-v3, Btrfs, Limine, NVIDIA) | Only distro with x86-64-v3 CPU optimizations; Limine is modern bootloader with limine-snapper-sync for Btrfs snapshot boot menu + themeable skins; Niri is installer option |
| Dotfile management | chezmoi + age encryption | Template-based cross-platform (Mac+Linux) sync; built-in encryption; `chezmoi init --apply` one-command deployment |
| nix usage | `nix develop` / `nix-shell` only | Dev environment isolation (CUDA/Python/Node.js/AI); NOT managing desktop or system config — user cannot write/debug nix independently |
| Mesh VPN | Tailscale | 3-device free tier sufficient; best macOS client; zero-config; can migrate to Headscale later |
| Encryption | age | Simple, modern, chezmoi built-in support |

## Software Selection

### Desktop ecosystem (CachyOS)

| Category | Software | Package source |
|----------|----------|---------------|
| Window Manager | Niri | pacman (CachyOS repo) |
| Status bar | Waybar | pacman |
| App launcher | rofi-wayland | pacman |
| Notification daemon | SwayNC (replaces dunst) | pacman |
| Theme | Catppuccin Mocha / Latte (dark/light toggle) | chezmoi dotfiles |
| Theme engine | wallbash (wallpaper-driven auto-theming for Waybar/Rofi/Ghostty/GTK/Niri) | AUR or scripts |
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
| Clipboard | wl-clipboard + cliphist (history manager) | pacman |
| Night light | wlsunset | pacman |
| Idle/lock | Niri built-in idle + swaylock | niri config |
| Bluetooth | blueman | pacman |
| Emoji picker | rofi-emoji | AUR |
| Color picker | hyprpicker | pacman |

### Rofi menu suite (7 menus)

| Menu type | Purpose |
|-----------|---------|
| App launcher | `rofi -show drun` |
| Power menu | logout/reboot/shutdown/suspend/hibernate |
| Clipboard history | `rofi -show clipboard` via cliphist |
| Screenshot menu | fullscreen/area/window/timed/save-or-clipboard |
| Emoji picker | `rofi -show emoji` via rofi-emoji |
| Wallpaper selector | browse/change wallpaper with swww |
| Theme switcher | toggle Catppuccin Mocha ↔ Latte + wallbash mode |

### Waybar modules (full set)

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

### Applications

| Category | Software | Package source |
|----------|----------|---------------|
| Editor (terminal) | Neovim (LazyVim) | pacman + LazyVim bootstrap |
| Editor (Emacs) | Doom Emacs | pacman + doom install script |
| Editor (GUI) | VS Code | AUR |
| File manager | Yazi (terminal) + Thunar (GUI) | pacman |
| Calculator | rofi-calc | AUR |
| Terminal multiplexer | Zellij | pacman |
| Proxy | clash-verge-rev-bin | AUR |
| Messaging | Telegram Desktop | pacman |
| Messaging | WeChat | AUR (wechat-universal-bwrap) |
| Browser | Firefox + Chrome | pacman |
| Media player | MPV | pacman |
| Audio control | pavucontrol + playerctl | pacman |
| Office | LibreOffice | pacman |
| Mail | Web (Gmail in Chrome) | — |
| Gaming | Steam + DOTA2 | pacman + gamemode |
| Fonts | JetBrainsMono Nerd Font + Noto CJK | pacman |
| Remote shell | Mosh | pacman |
| Remote desktop | Rustdesk (self-hosted) | AUR |
| Mesh VPN | Tailscale | AUR (tailscale-bin) |

### System services

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

### Development (nix devShells only)

| Category | Software | Managed by |
|----------|----------|------------|
| Python | uv + python3.13 | nix develop `.#python` |
| Node.js | Bun + nodejs_22 | nix develop `.#nodejs` |
| Rust | rustc + cargo + rust-analyzer | nix develop `.#rust` |
| Go | go (latest stable) | nix develop `.#go` |
| C++ | gcc + cmake + clang | nix develop `.#cpp` |
| Java | jdk (latest LTS) + gradle | nix develop `.#java` |
| CUDA toolkit | cudaPackages (latest) | nix develop `.#cuda` |
| AI CLI | Claude Code | nix develop `.#ai` |

## Project Structure

```
arch-config/          ← git repo = chezmoi source dir
├── dot_config/       ← ~/.config/ files
│   ├── niri/
│   │   ├── config.kdl.tmpl
│   │   ├── keybindings.kdl
│   │   └── windowrules.kdl
│   ├── ghostty/
│   │   └── config.tmpl
│   ├── waybar/
│   │   ├── config.tmpl
│   │   └── style.css
│   ├── rofi-wayland/
│   │   ├── config.rasi
│   │   ├── themes/
│   │   └── scripts/
│   │       ├── powermenu.sh
│   │       ├── screenshot.sh
│   │       ├── clipboard.sh
│   │       ├── emoji.sh
│   │       ├── wallpaper.sh
│   │       └── themeswitch.sh
│   ├── swaync/
│   │   ├── config.json
│   │   └── style.css
│   ├── starship.toml.tmpl
│   ├── zsh/
│   │   ├── .zshrc.tmpl
│   │   └── .zshenv.tmpl
│   ├── fcitx5/
│   ├── lazyvim/
│   ├── zellij/
│   ├── yazi/
│   ├── git/
│   ├── clash-verge-rev/
│   └── ...
├── encrypted/        ← age-encrypted sensitive files
├── scripts/
│   ├── cachyos-post-install.sh    ← main orchestrator
│   ├── install-paru.sh
│   ├── install-nix.sh
│   ├── install-tailscale.sh
│   ├── install-lazyvim.sh
│   ├── install-doom-emacs.sh
│   ├── setup-dev-tools.sh
│   └── ...
├── nix/
│   ├── flake.nix
│   ├── devShells/
│   │   ├── cuda.nix
│   │   ├── python.nix
│   │   ├── nodejs.nix
│   │   ├── rust.nix
│   │   ├── go.nix
│   │   ├── cpp.nix
│   │   ├── java.nix
│   │   └── ai.nix
│   └── flake.lock
├── docs/
│   ├── cachyos-install-guide.md
│   ├── architecture.md
│   └── software-list.md
├── .chezmoi.yaml.tmpl
├── .chezmoiignore.tmpl
└── README.md
```

## Template Strategy

### Machine detection

`.chezmoi.yaml.tmpl` defines machine type:

```yaml
data:
  machineType:
    {{- if eq .chezmoi.os "darwin" }}
    "mac"
    {{- else }}
    "linux"
    {{- end }}
```

### Cross-platform templates

Files that differ between Mac and Linux use `.tmpl` suffix with conditional blocks:

```toml
# Example: ghostty/config.tmpl
scrollback-limit = 10000000
theme = Catppuccin Mocha
{{- if eq .chezmoi.os "darwin" }}
macos-option-as-alt = true
{{- else }}
shell-integration = none
{{- end }}
```

### Linux-only configs ignored on Mac

`.chezmoiignore.tmpl`:

```
{{- if eq .chezmoi.os "darwin" }}
.config/niri/
.config/fcitx5/
.config/waybar/
.config/rofi-wayland/
.config/swaync/
encrypted/clash-verge-rev-profiles.yaml.age
{{- end }}
```

### Encryption

Sensitive files (clash-verge-rev proxy settings, SSH keys) stored in `encrypted/` with age encryption. chezmoi handles decryption on `apply`.

### Dark/Light Theme Switching

A `themeswitch.sh` rofi script toggles between Catppuccin Mocha (dark) and Catppuccin Latte (light). When triggered:

1. Writes theme choice to `~/.cache/arch-config/theme.cache`
2. Updates Niri environment variables (`Niri_CONFIG_THEME`)
3. Regenerates Waybar style.css, Rofi theme, Ghostty config, SwayNC style
4. Switches GTK theme via `nwg-look` or `gsettings`
5. Switches Kvantum theme
6. Signals all apps to reload (where possible)

All themed config files use `.tmpl` suffix and read the theme cache:

```toml
# Example: ghostty/config.tmpl
{{- if eq .theme "mocha" }}
theme = Catppuccin Mocha
window-theme = dark
{{- else }}
theme = Catppuccin Latte
window-theme = light
{{- end }}
```

### Wallpaper-driven Auto-Theming (wallbash)

Inspired by Hyprdots/HyDE wallbash. A simplified version:

1. When wallpaper changes (via rofi wallpaper selector or swww), a script extracts dominant colors using ImageMagick
2. Generated palette propagates to Waybar, Rofi, SwayNC, Ghostty, Niri
3. Theme cache stores: active theme (mocha/latte/custom), wallpaper path, extracted color palette
4. Mode options: `dark` (force dark palette), `light` (force light palette), `auto` (pick based on wallpaper luminance)

### Rofi Menu Suite

Seven rofi menus defined as separate scripts in `dot_config/rofi-wayland/scripts/`:

| Menu | Script | Description |
|------|--------|-------------|
| App launcher | (default rofi drun) | Application launcher |
| Power menu | `powermenu.sh` | Logout/reboot/shutdown/suspend/hibernate via wlogout |
| Clipboard | `clipboard.sh` | cliphist history browser with search |
| Screenshot | `screenshot.sh` | Fullscreen/area/window/timed, save-or-clipboard |
| Emoji | `emoji.sh` | rofi-emoji picker |
| Wallpaper | `wallpaper.sh` | Browse wallpapers, trigger wallbash on change |
| Theme switch | `themeswitch.sh` | Toggle dark/light/auto + wallbash mode |

### SwayNC (Notification Center)

Replaces dunst with SwayNC for richer notification management:

- Notification history with scrollable list
- Do-Not-Disturb toggle
- Grouped notifications per app
- Clear-all button
- Inline actions (reply, dismiss, etc.)
- Waybar toggle module to open/close the panel
- Style inherits from wallbash/theme cache

## Pacman vs Nix Division

**Principle**: pacman manages everything visible to the user (desktop, drivers, apps). nix manages invisible dev environments only.

| Managed by pacman/paru | Managed by nix develop |
|------------------------|------------------------|
| NVIDIA driver (nvidia-dkms) | CUDA toolkit (devShell) |
| Desktop (niri, waybar, rofi, SwayNC) | Python + uv (devShell) |
| Apps (steam, clash-verge-rev, wechat, telegram) | Bun + Node.js (devShell) |
| System (docker, podman, tailscale, snapper) | Rust + cargo (devShell) |
| Fonts, themes | Go (devShell) |
| Terminal (ghostty), shell (zsh) | C++ + gcc + cmake (devShell) |
| | Java + JDK + gradle (devShell) |
| | Claude Code + AI tools (devShell) |
| | Project-specific dependencies |

**Why this division**: User cannot debug nix independently. If nix breaks, it only affects dev shells — system keeps working. pacman packages are debuggable via Arch Wiki.

## Post-Install Script Design

`cachyos-post-install.sh` orchestrates the following steps:

1. **System basics**: kernel parameters, btrfs snapper hooks + limine-snapper-sync integration, zram, systemd services
2. **AUR helper**: install paru
3. **NVIDIA**: verify nvidia-dkms is working, enable nvidia-persistenced, nvidia-powerd
4. **Desktop**: install niri, waybar, rofi-wayland, SwayNC, swaylock, wlogout, wl-clipboard, cliphist, swww, wlsunset, blueman, hyprpicker, swappy, hyprshot, slurp, grim, wf-recorder
5. **System apps**: steam, gamemode, clash-verge-rev-bin, wechat-universal-bwrap, telegram-desktop, tailscale-bin, docker, podman, mosh, rustdesk, blueman, wlsunset
6. **Dev basics**: git, neovim, emacs, vscode (AUR), thunar (GUI file manager), mpv, pavucontrol, playerctl, libreoffice, firefox, google-chrome, telegram-desktop
7. **nix**: install nix, enable flakes, configure cache
8. **Fonts + themes**: JetBrainsMono Nerd Font, Noto CJK, Papirus-Icons (Catppuccin folder colors), Bibata-Modern-Cursor, Catppuccin GTK theme, kvantum + Catppuccin Kv theme, nwg-look
9. **Input method**: fcitx5, fcitx5-rime, fcitx5-chinese-addons (pinyin), fcitx5-gtk, fcitx5-configtool
10. **age + chezmoi**: install age, install chezmoi, init from this repo, apply
11. **LazyVim**: bootstrap neovim with LazyVim
12. **Doom Emacs**: install doom emacs
13. **Tailscale**: enable and authenticate

Each step is a separate script file for modularity and debugging. The main script calls them in sequence with error checking.

## nix Flake Design

```nix
{
  description = "viryoke dev environments";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    llm-agents = TODO; # user's existing llm-agents flake input or community equivalent - resolve during implementation
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    devShells.x86_64-linux = {
      cuda = import ./devShells/cuda.nix { pkgs = nixpkgs.legacyPackages.x86_64-linux; };
      python = import ./devShells/python.nix { pkgs = nixpkgs.legacyPackages.x86_64-linux; };
      nodejs = import ./devShells/nodejs.nix { pkgs = nixpkgs.legacyPackages.x86_64-linux; };
      rust = import ./devShells/rust.nix { pkgs = nixpkgs.legacyPackages.x86_64-linux; };
      go = import ./devShells/go.nix { pkgs = nixpkgs.legacyPackages.x86_64-linux; };
      cpp = import ./devShells/cpp.nix { pkgs = nixpkgs.legacyPackages.x86_64-linux; };
      java = import ./devShells/java.nix { pkgs = nixpkgs.legacyPackages.x86_64-linux; };
      ai = import ./devShells/ai.nix { pkgs = nixpkgs.legacyPackages.x86_64-linux; inputs = inputs; };
    };
  };
}
```

Each devShell is minimal — only the tools needed for that environment. User activates with `nix develop .#cuda` etc.

## Deployment Workflow

New CachyOS machine:

```bash
# 1. Install CachyOS (Calamares: Niri + x86-64-v3 + Btrfs + NVIDIA)
# 2. Clone this repo
git clone https://github.com/viryoke/arch-config.git ~/arch-config
# 3. Run post-install
bash ~/arch-config/scripts/cachyos-post-install.sh
# 4. chezmoi applies all dotfiles (part of post-install step 10)
# 5. Start niri and verify desktop
niri
# 6. Use dev environments
nix develop ~/arch-config/nix#cuda
```

New/existing Mac machine:

```bash
# 1. Install chezmoi + age (via Homebrew)
brew install chezmoi age
# 2. Init from this repo
chezmoi init --apply https://github.com/viryoke/arch-config.git
# 3. Use dev environments
nix develop ~/arch-config/nix#python
```

## Phases

This spec covers Phase 1 (system layer + dotfile repo init + nix dev envs). Future phases:

- **Phase 2**: Desktop environment detailed config (Niri layout, Waybar modules, rofi menus, SwayNC styling, wallbash engine)
- **Phase 3**: Application configs (LazyVim plugins, Doom Emacs modules, zsh completions, git delta)
- **Phase 4**: Advanced nix devShells (multi-CUDA versions, per-project overrides)

Each phase gets its own spec → plan → implementation cycle.