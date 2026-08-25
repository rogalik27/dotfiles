#!/usr/bin/env bash
# Freeze the screen, select an area, screenshot it, then notify with an
# "Edit" action that opens swappy for annotation.
set -uo pipefail

DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"
FILE="$DIR/screenshot-$(date +%Y%m%d-%H%M%S).png"

wayfreeze --hide-cursor &
FREEZE_PID=$!
sleep 0.1

GEOM=$(slurp)
if [ -z "$GEOM" ]; then
    kill "$FREEZE_PID" 2>/dev/null
    exit 0
fi

grim -g "$GEOM" "$FILE"
kill "$FREEZE_PID" 2>/dev/null

wl-copy < "$FILE"

ACTION=$(notify-send "Screenshot captured" "Press to edit" \
    -i "$FILE" \
    -A "edit=Edit" \
    -t 8000)

if [ "$ACTION" = "edit" ]; then
    swappy -f "$FILE"
fi
