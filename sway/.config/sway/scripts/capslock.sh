#!/bin/bash
# capslock.sh - Ultra-Lightweight Polling Notifier

shopt -s nullglob
led_files=(/sys/class/leds/*capslock/brightness)
shopt -u nullglob

[[ ${#led_files[@]} -eq 0 ]] && exit 1

declare -A prev_states

# Initialize using Bash built-in read (No 'cat' spawned)
for led in "${led_files[@]}"; do
    read -r prev_states["$led"] <"$led"
done

while true; do
    for led in "${led_files[@]}"; do
        read -r current_state <"$led"

        if [[ "$current_state" != "${prev_states[$led]}" ]]; then
            if [[ "$current_state" -eq 1 ]]; then
                # We run notify-send in the background (&) so the script
                # doesn't pause waiting for the notification daemon
                notify-send "CapsLock: ON" -t 1000 -h string:x-canonical-private-synchronous:capslock &
            else
                notify-send "CapsLock: OFF" -t 1000 -h string:x-canonical-private-synchronous:capslock &
            fi
            prev_states["$led"]="$current_state"
        fi
    done

    # 50ms polling: Fast enough to catch human spamming, light enough for 0% CPU
    sleep 0.05
done
