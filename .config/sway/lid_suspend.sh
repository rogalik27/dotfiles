#!/bin/bash
# Called from sway's lid:on bindswitch. Suspends unless the waybar
# caffeine button has locked sleep (/tmp/waybar_caffeine.lock exists).
LOCK="/tmp/waybar_caffeine.lock"

if [ ! -f "$LOCK" ]; then
    systemctl suspend
fi
