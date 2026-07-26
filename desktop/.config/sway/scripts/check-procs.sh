#!/bin/sh
# ~/dots/desktop/.config/sway/scripts/check-procs.sh

set -e

PROCS_FILE="$HOME/.config/sway/idle_procs"
[ -f "$PROCS_FILE" ] || exit 1

PATS=$(awk 'NF && !/^[[:space:]]*#/ {print $1}' "$PROCS_FILE" | paste -sd '|' -)
[ -n "$PATS" ] || exit 1

pgrep -i -x "$PATS" >/dev/null
