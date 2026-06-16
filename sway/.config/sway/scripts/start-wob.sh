#!/usr/bin/env bash
# ~/dots/sway/.config/sway/scripts/wob-start.sh

set -euo pipefail

WOB_SOCK="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/wob.sock"
WOB_CONFIG="$HOME/.config/wob/wob.ini"

pkill -x wob || true
pkill -f "tail -f $WOB_SOCK" || true

rm -f "$WOB_SOCK"
mkfifo "$WOB_SOCK"

tail -f "$WOB_SOCK" | wob -c "$WOB_CONFIG" &
