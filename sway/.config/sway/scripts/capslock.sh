#!/bin/bash
# capslock.sh - Optimized Polling Notifier

shopt -s nullglob
led_files=(/sys/class/leds/*capslock/brightness)
shopt -u nullglob

[[ ${#led_files[@]} -eq 0 ]] && exit 1

declare -A prev_states
last_pid=""

# Initialize using Bash built-in read
for led in "${led_files[@]}"; do
    read -r prev_states["$led"] <"$led"
done

while true; do
    for led in "${led_files[@]}"; do
        read -r current_state <"$led"

        if [[ "$current_state" != "${prev_states[$led]}" ]]; then

            # Kill the previous notify-send process if it's still trying to run
            # This prevents race conditions and out-of-order notifications
            if [[ -n "$last_pid" ]] && kill -0 "$last_pid" 2>/dev/null; then
                kill "$last_pid"
            fi

            if [[ "$current_state" -eq 1 ]]; then
                notify-send "Capslock: on" -t 1000 -h string:x-canonical-private-synchronous:capslock &
                last_pid=$!
            else
                notify-send "Capslock: off" -t 1000 -h string:x-canonical-private-synchronous:capslock &
                last_pid=$!
            fi
            prev_states["$led"]="$current_state"
        fi
    done

    # Use bash built-in 'read' with a timeout instead of the external 'sleep' binary
    # We read from a dummy file descriptor to ensure it just blocks for 0.05 seconds
    read -r -t 0.05 -u 9 9<>/dev/null
done
