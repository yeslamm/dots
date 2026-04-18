#!/bin/sh
# sway-run.sh - Minimal Session Loader
# Optimized for AMD RDNA 3.5 and Wayland.

# 1. Essential Desktop Environment & Portals
export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_DESKTOP=sway
export TERMINAL=kitty

# 2. XDG Data Directories (Required for Flatpak desktop entries)
export XDG_DATA_DIRS="/usr/local/share:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}"

# 3. Qt & Electron Wayland Enforcement
export QT_QPA_PLATFORM="wayland;xcb"
export QT_QPA_PLATFORMTHEME=qt5ct
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export ELECTRON_OZONE_PLATFORM_HINT=auto
export ELECTRON_ENABLE_FEATURES=VaapiVideoDecoder,UseOzonePlatform

# 4. AMD Hardware Acceleration & Vulkan
export LIBVA_DRIVER_NAME=radeonsi
export VDPAU_DRIVER=radeonsi
export AMD_VULKAN_ICD=radv

# 5. Launch Session
exec systemd-cat -t sway sway "$@"
