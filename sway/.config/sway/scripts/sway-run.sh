#!/bin/sh
# sway-run.sh - Session Loader
# Optimized for AMD RDNA 3.5 and Wayland compatibility.

# 1. Core Session Environment
export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_DESKTOP=sway

# 2. Path & Data Directory Management
export XDG_DATA_DIRS="/usr/local/share:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}"

# 3. Toolkit & Framework Compatibility
export _JAVA_AWT_WM_NONREPARENTING=1
export GTK_USE_PORTAL=1
export MOZ_ENABLE_WAYLAND=1
export QT_QPA_PLATFORM=wayland
export QT_QPA_PLATFORMTHEME=qt5ct
export XCURSOR_SIZE=24

# 4. Electron & Hardware Acceleration
export ELECTRON_OZONE_PLATFORM_HINT=auto
export ELECTRON_ENABLE_FEATURES=VaapiVideoDecoder,UseOzonePlatform

# 5. AMD RDNA 3.5 Graphics Tuning
export LIBVA_DRIVER_NAME=radeonsi
export VDPAU_DRIVER=radeonsi
export AMD_VULKAN_ICD=radv

# 6. Launch with systemd-journal
exec systemd-cat -t sway sway "$@"
