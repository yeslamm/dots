SHELL := /bin/bash
DOTS_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

.PHONY: all help sysconfigs services zram cgroups keyd logind scx vconsole pipewire dirs desktop stow-desktop minimal stow-core dry-run unstow

all: help

help:
	@echo "Dotfiles Management Commands:"
	@echo ""
	@echo "  make sysconfigs      - Deploy all /etc configs & enable system services"
	@echo "  make desktop         - Stow full Wayland/Sway desktop workstation profile"
	@echo "  make minimal         - Stow core CLI profile (terminal & dev tools only)"
	@echo "  make dry-run         - Preview stow symlink operations without touching files"
	@echo "  make unstow          - Remove all desktop stow symlinks"
	@echo "  make dirs            - Ensure required target XDG directories exist"
	@echo ""

# ==============================================================================
# System Configurations (/etc)
# ==============================================================================

sysconfigs: zram cgroups keyd logind scx vconsole pipewire services

zram:
	@echo "==> Configuring zram & memory sysctls..."
	@sudo install -Dm644 $(DOTS_DIR)/sysconfigs/memory/zram-generator.conf /etc/systemd/zram-generator.conf
	@sudo install -Dm644 $(DOTS_DIR)/sysconfigs/memory/99-memory.conf /etc/sysctl.d/99-memory.conf
	@sudo sysctl --system > /dev/null

cgroups:
	@echo "==> Configuring systemd user cgroup delegation..."
	@sudo install -Dm644 $(DOTS_DIR)/sysconfigs/systemd/user-delegate.conf /etc/systemd/system/user@.service.d/delegate.conf
	@sudo systemctl daemon-reload

keyd:
	@echo "==> Deploying keyd hardware mapping..."
	@sudo install -Dm644 $(DOTS_DIR)/sysconfigs/keyd/default.conf /etc/keyd/default.conf

logind:
	@echo "==> Configuring systemd-logind power handling..."
	@sudo install -Dm644 $(DOTS_DIR)/sysconfigs/systemd/lid.conf /etc/systemd/logind.conf.d/lid.conf

scx:
	@echo "==> Deploying scx scheduler service..."
	@sudo install -Dm644 $(DOTS_DIR)/sysconfigs/scx/scx /etc/default/scx
	@sudo install -Dm644 $(DOTS_DIR)/sysconfigs/scx/scx.service /etc/systemd/system/scx.service
	@sudo systemctl daemon-reload

vconsole:
	@echo "==> Deploying vconsole font & keymap settings..."
	@sudo install -Dm644 $(DOTS_DIR)/sysconfigs/vconsole/vconsole.conf /etc/vconsole.conf

pipewire:
	@echo "==> Installing system-wide PipeWire Dolby Atmos IRS impulse..."
	@sudo install -Dm644 $(DOTS_DIR)/sysconfigs/pipewire/Dolby_Atmos_Default.irs /etc/pipewire/Dolby_Atmos_Default.irs

services:
	@echo "==> Enabling system services..."
	@sudo systemctl enable --now keyd.service 2>/dev/null || true
	@sudo systemctl enable --now scx.service 2>/dev/null || true

# ==============================================================================
# User Stow Packages ($HOME)
# ==============================================================================

dirs:
	@echo "==> Creating required XDG base directories..."
	@mkdir -p $$HOME/.config $$HOME/.local/bin $$HOME/.local/share $$HOME/.cache $$HOME/.icons

desktop: stow-desktop
stow-desktop: dirs
	@echo "==> Stowing Full Desktop Profile..."
	@stow -d $(DOTS_DIR) -t $$HOME -R bin shell apps dev desktop

minimal: stow-core
stow-core: dirs
	@echo "==> Stowing Minimal / Core Profile..."
	@stow -d $(DOTS_DIR) -t $$HOME -R bin shell apps dev

dry-run: dirs
	@echo "==> Simulating Stow (Dry Run)..."
	@stow -d $(DOTS_DIR) -t $$HOME -nvR bin shell apps dev desktop

unstow:
	@echo "==> Removing Stow symlinks..."
	@stow -d $(DOTS_DIR) -t $$HOME -D bin shell apps dev desktop
