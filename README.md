# dots

Personal Arch Linux dotfiles and workstation configurations.

> [!WARNING]
> These configurations are dialed in for an Arch Linux laptop with specific AMD hardware, architecture-tuned package repositories, audio codec levels, power management, and custom kernel parameters.
> 
> **Use at your own risk.** Do not run the `Makefile` or deployment commands blindly. Review and understand the configurations first, and adapt them to match your own hardware before applying changes to your system.

---

## Quick Setup

### 1. Prerequisites & CachyOS Repos

```bash
sudo pacman -S --needed base-devel git stow
git clone https://github.com/yeslamm/dots ~/dots

# Add CachyOS repositories
curl -s https://mirror.cachyos.org/cachyos-repo.tar.xz | tar -xJ -C /tmp
sudo /tmp/cachyos-repo/cachyos-repo.sh
```

Place `znver4` repositories at the top of `/etc/pacman.conf`:

```ini
[cachyos-znver4]
Include = /etc/pacman.d/cachyos-v4-mirrorlist

[cachyos-core-znver4]
Include = /etc/pacman.d/cachyos-v4-mirrorlist

[cachyos-extra-znver4]
Include = /etc/pacman.d/cachyos-v4-mirrorlist

[cachyos]
Include = /etc/pacman.d/cachyos-mirrorlist
```

Update system and install AUR helper:

```bash
sudo pacman -Syu yay
```

---

### 2. Install Packages

```bash
cd ~/dots

# Full desktop profile (or swap to pkglists/{base,apps,cachyos}.txt for minimal CLI)
grep -h -vE '^\s*#|^\s*$' pkglists/{base,apps,desktop,fonts,cachyos}.txt | sort -u | yay -S --needed -

# Optional: Gaming packages
grep -h -vE '^\s*#|^\s*$' pkglists/gaming.txt | sort -u | yay -S --needed -
```

---

### 3. Deploy Configurations

```bash
cd ~/dots

# Deploy /etc configs, reload systemd, and enable services
make system

# Stow dotfiles, install Zsh plugins, and calibrate audio
make desktop-profile    # Use 'make minimal-profile' for CLI-only installs

# Restart audio daemons
systemctl --user restart pipewire pipewire-pulse wireplumber
```

---

### 4. Machine-Local Setup

```bash
# Local secrets and coordinates
cp ~/.config/bluelight/config.example ~/.config/bluelight/config
cp ~/.config/aria2/aria2-rpc.conf.example ~/.config/aria2/aria2-rpc.conf

# Link Firefox userChrome.css (replace <firefox_user> with your profile directory)
mkdir -p ~/.mozilla/firefox/<firefox_user>/chrome
ln -sf ~/dots/nostow/firefox/userChrome.css ~/.mozilla/firefox/<firefox_user>/chrome/userChrome.css
```

Add kernel parameters to `/boot/loader/entries/*.conf`:

```text
options ... loglevel=3 pcie_aspm.policy=powersave nowatchdog
```

> [!TIP]
> Add background process names (e.g., `aria2c`, `cargo`) to `~/.config/sway/idle_procs` to prevent the display from sleeping during long-running tasks.
