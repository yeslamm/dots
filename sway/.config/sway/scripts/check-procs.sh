#!/bin/sh
# ~/dots/sway/.config/sway/scripts/check_procs.sh
set -e

PROCS_FILE="$HOME/.config/sway/idle_procs"

[ -f "$PROCS_FILE" ] || exit 1
PATS=$(grep -vE '^#|^$' "$PROCS_FILE" | awk 'NF {print $1}' | paste -sd '|' -)
[ -n "$PATS" ] || exit 1

if pgrep -i "^($PATS)$" >/dev/null; then
    exit 0
else
    exit 1
fi
