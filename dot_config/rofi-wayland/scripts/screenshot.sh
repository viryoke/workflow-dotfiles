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