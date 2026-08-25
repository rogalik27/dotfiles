#!/usr/bin/env bash
# Toggles system-wide GTK dark/light theme: gsettings, GTK3/4 settings.ini,
# and alacritty theme.

current=$(gsettings get org.gnome.desktop.interface color-scheme)
if [ "$current" = "'prefer-dark'" ]; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
    sed -i 's/gtk-application-prefer-dark-theme=.*/gtk-application-prefer-dark-theme=0/' ~/.config/gtk-3.0/settings.ini ~/.config/gtk-4.0/settings.ini
    cp ~/.config/alacritty/theme_light.toml ~/.config/alacritty/theme.toml
else
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
    sed -i 's/gtk-application-prefer-dark-theme=.*/gtk-application-prefer-dark-theme=1/' ~/.config/gtk-3.0/settings.ini ~/.config/gtk-4.0/settings.ini
    cp ~/.config/alacritty/theme_dark.toml ~/.config/alacritty/theme.toml
fi
touch ~/.config/alacritty/alacritty.toml
