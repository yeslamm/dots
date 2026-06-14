#!/bin/bash
# ~/dots/sway/.config/sway/scripts/kill-menu.sh

set -euo pipefail

MODE="${1:-TERM}"
MODE="${MODE^^}"

case "$MODE" in
"KILL")
    SIGNAL="KILL"
    PROMPT="SIGKILL: "
    ;;
"TERM" | *)
    SIGNAL="TERM"
    PROMPT="SIGTERM: "
    ;;
esac

SELECTION=$(ps -u "$USER" -o pid,etime,comm,args --no-headers |
    awk -v self_pid="$$" '
        $1 == self_pid {next}
        {
            pid=$1; etime=$2; comm=$3;
            $1=$2=$3=""; sub(/^[ \t]+/, "");
            printf "%5s\t%8s\t%s\t%s\n", pid, etime, comm, $0 
        }
    ' |
    fuzzel --dmenu \
        --prompt="$PROMPT" \
        -l 20 -w 120 \
        --match-nth=3 \
        --with-nth="{1}  {2}  {4..}" || true)

[[ -z "$SELECTION" ]] && exit 0

read -r PID _ <<<"$SELECTION"

if [[ "$PID" =~ ^[0-9]+$ ]]; then
    if kill -0 "$PID" 2>/dev/null; then
        kill -s "$SIGNAL" "$PID" 2>/dev/null ||
            notify-send -t 2000 "Kill Menu" "Failed to send SIG$SIGNAL to PID $PID"
    else
        notify-send -t 2000 "Kill Menu" "Process $PID died before signal could be sent."
    fi
fi
