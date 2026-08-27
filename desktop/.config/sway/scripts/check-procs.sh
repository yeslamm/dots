#!/usr/bin/env bash
set -euo pipefail

PROCS_FILE="$HOME/.config/sway/idle_procs"
[[ -s "$PROCS_FILE" ]] || exit 1

PATS=$(awk 'NF && !/^[[:space:]]*#/ {print $1}' "$PROCS_FILE" | paste -sd '|' -)
[[ -n "$PATS" ]] || exit 1

pgrep -i -x "$PATS" >/dev/null
