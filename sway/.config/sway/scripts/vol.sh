#!/bin/bash
# vol.sh - Volume control with wob feedback

STEP="5%"
WOB_PIPE="${XDG_RUNTIME_DIR}/wobpipe"

case "$1" in
up) wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ "$STEP"+ ;;
down) wpctl set-volume @DEFAULT_AUDIO_SINK@ "$STEP"- ;;
mute) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
*)
    echo "Usage: $0 {up|down|mute}"
    exit 1
    ;;
esac

VAL_RAW=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)

if [[ "$VAL_RAW" == *"[MUTED]"* ]]; then
    echo 0 >"$WOB_PIPE"
else
    read -r _ VOL_DEC _ <<<"$VAL_RAW"
    echo "$((10#${VOL_DEC/./}))" >"$WOB_PIPE"
fi
