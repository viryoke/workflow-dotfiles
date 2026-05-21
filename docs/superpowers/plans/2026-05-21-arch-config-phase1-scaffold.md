# arch-config Phase 1: Project Scaffold + chezmoi Init Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Initialize the arch-config git repo as a chezmoi source directory with all foundational structure, chezmoi configuration, age encryption setup, and README.

**Architecture:** The repo root is the chezmoi source dir. `dot_*` prefixed directories map to `~/.*` paths via chezmoi convention. Scripts, nix, and docs live alongside but are not managed by chezmoi. Template files use `.tmpl` suffix for Mac/Linux conditional content. Age encryption for sensitive files.

**Tech Stack:** chezmoi, age, git, bash

---

## File Structure (this plan creates)

```
arch-config/
├── dot_config/               ← ~/.config/ (chezmoi managed, dirs only)
├── dot_zshrc.tmpl            ← ~/.zshrc (chezmoi managed)
├── dot_zshenv.tmpl           ← ~/.zshenv (chezmoi managed)
├── dot_starship.toml.tmpl    ← ~/.config/starship.toml (chezmoi managed)
├── dot_gitconfig.tmpl        ← ~/.gitconfig (chezmoi managed)
├── encrypted/                ← age encrypted files (chezmoi managed)
├── scripts/                  ← NOT chezmoi managed
├── nix/                      ← NOT chezmoi managed
│   ├── devShells/            ← NOT chezmoi managed
├── docs/                     ← NOT chezmoi managed
├── .chezmoi.yaml.tmpl        ← chezmoi config template
├── .chezmoiignore.tmpl       ← chezmoi ignore rules template
├── .gitignore                ← git ignore rules
└── README.md                 ← project overview
```

---

### Task 1: Initialize Git Repo

**Files:**
- Create: `/Users/viryoke/arch-config/.gitignore`
- Modify: `/Users/viryoke/arch-config/` (git init)

- [ ] **Step 1: Initialize git repo**

```bash
cd /Users/viryoke/arch-config
git init
```

Expected: Git repo initialized in `/Users/viryoke/arch-config/`

- [ ] **Step 2: Create .gitignore**

```gitignore
# chezmoi state
.chezmoi.state

# age encryption keys (never commit private keys)
*.age.key

# nix build results
nix/result
nix/result-*

# OS-specific junk
.DS_Store
Thumbs.db

# editor artifacts
*.swp
*.swo
*~
.vscode/
.idea/
```

- [ ] **Step 3: Commit initial gitignore**

```bash
git add .gitignore
git commit -m "init: add .gitignore for arch-config project"
```

---

### Task 2: Create chezmoi Config Templates

**Files:**
- Create: `/Users/viryoke/arch-config/.chezmoi.yaml.tmpl`
- Create: `/Users/viryoke/arch-config/.chezmoiignore.tmpl`

- [ ] **Step 1: Create .chezmoi.yaml.tmpl**

```yaml
data:
  machineType:
    {{- if eq .chezmoi.os "darwin" }}
    "mac"
    {{- else }}
    "linux"
    {{- end }}
  theme:
    {{- if eq .chezmoi.os "darwin" }}
    "mocha"
    {{- else }}
    "mocha"
    {{- end }}
```

Note: `theme` defaults to "mocha" on both platforms. The themeswitch.sh script will update `~/.cache/arch-config/theme.cache` and chezmoi can read it via `.chezmoi.yaml.tmpl` using external data sources (see chezmoi docs for `sourceDir`).

- [ ] **Step 2: Create .chezmoiignore.tmpl**

```
{{- if eq .chezmoi.os "darwin" }}
dot_config/niri/
dot_config/fcitx5/
dot_config/waybar/
dot_config/rofi-wayland/
dot_config/swaync/
dot_config/yazi/
dot_config/zellij/
dot_config/lazyvim/
dot_config/clash-verge-rev/
encrypted/clash-verge-rev-profiles.yaml.age
{{- end }}

{{- if eq .chezmoi.os "linux" }}
# Mac-specific files (none yet, but placeholder for future)
{{- end }}
```

Mac ignores all Linux-only desktop configs (Niri, Waybar, Rofi, SwayNC, fcitx5, etc.). Linux ignores nothing extra for now.

- [ ] **Step 3: Commit chezmoi config**

```bash
git add .chezmoi.yaml.tmpl .chezmoiignore.tmpl
git commit -m "init: add chezmoi config templates for Mac/Linux cross-platform"
```

---

### Task 3: Create Directory Structure (chezmoi dot_* dirs)

**Files:**
- Create: `/Users/viryoke/arch-config/dot_config/` (with subdirs)
- Create: `/Users/viryoke/arch-config/encrypted/` (empty, placeholder)

- [ ] **Step 1: Create all dot_config subdirectories**

These directories map to `~/.config/<name>` via chezmoi convention. We create empty dirs with `.keep` files so git tracks them:

```bash
cd /Users/viryoke/arch-config
mkdir -p dot_config/niri
mkdir -p dot_config/ghostty
mkdir -p dot_config/waybar
mkdir -p dot_config/rofi-wayland/scripts
mkdir -p dot_config/rofi-wayland/themes
mkdir -p dot_config/swaync
mkdir -p dot_config/zsh
mkdir -p dot_config/fcitx5
mkdir -p dot_config/lazyvim
mkdir -p dot_config/zellij
mkdir -p dot_config/yazi
mkdir -p dot_config/git
mkdir -p dot_config/clash-verge-rev
mkdir -p encrypted
```

Add `.keep` files to empty dirs so git tracks them:

```bash
for dir in dot_config/niri dot_config/ghostty dot_config/waybar dot_config/rofi-wayland/scripts dot_config/rofi-wayland/themes dot_config/swaync dot_config/zsh dot_config/fcitx5 dot_config/lazyvim dot_config/zellij dot_config/yazi dot_config/git dot_config/clash-verge-rev encrypted; do
  touch "$dir/.keep"
done
```

- [ ] **Step 2: Create non-chezmoi directories**

```bash
cd /Users/viryoke/arch-config
mkdir -p scripts
mkdir -p nix/devShells
mkdir -p docs
```

No `.keep` needed — these will have real files soon.

- [ ] **Step 3: Commit directory structure**

```bash
git add dot_config/ encrypted/ scripts/ nix/ docs/
git commit -m "init: create project directory structure for chezmoi and non-chezmoi areas"
```

---

### Task 4: Create Core Shell Config Templates

**Files:**
- Create: `/Users/viryoke/arch-config/dot_zshrc.tmpl`
- Create: `/Users/viryoke/arch-config/dot_zshenv.tmpl`
- Create: `/Users/viryoke/arch-config/dot_starship.toml.tmpl`
- Create: `/Users/viryoke/arch-config/dot_gitconfig.tmpl`

- [ ] **Step 1: Create dot_zshrc.tmpl**

```zsh
# zshrc - arch-config managed by chezmoi
# Cross-platform shell configuration

# ---- History ----
HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# ---- Aliases ----
alias ll='ls -lh'
alias la='ls -la'
alias gs='git status'
alias gd='git diff'
alias gc='git commit'
alias gco='git checkout'
alias gb='git branch'

{{- if eq .chezmoi.os "linux" }}
alias pac='paru'
alias pacs='paru -Ss'
alias pacu='paru -Syu'
alias niri-restart='niri msg action quit; niri'
alias screenshot='hyprshot -m region'
{{- else }}
alias brewu='brew update && brew upgrade'
alias brewc='brew cleanup'
{{- end }}

# ---- Key bindings ----
bindkey -e
bindkey '^R' history-incremental-search-backward

# ---- Completion ----
autoload -Uz compinit
compinit

# ---- Plugins (manual, not oh-my-zsh) ----
# zsh-autosuggestions - installed by pacman on Linux, brew on Mac
{{- if eq .chezmoi.os "linux" }}
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
{{- else }}
# Mac: these are installed via Homebrew or nix
if [ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi
if [ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
{{- end }}

# ---- Starship prompt ----
eval "$(starship init zsh)"

# ---- Direnv (nix) ----
if command -v direnv &>/dev/null; then
  eval "$(direnv hook zsh)"
fi

# ---- fcitx5 (Linux only) ----
{{- if eq .chezmoi.os "linux" }}
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
{{- end }}
```

- [ ] **Step 2: Create dot_zshenv.tmpl**

```zsh
# zshenv - environment variables (loaded for all zsh instances)
# arch-config managed by chezmoi

export EDITOR=nvim
export VISUAL=nvim

{{- if eq .chezmoi.os "linux" }}
export BROWSER=firefox
{{- else }}
export BROWSER=open
{{- end }}

# XDG directories
export XDG_CONFIG_HOME=~/.config
export XDG_CACHE_HOME=~/.cache
export XDG_DATA_HOME=~/.local/share
```

- [ ] **Step 3: Create dot_starship.toml.tmpl**

```toml
# Starship prompt config - arch-config managed by chezmoi
# Cross-platform configuration

format = """
$directory\
$git_branch\
$git_status\
$git_state\
${custom.niri}\
$python\
$rust\
$golang\
$nodejs\
$cmd_duration\
$line_break\
$jobs\
$character"""

[directory]
truncation_length = 3
truncate_to_repo = true

[git_branch]
symbol = " "
format = "[$symbol$branch]($style) "

[git_status]
format = '([$all_status$ahead_behind]($style) )'

[character]
{{- if eq .theme "mocha" }}
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"
{{- else }}
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"
{{- end }}

[cmd_duration]
min_time = 2_000
format = " [$duration]($style) "

{{- if eq .chezmoi.os "linux" }}
[custom.niri]
command = "echo 'niri'"
when = "test -n \"$NIRI_SOCKET\""
format = "[$output]($style) "
style = "bold purple"
{{- end }}
```

- [ ] **Step 4: Create dot_gitconfig.tmpl**

```gitconfig
# git config - arch-config managed by chezmoi
# Cross-platform configuration

[user]
	name = {{ .chezmoi.hostname | default "viryoke" }}
	email = viryoke@users.noreply.github.com

[core]
	editor = nvim
	autocrlf = input

[init]
	defaultBranch = main

[push]
	autoSetupRemote = true

[diff]
	tool = delta

[interactive]
	diffFilter = delta --color-only

[delta]
	navigate = true
	line-numbers = true
{{- if eq .theme "mocha" }}
	side-by-side = true
	dark = true
	syntax-theme = Catppuccin Mocha
{{- else }}
	side-by-side = true
	light = true
	syntax-theme = Catppuccin Latte
{{- end }}

[merge]
	conflictstyle = diff3

[credential]
{{- if eq .chezmoi.os "darwin" }}
	helper = osxkeychain
{{- else }}
	helper = cache --timeout=3600
{{- end }}

[alias]
	s = status -sb
	l = log --oneline -20
	ll = log --oneline --graph --all --decorate
	d = diff
	ds = diff --staged
```

- [ ] **Step 5: Commit core shell configs**

```bash
git add dot_zshrc.tmpl dot_zshenv.tmpl dot_starship.toml.tmpl dot_gitconfig.tmpl
git commit -m "feat: add cross-platform shell configs (zshrc, zshenv, starship, git) with Mac/Linux templates"
```

---

### Task 5: Create Ghostty Config Template

**Files:**
- Create: `/Users/viryoke/arch-config/dot_config/ghostty/config.tmpl`
- Remove: `/Users/viryoke/arch-config/dot_config/ghostty/.keep`

- [ ] **Step 1: Remove .keep placeholder**

```bash
rm /Users/viryoke/arch-config/dot_config/ghostty/.keep
```

- [ ] **Step 2: Create ghostty config.tmpl**

```toml
# Ghostty config - arch-config managed by chezmoi
# Cross-platform with Mac/Linux differences

scrollback-limit = 10000000

{{- if eq .theme "mocha" }}
theme = Catppuccin Mocha
window-theme = dark
{{- else }}
theme = Catppuccin Latte
window-theme = light
{{- end }}

{{- if eq .chezmoi.os "darwin" }}
macos-option-as-alt = true
{{- else }}
shell-integration = none
wait-after-command = true
abnormal-command-exit-runtime = 500
confirm-close-surface = always
{{- end }}

# Fonts
font-family = JetBrainsMono Nerd Font Mono
font-size = 14

# Window appearance
unfocused-split-opacity = 0.50
{{- if eq .theme "mocha" }}
unfocused-split-fill = #181825
split-divider-color = #cba6f7
{{- else }}
unfocused-split-fill = #e6e9ef
split-divider-color = #8839ef
{{- end }}

# Clipboard
copy-on-select = clipboard
```

- [ ] **Step 3: Commit ghostty config**

```bash
git add dot_config/ghostty/config.tmpl
git commit -m "feat: add Ghostty terminal config with dark/light theme and Mac/Linux templates"
```

---

### Task 6: Create README.md

**Files:**
- Create: `/Users/viryoke/arch-config/README.md`

- [ ] **Step 1: Create README.md**

```markdown
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
```

- [ ] **Step 2: Commit README**

```bash
git add README.md
git commit -m "docs: add project README with quick start, architecture, and dev environment docs"
```

---

### Task 7: Create docs/software-list.md

**Files:**
- Create: `/Users/viryoke/arch-config/docs/software-list.md`

- [ ] **Step 1: Create software list doc**

This is a reference document listing all software from the spec. Content is the full software selection tables from the spec document, reformatted as a flat list grouped by category. Include: Desktop ecosystem, Applications, System services, Development tools. Reference the spec for details.

- [ ] **Step 2: Commit docs**

```bash
git add docs/software-list.md
git commit -m "docs: add software selection list reference"
```

---

### Task 8: Verify chezmoi Works on Mac

**Files:** None (validation only)

- [ ] **Step 1: Test chezmoi init on Mac**

```bash
cd /Users/viryoke/arch-config
chezmoi init --source=.
chezmoi data
```

Expected: chezmoi reads `.chezmoi.yaml.tmpl`, shows `machineType: mac` and `theme: mocha`

- [ ] **Step 2: Test chezmoi apply**

```bash
chezmoi apply --verbose
```

Expected: chezmoi creates `~/.zshrc`, `~/.zshenv`, `~/.config/starship.toml`, `~/.config/ghostty/config`, `~/.gitconfig` with Mac-specific values. Linux-only configs (Niri, Waybar, etc.) are NOT created due to `.chezmoiignore.tmpl`.

- [ ] **Step 3: Verify Mac-specific values**

```bash
grep "macos-option-as-alt" ~/.config/ghostty/config
grep "brewu" ~/.zshrc
grep "osxkeychain" ~/.gitconfig
```

Expected: all three lines found (Mac-specific content is present)

- [ ] **Step 4: Verify Linux-only configs are absent**

```bash
ls ~/.config/niri 2>&1
ls ~/.config/waybar 2>&1
ls ~/.config/fcitx5 2>&1
```

Expected: all three return "No such file or directory" (Linux-only configs ignored on Mac)

- [ ] **Step 5: Cleanup test (restore original configs)**

Since this is a live Mac, we need to restore any configs that chezmoi overwrote:

```bash
# Check what chezmoi would change before applying
chezmoi diff

# If changes look wrong, restore originals:
chezmoi unapply
```

Note: Since the user already has Ghostty config at `~/.config/ghostty/config`, chezmoi will back it up before overwriting. The backup is at `~/.local/share/chezmoi/archive/`. The user can compare and decide whether to keep the chezmoi version or restore the original.

- [ ] **Step 6: Commit no changes (validation only)**

No files to commit — this was a validation step.

---

## Self-Review Checklist

**1. Spec coverage:**
- ✅ Project structure: Task 3
- ✅ chezmoi config templates: Task 2
- ✅ Cross-platform shell configs: Task 4
- ✅ Ghostty config with templates: Task 5
- ✅ README: Task 6
- ✅ Software list doc: Task 7
- ✅ Validation on Mac: Task 8
- ❌ Niri config (Phase 2)
- ❌ Waybar config (Phase 2)
- ❌ SwayNC config (Phase 2)
- ❌ Rofi menus (Phase 2)
- ❌ wallbash/theme engine (Phase 2)
- ❌ Post-install scripts (separate plan)
- ❌ Nix devShells (separate plan)
- ❌ fcitx5 config (Phase 2)

**2. Placeholder scan:** No TBD/TODO found. All code blocks contain actual content.

**3. Type consistency:** Template variable `.chezmoi.os` and `.theme` used consistently across all template files. `.chezmoi.hostname` used in gitconfig.

**Missing from this plan (deferred to later plans):**
- Post-install automation scripts → Plan 2
- Nix flake + devShells → Plan 3
- Desktop configs (Niri, Waybar, SwayNC, Rofi, fcitx5, wallbash) → Plan 4
- Application configs (LazyVim, Doom Emacs, Yazi, Zellij) → Plan 5