#!/usr/bin/env bash
# Screenshot menu - workflow-dotfiles managed by chezmoi
# Options: fullscreen, area, window, timed (5s delay)
# Uses slurp+grim for capture (Wayland-native, works on Niri)

pkill rofi && exit 0

SCREENSHOT_THEME="shared"

options="Fullscreen\nArea\nWindow\nTimed (5s)"

selected=$(echo -e "$options" | rofi -dmenu -i -p "Screenshot" \
    -theme "$SCREENSHOT_THEME" \
    -theme-str "window { width: 25em; height: 15em; }" \
    -theme-str "listview { lines: 4; }")

SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOT_DIR"
FILENAME="$(date +%Y-%m-%d-%H-%M-%S).png"

case "$selected" in
    "Fullscreen")
        grim "$SCREENSHOT_DIR/$FILENAME"
        ;;
    "Area")
        slurp | grim -g - "$SCREENSHOT_DIR/$FILENAME"
        ;;
    "Window")
        niri msg action screenshot-window
        ;;
    "Timed (5s)")
        sleep 5
        grim "$SCREENSHOT_DIR/$FILENAME"
        ;;
esac