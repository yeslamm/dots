.PHONY: user adopt system packages-install clean

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
	stow -R swayimg satty cliphist lazygit nvim easyeffects zsh emptty tmux waybar fuzzel fontconfig foot mako dev yazi sway git

adopt:
	@echo "Adopting existing configuration templates into tracking tree..."
	stow -A swayimg satty cliphist lazygit nvim easyeffects zsh emptty tmux waybar fuzzel fontconfig foot mako dev yazi sway git

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
	sudo mkdir -p /etc/emptty
	sudo cp sysconfigs/emptty/conf /etc/emptty/conf
	sudo cp sysconfigs/emptty/motd /etc/emptty/motd
	sudo systemctl daemon-reload
	sudo systemctl enable --now keyd || true
	sudo systemctl enable --now NetworkManager || true
	sudo systemctl enable emptty || true
	@echo "Infrastructure deployed and system daemons initialized successfully."

packages-install:
	@echo "======================================================================="
	@echo " Restoring Consolidated Core Manifesto via yay"
	@echo "======================================================================="
	yay -S --needed - < pkglist.txt

clean:
	@echo "Severing home folder environment symlinks cleanly..."
	stow -D swayimg satty cliphist lazygit nvim easyeffects zsh emptty tmux waybar fuzzel fontconfig foot mako dev yazi sway git
