.PHONY: help user adopt system packages-install clean

help:
	@echo "Workstation Architecture Controls"
	@echo "  make user             Initialize XDG structures and link user space configs via stow"
	@echo "  make adopt            Adopt existing home configs into repository tracking fields"
	@echo "  make system           Sync framework rules to /etc hierarchy and enable core services"
	@echo "  make install          Synchronize unified manifest (pkglist.txt) via yay"
	@echo "  make clean            Cleanly sever all home directory environment symlinks"

user:
	@echo "======================================================================="
	@echo " Initializing Home Directory System Structures"
	@echo "======================================================================="
	mkdir -p ~/.config
	mkdir -p ~/.local/share
	mkdir -p ~/.local/state
	mkdir -p ~/.local/bin
	@rm -f ~/.gitconfig
	@echo "======================================================================="
	@echo " Running Dynamic Stow Allocation"
	@echo "======================================================================="
	stow -R bin swayimg satty cliphist lazygit nvim easyeffects zsh tmux waybar fuzzel fontconfig foot mako dev yazi sway git

adopt:
	@echo "Adopting existing configuration templates into tracking tree..."
	stow -A bin swayimg satty cliphist lazygit nvim easyeffects zsh tmux waybar fuzzel fontconfig foot mako dev yazi sway git

system:
	@echo "======================================================================="
	@echo " Syncing Infrastructure Frameworks to System Hierarchy"
	@echo "======================================================================="
	sudo mkdir -p /etc/systemd/logind.conf.d
	sudo cp sysconfigs/systemd/lid.conf /etc/systemd/logind.conf.d/lid.conf
	sudo mkdir -p /etc/keyd
	sudo cp sysconfigs/keyd/default.conf /etc/keyd/default.conf
	sudo mkdir -p /etc/NetworkManager/conf.d
	sudo cp sysconfigs/NetworkManager/wifi_backend.conf /etc/NetworkManager/conf.d/wifi_backend.conf
	sudo systemctl daemon-reload
	sudo systemctl enable --now keyd || true
	sudo systemctl enable --now NetworkManager || true
	@echo "Infrastructure deployed and system daemons initialized successfully."

install:
	@echo "======================================================================="
	@echo " Restoring Consolidated Core Manifesto via yay"
	@echo "======================================================================="
	yay -S --needed - < pkglist.txt

clean:
	@echo "Severing home folder environment symlinks cleanly..."
	stow -D bin swayimg satty cliphist lazygit nvim easyeffects zsh tmux waybar fuzzel fontconfig foot mako dev yazi sway git
