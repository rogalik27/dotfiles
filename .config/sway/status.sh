uptime_formatted=$(uptime | cut -d ',' -f1 | awk '{print $3 " " $4}')

date_str=$(date "+%a %F %H:%M")

battery_info=$(upower --show-info $(upower --enumerate))
battery_is_charging=$(echo "$battery_info" | grep icon-name | grep 'charging' -c)
battery_is_low=$(echo "$battery_info" | grep icon-name | grep 'battery-low-symbolic' -c)

if [ $battery_is_low = 1 ]; then
    battery_icon=🪫
elif [ $battery_is_charging = 1 ]; then
    battery_icon=🔌
fi

battery_percent=$(echo "$battery_info" | grep percentage | awk '{print $2}')

echo "$(hostname), up since $uptime_formatted -- battery: $battery_percent $battery_icon -- $date_str"
