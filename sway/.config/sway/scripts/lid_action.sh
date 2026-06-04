#!/usr/bin/env bash

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
IDLE_FLAG="$RUNTIME_DIR/IDLE_ENABLED"

# Determine "Mobile" (Suspend) or "Server" (Stay Awake) mode via flag
if [[ -f "$IDLE_FLAG" ]]; then
    # MOBILE MODE: Authoritative Suspend
    # 1. Ensure Screen is Locked
    pgrep -x "swaylock" >/dev/null || swaylock -f

    # 2. Ensure Sentry is running (to handle the wake-up/re-suspend logic)
    # We use -f to be more robust with the script name matching
    pgrep -f "sentry.sh" >/dev/null || "$HOME/.config/sway/scripts/sentry.sh" &

    # 3. Force the system to sleep NOW
    systemctl suspend
else
    # SERVER MODE: Just lock and stay awake
    pgrep -x "swaylock" >/dev/null || "$HOME/.config/sway/scripts/lock-ns.sh"
fi
