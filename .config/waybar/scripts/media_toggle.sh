#!/bin/bash
STATE=/tmp/waybar_media_hidden
if [ -f "$STATE" ]; then
    rm "$STATE"
else
    touch "$STATE"
fi
pkill -RTMIN+8 waybar
