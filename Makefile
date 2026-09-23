SHELL := /bin/bash
DOTS_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

TARGET_USER ?= $(shell logname 2>/dev/null || echo "$$USER")

.PHONY: all help bootstrap pkgs pkgs-gaming pkgs-virt \
        system zram cgroups keyd logind scx vconsole services \
        dirs zsh audio stow profile simulate unstow

all: help

help:
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "  Setup:"
	@echo "    bootstrap    - Run pkgs, system, and profile"
	@echo ""
	@echo "  Packages:"
	@echo "    pkgs         - Install system and desktop packages"
	@echo "    pkgs-gaming  - Install gaming packages"
	@echo "    pkgs-virt    - Install virtualization packages"
	@echo ""
	@echo "  System:"
	@echo "    system       - Copy /etc configs and enable services"
	@echo "    audio        - Set mic boost and default volume"
	@echo "    zsh          - Install or update zimfw plugins"
	@echo ""
	@echo "  Dotfiles:"
	@echo "    profile      - Deploy dotfiles, set audio, update zsh"
	@echo "    stow         - Link dotfiles to home directory"
	@echo "    unstow       - Remove dotfile links from home directory"
	@echo "    simulate     - Preview stow changes (dry-run)"
	@echo ""

# ==============================================================================
# Bootstrap
# ==============================================================================

bootstrap: pkgs system profile
	@echo ""
	@echo "==> Bootstrap complete. Reboot recommended."
	@echo ""

# ==============================================================================
# Packages
# ==============================================================================

pkgs:
	@echo ""
	@echo "==> Installing packages..."
	@awk '!/^ *#/ && NF' $(DOTS_DIR)/pkglists/packages.txt | sort -u | yay -S --needed -

pkgs-gaming:
	@echo ""
	@echo "==> Installing gaming packages..."
	@awk '!/^ *#/ && NF' $(DOTS_DIR)/pkglists/gaming.txt | sort -u | yay -S --needed -

pkgs-virt:
	@echo ""
	@echo "==> Installing virtualization packages..."
	@awk '!/^ *#/ && NF' $(DOTS_DIR)/pkglists/virt.txt | sort -u | yay -S --needed -

# ==============================================================================
# System (/etc)
# ==============================================================================

system: zram cgroups keyd logind scx vconsole services

zram:
	@echo ""
	@echo "==> Configuring zram..."
	sudo install -Dm644 $(DOTS_DIR)/system/memory/zram-generator.conf /etc/systemd/zram-generator.conf
	sudo install -Dm644 $(DOTS_DIR)/system/memory/99-memory.conf /etc/sysctl.d/99-memory.conf
	sudo sysctl --system > /dev/null

cgroups:
	@echo ""
	@echo "==> Configuring systemd user delegate..."
	sudo install -Dm644 $(DOTS_DIR)/system/systemd/user-delegate.conf /etc/systemd/system/user@.service.d/delegate.conf

keyd:
	@echo ""
	@echo "==> Configuring keyd..."
	sudo install -Dm644 $(DOTS_DIR)/system/keyd/default.conf /etc/keyd/default.conf
	sudo usermod -aG keyd $(TARGET_USER)

logind:
	@echo ""
	@echo "==> Configuring logind..."
	sudo install -Dm644 $(DOTS_DIR)/system/systemd/lid.conf /etc/systemd/logind.conf.d/lid.conf

scx:
	@echo ""
	@echo "==> Configuring scx..."
	sudo install -Dm644 $(DOTS_DIR)/system/scx/scx /etc/default/scx
	sudo install -Dm644 $(DOTS_DIR)/system/scx/scx.service /etc/systemd/system/scx.service

vconsole:
	@echo ""
	@echo "==> Configuring vconsole..."
	sudo install -Dm644 $(DOTS_DIR)/system/vconsole/vconsole.conf /etc/vconsole.conf

services:
	@echo ""
	@echo "==> Enabling services..."
	sudo systemctl daemon-reload
	sudo systemctl enable --now keyd.service
	sudo systemctl enable --now scx.service
	@echo ""

# ==============================================================================
# Dotfiles ($HOME)
# ==============================================================================

dirs:
	@echo ""
	@echo "==> Creating XDG directories..."
	mkdir -p $(HOME)/.config $(HOME)/.local/bin $(HOME)/.local/share $(HOME)/.cache $(HOME)/.icons

zsh:
	@echo ""
	@echo "==> Installing zsh plugins..."
	zsh -i -c "zimfw install"

audio:
	@echo ""
	@echo "==> Setting audio levels..."
	amixer -c Generic_1 sset 'Capture' 20% 2>/dev/null || amixer -c 1 sset 'Capture' 20% 2>/dev/null || true
	amixer -c Generic_1 sset 'Internal Mic Boost' 0dB 2>/dev/null || true
	amixer -c Generic_1 sset 'Mic Boost' 0dB 2>/dev/null || true
	sudo alsactl store
	wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.25 2>/dev/null || true
	wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 1.0 2>/dev/null || true

stow: dirs
	@echo ""
	@echo "==> Stowing dotfiles..."
	stow -d $(DOTS_DIR) -t $(HOME) -R bin shell apps dev desktop

profile: stow zsh audio
	@echo ""
	@echo "==> Done."
	@echo ""

simulate: dirs
	@echo ""
	@echo "==> Dry-run stow..."
	stow -d $(DOTS_DIR) -t $(HOME) -nvR bin shell apps dev desktop
	@echo ""

unstow:
	@echo ""
	@echo "==> Unstowing dotfiles..."
	stow -d $(DOTS_DIR) -t $(HOME) -D bin shell apps dev desktop
	@echo ""
