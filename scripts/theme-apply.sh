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