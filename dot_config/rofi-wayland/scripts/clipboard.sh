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