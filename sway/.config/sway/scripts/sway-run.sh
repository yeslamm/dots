#!/bin/sh

# ==============================================================================
# 1. CORE WAYLAND/XDG & SESSION VARIABLES
# ==============================================================================
export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_DESKTOP=sway

# Update data directories safely
export XDG_DATA_DIRS="/usr/local/share:/usr/share${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}"

# ==============================================================================
# 2. TOOLKIT COMPATIBILITY & DECORATIONS
# ==============================================================================
# export GDK_BACKEND=wayland,x11
export GTK_USE_PORTAL=1
export MOZ_ENABLE_WAYLAND=1
export QT_QPA_PLATFORM=wayland
export QT_QPA_PLATFORMTHEME=qt5ct
export QT6_QPA_PLATFORMTHEME=qt6ct

# ==============================================================================
# 3. UTILITIES & FRAMEWORK FIXES
# ==============================================================================
export XCURSOR_SIZE=24

export ELECTRON_OZONE_PLATFORM_HINT=auto
export ELECTRON_ENABLE_FEATURES=VaapiVideoDecoder,UseOzonePlatform

# ==============================================================================
# 4. AMD HARDWARE ACCELERATION (RDNA 3.5 OPTIMIZED)
# ==============================================================================

# Driver selection
export LIBVA_DRIVER_NAME=radeonsi
export VDPAU_DRIVER=radeonsi

# Force Vulkan (RADV)
export AMD_VULKAN_ICD=radv

# Performance Tuning
# nggc: Enables Next Generation Geometry Culling (Performance)
# gpl:  Enables Graphics Pipeline Library (Eliminates shader stutter)
# export RADV_PERFTEST=nggc,gpl

# Optional: Enable resizing limits fix for some Wayland games
# export SDL_VIDEODRIVER=wayland

# Launch with journal logging
exec systemd-cat -t sway sway "$@"
