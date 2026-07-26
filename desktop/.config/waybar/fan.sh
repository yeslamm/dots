#!/bin/sh
# ~/dots/desktop/.config/waybar/fan.sh

for dev in /sys/class/hwmon/hwmon*; do
    [ -f "$dev/name" ] || continue

    read -r name <"$dev/name"

    if [ "$name" = "asus" ] && [ -f "$dev/fan1_input" ]; then
        read -r RPM <"$dev/fan1_input"

        if [ "${RPM:-0}" -gt 0 ]; then
            echo "${RPM} RPM"
            exit 0
        fi
    fi
done
