#!/usr/bin/env bash
# capslock.sh - Hardened, Zero-Fork Multi-Device Monitor
set -eu

LED_PATHS=(/sys/class/leds/*capslock/brightness)

if [[ ! -f "${LED_PATHS[0]}" ]]; then
    echo "Error: No Caps Lock LED nodes found" >&2
    exit 1
fi

coproc hold_loop { cat; }
TIMER_FD="${hold_loop[0]}"

check_caps() {
    for path in "${LED_PATHS[@]}"; do
        if [[ -f "$path" ]]; then
            read -r val <"$path" 2>/dev/null || val=0
            if [[ "$val" == "1" ]]; then
                return 0
            fi
        fi
    done
    return 1
}

if check_caps; then
    PREV_STATE="ON"
    echo "CAPS"
else
    PREV_STATE="OFF"
    echo ""
fi

while true; do
    read -t 0.1 -r <&"$TIMER_FD" || true

    if check_caps; then
        CURR_STATE="ON"
    else
        CURR_STATE="OFF"
    fi

    if [[ "$CURR_STATE" != "$PREV_STATE" ]]; then
        if [[ "$CURR_STATE" == "ON" ]]; then
            echo "CAPS"
        else
            echo ""
        fi

        notify-send "Caps Lock: ${CURR_STATE}" \
            -t 1000 \
            -h string:x-canonical-private-synchronous:capslock \
            -r 9993

        PREV_STATE="$CURR_STATE"
    fi
done
