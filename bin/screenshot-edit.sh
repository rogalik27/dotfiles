#!/usr/bin/env bash
# Freeze the screen, select an area, screenshot it, then notify with two
# edit options: Swappy (edits the captured file) and Flameshot (reopens
# the same region fresh, since flameshot can't load an existing file).
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

# slurp gives "X,Y WxH"; flameshot wants "WxH+X+Y".
XY=${GEOM% *}
WH=${GEOM#* }
FLAME_REGION="${WH}+${XY/,/+}"

ACTION=$(notify-send "Screenshot captured" "Choose an editor" \
    -i "$FILE" \
    -A "swappy=Swappy" \
    -A "flameshot=Flameshot" \
    -t 8000)

case "$ACTION" in
    swappy)
        swappy -f "$FILE"
        ;;
    flameshot)
        FLAME_FILE="$DIR/screenshot-$(date +%Y%m%d-%H%M%S)-flameshot.png"
        flameshot gui --region "$FLAME_REGION" -p "$FLAME_FILE" -c
        if [ -f "$FLAME_FILE" ]; then
            OPEN_ACTION=$(notify-send "Screenshot edited" "Saved to $(basename "$FLAME_FILE") and copied to clipboard" \
                -i "$FLAME_FILE" \
                -A "open=Open folder" \
                -t 8000)
            if [ "$OPEN_ACTION" = "open" ]; then
                nautilus --select "$FLAME_FILE" >/dev/null 2>&1 &
            fi
        fi
        ;;
esac
