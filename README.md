# dots

Personal Arch Linux dotfiles and workstation configurations.

> [!WARNING]
> These configurations are dialed in for an Arch Linux laptop with specific AMD hardware, architecture-tuned package repositories, audio codec levels, power management, and custom kernel parameters.
>
> **Use at your own risk.** Do not run the `Makefile` or deployment commands blindly. Review and understand the configurations first, and adapt them to match your own hardware before applying changes to your system.

---

## Setup

### 1. Prerequisites & CachyOS Repos

```bash
sudo pacman -S --needed base-devel git stow
git clone https://github.com/yeslamm/dots ~/dots

# Add CachyOS repositories
curl -s https://mirror.cachyos.org/cachyos-repo.tar.xz | tar -xJ -C /tmp
sudo /tmp/cachyos-repo/cachyos-repo.sh
```

Update system and install `yay`:

```bash
sudo pacman -Syu yay
```

---

### 2. Install & Deploy

```bash
cd ~/dots

# Full setup
make bootstrap
```

Or run individual steps manually:

```bash
make pkgs       # Install base, desktop, and CLI packages
make system     # Deploy /etc configs and enable systemd services
make profile    # Stow dotfiles, set audio levels, update zsh plugins

# Optional package groups
make pkgs-gaming
make pkgs-virt
```

---

### 3. Machine-Local Setup

```bash
# Local configs
cp ~/.config/bluelight/config.example ~/.config/bluelight/config
cp ~/.config/aria2/aria2-rpc.conf.example ~/.config/aria2/aria2-rpc.conf

# Firefox userChrome.css (replace <firefox_user> with your profile folder)
mkdir -p ~/.mozilla/firefox/<firefox_user>/chrome
ln -sf ~/dots/nostow/firefox/userChrome.css ~/.mozilla/firefox/<firefox_user>/chrome/userChrome.css
```

Add kernel parameters to `/boot/loader/entries/*.conf`:

```text
options ... loglevel=3 pcie_aspm.policy=powersave nowatchdog
```

> [!TIP]
> Add process names (e.g. `aria2c`, `cargo`) to `~/.config/sway/idle_procs` to prevent the display from sleeping during long-running tasks.
