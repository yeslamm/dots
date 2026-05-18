#!/bin/bash
PROCS_FILE="$HOME/.config/sway/idle_procs"

[[ -f "$PROCS_FILE" ]] || exit 1
PATS=$(grep -vE '^#|^$' "$PROCS_FILE" | xargs | tr ' ' '|')
[[ -n "$PATS" ]] || exit 1

pgrep -i "^($PATS)$" >/dev/null
