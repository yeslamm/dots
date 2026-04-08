#!/usr/bin/env bash
# fuzzel-kill.sh - Dual-mode app killer (TERM or KILL)

set -euo pipefail

# Take the first argument, default to "TERM" if none is provided
MODE=${1:-TERM}

# Apps to NEVER show in the menu
PROTECTED="sway|waybar|pipewire|wireplumber|dbus|systemd|fuzzel|bash|ssh|polkit|idle-mgr.sh|grep|ps|awk|sort"

# Get a simple, unique list of running applications
# shellcheck disable=SC2009
PROCESS_LIST=$(ps -u "$USER" -o comm= | grep -vE "^(${PROTECTED})$" | sort -u)

# Change the prompt text so you know which mode you are in
if [[ "$MODE" == "KILL" ]]; then
    PROMPT="SIGKILL: "
else
    PROMPT="SIGTERM: "
fi

# Select Application
APP_NAME=$(echo "$PROCESS_LIST" | fuzzel --dmenu --prompt="$PROMPT" -w 30 -l 15)

if [[ -n "$APP_NAME" ]]; then
    if [[ "$MODE" == "KILL" ]]; then
        # Ruthless immediate kill
        pkill -9 -x "$APP_NAME" 2>/dev/null || true
        notify-send -u critical -t 2000 -h string:x-canonical-private-synchronous:kill "Force Killed: $APP_NAME"
    else
        # Polite close
        pkill -15 -x "$APP_NAME" 2>/dev/null || true
        notify-send -t 2000 -h string:x-canonical-private-synchronous:kill "Sent Close Signal: $APP_NAME"
    fi
fi
