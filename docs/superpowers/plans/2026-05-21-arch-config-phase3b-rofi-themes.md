# Rofi Menus + Theme Engine + fcit5 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create 7 rofi menu scripts, rofi config, wallbash theme switching engine (themeswitch.sh + theme cache mechanism), and fcitx5 input method config.

**Architecture:** Rofi scripts live in `dot_config/rofi-wayland/scripts/` and are called via niri keybindings. The `themeswitch.sh` script toggles Catppuccin Mocha/Latte by writing to `~/.cache/arch-config/theme.cache`, then regenerating themed configs and signalling apps to reload. The `wallpaper.sh` script handles wallpaper selection via swww and triggers wallbash color extraction. fcitx5 config provides Chinese+English input method setup. All files are Linux-only (ignored on Mac).

**Tech Stack:** rofi-wayland, swww, cliphist, hyprshot, wlogout, swaylock, ImageMagick (for wallbash color extraction), fcitx5-rime

---

## File Structure (this plan creates)

```
dot_config/
├── rofi-wayland/
│   ├── config.rasi              ← base rofi config (drun launcher)
│   ├── themes/
│   │   └── catppuccin-mocha.rasi ← dark theme colors
│   │   └── catppuccin-latte.rasi ← light theme colors
│   │   └── shared.rasi          ← shared layout dimensions
│   └── scripts/
│       ├── powermenu.sh         ← wlogout-based power menu
│       ├── clipboard.sh         ← cliphist clipboard browser
│       ├── screenshot.sh         ← hyprshot screenshot menu
│       ├── emoji.sh              ← rofi-emoji picker
│       ├── wallpaper.sh          ← swww wallpaper selector + wallbash
│       └── themeswitch.sh        ← Catppuccin Mocha/Latte toggle + app reload
scripts/
└── theme-apply.sh               ← theme cache → regenerate themed configs + signal apps
```

Note: `dot_config/fcitx5/` will also get config files. The `scripts/theme-apply.sh` lives in the project's `scripts/` directory (NOT chezmoi managed) because it needs to run on the host system outside chezmoi's template engine — it regenerates files in `~/.cache/arch-config/`.

---

### Task 1: Create Rofi Base Config + Themes

**Files:**
- Remove: `/Users/viryoke/arch-config/dot_config/rofi-wayland/scripts/.keep`
- Remove: `/Users/viryoke/arch-config/dot_config/rofi-wayland/themes/.keep`
- Create: `/Users/viryoke/arch-config/dot_config/rofi-wayland/config.rasi`
- Create: `/Users/viryoke/arch-config/dot_config/rofi-wayland/themes/shared.rasi`
- Create: `/Users/viryoke/arch-config/dot_config/rofi-wayland/themes/catppuccin-mocha.rasi`
- Create: `/Users/viryoke/arch-config/dot_config/rofi-wayland/themes/catppuccin-latte.rasi`

- [ ] **Step 1: Remove .keep placeholders**

```bash
rm /Users/viryoke/arch-config/dot_config/rofi-wayland/scripts/.keep
rm /Users/viryoke/arch-config/dot_config/rofi-wayland/themes/.keep
```

- [ ] **Step 2: Create config.rasi**

```rasi
// Rofi base config - arch-config managed by chezmoi
// App launcher (drun mode)

configuration {
    modi:                        "drun";
    show-icons:                  true;
    drun-display-format:         "{name}";
    font:                        "JetBrainsMono Nerd Font 10";
    icon-theme:                  "Papirus-Dark";
}

@theme "shared"
@theme "catppuccin-mocha"

window {
    height:                      33em;
    width:                       63em;
    transparency:                "real";
    border-color:                @main-br;
    background-color:            @main-bg;
}

mainbox {
    orientation:                 horizontal;
    children:                    [ "listbox" ];
    background-color:            transparent;
}

listbox {
    orientation:                 vertical;
    children:                    [ "inputbar", "listview" ];
    spacing:                     5;
    background-color:            transparent;
}

inputbar {
    children:                    [ "entry" ];
    padding:                     8px;
    background-color:            @main-bg;
    border-radius:               12px;
}

entry {
    placeholder:                 "Search...";
    placeholder-color:           @main-fg;
    text-color:                  @main-fg;
    padding:                     6px;
}

listview {
    columns:                     1;
    lines:                       12;
    spacing:                     4px;
    cycle:                       true;
    dynamic:                     true;
    scrollbar:                   false;
}

element {
    orientation:                 horizontal;
    children:                    [ "element-icon", "element-text" ];
    padding:                     8px;
    border-radius:               12px;
    spacing:                     8px;
}

element-icon {
    size:                        2.5em;
    vertical-align:              0.5;
}

element-text {
    text-color:                  @main-fg;
    vertical-align:              0.5;
}

element selected {
    background-color:            @select-bg;
    text-color:                  @select-fg;
    border-color:                @main-br;
}

element-icon selected {
    background-color:            transparent;
}
```

- [ ] **Step 3: Create themes/shared.rasi**

```rasi
// Shared rofi layout dimensions - arch-config managed by chezmoi
// Imported by all rofi configs for consistent sizing

* {
    main-bg:                     #11111be6;
    main-fg:                     #cdd6f4ff;
    main-br:                     #cba6f7ff;
    main-ex:                     #f5e0dcff;
    select-bg:                   #b4befeff;
    select-fg:                   #11111bff;
    separatorcolor:              transparent;
    border-color:                transparent;

    font:                        "JetBrainsMono Nerd Font 10";

    border-radius:               12;
    spacing:                     5;
    padding:                     8;

    background-color:            transparent;
    text-color:                  @main-fg;
}
```

Note: shared.rasi provides default Catppuccin Mocha values. The theme-specific files override these colors.

- [ ] **Step 4: Create themes/catppuccin-mocha.rasi**

```rasi
// Catppuccin Mocha rofi theme - arch-config managed by chezmoi
// Dark theme for Wayland desktop

* {
    main-bg:                     #1e1e2ee6;
    main-fg:                     #cdd6f4ff;
    main-br:                     #cba6f7ff;
    main-ex:                     #f5e0dcff;
    select-bg:                   #b4befeff;
    select-fg:                   #1e1e2eff;
}
```

- [ ] **Step 5: Create themes/catppuccin-latte.rasi**

```rasi
// Catppuccin Latte rofi theme - arch-config managed by chezmoi
// Light theme for Wayland desktop

* {
    main-bg:                     #eff1f5e6;
    main-fg:                     #4c4f69ff;
    main-br:                     #8839efff;
    main-ex:                     #dc8a78ff;
    select-bg:                   #7287fdff;
    select-fg:                   #eff1f5ff;
}
```

- [ ] **Step 6: Commit rofi config and themes**

```bash
git add dot_config/rofi-wayland/config.rasi dot_config/rofi-wayland/themes/
git commit -m "feat: add Rofi base config and Catppuccin Mocha/Latte theme files"
```

---

### Task 2: Create Power Menu Script

**Files:**
- Create: `/Users/viryoke/arch-config/dot_config/rofi-wayland/scripts/powermenu.sh`

- [ ] **Step 1: Create powermenu.sh**

```bash
#!/bin/env bash
# Power menu - arch-config managed by chezmoi
# Launches wlogout for lock/logout/suspend/hibernate/reboot/shutdown

if pgrep -x "wlogout" > /dev/null; then
    pkill -x "wlogout"
    exit 0
fi

wlogout
```

Note: This is intentionally simple — wlogout handles the full power menu UI with its layout and CSS. The script just launches wlogout and prevents duplicate instances. The niri keybinding `Mod+Shift+E` calls this script.

- [ ] **Step 2: Make executable and commit**

```bash
chmod +x dot_config/rofi-wayland/scripts/powermenu.sh
git add dot_config/rofi-wayland/scripts/powermenu.sh
git commit -m "feat: add power menu script (wlogout launcher)"
```

---

### Task 3: Create Clipboard Script

**Files:**
- Create: `/Users/viryoke/arch-config/dot_config/rofi-wayland/scripts/clipboard.sh`

- [ ] **Step 1: Create clipboard.sh**

```bash
#!/bin/env bash
# Clipboard history browser - arch-config managed by chezmoi
# Uses cliphist for Wayland clipboard history management

pkill rofi && exit 0

CLIPBOARD_THEME="shared"

selected=$(cliphist list | rofi -dmenu -i -p "Clipboard" \
    -theme "$CLIPBOARD_THEME" \
    -theme-str "window { width: 30em; height: 30em; }" \
    -theme-str "listview { lines: 15; }")

if [ -n "$selected" ]; then
    # Decode the selected cliphist entry and copy to clipboard
    cliphist decode "$selected" | wl-copy
fi
```

Note: `cliphist list` outputs clipboard history entries. `cliphist decode` converts them back to content. `wl-copy` puts content on the Wayland clipboard. The `pkill rofi && exit 0` pattern prevents duplicate rofi instances.

- [ ] **Step 2: Make executable and commit**

```bash
chmod +x dot_config/rofi-wayland/scripts/clipboard.sh
git add dot_config/rofi-wayland/scripts/clipboard.sh
git commit -m "feat: add clipboard history script (cliphist + rofi)"
```

---

### Task 4: Create Screenshot Script

**Files:**
- Create: `/Users/viryoke/arch-config/dot_config/rofi-wayland/scripts/screenshot.sh`

- [ ] **Step 1: Create screenshot.sh**

```bash
#!/bin/env bash
# Screenshot menu - arch-config managed by chezmoi
# Options: fullscreen, area, window, timed (5s delay)
# Uses hyprshot for capture, swappy for annotation

pkill rofi && exit 0

SCREENSHOT_THEME="shared"

options="Fullscreen\nArea\nWindow\nTimed (5s)"

selected=$(echo -e "$options" | rofi -dmenu -i -p "Screenshot" \
    -theme "$SCREENSHOT_THEME" \
    -theme-str "window { width: 25em; height: 15em; }" \
    -theme-str "listview { lines: 4; }")

SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOT_DIR"

case "$selected" in
    "Fullscreen")
        hyprshot -m screen -o "$SCREENSHOT_DIR" -f "$(date +%Y-%m-%d-%H-%M-%S).png"
        ;;
    "Area")
        hyprshot -m region -o "$SCREENSHOT_DIR" -f "$(date +%Y-%m-%d-%H-%M-%S).png"
        ;;
    "Window")
        hyprshot -m window -o "$SCREENSHOT_DIR" -f "$(date +%Y-%m-%d-%H-%M-%S).png"
        ;;
    "Timed (5s)")
        sleep 5
        hyprshot -m screen -o "$SCREENSHOT_DIR" -f "$(date +%Y-%m-%d-%H-%M-%S).png"
        ;;
esac
```

Note: `hyprshot` is the screenshot tool for Wayland compositors (works with niri). It supports `-m screen`, `-m region`, `-m window` modes. Screenshots are saved to `~/Pictures/Screenshots/` with timestamp filenames.

- [ ] **Step 2: Make executable and commit**

```bash
chmod +x dot_config/rofi-wayland/scripts/screenshot.sh
git add dot_config/rofi-wayland/scripts/screenshot.sh
git commit -m "feat: add screenshot menu script (hyprshot fullscreen/area/window/timed)"
```

---

### Task 5: Create Emoji Picker Script

**Files:**
- Create: `/Users/viryoke/arch-config/dot_config/rofi-wayland/scripts/emoji.sh`

- [ ] **Step 1: Create emoji.sh**

```bash
#!/bin/env bash
# Emoji picker - arch-config managed by chezmoi
# Uses rofi-emoji plugin for Wayland emoji selection

pkill rofi && exit 0

export ROFI_CLIPBOARD="wl-copy"

rofi -modi emoji -show emoji \
    -theme "shared" \
    -theme-str "window { width: 30em; height: 30em; }" \
    -theme-str "listview { columns: 8; lines: 10; }" \
    -theme-str "element-icon { size: 2em; }" \
    -theme-str "element { padding: 4px; border-radius: 8px; }"
```

Note: `rofi-emoji` is a rofi plugin (package `rofi-emoji` on pacman). `ROFI_CLIPBOARD=wl-copy` tells it to use Wayland clipboard. Grid layout (8 columns) is used for emoji display since emojis work better in a grid than a list.

- [ ] **Step 2: Make executable and commit**

```bash
chmod +x dot_config/rofi-wayland/scripts/emoji.sh
git add dot_config/rofi-wayland/scripts/emoji.sh
git commit -m "feat: add emoji picker script (rofi-emoji plugin with grid layout)"
```

---

### Task 6: Create Wallpaper Selector Script

**Files:**
- Create: `/Users/viryoke/arch-config/dot_config/rofi-wayland/scripts/wallpaper.sh`

- [ ] **Step 1: Create wallpaper.sh**

```bash
#!/bin/env bash
# Wallpaper selector - arch-config managed by chezmoi
# Browse wallpapers with rofi, apply with swww, trigger wallbash color extraction

pkill rofi && exit 0

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
CACHE_DIR="$HOME/.cache/arch-config"
WALLPAPER_THEME="shared"

# Ensure swww daemon is running
swww query &> /dev/null || swww-daemon --format xrgb &

# Get list of wallpapers
if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Wallpaper" "No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

wallpapers=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.webp" -o -name "*.gif" \) | sort)

if [ -z "$wallpapers" ]; then
    notify-send "Wallpaper" "No image files found in $WALLPAPER_DIR"
    exit 1
fi

# Show filenames only (not full paths) in rofi
selected=$(echo "$wallpapers" | while read -r f; do basename "$f"; done | \
    rofi -dmenu -i -p "Wallpapers" \
    -theme "$WALLPAPER_THEME" \
    -theme-str "window { width: 35em; height: 30em; }" \
    -theme-str "listview { lines: 15; }")

if [ -n "$selected" ]; then
    # Find full path from basename
    wallpaper_path=$(echo "$wallpapers" | grep "/$selected$")

    if [ -n "$wallpaper_path" ]; then
        # Apply wallpaper with swww transition
        swww img "$wallpaper_path" \
            --transition-type random \
            --transition-duration 0.4 \
            --transition-fps 60

        # Save current wallpaper path to cache
        echo "$wallpaper_path" > "$CACHE_DIR/wallpaper.cache"

        # Trigger wallbash color extraction
        ~/.config/rofi-wayland/scripts/themeswitch.sh --wallbash "$wallpaper_path"
    fi
fi
```

Note: After selecting a wallpaper, this script: (1) applies it via swww with a random transition, (2) saves the path to wallpaper.cache, (3) triggers themeswitch.sh to extract colors from the new wallpaper.

- [ ] **Step 2: Make executable and commit**

```bash
chmod +x dot_config/rofi-wayland/scripts/wallpaper.sh
git add dot_config/rofi-wayland/scripts/wallpaper.sh
git commit -m "feat: add wallpaper selector script (swww + rofi browse + wallbash trigger)"
```

---

### Task 7: Create Theme Switch Script + Theme Apply Script

**Files:**
- Create: `/Users/viryoke/arch-config/dot_config/rofi-wayland/scripts/themeswitch.sh`
- Create: `/Users/viryoke/arch-config/scripts/theme-apply.sh`

- [ ] **Step 1: Create themeswitch.sh**

```bash
#!/bin/env bash
# Theme switcher - arch-config managed by chezmoi
# Toggles Catppuccin Mocha (dark) <-> Latte (light) or auto (wallpaper luminance)
# Also handles wallbash color extraction when wallpaper changes

CACHE_DIR="$HOME/.cache/arch-config"
THEME_CACHE="$CACHE_DIR/theme.cache"
WALLPAPER_CACHE="$CACHE_DIR/wallpaper.cache"

mkdir -p "$CACHE_DIR"

# Get current theme
current_theme="mocha"
if [ -f "$THEME_CACHE" ]; then
    current_theme=$(cat "$THEME_CACHE")
fi

# Wallbash mode: extract colors from wallpaper and set theme automatically
wallbash_mode() {
    wallpaper_path="$1"

    if [ ! -f "$wallpaper_path" ]; then
        return
    fi

    # Extract dominant colors using ImageMagick
    # Get average luminance to determine dark/light
    luminance=$(convert "$wallpaper_path" -resize 1x1\! -colorspace Gray -format "%[fx:int(mean*255)]" info:)

    # Threshold: luminance > 128 = light wallpaper → Latte theme
    # luminance < 128 = dark wallpaper → Mocha theme
    if [ "$luminance" -gt 128 ]; then
        new_theme="latte"
    else
        new_theme="mocha"
    fi

    # Extract palette colors for wallbash (simplified version)
    # Store extracted colors for potential future use
    palette=$(convert "$wallpaper_path" -resize 25%\! +dither -colors 8 -unique-colors txt: | \
        tail -n +2 | awk '{print $3}' | tr '\n' ' ')

    echo "$palette" > "$CACHE_DIR/palette.cache"

    apply_theme "$new_theme"
}

# Rofi menu for theme selection
rofi_menu() {
    pkill rofi && exit 0

    if [ "$current_theme" = "mocha" ]; then
        options="Latte (light)\nAuto (wallpaper)\nMocha (dark)"
    else
        options="Mocha (dark)\nAuto (wallpaper)\nLatte (light)"
    fi

    selected=$(echo -e "$options" | rofi -dmenu -i -p "Theme" \
        -theme "shared" \
        -theme-str "window { width: 25em; height: 15em; }" \
        -theme-str "listview { lines: 3; }")

    case "$selected" in
        "Mocha (dark)")
            apply_theme "mocha"
            ;;
        "Latte (light)")
            apply_theme "latte"
            ;;
        "Auto (wallpaper)")
            # Use wallpaper luminance to decide
            if [ -f "$WALLPAPER_CACHE" ]; then
                wallbash_mode "$(cat "$WALLPAPER_CACHE")"
            else
                notify-send "Theme" "No wallpaper set for auto mode"
            fi
            ;;
    esac
}

# Apply theme: write cache, regenerate themed configs, signal apps
apply_theme() {
    new_theme="$1"

    # Skip if same theme
    if [ "$new_theme" = "$current_theme" ]; then
        return
    fi

    # Write theme to cache
    echo "$new_theme" > "$THEME_CACHE"

    # Run theme-apply to regenerate configs and signal apps
    ~/arch-config/scripts/theme-apply.sh "$new_theme"

    notify-send "Theme" "Switched to Catppuccin ${new_theme}"
}

# Main: handle arguments or show rofi menu
case "$1" in
    --wallbash)
        wallbash_mode "$2"
        ;;
    --toggle)
        if [ "$current_theme" = "mocha" ]; then
            apply_theme "latte"
        else
            apply_theme "mocha"
        fi
        ;;
    --mocha)
        apply_theme "mocha"
        ;;
    --latte)
        apply_theme "latte"
        ;;
    *)
        rofi_menu
        ;;
esac
```

- [ ] **Step 2: Create scripts/theme-apply.sh**

```bash
#!/bin/env bash
# Theme apply script - arch-config (NOT chezmoi managed)
# Reads theme cache, regenerates themed config files, and signals apps to reload
# Called by themeswitch.sh after writing theme.cache

CACHE_DIR="$HOME/.cache/arch-config"
THEME_CACHE="$CACHE_DIR/theme.cache"

theme="$1"
if [ -z "$theme" ]; then
    if [ -f "$THEME_CACHE" ]; then
        theme=$(cat "$THEME_CACHE")
    else
        theme="mocha"
    fi
fi

# Step 1: Re-apply chezmoi to regenerate all .tmpl files with new theme
# chezmoi reads .chezmoi.yaml.tmpl which reads theme.cache via external data
# This regenerates: ghostty config, starship config, gitconfig, niri config,
# waybar CSS, swaync CSS, wlogout CSS
chezmoi apply --force

# Step 2: Copy the correct rofi theme file to the active theme location
# Rofi can't use chezmoi templates, so we copy the static theme file
case "$theme" in
    mocha)
        cp ~/.config/rofi-wayland/themes/catppuccin-mocha.rasi ~/.config/rofi-wayland/themes/current.rasi
        ;;
    latte)
        cp ~/.config/rofi-wayland/themes/catppuccin-latte.rasi ~/.config/rofi-wayland/themes/current.rasi
        ;;
esac

# Step 3: Signal apps to reload their configs
# Waybar: restart to pick up new CSS
pkill -x waybar && waybar &

# SwayNC: reload style
swaync-client -R && swaync-client -rs

# GTK theme: switch via gsettings
case "$theme" in
    mocha)
        gsettings set org.gnome.desktop.interface gtk-theme 'Catppuccin-Mocha-Dark'
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
        ;;
    latte)
        gsettings set org.gnome.desktop.interface gtk-theme 'Catppuccin-Latte-Light'
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
        ;;
esac

# Kvantum theme
case "$theme" in
    mocha)
        kvantummanager --set Catppuccin-Mocha-Dark
        ;;
    latte)
        kvantummanager --set Catppuccin-Latte-Light
        ;;
esac

echo "Theme applied: $theme"
```

Note: `theme-apply.sh` lives in `scripts/` (project-level, NOT chezmoi managed) because it needs to call `chezmoi apply` and modify system-level settings (GTK theme, Kvantum). It's the bridge between the chezmoi template system and runtime theme switching.

- [ ] **Step 3: Make executable and commit**

```bash
chmod +x dot_config/rofi-wayland/scripts/themeswitch.sh
chmod +x scripts/theme-apply.sh
git add dot_config/rofi-wayland/scripts/themeswitch.sh scripts/theme-apply.sh
git commit -m "feat: add theme switch script (Mocha/Latte/auto toggle) and theme-apply helper (chezmoi apply + GTK/Kvantum reload)"
```

---

### Task 8: Create fcitx5 Config

**Files:**
- Remove: `/Users/viryoke/arch-config/dot_config/fcitx5/.keep`
- Create: `/Users/viryoke/arch-config/dot_config/fcitx5/config`
- Create: `/Users/viryoke/arch-config/dot_config/fcitx5/profile`

- [ ] **Step 1: Remove .keep placeholder**

```bash
rm /Users/viryoke/arch-config/dot_config/fcitx5/.keep
```

- [ ] **Step 2: Create fcitx5/config**

```ini
[Hotkey]
TriggerKey=CTRL_SPACE
EnumerateForwardKey=CTRL_SHIFT_SPACE
EnumerateBackwardKey=

[Behavior]
ActiveByDefault=False
ShareInputState=Program
DefaultIM=pinyin

```

Note: `CTRL_SPACE` toggles between English and Chinese input. `pinyin` is the default input method. `ActiveByDefault=False` means English is default until toggled.

- [ ] **Step 3: Create fcitx5/profile**

```ini
[Groups/0]
# Group Name
Name=Default
# Layout
Default Layout=us
# Default Input Method
DefaultIM=pinyin

[Groups/0/Items/0]
# Name
Name=keyboard-us
# Layout
Layout=

[Groups/0/Items/1]
# Name
Name=pinyin
# Layout
Layout=

[GroupOrder]
0=Default
```

Note: Defines two input methods in the default group: `keyboard-us` (English keyboard) and `pinyin` (Chinese pinyin via fcitx5-chinese-addons). The `pinyin` method uses fcitx5-rime as backend if available, otherwise falls back to fcitx5-chinese-addons' built-in pinyin.

- [ ] **Step 4: Commit fcitx5 config**

```bash
git add dot_config/fcitx5/config dot_config/fcitx5/profile
git commit -m "feat: add fcitx5 input method config (Chinese pinyin + English keyboard)"
```

---

### Task 9: Update .chezmoiignore.tmpl for New Dirs

**Files:**
- Modify: `/Users/viryoke/arch-config/.chezmoiignore.tmpl`

The swaylock and wlogout directories need to be added to the Mac ignore list since they're Linux-only (swaylock and wlogout don't exist on macOS).

- [ ] **Step 1: Update .chezmoiignore.tmpl**

Add swaylock and wlogout to the Darwin ignore section:

```
{{- if eq .chezmoi.os "darwin" }}
.config/niri/
.config/fcitx5/
.config/waybar/
.config/rofi-wayland/
.config/swaync/
.config/yazi/
.config/zellij/
.config/lazyvim/
.config/clash-verge-rev/
.config/swaylock/
.config/wlogout/
encrypted/clash-verge-rev-profiles.yaml.age
{{- end }}
```

- [ ] **Step 2: Commit chezmoiignore update**

```bash
git add .chezmoiignore.tmpl
git commit -m "fix: add swaylock and wlogout to Mac ignore list in chezmoiignore"
```

---

## Self-Review Checklist

**1. Spec coverage:**
- ✅ Rofi app launcher (drun) → Task 1 (config.rasi)
- ✅ Rofi power menu → Task 2 (powermenu.sh via wlogout)
- ✅ Rofi clipboard → Task 3 (clipboard.sh via cliphist)
- ✅ Rofi screenshot → Task 4 (screenshot.sh via hyprshot)
- ✅ Rofi emoji picker → Task 5 (emoji.sh via rofi-emoji)
- ✅ Rofi wallpaper selector → Task 6 (wallpaper.sh via swww)
- ✅ Rofi theme switcher → Task 7 (themeswitch.sh)
- ✅ wallbash color extraction → Task 7 (wallbash_mode in themeswitch.sh)
- ✅ Dark/Light theme toggle → Task 7 (Mocha/Latte/auto)
- ✅ Theme cache mechanism → Task 7 (theme.cache + wallpaper.cache + palette.cache)
- ✅ Theme apply (regenerate configs + signal apps) → Task 7 (theme-apply.sh)
- ✅ fcitx5 config (Chinese+English) → Task 8
- ✅ swaylock/wlogout Mac ignore → Task 9
- ✅ Rofi theme files (Mocha/Latte/shared) → Task 1

**2. Placeholder scan:** No TBD/TODO found. All scripts contain complete bash code. All config files contain actual content.

**3. Type consistency:** Theme values "mocha" and "latte" used consistently across themeswitch.sh, theme-apply.sh, and rofi theme files. Cache file paths (`$CACHE_DIR/theme.cache`, `$CACHE_DIR/wallpaper.cache`) consistent between wallpaper.sh and themeswitch.sh.