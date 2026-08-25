#!/bin/bash
# Mirror the internal display (eDP-1) onto every other active output using wl-mirror,
# since sway has no native output-cloning support.

SOURCE_OUTPUT="eDP-1"
PIDFILE="${XDG_RUNTIME_DIR:-/tmp}/wl-mirror-toggle.pids"

if [ -s "$PIDFILE" ]; then
    # Mirroring is active: stop it.
    while read -r pid; do
        kill "$pid" 2>/dev/null
    done < "$PIDFILE"
    rm -f "$PIDFILE"
    exit 0
fi

mapfile -t targets < <(swaymsg -t get_outputs | jq -r --arg src "$SOURCE_OUTPUT" '.[] | select(.active and .name != $src) | .name')

if [ "${#targets[@]}" -eq 0 ]; then
    notify-send "Mirror displays" "No external display detected." 2>/dev/null
    exit 1
fi

: > "$PIDFILE"
for target in "${targets[@]}"; do
    wl-mirror --fullscreen-output "$target" --title "wl-mirror-$target" "$SOURCE_OUTPUT" &
    echo "$!" >> "$PIDFILE"
done
