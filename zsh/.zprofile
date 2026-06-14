if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then

    if [ -f "$HOME/.arch_logo" ]; then
        cat "$HOME/.arch_logo"
        echo ""
    fi

    read -k 1 "REPLY?Start Sway? [Y/n]: "
    echo ""

    case "$REPLY" in
        [Yy]|$'\n')
            exec sway-run
            ;;
        *)
            echo "Staying in TTY. Type 'sway-run' to launch later.\n"
            ;;
    esac
fi
