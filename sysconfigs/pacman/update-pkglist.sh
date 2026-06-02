#!/usr/bin/env bash
TARGET_DIR="/home/r3d/dots"

sudo -u r3d pacman -Qqen > "$TARGET_DIR/pkglist-native.txt"
sudo -u r3d pacman -Qqem > "$TARGET_DIR/pkglist-aur.txt"
