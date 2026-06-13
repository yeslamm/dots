#!/bin/bash
# bright.sh - Brightness control with wob feedback

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

IFS=',' read -r _ _ _ PERC _ <<<"$(brightnessctl -m)"
echo "${PERC%%%}" >"$WOB_SOCK"
