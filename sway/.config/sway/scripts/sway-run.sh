#!/usr/bin/env bash
set -euo pipefail

export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_DESKTOP=sway
export TERMINAL=foot

export XCURSOR_THEME=capitaine-cursors-r3
export XCURSOR_SIZE=24

export XDG_DATA_DIRS="/usr/local/share:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}"

export QT_QPA_PLATFORM="wayland;xcb"
export QT_QPA_PLATFORMTHEME=qt5ct
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export ELECTRON_OZONE_PLATFORM_HINT=auto
export ELECTRON_ENABLE_FEATURES=VaapiVideoDecoder,UseOzonePlatform

export LIBVA_DRIVER_NAME=radeonsi
export VDPAU_DRIVER=radeonsi
export AMD_VULKAN_ICD=radv

exec systemd-cat -t sway sway "$@"
