#!/usr/bin/env bash
# ~/dots/sway/.config/sway/scripts/osd.sh

set -euo pipefail

TARGET="${1:-}"
ACTION="${2:-}"
WOB_SOCK="${XDG_RUNTIME_DIR}/wob.sock"
STEP="5"

case "$TARGET" in
volume)
    case "$ACTION" in
    up) wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ "${STEP}%+" ;;
    down) wpctl set-volume @DEFAULT_AUDIO_SINK@ "${STEP}%-" ;;
    mute) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
    *)
        echo "Usage: $0 volume {up|down|mute}"
        exit 1
        ;;
    esac
    ;;
brightness)
    case "$ACTION" in
    up) brightnessctl set "${STEP}%+" -q ;;
    down) brightnessctl set "${STEP}%-" -q ;;
    *)
        echo "Usage: $0 brightness {up|down}"
        exit 1
        ;;
    esac
    ;;
*)
    echo "Usage: $0 {volume|brightness} {up|down|mute}"
    exit 1
    ;;
esac

if pgrep -x wob >/dev/null && [[ -p "$WOB_SOCK" ]]; then
    VALUE=""

    case "$TARGET" in
    volume)
        VAL_RAW=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
        if [[ "$VAL_RAW" == *"[MUTED]"* ]]; then
            VALUE=0
        else
            read -r _ VOL_DEC _ <<<"$VAL_RAW"
            VALUE="$((10#${VOL_DEC/./}))"
        fi
        ;;
    brightness)
        IFS=',' read -r _ _ _ PERC _ <<<"$(brightnessctl -m)"
        VALUE="${PERC%%%}"
        ;;
    esac

    if [[ -n "$VALUE" ]]; then
        echo "$VALUE" >"$WOB_SOCK"
    fi
fi
