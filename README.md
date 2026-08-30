# dots

Arch Linux dotfiles managed with GNU Stow for Sway, Zsh, Neovim, and PipeWire.

---

## Directory Structure

* **`apps/`** — User application configs (`nvim`, `tmux`, `yazi`, `lazygit`, `aria2`, `fastfetch`)
* **`bin/`** — User scripts (`~/.local/bin`)
* **`desktop/`** — Wayland and audio configs (`sway`, `waybar`, `foot`, `mako`, `fuzzel`, `pipewire`, `wireplumber`)
* **`dev/`** — Code formatters and linters (`clang-format`, `prettier`, `stylua`, `taplo`)
* **`shell/`** — Shell configuration (`zsh`, `zimfw`, `p10k`, `.gitconfig`)
* **`sysconfigs/`** — System configs deployed to `/etc` via `make sysconfigs` (`sysctl`, `zram`, `logind`, `scx`, `keyd`)

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

# 1. Copy /etc configs and enable system services
make sysconfigs

# 2. Symlink user configs to $HOME
make desktop    # or `make minimal` for CLI only

# 3. Install Zsh plugins
zsh -i -c "zimfw install"

# 4. Restart audio services
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

### 5. Audio Configuration

Set ALSA hardware levels before WirePlumber locks mixer states:

```bash
# 1. Set microphone hardware volume to 10% and disable mic boost
amixer -c Generic_1 sset 'Capture' 10% 2>/dev/null || amixer -c 1 sset 'Capture' 10%
amixer -c Generic_1 sset 'Internal Mic Boost' 0dB 2>/dev/null || true
amixer -c Generic_1 sset 'Mic Boost' 0dB 2>/dev/null || true

# 2. Save ALSA state across reboots
sudo alsactl store

# 3. Set default output volume to 35% and input volume to 100%
wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.35
wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 1.0
```

> **Note:** The native DSP chain requires `noise-suppression-for-voice` and `swh-plugins` (included in `pkglists/base.txt`). Verify the filter sinks are active after restarting PipeWire:
>
>
> ```bash
> wpctl status | grep -E "Dolby Atmos IEM Sink|Noise Canceling Microphone"
> ```
>
>

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

## Makefile Targets

| Target | Action |
| --- | --- |
| `make sysconfigs` | Copies `/etc` templates and enables systemd services |
| `make desktop` | Stows all user configurations into `$HOME` |
| `make minimal` | Stows CLI and development configurations only |
| `make dry-run` | Shows stow symlink operations without applying them |
| `make unstow` | Unlinks all active dotfiles from `$HOME` |
