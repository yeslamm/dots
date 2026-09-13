SHELL := /bin/bash
DOTS_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

.PHONY: all help system services zram cgroups keyd logind scx vconsole pipewire dirs desktop-profile minimal-profile simulate-desktop simulate-minimal unstow-desktop unstow-minimal zsh audio stow-desktop stow-minimal

all: help

help:
	@echo ""
	@echo "Dotfiles Management Commands:"
	@echo ""
	@echo "  System & Tools:"
	@echo "    make system                - Deploy /etc configs and enable systemd services"
	@echo "    make audio                 - Configure ALSA levels and WirePlumber volumes"
	@echo "    make zsh                   - Install or update Zsh plugins"
	@echo ""
	@echo "  Workstation Profiles:"
	@echo "    make desktop-profile       - Deploy full Wayland/Sway profile + dependencies"
	@echo "    make minimal-profile       - Deploy core CLI profile (terminal & dev tools)"
	@echo ""
	@echo "  Maintenance:"
	@echo "    make stow-desktop          - Fast restow of desktop symlinks"
	@echo "    make stow-minimal          - Fast restow of minimal symlinks"
	@echo "    make unstow-desktop        - Remove all desktop stow symlinks"
	@echo "    make unstow-minimal        - Remove all minimal stow symlinks"
	@echo "    make simulate-desktop      - Preview desktop stow operations safely"
	@echo "    make simulate-minimal      - Preview minimal stow operations safely"

# ==============================================================================
# System Configurations (/etc)
# ==============================================================================

system: zram cgroups keyd logind scx vconsole pipewire services

zram:
	@echo "==> Configuring zram & memory sysctls..."
	@sudo install -Dm644 $(DOTS_DIR)/system/memory/zram-generator.conf /etc/systemd/zram-generator.conf
	@sudo install -Dm644 $(DOTS_DIR)/system/memory/99-memory.conf /etc/sysctl.d/99-memory.conf
	@sudo sysctl --system > /dev/null

cgroups:
	@echo "==> Configuring systemd user cgroup delegation..."
	@sudo install -Dm644 $(DOTS_DIR)/system/systemd/user-delegate.conf /etc/systemd/system/user@.service.d/delegate.conf
	@sudo systemctl daemon-reload

keyd:
	@echo "==> Deploying keyd hardware mapping..."
	@sudo install -Dm644 $(DOTS_DIR)/system/keyd/default.conf /etc/keyd/default.conf
	@sudo usermod -aG keyd $$USER

logind:
	@echo "==> Configuring systemd-logind power handling..."
	@sudo install -Dm644 $(DOTS_DIR)/system/systemd/lid.conf /etc/systemd/logind.conf.d/lid.conf

scx:
	@echo "==> Deploying scx scheduler service..."
	@sudo install -Dm644 $(DOTS_DIR)/system/scx/scx /etc/default/scx
	@sudo install -Dm644 $(DOTS_DIR)/system/scx/scx.service /etc/systemd/system/scx.service
	@sudo systemctl daemon-reload

vconsole:
	@echo "==> Deploying vconsole font & keymap settings..."
	@sudo install -Dm644 $(DOTS_DIR)/system/vconsole/vconsole.conf /etc/vconsole.conf

pipewire:
	@echo "==> Installing system-wide PipeWire Dolby Atmos IRS impulse..."
	@sudo install -Dm644 $(DOTS_DIR)/system/pipewire/Dolby_Atmos_Default.irs /etc/pipewire/Dolby_Atmos_Default.irs

services:
	@echo "==> Enabling system services..."
	@sudo systemctl daemon-reload
	@sudo systemctl enable --now keyd.service 2>/dev/null || true
	@sudo systemctl enable --now scx.service 2>/dev/null || true

# ==============================================================================
# User Stow Packages ($HOME)
# ==============================================================================

dirs:
	@echo "==> Creating required XDG base directories..."
	@mkdir -p $$HOME/.config $$HOME/.local/bin $$HOME/.local/share $$HOME/.cache $$HOME/.icons

zsh:
	@echo "==> Installing/Updating Zsh plugins..."
	@zsh -i -c "zimfw install"

audio:
	@echo "==> Configuring ALSA and WirePlumber audio levels..."
	@amixer -c Generic_1 sset 'Capture' 20% 2>/dev/null || amixer -c 1 sset 'Capture' 20%
	@amixer -c Generic_1 sset 'Internal Mic Boost' 0dB 2>/dev/null || true
	@amixer -c Generic_1 sset 'Mic Boost' 0dB 2>/dev/null || true
	@sudo alsactl store
	@wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.35
	@wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 1.0

stow-desktop: dirs
	@echo "==> Restowing Full Desktop Profile..."
	@stow -d $(DOTS_DIR) -t $$HOME -R bin shell apps dev desktop

stow-minimal: dirs
	@echo "==> Restowing Minimal Profile..."
	@stow -d $(DOTS_DIR) -t $$HOME -R bin shell apps dev

desktop-profile: stow-desktop zsh audio
	@echo "==> Full desktop profile successfully deployed!"

minimal-profile: stow-minimal zsh
	@echo "==> Minimal CLI profile successfully deployed!"

simulate-desktop: dirs
	@echo "==> Simulating Desktop Stow..."
	@stow -d $(DOTS_DIR) -t $$HOME -nvR bin shell apps dev desktop

simulate-minimal: dirs
	@echo "==> Simulating Minimal Stow..."
	@stow -d $(DOTS_DIR) -t $$HOME -nvR bin shell apps dev

unstow-desktop:
	@echo "==> Removing Desktop Stow symlinks..."
	@stow -d $(DOTS_DIR) -t $$HOME -D bin shell apps dev desktop

unstow-minimal:
	@echo "==> Removing Minimal Stow symlinks..."
	@stow -d $(DOTS_DIR) -t $$HOME -D bin shell apps dev
