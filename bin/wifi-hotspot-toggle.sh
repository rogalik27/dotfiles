#!/usr/bin/env bash
set -euo pipefail

IFACE="wlp0s20f3"
ORIGINAL_CONN="Hotspot@MSS"
HOTSPOT_SSID="MinecraftLAN"
HOTSPOT_PASSWORD="${HOTSPOT_PASSWORD:-changeme}"

active_conn=$(nmcli -g GENERAL.CONNECTION device show "$IFACE")
mode=$(nmcli -g 802-11-wireless.mode connection show "$active_conn" 2>/dev/null || echo "")

if [[ "$mode" == "ap" ]]; then
    echo "Hotspot active, reverting to '$ORIGINAL_CONN'..."
    nmcli connection up "$ORIGINAL_CONN"
else
    echo "Starting hotspot '$HOTSPOT_SSID'..."
    nmcli device wifi hotspot ifname "$IFACE" ssid "$HOTSPOT_SSID" password "$HOTSPOT_PASSWORD"
fi
