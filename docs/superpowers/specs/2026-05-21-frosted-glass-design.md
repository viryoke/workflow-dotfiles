# Frosted Glass (Blur/Opacity/Vibrancy) Design

**Date**: 2026-05-21
**Scope**: Add blur, opacity, and vibrancy (frosted glass) effects across the niri Wayland desktop

## Approach

Unified through niri compositor — all blur rendering handled by niri's `blur {}` block, `layer-rule`, and `window-rule`. CSS changes are minimal: just switch opaque hex backgrounds to semi-transparent `rgba()` so compositor blur tints through.

## 1. Niri `blur {}` Block

Add top-level block in `niri/config.kdl.tmpl` after `layout {}`:

```kdl
blur {
    passes 2
    offset 1.0
    noise 0.02
    saturation 1.2
}
```

- `passes 2`: light dual-kawase blur intensity
- `offset 1.0`: original dual kawase offset (free in GPU cost)
- `noise 0.02`: reduces color banding artifacts
- `saturation 1.2`: subtle vibrancy boost (20% more saturated colors bleeding through)

## 2. Niri Layer Rules

New file `niri/layerrules.kdl`, included in main config via `include "./layerrules.kdl"`:

```kdl
// Layer rules for frosted glass on layer-shell surfaces

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

## 3. Niri Window Rules

Append to existing `niri/windowrules.kdl`:

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

Terminals at 0.90 with vibrancy. Inactive windows at 0.95 with plain blur (no saturation boost).

## 4. CSS Changes

### Waybar (`waybar/style.css.tmpl`)

Replace opaque `@base` and `@surface0` backgrounds with rgba equivalents:
- `window#waybar` background: `rgba(base, 0.85)`
- Modules using `@surface0` background: `rgba(surface0, 0.85)`
- Tooltip background: `rgba(mantle, 0.85)`

Implementation: since CSS doesn't support `rgba(@variable, alpha)`, we'll define theme-specific rgba variables alongside the hex ones. For mocha: `@define-color base-alpha rgba(30, 30, 46, 0.85)`. For latte: `@define-color base-alpha rgba(239, 241, 245, 0.85)`.

### SwayNC (`swaync/style.css.tmpl`)

Same pattern — add rgba color variables and use them:
- `.control-center` background: `@base-alpha`
- `.notification` background: `@surface0-alpha`
- Widget backgrounds: corresponding rgba values

### Rofi (`themes/shared.rasi`)

Rofi uses hex with alpha channel (8-digit hex). Update `main-bg`:
- Current: `#11111be6` (already has alpha `e6` ≈ 90%)
- This is already semi-transparent! Just ensure the niri layer-rule provides blur behind it.

No changes needed to shared.rasi — the existing alpha is sufficient.

### wlogout

No changes. Full-screen overlay — blur behind it would be visually confusing.

## 5. Files Modified

| File | Change |
|------|--------|
| `niri/config.kdl.tmpl` | Add `blur {}` block + `include "./layerrules.kdl"` |
| `niri/layerrules.kdl` | New file — layer rules for waybar/swaync/rofi |
| `niri/windowrules.kdl` | Append terminal blur rules + inactive dim rule |
| `waybar/style.css.tmpl` | Add rgba color variables, use them for backgrounds |
| `swaync/style.css.tmpl` | Add rgba color variables, use them for backgrounds |

## 6. Not Modified

- `rofi/themes/shared.rasi` — already has alpha in hex colors
- `wlogout/style.css.tmpl` — full-screen overlay, no transparency needed
- `ghostty/config.tmpl` — terminal opacity handled by niri window-rule
- `swaylock/config` — lock screen, no transparency applicable