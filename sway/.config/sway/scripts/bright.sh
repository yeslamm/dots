#!/bin/bash

STEP=5
WOB_SOCK="${XDG_RUNTIME_DIR}/wob.sock"

case "$1" in
up) brightnessctl set "${STEP}%+" -q ;;
down) brightnessctl set "${STEP}%-" -q ;;
*)
    echo "Usage: $0 {up|down}"
    exit 1
    ;;
esac

if pgrep -x wob >/dev/null && [ -p "$WOB_SOCK" ]; then
    IFS=',' read -r _ _ _ PERC _ <<<"$(brightnessctl -m)"
    echo "${PERC%%%}" >"$WOB_SOCK"
fi
