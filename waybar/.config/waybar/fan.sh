#!/bin/bash
# fan.sh - Readable, reliable CPU fan monitor

for dev in /sys/class/hwmon/hwmon*; do
    if [[ -f "$dev/name" ]] && [[ "$(<"$dev/name")" == "asus" ]]; then

        # 2. Grab the actual CPU fan speed
        if [[ -f "$dev/fan1_input" ]]; then
            RPM=$(<"$dev/fan1_input")

            # 3. Only print if it's spinning (otherwise print nothing to auto-hide)
            if [[ ${RPM:-0} -gt 0 ]]; then
                echo "${RPM} RPM  "
                exit 0
            fi
        fi
    fi
done
