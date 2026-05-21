# arch-config

CachyOS (Niri) + macOS cross-platform desktop and development environment configuration, managed by [chezmoi](https://chezmoi.io).

## Quick Start

### CachyOS (new machine)

1. Install CachyOS Desktop Edition via Calamares: select **Niri + x86-64-v3 + Btrfs + Limine + NVIDIA**
2. Clone and run post-install:

```bash
git clone https://github.com/viryoke/arch-config.git ~/arch-config
bash ~/arch-config/scripts/cachyos-post-install.sh
```

3. Start Niri: `niri`

### macOS

```bash
brew install chezmoi age
chezmoi init --apply https://github.com/viryoke/arch-config.git
```

## Architecture

```
arch-config/          = chezmoi source dir (git repo)
├── dot_config/       → ~/.config/       (chezmoi managed)
├── dot_*             → ~/.*             (chezmoi managed)
├── encrypted/        → age encrypted    (chezmoi managed)
├── scripts/          → post-install     (NOT chezmoi managed)
├── nix/              → dev environments (NOT chezmoi managed)
└── docs/             → documentation    (NOT chezmoi managed)
```

**Package division**: pacman/paru manages desktop, drivers, apps. nix manages dev environments only (`nix develop`).

## Dev Environments

```bash
nix develop ~/arch-config/nix#python   # Python 3.13 + uv
nix develop ~/arch-config/nix#cuda     # CUDA toolkit
nix develop ~/arch-config/nix#rust     # Rust + cargo
nix develop ~/arch-config/nix#go       # Go
nix develop ~/arch-config/nix#cpp      # C++ + gcc + cmake
nix develop ~/arch-config/nix#java     # JDK + gradle
nix develop ~/arch-config/nix#nodejs   # Bun + Node.js
nix develop ~/arch-config/nix#ai       # Claude Code + AI tools
```

## Theme Switching

Rofi theme menu: `Catppuccin Mocha (dark) ↔ Catppuccin Latte (light) ↔ Auto (wallpaper luminance)`

Wallbash engine: changing wallpaper auto-recolors Waybar, Rofi, SwayNC, Ghostty, GTK, Niri.

## Software

See [docs/software-list.md](docs/software-list.md) for the full selection.

## Dotfile Management

- **chezmoi**: template-based, cross-platform (Mac+Linux)
- **age**: encrypt sensitive files (proxy configs, SSH keys)
- **`chezmoi apply`**: deploy dotfiles
- **`chezmoi edit`**: edit source files
- **`chezmoi diff`**: check for manual changes not synced back

## License

Personal configuration — not intended for redistribution.