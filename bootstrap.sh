#!/usr/bin/env bash
# bootstrap.sh - Zero-dependency bare-metal initialization controller
set -euo pipefail

echo "======================================================================="
# 1. Ensure core compilation toolchains and version control are present
echo " Synchronizing Core Distro Build Utilities..."
echo "======================================================================="
sudo pacman -S --needed --noconfirm base-devel git

# 2. Compile and bootstrap 'yay' from the AUR if it is missing
if ! command -v yay >/dev/null 2>&1; then
    echo "======================================================================="
    echo " 'yay' AUR helper not found. Building toolchain from source..."
    echo "======================================================================="
    BUILD_DIR=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.bin.git "$BUILD_DIR"
    cd "$BUILD_DIR"
    makepkg -si --noconfirm
    cd -
    rm -rf "$BUILD_DIR"
fi

# 3. Synchronize your entire package tree blueprint
echo "======================================================================="
echo " Restoring Workspace Application Footprint..."
echo "======================================================================="
yay -S --needed --noconfirm - <pkglist-native.txt
yay -S --needed --noconfirm - <pkglist-aur.txt

# 4. Hand off execution cleanly to the Make engine to link layouts and hooks
echo "======================================================================="
echo " Running Local Master Makefile Deployment..."
echo "======================================================================="
make user
make system

echo "======================================================================="
echo " Workstation successfully deployed. Ready for login shell execution."
echo "======================================================================="
