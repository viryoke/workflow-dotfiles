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