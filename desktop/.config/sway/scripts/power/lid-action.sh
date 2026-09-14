#!/usr/bin/env bash
# ~/dots/desktop/.config/sway/scripts/power/lid-action.sh

set -euo pipefail

STATE_DIR="${XDG_RUNTIME_DIR:-/run/user/${UID}}/sway-power"
IDLE_FLAG="$STATE_DIR/idle_enabled"

if [[ -f "$IDLE_FLAG" ]]; then
    "$HOME/.config/sway/scripts/power/lock-suspend.sh" &
else
    pgrep -x "swaylock" >/dev/null || "$HOME/.config/sway/scripts/power/lock.sh"
fi
