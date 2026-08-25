#!/bin/bash
until [ -n "$SWAYSOCK" ] && swaymsg -t get_outputs; do
    export SWAYSOCK=$(ls /run/user/$(id -u)/sway-ipc.* | head -1)
    sleep 1
done
echo "Connected to sway socket: $SWAYSOCK"
swaymsg -t subscribe '["window"]' | while read -r event; do
    change=$(echo "$event" | jq -r '.change')
    [ "$change" != "new" ] && continue

    con_id=$(echo "$event" | jq '.container.id')
    pid=$(echo "$event" | jq '.container.pid')

    # Check if any window with this PID belongs to Teams
    match=$(swaymsg -t get_tree | jq ".. | objects | select(.pid? == $pid) | select(.name? | strings | test(\"Microsoft Teams\"; \"i\"))")

    if [ -n "$match" ]; then
        echo "found match"
        swaymsg "[con_id=$con_id] floating enable"
        swaymsg "[con_id=$con_id] floating enable, move position 1720 10"
    fi
done
