SHELL := /bin/bash
DOTS_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

.PHONY: all help sysconfigs services keyd logind scx vconsole dirs desktop stow-desktop server stow-server dry-run unstow

all: help

help:
	@echo "Dotfiles Management Commands:"
	@echo ""
	@echo "  make sysconfigs    - Deploy all /etc configs & enable system services"
	@echo "  make desktop       - Stow full Wayland/Sway desktop workstation profile"
	@echo "  make server        - Stow headless / CLI server profile (no GUI)"
	@echo "  make dry-run       - Preview stow symlink operations without touching files"
	@echo "  make unstow        - Remove all desktop stow symlinks"
	@echo "  make dirs          - Ensure required target XDG directories exist"
	@echo ""

# ==============================================================================
# System Configurations (/etc) - Requires sudo
# ==============================================================================

sysconfigs: keyd logind scx vconsole services
	@echo "==> All system configurations and services deployed successfully."

services:
	@echo "==> Enabling system and hardware daemons..."
	@sudo systemctl daemon-reload
	@sudo systemctl enable --now bluetooth.service power-profiles-daemon.service asusd.service ufw.service

keyd:
	@echo "==> Deploying keyd configuration..."
	@sudo install -Dm644 sysconfigs/keyd/default.conf /etc/keyd/default.conf
	@sudo systemctl daemon-reload
	@sudo systemctl enable --now keyd.service
	@sudo usermod -aG keyd $$USER

logind:
	@echo "==> Deploying systemd-logind configuration..."
	@sudo install -Dm644 sysconfigs/systemd/login.conf /etc/systemd/logind.conf.d/login.conf

scx:
	@echo "==> Deploying Sched-EXT (scx_lavd) configuration..."
	@sudo install -Dm644 sysconfigs/scx/scx /etc/default/scx
	@sudo install -Dm644 sysconfigs/systemd/scx.service /etc/systemd/system/scx.service
	@sudo systemctl daemon-reload
	@sudo systemctl enable --now scx.service

vconsole:
	@if [ -f sysconfigs/vconsole/vconsole.conf ]; then \
		echo "==> Deploying vconsole (TTY font) configuration..."; \
		sudo install -Dm644 sysconfigs/vconsole/vconsole.conf /etc/vconsole.conf; \
	fi

# ==============================================================================
# User Stow Profiles ($HOME)
# ==============================================================================

dirs:
	@echo "==> Initializing target XDG directories..."
	@mkdir -p $$HOME/.config $$HOME/.local/share $$HOME/.local/state $$HOME/.local/bin $$HOME/.icons

desktop: stow-desktop
stow-desktop: dirs
	@echo "==> Stowing Full Desktop Profile..."
	@stow -d $(DOTS_DIR) -t $$HOME -R bin shell apps dev desktop

server: stow-server
stow-server: dirs
	@echo "==> Stowing Headless / CLI Profile..."
	@stow -d $(DOTS_DIR) -t $$HOME -R bin shell apps dev

dry-run: dirs
	@echo "==> Simulating Desktop Stow (Dry Run)..."
	@stow -d $(DOTS_DIR) -t $$HOME -nvR bin shell apps dev desktop

unstow:
	@echo "==> Unstowing all packages..."
	@stow -d $(DOTS_DIR) -t $$HOME -D bin shell apps dev desktop
