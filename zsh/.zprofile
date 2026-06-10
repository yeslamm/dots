if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then

    if [ -f "$HOME/.arch_logo" ]; then
        cat "$HOME/.arch_logo"
        echo ""
    fi

    echo -n "Start Sway? [y/N]: "
    read -k 1 REPLY
    echo ""

    if [[ "$REPLY" =~ ^[Yy]$ ]]; then
        exec sway-run
    else
        echo "Staying in TTY. Type 'sway-run' to launch later."
    fi
fi
