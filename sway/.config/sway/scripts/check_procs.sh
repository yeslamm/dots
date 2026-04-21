#!/bin/bash
PROCS_FILE="$HOME/.config/sway/idle_procs"

[[ -f "$PROCS_FILE" ]] || exit 1
PATS=$(grep -vE '^#|^$' "$PROCS_FILE" | tr '\n' '|' | sed 's/|$//')
[[ -n "$PATS" ]] || exit 1

# Exits with 0 (Success) if yay, pacman, yt-dlp, etc., are actually running
pgrep -i "^($PATS)$" >/dev/null
