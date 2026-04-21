#!/bin/bash
# Listens for charger events with a 2-second debounce

last_run=0

acpi_listen | grep --line-buffered 'ac_adapter' | while read -r _; do
    current_time=$(date +%s)

    # Only run if 2 seconds have passed since the last trigger
    if ((current_time - last_run >= 2)); then
        ~/.config/sway/scripts/start_idle.sh &
        last_run=$current_time
    fi
done
