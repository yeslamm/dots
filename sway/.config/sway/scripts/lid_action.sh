#!/bin/bash

if pgrep -x "swayidle" >/dev/null; then
    swaylock -f && systemctl suspend

else
    "$HOME/.config/sway/scripts/lock-ns.sh"
fi
