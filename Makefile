SHELL := /bin/bash

DOTS_DIR   := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
HOME_DIR   := $(DOTS_DIR)/home
SYSTEM_DIR := $(DOTS_DIR)/system

TARGET_USER ?= $(shell logname 2>/dev/null || echo "$$USER")

PACKAGES := $(notdir $(patsubst %/,%,$(wildcard $(HOME_DIR)/*/)))
STOW     := stow -d $(HOME_DIR) -t $(HOME) --no-folding

.PHONY: all help bootstrap pkgs pkgs-gaming pkgs-virt system \
        audio stow unstow simulate profile

.NOTPARALLEL:

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
	@echo "    system       - Install system/etc into /etc and enable services"
	@echo "    audio        - Set mic boost and default volume"
	@echo ""
	@echo "  Dotfiles:"
	@echo "    profile      - Run stow and audio"
	@echo "    stow         - Link home/* packages into $(HOME)"
	@echo "    unstow       - Remove those links"
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

system:
	@echo ""
	@echo "==> Installing /etc configs and enabling services..."
	cd $(SYSTEM_DIR) && find etc -type f -exec sudo install -Dm644 -v {} /{} \;
	sudo usermod -aG keyd $(TARGET_USER)
	sudo systemctl daemon-reload
	sudo systemctl enable --now keyd.service scx.service
	@echo ""

audio:
	@echo ""
	@echo "==> Setting audio levels..."
	amixer -c Generic_1 sset 'Capture' 20% 2>/dev/null || amixer -c 1 sset 'Capture' 20% 2>/dev/null || true
	amixer -c Generic_1 sset 'Internal Mic Boost' 0dB 2>/dev/null || true
	amixer -c Generic_1 sset 'Mic Boost' 0dB 2>/dev/null || true
	sudo alsactl store
	wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.25 2>/dev/null || true
	wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 1.0 2>/dev/null || true

# ==============================================================================
# Dotfiles ($HOME)
# ==============================================================================

stow:
	@echo ""
	@echo "==> Stowing: $(PACKAGES)"
	$(STOW) -R $(PACKAGES)

simulate:
	@echo ""
	@echo "==> Dry-run stow..."
	$(STOW) -nvR $(PACKAGES)
	@echo ""

unstow:
	@echo ""
	@echo "==> Unstowing dotfiles..."
	$(STOW) -D $(PACKAGES)
	@echo ""

profile: stow audio
	@echo ""
	@echo "==> Done."
	@echo ""
