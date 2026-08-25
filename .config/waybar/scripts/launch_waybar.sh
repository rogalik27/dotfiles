#!/bin/bash
# Launches waybar using whichever config (mine / erik) was last selected via toggle_waybar_config.sh

WAYBAR_DIR="$HOME/.config/waybar"
STATE_FILE="$WAYBAR_DIR/.active_config"

current="mine"
[ -f "$STATE_FILE" ] && current="$(cat "$STATE_FILE")"

exec waybar -c "$WAYBAR_DIR/$current/config.jsonc" -s "$WAYBAR_DIR/$current/style.css"
