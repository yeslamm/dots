#!/usr/bin/env bash
# ~/dots/sway/.config/sway/scripts/power-menu.sh

set -euo pipefail

ACTION="${1:-}"
[[ -z "$ACTION" ]] && exit 1

CONFIRM=$(echo -e "Yes\nNo" | fuzzel --dmenu --lines=2 --prompt="Confirm ${ACTION^}? " -w 30)

[[ "$CONFIRM" != "Yes" ]] && exit 0

case "$ACTION" in
logout)
    killall swayidle 2>/dev/null || true
    swaymsg exit
    ;;
reboot)
    systemctl reboot
    ;;
poweroff)
    systemctl poweroff
    ;;
*)
    exit 1
    ;;
esac
