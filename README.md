# dots

Arch Linux dotfiles managed with GNU Stow for Sway, Zsh, Neovim, and PipeWire.

---

## Directory Structure

* **`apps/`** — User application configs (`nvim`, `tmux`, `yazi`, `lazygit`, `aria2`, `fastfetch`)
* **`bin/`** — User scripts (`~/.local/bin`)
* **`desktop/`** — Wayland and audio configs (`sway`, `waybar`, `foot`, `mako`, `fuzzel`, `pipewire`, `wireplumber`)
* **`dev/`** — Code formatters and linters (`clang-format`, `prettier`, `stylua`, `taplo`)
* **`shell/`** — Shell configuration (`zsh`, `zimfw`, `p10k`, `.gitconfig`)
* **`system/`** — System configs deployed to `/etc` via `make system` (`sysctl`, `zram`, `logind`, `scx`, `keyd`)

---

## Installation

### 1. Base Setup & CachyOS Repositories

```bash
sudo pacman -S --needed base-devel git stow
git clone https://github.com/r3dr3d007/dots ~/dots
```

Add CachyOS repositories:

```bash
curl -s https://mirror.cachyos.org/cachyos-repo.tar.xz | tar -xJ -C /tmp
sudo /tmp/cachyos-repo/cachyos-repo.sh
```

For AMD Zen 4/5 CPUs, put `znver4` repositories at the top of `/etc/pacman.conf`:

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

Update package databases and install `yay`:

```bash
sudo pacman -Syu yay
```

---

### 2. Install Packages

```bash
cd ~/dots

# Minimal / CLI profile
grep -h -vE '^\s*#|^\s*$' pkglists/{base,apps,cachyos}.txt | sort -u | yay -S --needed -

# Full Sway desktop profile
grep -h -vE '^\s*#|^\s*$' pkglists/{base,apps,desktop,fonts,cachyos}.txt | sort -u | yay -S --needed -

# Optional: Gaming packages
grep -h -vE '^\s*#|^\s*$' pkglists/gaming.txt | sort -u | yay -S --needed -
```

---

### 3. Stow & Deploy Configurations

```bash
cd ~/dots

# 1. Deploy /etc configurations and start system services
make system

# 2. Deploy the complete workstation profile (stows apps/desktop, installs Zsh plugins, tunes audio)
make desktop-profile    # Use `make minimal-profile` for CLI-only environments

# 3. Restart audio services
systemctl --user restart pipewire pipewire-pulse wireplumber
```

---

### 4. Configure Local Templates

Copy the template configuration files and fill in your local coordinates and RPC tokens:

```bash
# Set your location coordinates (Latitude / Longitude) for sunrise/sunset color temperature
cp ~/.config/bluelight/config.example ~/.config/bluelight/config

# Set your aria2 RPC secret token
cp ~/.config/aria2/aria2-rpc.conf.example ~/.config/aria2/aria2-rpc.conf
```

---

### 5. Audio Verification & System Parameters

Verify that the native DSP filter source is active after your first session start:

```bash
wpctl status | grep -E "Noise Canceling Microphone"
```

#### Kernel Parameters (systemd-boot)

Add to your `/boot/loader/entries/*.conf` options:

```text
options ... loglevel=3 pcie_aspm.policy=powersave nowatchdog
```

*Log out or reboot to apply group permissions (`keyd`) and system configs.*

---

### 6. Idle Management & Process Inhabitation

The custom idle governor checks `~/.config/sway/idle_procs` before dimming or locking the screen. Add process names (one per line) to inhibit sleep during execution (e.g., compile jobs, downloads):

```text
aria2c
qbittorrent
yay
cargo
```

---

### 7. Manual Configuration Links (`nostow`)

For applications like Firefox whose internal profile directory hashes change per installation, link files manually from the `nostow` directory:

```bash
# Ensure the chrome directory exists inside your active Firefox profile path
mkdir -p ~/.mozilla/firefox/*.default-release/chrome

# Symlink userChrome.css (replace *.default-release with your actual profile folder name)
ln -sf ~/dots/nostow/firefox/userChrome.css ~/.mozilla/firefox/*.default-release/chrome/userChrome.css
```

---

## Makefile Targets

| Target | Action |
| --- | --- |
| `make system` | Deploy `/etc` configs and enable system services |
| `make desktop-profile` | Deploy full Wayland/Sway profile + audio & shell dependencies |
| `make minimal-profile` | Deploy core CLI profile (terminal & dev tools + shell) |
| `make stow-desktop` | Fast restow/refresh of desktop symlinks only |
| `make stow-minimal` | Fast restow/refresh of minimal symlinks only |
| `make unstow-desktop` | Remove all active desktop stow symlinks |
| `make unstow-minimal` | Remove all active minimal stow symlinks |
| `make simulate-desktop` | Preview desktop stow symlink actions safely |
| `make simulate-minimal` | Preview minimal stow symlink actions safely |
| `make audio` | Re-apply ALSA hardware levels and WirePlumber volumes |
| `make zsh` | Install or update Zsh plugins via Zimfw |
