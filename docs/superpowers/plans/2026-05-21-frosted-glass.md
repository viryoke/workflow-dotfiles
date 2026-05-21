# Frosted Glass Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add light & subtle frosted glass (blur/opacity/vibrancy) effects across the niri Wayland desktop via compositor-level rules and minimal CSS rgba changes.

**Architecture:** Niri compositor handles all blur rendering via top-level `blur {}` block, `layer-rule` for layer-shell surfaces (waybar, swaync, rofi), and `window-rule` for terminals and inactive windows. CSS changes are limited to adding rgba color variables and swapping opaque backgrounds for semi-transparent ones.

**Tech Stack:** Niri (KDL config), Waybar/SwayNC (CSS with chezmoi templating), Rofi (rasi)

---

### Task 1: Add niri `blur {}` block and include layerrules

**Files:**
- Modify: `dot_config/niri/config.kdl.tmpl` — add blur block + include line

- [ ] **Step 1: Add `blur {}` block after `layout {}` section**

Insert after line 127 (the `animations {}` block), before `output "eDP-1"`:

```kdl
blur {
    passes 2
    offset 1.0
    noise 0.02
    saturation 1.2
}
```

- [ ] **Step 2: Add `include "./layerrules.kdl"` line**

Add this include alongside the existing ones (after line 23):

```kdl
include "./layerrules.kdl"
```

The existing include lines are:
```kdl
include "./keybindings.kdl"
include "./windowrules.kdl"
include "./spawn-at-startup.kdl"
```

- [ ] **Step 3: Commit**

```bash
git add dot_config/niri/config.kdl.tmpl
git commit -m "feat: add niri blur block and layerrules include for frosted glass"
```

---

### Task 2: Create niri layer rules file

**Files:**
- Create: `dot_config/niri/layerrules.kdl`

- [ ] **Step 1: Create the layerrules.kdl file**

```kdl
// Niri layer rules for frosted glass - arch-config managed by chezmoi

layer-rule {
    match namespace="^waybar$"
    opacity 0.85
    background-effect {
        blur true
        noise 0.02
        saturation 1.2
    }
}

layer-rule {
    match namespace="^swaync-.*$"
    opacity 0.85
    background-effect {
        blur true
        noise 0.02
        saturation 1.2
    }
}

layer-rule {
    match namespace="^rofi-.*$"
    opacity 0.85
    background-effect {
        blur true
        noise 0.02
        saturation 1.2
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add dot_config/niri/layerrules.kdl
git commit -m "feat: add niri layer rules for waybar/swaync/rofi frosted glass"
```

---

### Task 3: Add niri window rules for terminals and inactive dim

**Files:**
- Modify: `dot_config/niri/windowrules.kdl` — append rules at end

- [ ] **Step 1: Append frosted glass rules after existing rules**

Append after the last existing `window-rule` block (line 62, the swaync floating rule):

```kdl
// Frosted glass for terminals
window-rule {
    match app-id="com.mitchellh.ghostty"
    opacity 0.90
    background-effect {
        blur true
        noise 0.02
        saturation 1.2
    }
}

window-rule {
    match app-id="Alacritty"
    opacity 0.90
    background-effect {
        blur true
        noise 0.02
        saturation 1.2
    }
}

window-rule {
    match app-id="kitty"
    opacity 0.90
    background-effect {
        blur true
        noise 0.02
        saturation 1.2
    }
}

// Subtle dim for inactive windows
window-rule {
    match is-active=false
    opacity 0.95
    background-effect {
        blur true
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add dot_config/niri/windowrules.kdl
git commit -m "feat: add niri window rules for terminal blur and inactive dim"
```

---

### Task 4: Update waybar CSS with rgba transparency

**Files:**
- Modify: `dot_config/waybar/style.css.tmpl`

- [ ] **Step 1: Add rgba color variables alongside existing hex defines**

After the `@define-color crust ...` line in both the mocha and latte template blocks, add:

For **mocha** block (after line 29 `@define-color crust #11111b;`):
```css
@define-color base-alpha rgba(30, 30, 46, 0.85);
@define-color surface0-alpha rgba(49, 50, 68, 0.85);
@define-color mantle-alpha rgba(24, 24, 37, 0.85);
```

For **latte** block (after line 57 `@define-color crust #dce0e8;`):
```css
@define-color base-alpha rgba(239, 241, 245, 0.85);
@define-color surface0-alpha rgba(204, 208, 218, 0.85);
@define-color mantle-alpha rgba(230, 233, 239, 0.85);
```

- [ ] **Step 2: Swap opaque backgrounds for rgba equivalents**

Replace these specific lines:

`window#waybar` background (line 67):
```css
/* Old: background: @base; */
background: @base-alpha;
```

Module backgrounds using `@surface0` — change all instances of `background: @surface0;` to `background: @surface0-alpha;` in these selectors:
- `#keyboard-state`
- `#cpu`
- `#memory`
- `#temperature`
- `#disk`
- `#network`
- `#bluetooth`
- `#pulseaudio`
- `#battery`
- `#backlight`
- `#idle_inhibitor`
- `#custom-swaync`
- `#custom-cliphist`
- `#custom-wlsunset`

Tooltip background (line 244):
```css
/* Old: background: @mantle; */
background: @mantle-alpha;
```

- [ ] **Step 3: Commit**

```bash
git add dot_config/waybar/style.css.tmpl
git commit -m "feat: add rgba transparency to waybar for frosted glass"
```

---

### Task 5: Update swaync CSS with rgba transparency

**Files:**
- Modify: `dot_config/swaync/style.css.tmpl`

- [ ] **Step 1: Add rgba color variables alongside existing hex defines**

After `@define-color crust ...` in both template blocks, add:

For **mocha** block (after line 29 `@define-color crust #11111b;`):
```css
@define-color base-alpha rgba(30, 30, 46, 0.85);
@define-color surface0-alpha rgba(49, 50, 68, 0.85);
@define-color surface1-alpha rgba(69, 71, 90, 0.85);
@define-color surface2-alpha rgba(88, 91, 112, 0.85);
```

For **latte** block (after line 57 `@define-color crust #dce0e8;`):
```css
@define-color base-alpha rgba(239, 241, 245, 0.85);
@define-color surface0-alpha rgba(204, 208, 218, 0.85);
@define-color surface1-alpha rgba(188, 192, 204, 0.85);
@define-color surface2-alpha rgba(172, 176, 190, 0.85);
```

- [ ] **Step 2: Swap opaque backgrounds for rgba equivalents**

`.control-center` (line 60):
```css
/* Old: background: @base; */
background: @base-alpha;
```

`.notification` (line 72):
```css
/* Old: background: @surface0; */
background: @surface0-alpha;
```

`.dnd-button` (line 93):
```css
/* Old: background: @surface0; */
background: @surface0-alpha;
```

`.clear-notifications-button` (line 103):
```css
/* Old: background: @surface0; */
background: @surface0-alpha;
```

`.notification-action` (line 118):
```css
/* Old: background: @surface0; */
background: @surface0-alpha;
```

`.notification-close-button` (line 130):
```css
/* Old: background: @surface0; */
background: @surface0-alpha;
```

`.widget-mpris` (line 153):
```css
/* Old: background: @surface0; */
background: @surface0-alpha;
```

`.widget-volume` (line 174):
```css
/* Old: background: @surface0; */
background: @surface0-alpha;
```

`.widget-backlight` (line 180):
```css
/* Old: background: @surface0; */
background: @surface0-alpha;
```

`.widget-buttons-grid flowboxchild` (line 190):
```css
/* Old: background: @surface0; */
background: @surface0-alpha;
```

`.notification-action:hover` stays `@mauve` (not a surface color).
`.widget-buttons-grid flowboxchild:hover` stays `@mauve`.

- [ ] **Step 3: Commit**

```bash
git add dot_config/swaync/style.css.tmpl
git commit -m "feat: add rgba transparency to swaync for frosted glass"
```