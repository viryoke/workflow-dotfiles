# Desktop Shell Implementation Plan (Niri + Waybar + SwayNC)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create Niri WM config, Waybar bar config with 17 modules, SwayNC notification center config, and startup/lock/logout configs — the core desktop shell for the CachyOS PC.

**Architecture:** All config files live in `dot_config/` chezmoi source directory and are deployed to `~/.config/` on the CachyOS machine. Niri config uses KDL format with `include` directives for modularity (keybindings, window rules, hardware). Waybar uses JSONC config + CSS styling with Catppuccin color variables. SwayNC uses JSON config + CSS styling. All configs are Linux-only (ignored on Mac via `.chezmoiignore.tmpl`). Some files use `.tmpl` suffix for theme conditional content (Mocha vs Latte), others are static (only used on Linux with dark theme default).

**Tech Stack:** niri (KDL config), waybar (JSONC + GTK3 CSS), SwayNC (JSON + CSS), swayidle, swaylock, wlogout, Catppuccin color palette

---

## File Structure (this plan creates)

```
dot_config/
├── niri/
│   ├── config.kdl.tmpl        ← main niri config (includes other files)
│   ├── keybindings.kdl         ← keyboard shortcuts (static, no theme deps)
│   ├── windowrules.kdl         ← window matching rules (static)
│   └── spawn-at-startup.kdl    ← autostart commands (static)
├── waybar/
│   ├── config.jsonc.tmpl       ← module layout + config (theme affects icons)
│   └── style.css.tmpl          ← Catppuccin Mocha/Latte CSS variables
├── swaync/
│   ├── config.json             ← notification center config (static)
│   └── style.css.tmpl          ← Catppuccin Mocha/Latte styling
├── swaylock/
│   └── config                  ← lock screen config (static)
└── wlogout/
│   └── layout                  ← logout menu buttons (static)
│   └── style.css.tmpl          ← Catppuccin Mocha/Latte styling
```

---

### Task 1: Create Niri Main Config (config.kdl.tmpl)

**Files:**
- Remove: `/Users/viryoke/arch-config/dot_config/niri/.keep`
- Create: `/Users/viryoke/arch-config/dot_config/niri/config.kdl.tmpl`

- [ ] **Step 1: Remove .keep placeholder**

```bash
rm /Users/viryoke/arch-config/dot_config/niri/.keep
```

- [ ] **Step 2: Create config.kdl.tmpl**

```kdl
// Niri config - arch-config managed by chezmoi
// Cross-platform but Linux-only (ignored on Mac)

{{- if eq .theme "mocha" }}
environment {
    NIRI_CONFIG_THEME "mocha"
    QT_QPA_PLATFORM "wayland;xcb"
    XDG_CURRENT_DESKTOP "niri"
    GDK_BACKEND "wayland"
    ELECTRON_OZONE_PLATFORM_HINT "wayland"
}
{{- else }}
environment {
    NIRI_CONFIG_THEME "latte"
    QT_QPA_PLATFORM "wayland;xcb"
    XDG_CURRENT_DESKTOP "niri"
    GDK_BACKEND "wayland"
    ELECTRON_OZONE_PLATFORM_HINT "wayland"
}
{{- end }}

include "./keybindings.kdl"
include "./windowrules.kdl"
include "./spawn-at-startup.kdl"

input {
    keyboard {
        xkb {
            layout "us"
            options "ctrl:nocaps,compose:ralt"
        }
        repeat-delay 600
        repeat-rate 25
    }
    touchpad {
        tap
        dwt
        natural-scroll
        accel-speed 0.2
    }
    mouse {
        natural-scroll
        accel-speed 0.2
    }
    warp-mouse-to-focus
    focus-follows-mouse max-scroll-amount="0%"
}

cursor {
    xcursor-theme "Bibata-Modern-Cursor"
    xcursor-size 24
    hide-after-inactive-ms 3000
}

layout {
    gaps 8
    center-focused-column "on-overflow"
    always-center-single-column

    preset-column-widths {
        proportion 0.33333
        proportion 0.5
        proportion 0.66667
        fixed 1280
    }
    default-column-width { proportion 0.5; }

    preset-window-heights {
        proportion 0.33333
        proportion 0.5
        proportion 0.66667
        fixed 720
    }

    focus-ring {
        width 4
        {{- if eq .theme "mocha" }}
        active-color "#cba6f7"
        inactive-color "#45475a"
        urgent-color "#f38ba8"
        {{- else }}
        active-color "#8839ef"
        inactive-color "#9ca0b0"
        urgent-color "#d20f39"
        {{- end }}
    }

    border {
        off
    }

    shadow {
        softness 30
        spread 5
        offset x=0 y=5
        draw-behind-window true
        color "#00000070"
    }

    struts {
        left 0
        right 0
        top 0
        bottom 0
    }

    tab-indicator {
        hide-when-single-tab
        place-within-column
        gap 5
        width 4
        active-color "#cba6f7"
        inactive-color "#585b70"
    }
}

prefer-no-csd

screenshot-path "~/Pictures/Screenshots/%Y-%m-%d-%H-%M-%S.png"

hotkey-overlay {
    skip-at-startup
}

animations {
    slowdown 1.0
}

output "eDP-1" {
    // Laptop screen placeholder - configure per machine
}

output "HDMI-A-1" {
    // External monitor placeholder - configure per machine
}
```

Notes:
- Uses `include` directives for modular config (keybindings, window rules, startup)
- Template conditionals for theme-dependent focus-ring colors and environment variables
- `ctrl:nocaps` remaps Caps Lock to Ctrl (common preference)
- `compose:ralt` uses Right Alt as compose key
- `center-focused-column "on-overflow"` — centers only when work area is narrow
- `prefer-no-csd` — asks apps to omit client-side decorations
- Output blocks are placeholders — user will configure per machine

- [ ] **Step 3: Commit niri main config**

```bash
git add dot_config/niri/config.kdl.tmpl
git commit -m "feat: add Niri WM config with Catppuccin theme conditionals and modular includes"
```

---

### Task 2: Create Niri Keybindings (keybindings.kdl)

**Files:**
- Create: `/Users/viryoke/arch-config/dot_config/niri/keybindings.kdl`

- [ ] **Step 1: Create keybindings.kdl**

```kdl
// Niri keybindings - arch-config managed by chezmoi
// Mod = Super key

binds {
    // Terminal
    Mod+Return { spawn "ghostty"; }

    // App launcher
    Mod+D { spawn "rofi" "-show" "drun"; }

    // Clipboard
    Mod+V { spawn "rofi" "-show" "clipboard" "-modi" "clipboard:~/.config/rofi-wayland/scripts/clipboard.sh"; }

    // Close window
    Mod+Q { close-window; }

    // Window focus (vim-style)
    Mod+Left { focus-column-left; }
    Mod+Down { focus-window-down; }
    Mod+Up { focus-window-up; }
    Mod+Right { focus-column-right; }
    Mod+H { focus-column-left; }
    Mod+J { focus-window-down; }
    Mod+K { focus-window-up; }
    Mod+L { focus-column-right; }

    // Move window
    Mod+Ctrl+Left { move-column-left; }
    Mod+Ctrl+Down { move-window-down; }
    Mod+Ctrl+Up { move-window-up; }
    Mod+Ctrl+Right { move-column-right; }
    Mod+Ctrl+H { move-column-left; }
    Mod+Ctrl+J { move-window-down; }
    Mod+Ctrl+K { move-window-up; }
    Mod+Ctrl+L { move-column-right; }

    // Workspace switching (1-9)
    Mod+1 { focus-workspace "1"; }
    Mod+2 { focus-workspace "2"; }
    Mod+3 { focus-workspace "3"; }
    Mod+4 { focus-workspace "4"; }
    Mod+5 { focus-workspace "5"; }
    Mod+6 { focus-workspace "6"; }
    Mod+7 { focus-workspace "7"; }
    Mod+8 { focus-workspace "8"; }
    Mod+9 { focus-workspace "9"; }
    Mod+0 { focus-workspace "10"; }

    // Move window to workspace
    Mod+Ctrl+1 { move-column-to-workspace "1"; }
    Mod+Ctrl+2 { move-column-to-workspace "2"; }
    Mod+Ctrl+3 { move-column-to-workspace "3"; }
    Mod+Ctrl+4 { move-column-to-workspace "4"; }
    Mod+Ctrl+5 { move-column-to-workspace "5"; }
    Mod+Ctrl+6 { move-column-to-workspace "6"; }
    Mod+Ctrl+7 { move-column-to-workspace "7"; }
    Mod+Ctrl+8 { move-column-to-workspace "8"; }
    Mod+Ctrl+9 { move-column-to-workspace "9"; }
    Mod+Ctrl+0 { move-column-to-workspace "10"; }

    // Adjacent workspace nav
    Mod+U { focus-workspace-down; }
    Mod+I { focus-workspace-up; }
    Mod+Ctrl+U { move-column-to-workspace-down; }
    Mod+Ctrl+I { move-column-to-workspace-up; }

    // Column width presets
    Mod+R { switch-preset-column-width; }
    Mod+F { maximize-column; }
    Mod+Shift+F { fullscreen-window; }

    // Column resize
    Mod+Minus { set-column-width "-10%"; }
    Mod+Equal { set-column-width "+10%"; }
    Mod+Shift+Minus { set-window-height "-10%"; }
    Mod+Shift+Equal { set-window-height "+10%"; }

    // Window merging/splitting
    Mod+Comma { consume-window-into-column; }
    Mod+Period { expel-window-from-column; }

    // Floating/tiling toggle
    Mod+Shift+V { toggle-window-floating; }

    // Tabbed display
    Mod+W { toggle-column-tabbed-display; }

    // Overview
    Mod+O { toggle-overview; }

    // Screenshots
    Print { screenshot; }
    Ctrl+Print { screenshot-screen; }
    Alt+Print { screenshot-window; }

    // Power/lock
    Mod+Shift+E { quit; }
    Mod+Shift+P { power-off-monitors; }
    Mod+Escape { toggle-keyboard-shortcuts-inhibit; }
    Ctrl+Alt+Delete { quit; skip-confirmation; }

    // Audio/media keys
    XF86AudioRaiseVolume { spawn "pactl" "set-sink-volume" "@DEFAULT_SINK@" "+5%"; }
    XF86AudioLowerVolume { spawn "pactl" "set-sink-volume" "@DEFAULT_SINK@" "-5%"; }
    XF86AudioMute { spawn "pactl" "set-sink-mute" "@DEFAULT_SINK@" "toggle"; }
    XF86AudioMicMute { spawn "pactl" "set-source-mute" "@DEFAULT_SOURCE@" "toggle"; }
    XF86AudioPlay { spawn "playerctl" "play-pause"; }
    XF86AudioNext { spawn "playerctl" "next"; }
    XF86AudioPrev { spawn "playerctl" "previous"; }

    // Rofi menus
    Mod+Shift+D { spawn "~/.config/rofi-wayland/scripts/powermenu.sh"; }
    Mod+Shift+S { spawn "~/.config/rofi-wayland/scripts/screenshot.sh"; }
    Mod+Shift+E { spawn "~/.config/rofi-wayland/scripts/emoji.sh"; }
    Mod+Shift+W { spawn "~/.config/rofi-wayland/scripts/wallpaper.sh"; }
    Mod+Shift+T { spawn "~/.config/rofi-wayland/scripts/themeswitch.sh"; }

    // Monitor brightness
    XF86MonBrightnessUp { spawn "light" "-A" "5"; }
    XF86MonBrightnessDown { spawn "light" "-U" "5"; }
}
```

- [ ] **Step 2: Commit keybindings**

```bash
git add dot_config/niri/keybindings.kdl
git commit -m "feat: add Niri keybindings with vim-style nav, workspace switching, and rofi menu bindings"
```

---

### Task 3: Create Niri Window Rules + Startup

**Files:**
- Create: `/Users/viryoke/arch-config/dot_config/niri/windowrules.kdl`
- Create: `/Users/viryoke/arch-config/dot_config/niri/spawn-at-startup.kdl`

- [ ] **Step 1: Create windowrules.kdl**

```kdl
// Niri window rules - arch-config managed by chezmoi

window-rule {
    match app-id="firefox"
    open-on-workspace "2"
}

window-rule {
    match app-id="telegramdesktop"
    open-on-workspace "3"
}

window-rule {
    match title=r#"WeChat"#
    open-on-workspace "3"
}

window-rule {
    match app-id="steam"
    open-on-workspace "4"
    open-maximized true
}

window-rule {
    match app-id="org.kde.dolphin"
    open-on-workspace "5"
}

window-rule {
    match app-id="thunar"
    open-on-workspace "5"
}

window-rule {
    match app-id="libreoffice"
    open-on-workspace "6"
}

window-rule {
    match app-id="mpv"
    open-maximized true
    open-floating true
}

window-rule {
    match app-id="pavucontrol"
    open-floating true
    default-column-width { fixed 600; }
    default-window-height { fixed 400; }
}

window-rule {
    match app-id="blueman-manager"
    open-floating true
    default-column-width { fixed 500; }
    default-window-height { fixed 400; }
}

window-rule {
    match app-id="swaync"
    open-floating true
}
```

- [ ] **Step 2: Create spawn-at-startup.kdl**

```kdl
// Niri startup commands - arch-config managed by chezmoi

spawn-at-startup "waybar"
spawn-at-startup "swaync-client" "-sw"
spawn-at-startup "swww" "restore"
spawn-at-startup "wl-paste" "--watch" "cliphist" "store"
spawn-at-startup "swayidle" "-w" "timeout" "300" "swaylock" "timeout" "600" "loginctl" "suspend" "before-sleep" "swaylock"
spawn-at-startup "fcitx5" "-d" "--replace"
```

Notes:
- `waybar` — status bar
- `swaync-client -sw` — start SwayNC and wait
- `swww restore` — restore last wallpaper
- `wl-paste --watch cliphist store` — clipboard history tracking
- `swayidle` — idle timeout → lock after 5min, suspend after 10min
- `fcitx5 -d --replace` — input method daemon

- [ ] **Step 3: Commit window rules and startup**

```bash
git add dot_config/niri/windowrules.kdl dot_config/niri/spawn-at-startup.kdl
git commit -m "feat: add Niri window rules (workspace assignment) and autostart commands"
```

---

### Task 4: Create Waybar Config (config.jsonc.tmpl)

**Files:**
- Remove: `/Users/viryoke/arch-config/dot_config/waybar/.keep`
- Create: `/Users/viryoke/arch-config/dot_config/waybar/config.jsonc.tmpl`

- [ ] **Step 1: Remove .keep placeholder**

```bash
rm /Users/viryoke/arch-config/dot_config/waybar/.keep
```

- [ ] **Step 2: Create config.jsonc.tmpl**

```jsonc
// Waybar config - arch-config managed by chezmoi
// 17 modules + tray for Niri desktop

{
    "layer": "top",
    "position": "top",
    "height": 36,
    "spacing": 4,
    "modules-left": ["niri/workspaces", "niri/window"],
    "modules-center": ["clock"],
    "modules-right": [
        "keyboard-state",
        "cpu",
        "memory",
        "temperature",
        "disk",
        "network",
        "bluetooth",
        "pulseaudio",
        "battery",
        "backlight",
        "idle_inhibitor",
        "custom/swaync",
        "custom/cliphist",
        "custom/wlsunset",
        "tray"
    ],
    "niri/workspaces": {
        "format": "{icon}",
        "format-icons": {
            "1": "一",
            "2": "二",
            "3": "三",
            "4": "四",
            "5": "五",
            "6": "六",
            "7": "七",
            "8": "八",
            "9": "九",
            "10": "十",
            "focused": "",
            "active": "",
            "urgent": "",
            "empty": "",
            "default": ""
        },
        "current-only": false,
        "hide-empty": false
    },
    "niri/window": {
        "format": "{title}",
        "icon": true,
        "icon-size": 24,
        "max-length": 50,
        "separate-outputs": false
    },
    "keyboard-state": {
        "numlock": true,
        "capslock": true,
        "format": "{name} {icon}",
        "format-icons": {
            "locked": "",
            "unlocked": ""
        }
    },
    "cpu": {
        "format": "{usage}% ",
        "tooltip": false
    },
    "memory": {
        "format": "{}% "
    },
    "temperature": {
        "critical-threshold": 80,
        "format": "{temperatureC}°C {icon}",
        "format-icons": ["", "", ""]
    },
    "disk": {
        "format": "{percentage_used}% ",
        "path": "/"
    },
    "network": {
        "format-wifi": "{essid} ({signalStrength}%) ",
        "format-ethernet": "{ipaddr}/{cidr} ",
        "format-disconnected": "Disconnected ⚠",
        "tooltip-format": "{ifname} via {gwaddr}"
    },
    "bluetooth": {
        "format": " {status}",
        "format-connected": " {device_alias}",
        "format-connected-battery": " {device_alias} {device_battery_percentage}",
        "on-click": "blueman-manager"
    },
    "pulseaudio": {
        "format": "{volume}% {icon}",
        "format-muted": "󰅶",
        "format-icons": { "default": ["", "", ""], "headphone": "" },
        "on-click": "pavucontrol"
    },
    "battery": {
        "states": { "warning": 30, "critical": 15 },
        "format": "{capacity}% {icon}",
        "format-charging": "{capacity}% 󰃨",
        "format-plugged": "{capacity}% ",
        "format-icons": ["", "", "", "", ""]
    },
    "backlight": {
        "format": "{percent}% {icon}",
        "format-icons": ["", "", "", "", "", "", "", "", ""],
        "on-scroll-up": "light -A 5",
        "on-scroll-down": "light -U 5"
    },
    "idle_inhibitor": {
        "format": "{icon}",
        "format-icons": { "activated": "", "deactivated": "" }
    },
    "custom/swaync": {
        "exec": "swaync-client -swb",
        "return-type": "json",
        "format": "{icon}",
        "format-icons": {
            "none": "󰂚",
            "notification": "󰂚",
            "dnd-none": "󰖂",
            "dnd-notification": "󰖂"
        },
        "on-click": "swaync-client -t -sw",
        "on-click-right": "swaync-client -d -sw",
        "escape": true
    },
    "custom/cliphist": {
        "format": "",
        "on-click": "cliphist list | rofi -dmenu | cliphist decode | wl-copy",
        "tooltip-format": "Clipboard History",
        "interval": "once"
    },
    "custom/wlsunset": {
        "format": "{}",
        "exec": "pgrep -x wlsunset && echo '' || echo ''",
        "on-click": "pkill -x wlsunset || wlsunset -l 40 -L 116",
        "tooltip-format": "Night Light",
        "interval": 5
    },
    "clock": {
        "format": "{:%H:%M}",
        "format-alt": "{:%Y-%m-%d}",
        "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>"
    },
    "tray": {
        "spacing": 10
    }
}
```

- [ ] **Step 3: Commit waybar config**

```bash
git add dot_config/waybar/config.jsonc.tmpl
git commit -m "feat: add Waybar config with 17 modules for Niri desktop (workspaces, window, keyboard, cpu, memory, temp, disk, network, bluetooth, pulseaudio, battery, backlight, idle_inhibitor, swaync, cliphist, wlsunset, tray)"
```

---

### Task 5: Create Waybar Style (style.css.tmpl)

**Files:**
- Create: `/Users/viryoke/arch-config/dot_config/waybar/style.css.tmpl`

- [ ] **Step 1: Create style.css.tmpl**

```css
/* Waybar style - arch-config managed by chezmoi */

{{- if eq .theme "mocha" }}
@define-color rosewater #f5e0dc;
@define-color flamingo #f2cdcd;
@define-color pink #f5c2e7;
@define-color mauve #cba6f7;
@define-color red #f38ba8;
@define-color maroon #eba0ac;
@define-color peach #fab387;
@define-color yellow #f9e2af;
@define-color green #a6e3a1;
@define-color teal #94e2d5;
@define-color sky #89dceb;
@define-color sapphire #74c7ec;
@define-color blue #89b4fa;
@define-color lavender #b4befe;
@define-color text #cdd6f4;
@define-color subtext1 #bac2de;
@define-color subtext0 #a6adc8;
@define-color overlay2 #9399b2;
@define-color overlay1 #7f849c;
@define-color overlay0 #6c7086;
@define-color surface2 #585b70;
@define-color surface1 #45475a;
@define-color surface0 #313244;
@define-color base #1e1e2e;
@define-color mantle #181825;
@define-color crust #11111b;
{{- else }}
@define-color rosewater #dc8a78;
@define-color flamingo #dd7878;
@define-color pink #ea76ac;
@define-color mauve #8839ef;
@define-color red #d20f39;
@define-color maroon #e64553;
@define-color peach #fe640b;
@define-color yellow #df8e1d;
@define-color green #40a02b;
@define-color teal #179299;
@define-color sky #04a5e5;
@define-color sapphire #209fb5;
@define-color blue #1e66f5;
@define-color lavender #7287fd;
@define-color text #4c4f69;
@define-color subtext1 #5c5f77;
@define-color subtext0 #6c6f85;
@define-color overlay2 #7c7f93;
@define-color overlay1 #8c8fa1;
@define-color overlay0 #9ca0b0;
@define-color surface2 #acb0be;
@define-color surface1 #bcc0cc;
@define-color surface0 #ccd0da;
@define-color base #eff1f5;
@define-color mantle #e6e9ef;
@define-color crust #dce0e8;
{{- end }}

* {
    font-family: "JetBrainsMono Nerd Font";
    font-size: 14px;
    min-height: 0;
}

window#waybar {
    background: @base;
    color: @text;
}

#workspaces button {
    padding: 0 8px;
    color: @text;
    background: transparent;
    border-radius: 8px;
}

#workspaces button.focused {
    background: @mauve;
    color: @base;
}

#workspaces button.urgent {
    background: @red;
    color: @base;
}

#workspaces button:hover {
    background: @surface0;
}

#window {
    padding: 0 10px;
    color: @text;
}

#clock {
    padding: 0 10px;
    color: @mauve;
}

#keyboard-state {
    padding: 0 8px;
    color: @text;
    background: @surface0;
    border-radius: 8px;
}

#cpu {
    padding: 0 8px;
    color: @mauve;
    background: @surface0;
    border-radius: 8px;
}

#memory {
    padding: 0 8px;
    color: @peach;
    background: @surface0;
    border-radius: 8px;
}

#temperature {
    padding: 0 8px;
    color: @sapphire;
    background: @surface0;
    border-radius: 8px;
}

#temperature.critical {
    color: @red;
}

#disk {
    padding: 0 8px;
    color: @teal;
    background: @surface0;
    border-radius: 8px;
}

#network {
    padding: 0 8px;
    color: @teal;
    background: @surface0;
    border-radius: 8px;
}

#network.disconnected {
    color: @red;
}

#bluetooth {
    padding: 0 8px;
    color: @blue;
    background: @surface0;
    border-radius: 8px;
}

#bluetooth.connected {
    color: @blue;
}

#pulseaudio {
    padding: 0 8px;
    color: @rosewater;
    background: @surface0;
    border-radius: 8px;
}

#pulseaudio.muted {
    color: @overlay0;
}

#battery {
    padding: 0 8px;
    color: @green;
    background: @surface0;
    border-radius: 8px;
}

#battery.warning {
    color: @yellow;
}

#battery.critical {
    color: @red;
}

#backlight {
    padding: 0 8px;
    color: @yellow;
    background: @surface0;
    border-radius: 8px;
}

#idle_inhibitor {
    padding: 0 8px;
    color: @text;
    background: @surface0;
    border-radius: 8px;
}

#idle_inhibitor.activated {
    color: @mauve;
}

#custom-swaync {
    padding: 0 8px;
    color: @text;
    background: @surface0;
    border-radius: 8px;
}

#custom-swaync.notification {
    color: @mauve;
}

#custom-cliphist {
    padding: 0 8px;
    color: @text;
    background: @surface0;
    border-radius: 8px;
}

#custom-wlsunset {
    padding: 0 8px;
    color: @text;
    background: @surface0;
    border-radius: 8px;
}

#tray {
    padding: 0 8px;
}

#tray > .passive {
    color: @overlay0;
}

#tray > .needs-attention {
    color: @red;
}

tooltip {
    background: @mantle;
    color: @text;
    border: 1px solid @surface2;
    border-radius: 8px;
}
```

- [ ] **Step 2: Commit waybar style**

```bash
git add dot_config/waybar/style.css.tmpl
git commit -m "feat: add Waybar CSS style with Catppuccin Mocha/Latte theme conditionals"
```

---

### Task 6: Create SwayNC Config + Style

**Files:**
- Remove: `/Users/viryoke/arch-config/dot_config/swaync/.keep`
- Create: `/Users/viryoke/arch-config/dot_config/swaync/config.json`
- Create: `/Users/viryoke/arch-config/dot_config/swaync/style.css.tmpl`

- [ ] **Step 1: Remove .keep placeholder**

```bash
rm /Users/viryoke/arch-config/dot_config/swaync/.keep
```

- [ ] **Step 2: Create config.json**

```json
{
    "$schema": "https://raw.githubusercontent.com/ErikReider/SwayNotificationCenter/refs/heads/main/src/configSchema.json",
    "positionX": "right",
    "positionY": "top",
    "control-center-positionX": "none",
    "control-center-positionY": "none",
    "control-center-margin-top": 2,
    "control-center-margin-bottom": 2,
    "control-center-margin-right": 1,
    "control-center-margin-left": 0,
    "control-center-width": 400,
    "control-center-height": 300,
    "fit-to-screen": true,
    "layer-shell": true,
    "cssPriority": "user",
    "notification-icon-opacity": 1.0,
    "timeout": 10,
    "timeout-low": 5,
    "timeout-critical": 0,
    "notification-window-width": 400,
    "keyboard-shortcuts": true,
    "image-visibility": "when-available",
    "transition-time": 200,
    "hide-on-clear": false,
    "hide-on-action": true,
    "script-fail-notify": true,
    "widgets": [
        "title",
        "dnd",
        "notifications",
        "mpris",
        "volume",
        "backlight",
        "buttons-grid"
    ],
    "widget-config": {
        "title": {
            "text": "Notifications",
            "clear-all-button": true,
            "button-text": "Clear All"
        },
        "dnd": {
            "text": "Do Not Disturb"
        },
        "volume": {
            "label": " 󰕾 "
        },
        "backlight": {
            "label": " 󰃟 ",
            "device": "intel_backlight"
        },
        "buttons-grid": {
            "actions": [
                {
                    "label": "  _wifi  ",
                    "command": "nm-connection-editor",
                    "type": "normal"
                },
                {
                    "label": "  󰂯  ",
                    "command": "blueman-manager",
                    "type": "normal"
                },
                {
                    "label": "  󰃛  ",
                    "command": "pkill -x wlsunset || wlsunset -l 40 -L 116",
                    "type": "toggle"
                },
                {
                    "label": "  ⏻  ",
                    "command": "wlogout",
                    "type": "normal"
                }
            ]
        }
    }
}
```

- [ ] **Step 3: Create style.css.tmpl**

```css
/* SwayNC style - arch-config managed by chezmoi */

{{- if eq .theme "mocha" }}
@define-color rosewater #f5e0dc;
@define-color flamingo #f2cdcd;
@define-color pink #f5c2e7;
@define-color mauve #cba6f7;
@define-color red #f38ba8;
@define-color maroon #eba0ac;
@define-color peach #fab387;
@define-color yellow #f9e2af;
@define-color green #a6e3a1;
@define-color teal #94e2d5;
@define-color sky #89dceb;
@define-color sapphire #74c7ec;
@define-color blue #89b4fa;
@define-color lavender #b4befe;
@define-color text #cdd6f4;
@define-color subtext1 #bac2de;
@define-color subtext0 #a6adc8;
@define-color overlay2 #9399b2;
@define-color overlay1 #7f849c;
@define-color overlay0 #6c7086;
@define-color surface2 #585b70;
@define-color surface1 #45475a;
@define-color surface0 #313244;
@define-color base #1e1e2e;
@define-color mantle #181825;
@define-color crust #11111b;
{{- else }}
@define-color rosewater #dc8a78;
@define-color flamingo #dd7878;
@define-color pink #ea76ac;
@define-color mauve #8839ef;
@define-color red #d20f39;
@define-color maroon #e64553;
@define-color peach #fe640b;
@define-color yellow #df8e1d;
@define-color green #40a02b;
@define-color teal #179299;
@define-color sky #04a5e5;
@define-color sapphire #209fb5;
@define-color blue #1e66f5;
@define-color lavender #7287fd;
@define-color text #4c4f69;
@define-color subtext1 #5c5f77;
@define-color subtext0 #6c6f85;
@define-color overlay2 #7c7f93;
@define-color overlay1 #8c8fa1;
@define-color overlay0 #9ca0b0;
@define-color surface2 #acb0be;
@define-color surface1 #bcc0cc;
@define-color surface0 #ccd0da;
@define-color base #eff1f5;
@define-color mantle #e6e9ef;
@define-color crust #dce0e8;
{{- end }}

.control-center {
    background: @base;
    color: @text;
    border-radius: 12px;
    border: 2px solid @surface2;
    padding: 12px;
}

.notification-row .notification-background .notification {
    color: @text;
    border-radius: 12px;
    border: 2px solid @surface2;
    background: @surface0;
    padding: 8px;
}

.notification-row .notification-background .notification .notification-content .text-box .summary {
    color: @text;
    font-size: 14px;
    font-weight: bold;
}

.notification-row .notification-background .notification .notification-content .text-box .body {
    color: @subtext1;
    font-size: 13px;
}

.notification-default-action .notification-content .image {
    margin: 4px;
}

.dnd-button {
    border-radius: 8px;
    background: @surface0;
    color: @text;
    border: 1px solid @surface2;
    padding: 4px 12px;
}

.dnd-button:checked {
    background: @mauve;
    color: @base;
}

.clear-notifications-button {
    border-radius: 8px;
    background: @surface0;
    color: @text;
    border: 1px solid @surface2;
    padding: 4px 12px;
}

.clear-notifications-button:hover {
    background: @red;
    color: @base;
}

.notification-action {
    border-radius: 8px;
    background: @surface0;
    color: @text;
    border: 1px solid @surface2;
}

.notification-action:hover {
    background: @mauve;
    color: @base;
}

.notification-close-button {
    background: @surface0;
    color: @text;
    border-radius: 8px;
}

.notification-close-button:hover {
    background: @red;
    color: @base;
}

.widget-title {
    color: @mauve;
    font-size: 18px;
    font-weight: bold;
    padding: 4px;
}

.widget-dnd {
    color: @text;
    font-size: 14px;
}

.widget-mpris {
    background: @surface0;
    border-radius: 8px;
    color: @text;
    padding: 8px;
}

.widget-mpris-player {
    padding: 4px;
}

.widget-mpris-title {
    font-weight: bold;
    font-size: 14px;
}

.widget-mpris-artist {
    color: @subtext1;
    font-size: 12px;
}

.widget-volume {
    background: @surface0;
    border-radius: 8px;
    padding: 8px;
    color: @text;
}

.widget-backlight {
    background: @surface0;
    border-radius: 8px;
    padding: 8px;
    color: @text;
}

.widget-buttons-grid {
    padding: 4px;
    flowboxchild {
        border-radius: 8px;
        background: @surface0;
        color: @text;
        padding: 8px;
        border: 1px solid @surface2;
    }
    flowboxchild:hover {
        background: @mauve;
        color: @base;
    }
    flowboxchild:active {
        background: @surface1;
    }
}
```

- [ ] **Step 4: Commit SwayNC config and style**

```bash
git add dot_config/swaync/config.json dot_config/swaync/style.css.tmpl
git commit -m "feat: add SwayNC notification center config with Catppuccin theme styling"
```

---

### Task 7: Create swaylock + wlogout Configs

**Files:**
- Create: `/Users/viryoke/arch-config/dot_config/swaylock/config`
- Create: `/Users/viryoke/arch-config/dot_config/wlogout/layout`
- Create: `/Users/viryoke/arch-config/dot_config/wlogout/style.css.tmpl`

- [ ] **Step 1: Create swaylock config**

```ini
# swaylock config - arch-config managed by chezmoi
ignore-empty-password
show-failed-attempts
daemonize
color=#1e1e2e
inside-color=#313244
ring-color=#585b70
key-hl-color=#cba6f7
bs-hl-color=#f38ba8
text-color=#cdd6f4
inside-ver-color=#cba6f7
ring-ver-color=#cba6f7
text-ver-color=#1e1e2e
inside-wrong-color=#f38ba8
ring-wrong-color=#f38ba8
text-wrong-color=#1e1e2e
line-uses-inside
```

Note: Colors are hardcoded Catppuccin Mocha (dark theme). Lock screen always uses dark colors since you don't want bright colors when locking at night.

- [ ] **Step 2: Create wlogout layout**

```json
[
    {
        "label": "lock",
        "action": "swaylock",
        "text": "Lock",
        "keybind": "l"
    },
    {
        "label": "logout",
        "action": "niri msg action quit",
        "text": "Logout",
        "keybind": "e"
    },
    {
        "label": "suspend",
        "action": "systemctl suspend",
        "text": "Suspend",
        "keybind": "u"
    },
    {
        "label": "hibernate",
        "action": "systemctl hibernate",
        "text": "Hibernate",
        "keybind": "h"
    },
    {
        "label": "reboot",
        "action": "systemctl reboot",
        "text": "Reboot",
        "keybind": "r"
    },
    {
        "label": "shutdown",
        "action": "systemctl poweroff",
        "text": "Shutdown",
        "keybind": "s"
    }
]
```

- [ ] **Step 3: Create wlogout style.css.tmpl**

```css
/* wlogout style - arch-config managed by chezmoi */

{{- if eq .theme "mocha" }}
@define-color base #1e1e2e;
@define-color surface0 #313244;
@define-color mauve #cba6f7;
@define-color red #f38ba8;
@define-color text #cdd6f4;
@define-color subtext1 #bac2de;
{{- else }}
@define-color base #eff1f5;
@define-color surface0 #ccd0da;
@define-color mauve #8839ef;
@define-color red #d20f39;
@define-color text #4c4f69;
@define-color subtext1 #5c5f77;
{{- end }}

window {
    background: @base;
    font-family: "JetBrainsMono Nerd Font";
    font-size: 16pt;
    color: @text;
}

button {
    background: @surface0;
    color: @text;
    border-radius: 16px;
    margin: 16px;
    padding: 48px;
    border: 2px solid @mauve;
}

button:focus {
    background: @mauve;
    color: @base;
}

button:hover {
    background: @mauve;
    color: @base;
}

#lock {
    background-image: url("/usr/share/wlogout/icons/lock.png");
}

#logout {
    background-image: url("/usr/share/wlogout/icons/logout.png");
}

#suspend {
    background-image: url("/usr/share/wlogout/icons/suspend.png");
}

#hibernate {
    background-image: url("/usr/share/wlogout/icons/hibernate.png");
}

#reboot {
    background-image: url("/usr/share/wlogout/icons/reboot.png");
}

#shutdown {
    background-image: url("/usr/share/wlogout/icons/shutdown.png");
}
```

- [ ] **Step 4: Commit swaylock and wlogout configs**

```bash
git add dot_config/swaylock/config dot_config/wlogout/layout dot_config/wlogout/style.css.tmpl
git commit -m "feat: add swaylock and wlogout configs with Catppuccin Mocha/Latte styling"
```

---

## Self-Review Checklist

**1. Spec coverage:**
- ✅ Niri config (config.kdl + includes) → Tasks 1-3
- ✅ Niri keybindings (vim-style, workspace, rofi menus) → Task 2
- ✅ Niri window rules (workspace assignment) → Task 3
- ✅ Niri startup (waybar, swaync, swww, cliphist, swayidle, fcitx5) → Task 3
- ✅ Waybar 17 modules → Task 4
- ✅ Waybar Catppuccin CSS styling → Task 5
- ✅ SwayNC config (position, timeout, widgets, buttons-grid) → Task 6
- ✅ SwayNC Catppuccin CSS styling → Task 6
- ✅ swaylock config → Task 7
- ✅ wlogout layout (6 buttons) → Task 7
- ✅ wlogout Catppuccin CSS → Task 7
- ❌ Rofi menus (7 scripts + config) → Plan 3B (separate)
- ❌ wallbash/theme engine → Plan 3B (separate)
- ❌ fcitx5 config → Plan 3B (separate)

**2. Placeholder scan:** No TBD/TODO found. All code blocks contain actual config content. Output blocks have placeholder comments ("configure per machine") which are intentional user instructions.

**3. Type consistency:** Theme variable `.theme` used consistently across all `.tmpl` files. Catppuccin color hex values match between Mocha and Latte variants. Waybar CSS module IDs match config module names (`#custom-swaync` matches `"custom/swaync"`, etc.).

**Missing from this plan (deferred to Plan 3B):**
- Rofi menu scripts (7 scripts + config.rasi + themes)
- wallbash/theme switching engine (themeswitch.sh, wallpaper color extraction)
- fcitx5 config