#!/bin/bash

STEP="5%"
WOB_SOCK="${XDG_RUNTIME_DIR}/wob.sock"

case "$1" in
up) wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ "$STEP"+ ;;
down) wpctl set-volume @DEFAULT_AUDIO_SINK@ "$STEP"- ;;
mute) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
*)
    echo "Usage: $0 {up|down|mute}"
    exit 1
    ;;
esac

if pgrep -x wob >/dev/null && [ -p "$WOB_SOCK" ]; then
    VAL_RAW=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)

    if [[ "$VAL_RAW" == *"[MUTED]"* ]]; then
        echo 0 >"$WOB_SOCK"
    else
        read -r _ VOL_DEC _ <<<"$VAL_RAW"
        echo "$((10#${VOL_DEC/./}))" >"$WOB_SOCK"
    fi
fi
