#!/bin/bash
focused=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused == true) | .name')
rofi -show drun -show-icons -monitor "$focused"
