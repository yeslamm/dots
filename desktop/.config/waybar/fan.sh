#!/usr/bin/env bash
# ~/dots/desktop/.config/waybar/fan.sh

set -euo pipefail

for dev in /sys/class/hwmon/hwmon*; do
    [[ -f "$dev/name" ]] || continue

    read -r name <"$dev/name"

    if [[ "$name" == "asus" && -f "$dev/fan1_input" ]]; then
        read -r rpm <"$dev/fan1_input"

        if ((${rpm:-0} > 0)); then
            echo "${rpm} RPM"
        fi
        exit 0
    fi
done
