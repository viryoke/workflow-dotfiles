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