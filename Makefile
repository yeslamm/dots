STOW_FOLDERS = btop fastfetch bin swayimg satty cliphist lazygit nvim easyeffects zsh tmux waybar fuzzel foot mako dev yazi sway git

.PHONY: help user adopt system install clean

help:
	@echo "Workstation Architecture Controls"
	@echo "  make user           Initialize XDG structures and link user space configs via stow"
	@echo "  make adopt          Adopt existing home configs into repository tracking fields"
	@echo "  make system         Sync framework rules to /etc hierarchy and enable core services"
	@echo "  make install        Synchronize unified manifest (pkglist.txt) via yay"
	@echo "  make clean          Cleanly sever all home directory environment symlinks"

user:
	@echo "======================================================================="
	@echo " Initializing Home Directory System Structures"
	@echo "======================================================================="
	mkdir -p ~/.config
	mkdir -p ~/.local/share
	mkdir -p ~/.local/state
	mkdir -p ~/.local/bin
	@if [ -f ~/.gitconfig ]; then \
		mv ~/.gitconfig ~/.gitconfig.bak; \
	fi
	@echo "======================================================================="
	@echo " Running Dynamic Stow Allocation"
	@echo "======================================================================="
	stow -R $(STOW_FOLDERS)

adopt:
	@echo "Adopting existing configuration templates into tracking tree..."
	stow -A $(STOW_FOLDERS)

system:
	@echo "======================================================================="
	@echo " Syncing Infrastructure Frameworks to System Hierarchy"
	@echo "======================================================================="
	sudo mkdir -p /etc/systemd/logind.conf.d
	sudo cp sysconfigs/systemd/lid.conf /etc/systemd/logind.conf.d/lid.conf
	sudo mkdir -p /etc/keyd
	sudo cp sysconfigs/keyd/default.conf /etc/keyd/default.conf
	sudo systemctl daemon-reload
	sudo systemctl enable --now keyd || true
	@echo "Infrastructure deployed and system daemons initialized successfully."

install:
	@echo "======================================================================="
	@echo " Restoring Consolidated Core Manifesto via yay"
	@echo "======================================================================="
	@if [ -f pkglist.txt ]; then \
		yay -S --needed - < pkglist.txt; \
	else \
		echo "Error: pkglist.txt not found!"; exit 1; \
	fi

clean:
	@echo "Severing home folder environment symlinks cleanly..."
	stow -D $(STOW_FOLDERS)
