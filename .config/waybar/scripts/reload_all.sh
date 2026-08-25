#!/bin/bash
# Reloads sway, waybar (current config) and swaync in one shot.

swaymsg reload

killall waybar 2>/dev/null
~/.config/waybar/scripts/launch_waybar.sh >/tmp/waybar.log 2>&1 &
disown

# Full restart (not just --reload-config/--reload-css) so a stale process
# picks up newly installed fonts/resources, not just text-config changes.
killall swaync 2>/dev/null
nohup swaync >/tmp/swaync.log 2>&1 &
disown

notify-send "sway" "Reloaded: sway config, waybar, swaync"
