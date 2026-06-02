#!/usr/bin/env bash

if pgrep -x "swaylock" >/dev/null; then
    exit 0
fi

if pgrep -x "swayidle" >/dev/null; then
    swaylock -f && systemctl suspend
else
    "$HOME/.config/sway/scripts/lock-ns.sh"
fi
