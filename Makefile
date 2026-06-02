# ====================================================================================================
#  MASTER WORKSTATION BUILD AUTOMATION PIPELINE
# ====================================================================================================

HOME_DIR       := $(HOME)
STOW_FLAGS     := -v -R -t $(HOME_DIR)
SYSCONFIGS_DIR := sysconfigs

# Dynamic Lookup: Grab all top-level folders, excluding dot-dirs and sysconfigs
STOW_PACKAGES := $(shell find . -maxdepth 1 -type d ! -name "." ! -name ".*" ! -name "$(SYSCONFIGS_DIR)" -exec basename {} \;)

.PHONY: all user system adopt packages-install clean help

# Safe default goal prevents accidental script triggers or unprompted sudo pauses
.DEFAULT_GOAL := help

help:
	@echo "Workstation Architecture Controls"
	@echo "  make user             Dynamically restow all user-space configs"
	@echo "  make adopt            Adopt existing user-space skeleton files into repo"
	@echo "  make system           Physically sync flattened configs to /etc & reload daemons"
	@echo "  make packages-install Restores all native and AUR packages from repo lists"
	@echo "  make clean            Sever all home folder symlinks"

all: user system

# --- User-Space Engine (Dynamic Stow Allocation) ---
user:
	@echo "======================================================================="
	@echo " Running Dynamic Stow Allocation for: $(STOW_PACKAGES)"
	@echo "======================================================================="
	@stow $(STOW_FLAGS) $(STOW_PACKAGES)
	@echo "User profiles synchronized successfully."

# --- Stow Asset Absorption Engine ---
adopt:
	@echo "======================================================================="
	@echo " Adopting Existing Profile Skeleton Files into Repository Tracking"
	@echo "======================================================================="
	@stow $(STOW_FLAGS) --adopt $(STOW_PACKAGES)
	@echo "System configurations adopted cleanly."

# --- System Infrastructure Engine (Privileged Configurations Deployment) ---
system:
	@echo "======================================================================="
	@echo " Syncing Infrastructure Frameworks to System Hierarchy"
	@echo "======================================================================="
	@# 1. systemd-logind (Deploys safely; changes take effect on next reboot)
	sudo mkdir -p /etc/systemd/logind.conf.d
	sudo cp $(SYSCONFIGS_DIR)/systemd/lid.conf /etc/systemd/logind.conf.d/lid.conf
	
	@# 2. keyd
	sudo mkdir -p /etc/keyd
	sudo cp $(SYSCONFIGS_DIR)/keyd/default.conf /etc/keyd/default.conf
	
	@# 3. NetworkManager
	sudo mkdir -p /etc/NetworkManager/conf.d
	sudo cp $(SYSCONFIGS_DIR)/NetworkManager/wifi_backend.conf /etc/NetworkManager/conf.d/wifi_backend.conf
	
	@# 4. emptty display manager
	sudo mkdir -p /etc/emptty
	sudo cp $(SYSCONFIGS_DIR)/emptty/conf /etc/emptty/conf
	sudo cp $(SYSCONFIGS_DIR)/emptty/motd /etc/emptty/motd
	
	@# 5. Automated Pacman Auto-Tracking Hooks
	sudo mkdir -p /etc/pacman.d/hooks
	sudo cp $(SYSCONFIGS_DIR)/pacman/pkglist.hook /etc/pacman.d/hooks/pkglist.hook
	sudo cp $(SYSCONFIGS_DIR)/pacman/update-pkglist.sh /usr/local/bin/update-pkglist.sh
	sudo chmod +x /usr/local/bin/update-pkglist.sh
	
	@# 6. Core Kernel Interface Hot-Reload (Safe Configuration Parsing)
	sudo systemctl daemon-reload
	sudo systemctl reload NetworkManager || true
	sudo systemctl restart keyd || true
	@echo "Infrastructure deployed and system daemons hot-reloaded successfully."

# --- Package Synchronization Pipeline ---
packages-install:
	@echo "======================================================================="
	@echo " Restoring Native and AUR Workspace Packages cleanly via yay"
	@echo "======================================================================="
	@if command -v yay >/dev/null 2>&1; then \
		yay -S --needed --noconfirm - < pkglist-native.txt; \
		yay -S --needed --noconfirm - < pkglist-aur.txt; \
	else \
		echo "ERROR: 'yay' aur helper is missing. Please bootstrap yay manually first."; \
		exit 1; \
	fi

clean:
	@stow -v -D -t $(HOME_DIR) $(STOW_PACKAGES)
