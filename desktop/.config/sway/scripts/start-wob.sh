#!/usr/bin/env bash
# ~/dots/desktop/.config/sway/scripts/start-wob.sh

set -euo pipefail

WOB_SOCK="${XDG_RUNTIME_DIR:-/run/user/${UID}}/wob.sock"
WOB_CONFIG="$HOME/.config/wob/wob.ini"

pkill -x wob 2>/dev/null || true
pkill -f "tail -f $WOB_SOCK" 2>/dev/null || true

rm -f "$WOB_SOCK"
mkfifo "$WOB_SOCK"

WOB_ARGS=()
[[ -f "$WOB_CONFIG" ]] && WOB_ARGS=(-c "$WOB_CONFIG")

tail -f "$WOB_SOCK" | wob "${WOB_ARGS[@]}" &
