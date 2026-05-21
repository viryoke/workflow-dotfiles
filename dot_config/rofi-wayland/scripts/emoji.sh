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