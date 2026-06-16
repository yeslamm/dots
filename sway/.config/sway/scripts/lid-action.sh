#!/usr/bin/env bash
# ~/dots/sway/.config/sway/scripts/lid-action.sh

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
IDLE_FLAG="$RUNTIME_DIR/IDLE_ENABLED"

if [[ -f "$IDLE_FLAG" ]]; then
    pgrep -x "swaylock" >/dev/null || swaylock -f
    pgrep -x "sentry.sh" >/dev/null || "$HOME/.config/sway/scripts/sentry.sh" &
else
    pgrep -x "swaylock" >/dev/null || "$HOME/.config/sway/scripts/lock-ns.sh"
fi
