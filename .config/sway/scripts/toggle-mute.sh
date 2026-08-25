#!/bin/sh
# This sink uses hardware mixer registers for both mute and volume
# (HW_MUTE_CTRL / HW_VOLUME_CTRL). They are independent registers, so if
# volume's register holds a stale/default value while mute is on, unmuting
# briefly plays at that stale value before the correct volume gets
# rewritten - an audible blip. Fix: when unmuting, rewrite the volume
# register first (while still silent), then flip mute off last.
set -eu

SINK=@DEFAULT_SINK@
LOG=/tmp/toggle-mute-debug.log

capture() (
    set +e
    for i in $(seq 1 60); do
        T=$(date +%H:%M:%S.%3N)
        SPK=$(amixer -c0 sget 'Speaker' 2>&1 | grep -oP '(Front Left|Mono):.*')
        MST=$(amixer -c0 sget 'Master' 2>&1 | grep -oP '(Front Left|Mono):.*')
        echo "$T cap Speaker=[$SPK] Master=[$MST]" >> "$LOG"
        sleep 0.01
    done
)

capture &
CAPPID=$!

echo "$(date +%H:%M:%S.%3N) invoked, mute-before=$(pactl get-sink-mute "$SINK")" >> "$LOG"

if pactl get-sink-mute "$SINK" | grep -q "yes"; then
    VOL=$(pactl get-sink-volume "$SINK" | grep -oP '\d+(?=%)' | head -1)
    pactl set-sink-volume "$SINK" "${VOL}%"
    pactl set-sink-mute "$SINK" 0
    echo "$(date +%H:%M:%S.%3N) unmuted, restored vol=${VOL}%" >> "$LOG"
else
    pactl set-sink-mute "$SINK" 1
    echo "$(date +%H:%M:%S.%3N) muted" >> "$LOG"
fi

wait "$CAPPID"
