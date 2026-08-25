#!/bin/bash
CONFIG="$HOME/.config/sway/config"

if grep -q "^# output DP-1 resolution 2560x1440" "$CONFIG"; then
    sed -i 's|^# output DP-1 resolution 2560x1440|output DP-1 resolution 2560x1440|' "$CONFIG"
    sed -i 's|^# output eDP-1 resolution 1920x1200|output eDP-1 resolution 1920x1200|' "$CONFIG"
else
    sed -i 's|^output DP-1 resolution 2560x1440|# output DP-1 resolution 2560x1440|' "$CONFIG"
    sed -i 's|^output eDP-1 resolution 1920x1200|# output eDP-1 resolution 1920x1200|' "$CONFIG"
fi

swaymsg reload
