#!/bin/bash
# Caffeine toggle for waybar: keeps the laptop from suspending on lid close.
# See sway/lid_suspend.sh, which checks this same lock file.
LOCK="/tmp/waybar_caffeine.lock"
ICON=$''

if [ "$1" == "toggle" ]; then
    if [ -f "$LOCK" ]; then
        rm "$LOCK"
    else
        touch "$LOCK"
    fi
    pkill -RTMIN+10 waybar
    exit 0
fi

if [ -f "$LOCK" ]; then
    printf '{"text":"%s","tooltip":"Caffeine: on — lid-close sleep disabled","class":"on"}\n' "$ICON"
else
    printf '{"text":"%s","tooltip":"Caffeine: off — click to keep the laptop awake","class":"off"}\n' "$ICON"
fi
