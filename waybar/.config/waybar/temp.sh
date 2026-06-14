#!/bin/bash
# temp.sh - Readable, reliable CPU temperature monitor

for dev in /sys/class/hwmon/hwmon*; do
    if [[ -f "$dev/name" ]] && [[ "$(<"$dev/name")" == "k10temp" ]]; then

        if [[ -f "$dev/temp1_input" ]]; then
            TEMP_RAW=$(<"$dev/temp1_input")

            TEMP_C=$((TEMP_RAW / 1000))

            echo "${TEMP_C}°C"
            exit 0
        fi
    fi
done
