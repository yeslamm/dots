#!/usr/bin/env bash
# powermenu.sh

ACTION=$1

# 1. Capitalize the action for a cleaner UI (e.g., "poweroff" -> "Poweroff")
# and prompt for confirmation.
CONFIRM=$(echo -e "Yes\nNo" | fuzzel --dmenu --lines=2 --prompt="Confirm ${ACTION^}? " -w 30)

# 2. If the user presses Esc or selects No, exit immediately.
[[ "$CONFIRM" != "Yes" ]] && exit 0

# 3. Execute the validated action.
case "$ACTION" in
logout)
    ~/.config/sway/scripts/idle-off.sh && swaymsg exit
    ;;
reboot)
    systemctl reboot
    ;;
poweroff)
    systemctl poweroff
    ;;
*)
    # Invalid or empty action passed to script
    exit 1
    ;;
esac
