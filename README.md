# workflow-dotfiles

Cross-platform dotfiles and CachyOS post-install automation. Manages configuration for two machines: a **CachyOS Linux PC** (i9 14900KF + GTX 4060 + 64GB DDR5 + 2TB NVMe, Niri WM) and a **macOS MacBook Air M2**.

Powered by [chezmoi](https://chezmoi.io) for template-based dotfile sync, [age](https://age-encryption.org) for secrets encryption, and [nix](https://nixos.org) for isolated dev environments.

---

## Features

- **Cross-platform templates** — single source tree with `{{- if eq .chezmoi.os "darwin" }}` conditionals for Mac/Linux differences
- **Catppuccin Mocha/Latte theme toggle** — dark/light switching across Waybar, Rofi, SwayNC, Ghostty, Niri, GTK, Qt via a single rofi menu
- **Wallbash auto-theming** — wallpaper changes auto-recolor the entire desktop based on luminance detection
- **7 Rofi menu suite** — app launcher, power menu, clipboard, screenshot, emoji, wallpaper, theme switch
- **15 Waybar modules** — workspaces, window title, keyboard, CPU, memory, temp, disk, network, bluetooth, audio, idle inhibitor, swaync, cliphist, wlsunset, tray
- **7 nix devShells** — Python, Node.js, Rust, Go, C++, Java, CUDA — isolated, reproducible, zero system pollution
- **Full post-install automation** — 10 scripts that turn a fresh CachyOS install into a configured desktop in one command
- **Age encryption** — proxy configs, SSH keys encrypted via chezmoi's built-in age integration

---

## Quick Start

### CachyOS (new machine)

```bash
# 1. Install CachyOS Desktop Edition via Calamares
#    Select: Niri + x86-64-v3 + Btrfs + Limine + NVIDIA

# 2. Clone and run post-install
git clone https://github.com/viryoke/workflow-dotfiles.git ~/workflow-dotfiles
bash ~/workflow-dotfiles/scripts/cachyos-post-install.sh

# 3. Start Niri
niri
```

The post-install script handles everything: system basics (snapper, zram), NVIDIA setup, paru AUR helper, desktop ecosystem, applications, nix, chezmoi dotfile deployment, LazyVim, Doom Emacs, and Tailscale.

Skip specific steps with `--skip-step`:

```bash
bash ~/workflow-dotfiles/scripts/cachyos-post-install.sh --skip-step doom --skip-step tailscale
```

See the [CachyOS install guide](docs/cachyos-install-guide.md) for detailed step-by-step instructions.

### macOS

```bash
brew install chezmoi age
chezmoi init --apply https://github.com/viryoke/workflow-dotfiles.git
```

Linux-only configs (Niri, Waybar, Rofi, SwayNC, fcitx5, swaylock, wlogout) are automatically ignored on Mac via `.chezmoiignore.tmpl`.

---

## Architecture

```
workflow-dotfiles/      ← git repo = chezmoi source dir
├── dot_config/         → ~/.config/       (chezmoi managed)
│   ├── niri/           → Niri WM config + keybindings + window rules + autostart
│   ├── waybar/         → 15-module bar config + Catppuccin CSS
│   ├── rofi-wayland/   → 7 menu scripts + Catppuccin Mocha/Latte themes
│   ├── swaync/         → Notification center + widget styling
│   ├── ghostty/        → Terminal config (Mac/Linux conditional)
│   ├── nvim/           → LazyVim with Catppuccin + language extras
│   ├── yazi/           → File manager config + Catppuccin theme
│   ├── zellij/         → Terminal multiplexer config + Catppuccin themes
│   ├── fcitx5/         → Chinese pinyin input method
│   ├── swaylock/       → Lock screen (always dark)
│   └── wlogout/        → Logout menu (6 buttons)
├── dot_*               → ~/.*             (chezmoi managed)
│   ├── zshrc.tmpl      → Shell config (Mac/Linux aliases)
│   ├── zshenv.tmpl     → Environment variables
│   ├── gitconfig.tmpl  → Git config (delta, credential helper per OS)
│   └── starship.toml   → Prompt (niri module on Linux)
├── encrypted/          → age-encrypted    (chezmoi managed, decrypted on apply)
├── scripts/            → Post-install     (NOT chezmoi managed)
│   ├── cachyos-post-install.sh  → Main orchestrator (10 sub-scripts)
│   ├── setup-system.sh          → Snapper, zram, systemd
│   ├── install-nvidia.sh        → NVIDIA driver verification + services
│   ├── install-paru.sh          → AUR helper
│   ├── install-desktop.sh       → Desktop ecosystem + fonts + themes + fcitx5
│   ├── install-apps.sh          → System apps + dev basics
│   ├── install-nix.sh           → nix + flakes
│   ├── setup-chezmoi.sh         → age + chezmoi init + apply
│   ├── install-lazyvim.sh       → LazyVim bootstrap
│   ├── install-doom-emacs.sh    → Doom Emacs install
│   ├── install-tailscale.sh     → Tailscale VPN
│   └── theme-apply.sh           → Theme propagation helper
├── nix/                → Dev environments  (NOT chezmoi managed)
│   ├── flake.nix       → 8 devShells (x86_64-linux + aarch64-darwin)
│   ├── flake.lock      → Locked dependencies
│   └── devShells/      → Per-language shell definitions
└── docs/               → Documentation     (NOT chezmoi managed)
    ├── cachyos-install-guide.md
    └── software-list.md
```

### Package Division

**pacman/paru** manages everything visible — desktop, drivers, apps, fonts, themes. **nix** manages invisible dev environments only.

If nix breaks, only dev shells stop working; the system remains operational. pacman packages are debuggable via Arch Wiki.

| Managed by pacman/paru | Managed by nix develop |
|------------------------|------------------------|
| NVIDIA driver, desktop, apps | Python 3.13 + uv |
| Fonts, themes, cursor | Bun + Node.js 22 |
| Steam, Telegram, WeChat, Claude Code, Antigravity | Rust + cargo + rust-analyzer |
| Docker, Podman, Tailscale | Go, C++/gcc/cmake, Java/JDK |

---

## Dev Environments

All dev environments are isolated via nix. No system pollution, no version conflicts.

```bash
cd ~/workflow-dotfiles/nix

nix develop .#python    # Python 3.13 + uv + ruff + mypy
nix develop .#nodejs    # Node.js 22 + Bun + TypeScript
nix develop .#rust      # rustc + cargo + rust-analyzer + clippy + cargo-watch + cargo-nextest
nix develop .#go        # Go + gopls
nix develop .#cpp       # gcc + cmake + clang + gdb
nix develop .#java      # JDK 21 + gradle
nix develop .#cuda      # CUDA 12 + cuDNN + numpy (Linux only)
```

Works on both **aarch64-darwin** (Mac) and **x86_64-linux** (CachyOS), except CUDA which is Linux-only.

---

## Theme Switching

### Rofi Theme Menu (`Mod+Shift+T`)

Three modes:
- **Mocha** — force dark Catppuccin theme
- **Latte** — force light Catppuccin theme
- **Auto** — pick dark/light based on wallpaper luminance (via ImageMagick)

Quick toggle from terminal:

```bash
~/.config/rofi-wayland/scripts/themeswitch.sh --toggle
```

### What gets themed

When theme changes, the apply script propagates to:
1. **chezmoi apply --force** — regenerates all `.tmpl` files (reads theme from `~/.cache/arch-config/theme.cache`)
2. **Niri** — `niri msg action reload` (focus-ring, tab-indicator colors)
3. **Rofi** — copies current theme file to `current.rasi`
4. **Waybar** — restarts process
5. **SwayNC** — reloads style
5. **GTK** — switches via `gsettings`
6. **Qt/Kvantum** — switches Catppuccin Kv theme

### Wallbash (wallpaper-driven auto-theming)

When wallpaper changes via the rofi wallpaper selector:
- ImageMagick extracts dominant colors and computes luminance
- If luminance < 128 → dark mode (Mocha); if >= 128 → light mode (Latte)
- Entire desktop recolors automatically

---

## Rofi Menu Suite

| Menu | Shortcut | Script | Description |
|------|----------|--------|-------------|
| App launcher | `Mod+D` | default drun | Search and launch applications |
| Power menu | `Mod+Shift+D` | `powermenu.sh` | Lock/logout/suspend/hibernate/reboot/shutdown via wlogout |
| Clipboard | `Mod+Shift+S` | `clipboard.sh` | Browse cliphist history, select to copy |
| Screenshot | `Mod+Shift+S` | `screenshot.sh` | Fullscreen/area/window/timed(5s) via slurp+grim |
| Emoji | `Mod+Shift+E` | `emoji.sh` | rofi-emoji grid picker, copies to clipboard via wl-copy |
| Wallpaper | `Mod+Shift+W` | `wallpaper.sh` | Browse ~/Pictures/Wallpapers, apply with swww |
| Theme switch | `Mod+Shift+T` | `themeswitch.sh` | Mocha/Latte/Auto toggle + wallbash |

---

## Keybindings (Niri)

| Action | Key | Description |
|--------|-----|-------------|
| Terminal | `Mod+Return` | Open Ghostty |
| App launcher | `Mod+D` | Rofi drun |
| Emoji picker | `Mod+Shift+E` | Rofi emoji picker |
| Quit niri | `Mod+Shift+X` | Quit Niri (with confirmation) |
| Navigate | `Mod+H/J/K/L` | Vim-style focus movement |
| Workspaces | `Mod+1-10` | Switch workspace (CJK numeral icons) |
| Column width | `Mod+1/2/3` | 1/3, 1/2, 2/3 width presets |
| Fullscreen | `Mod+Shift+F` | Toggle fullscreen |
| Float | `Mod+Shift+G` | Toggle floating |
| Screenshot | `Mod+Shift+P` | Screenshot menu (slurp+grim) |
| Night light | Waybar module | Toggle wlsunset |

---

## Dotfile Management

| Command | Purpose |
|---------|---------|
| `chezmoi apply` | Deploy all dotfiles |
| `chezmoi apply --force` | Force regenerate all `.tmpl` files |
| `chezmoi edit <file>` | Edit source file in repo |
| `chezmoi diff` | Check for manual changes not synced back |
| `chezmoi managed` | List all managed files |
| `chezmoi add --encrypt <file>` | Add file with age encryption |

Template files use `.tmpl` suffix and Go template syntax:

```toml
# Example: ghostty/config.tmpl
{{- if eq .theme "mocha" }}
theme = Catppuccin Mocha
{{- else }}
theme = Catppuccin Latte
{{- end }}
{{- if eq .chezmoi.os "darwin" }}
macos-option-as-alt = true
{{- else }}
shell-integration = none
{{- end }}
```

---

## Hardware Target

| Component | Spec |
|-----------|------|
| CPU | Intel i9 14900KF (x86-64-v3) |
| GPU | NVIDIA GTX 4060 8GB |
| RAM | 64GB DDR5 |
| Storage | 2TB NVMe (Btrfs + Snapper) |
| Bootloader | Limine (with snapper-sync for snapshot boot menu) |

---

## Software

See [docs/software-list.md](docs/software-list.md) for the complete software selection across all categories.

---

## License

Personal configuration — not intended for redistribution.