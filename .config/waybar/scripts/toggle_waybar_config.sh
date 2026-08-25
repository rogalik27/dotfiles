#!/bin/bash
# Cycle waybar between my own config and Erik Reider's (SwayNotificationCenter author) config.

WAYBAR_DIR="$HOME/.config/waybar"
STATE_FILE="$WAYBAR_DIR/.active_config"

current="mine"
[ -f "$STATE_FILE" ] && current="$(cat "$STATE_FILE")"

if [ "$current" = "mine" ]; then
    next="erik"
else
    next="mine"
fi

echo "$next" > "$STATE_FILE"

killall waybar
waybar -c "$WAYBAR_DIR/$next/config.jsonc" -s "$WAYBAR_DIR/$next/style.css" >/tmp/waybar.log 2>&1 &
disown
