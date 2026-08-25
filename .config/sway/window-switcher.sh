#!/bin/bash
focused=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused == true) | .name')

# Build list: one entry per line, tab-separated: ID <TAB> display label
ENTRIES=$(swaymsg -t get_tree | jq -r '
  [.. | objects | select(.type? == "con" or .type? == "floating_con")
      | select(.name? and .name != "")
      | select(.app_id? or .window_properties?)]
  | sort_by(.focused | not)
  | .[]
  | "\(.id)\t[\(.app_id // .window_properties.class // "?")] \(.name)"
')

[ -z "$ENTRIES" ] && exit 0

# Show only the display labels in rofi; get back the 0-based line index
IDX=$(echo "$ENTRIES" | cut -f2- \
  | rofi -dmenu -p "Window" -monitor "$focused" -i -format i)

[ -z "$IDX" ] && exit 0

CON_ID=$(echo "$ENTRIES" | sed -n "$((IDX + 1))p" | cut -f1)
swaymsg "[con_id=$CON_ID] focus"
