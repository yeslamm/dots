# dots

Personal Arch Linux dotfiles managed with GNU Stow, configured for Sway and terminal-driven workflows.

---

## Structure

* **`apps/`** — CLI tools (`nvim`, `tmux`, `yazi`, `lazygit`, `aria2`, `fastfetch`)
* **`bin/`** — User scripts (`~/.local/bin`)
* **`desktop/`** — Wayland stack (`sway`, `waybar`, `foot`, `mako`, `fuzzel`, `easyeffects`)
* **`dev/`** — Linters and formatters (`clang-format`, `prettier`, `stylua`, `taplo`)
* **`shell/`** — Zsh, Powerlevel10k, `.gitconfig`, and XDG paths
* **`sysconfigs/`** — System configs deployed via Makefile (`sysctl`, `zram`, `logind`, `scx`, `keyd`, `cgroups`)

---

## Quickstart

### 1. Prerequisites & CachyOS Repos

```bash
# Base tools
sudo pacman -S --needed base-devel git stow

# Dotfiles
git clone https://github.com/r3dr3d007/dots ~/dots
```

Add CachyOS repositories:

```bash
curl -s https://mirror.cachyos.org/cachyos-repo.tar.xz | tar -xJ -C /tmp
sudo /tmp/cachyos-repo/cachyos-repo.sh
```

For Zen 4/5 hardware, place the `znver4` repos at the top of `/etc/pacman.conf`:

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

Sync and install `yay`:

```bash
sudo pacman -Syu yay
```

---

### 2. Package Installation

Install packages for your target setup:

```bash
cd ~/dots

# Profile A: Minimal / Headless
grep -h -vE '^\s*#|^\s*$' pkglists/{base,apps,cachyos}.txt | sort -u | yay -S --needed -

# Profile B: Full Desktop
grep -h -vE '^\s*#|^\s*$' pkglists/{base,apps,desktop,fonts,cachyos}.txt | sort -u | yay -S --needed -

# Optional: Gaming stack
grep -h -vE '^\s*#|^\s*$' pkglists/gaming.txt | sort -u | yay -S --needed -

# Verify znver4 packages installed from CachyOS repos
pacman -Sl cachyos-znver4 cachyos-core-znver4 cachyos-extra-znver4 | grep -Fc '[installed]'
```

---

### 3. Deploy & Stow

```bash
cd ~/dots

# 1. Deploy system configs to /etc (zram, sysctl, scx, keyd, logind)
make sysconfigs

# 2. Stow user dotfiles
make desktop   # or `make minimal` for CLI only
```

#### Optional: Bootloader Parameters

Append to `/boot/loader/entries/*.conf` options line:

```text
pcie_aspm.policy=powersave nowatchdog
```

*Reboot after initial setup.*

---

## Makefile Targets

| Command | Action |
| --- | --- |
| `make desktop` | Stow full desktop environment |
| `make minimal` | Stow headless CLI utilities |
| `make sysconfigs` | Install system-level `/etc` configurations |
| `make dry-run` | Preview stow symlinks without writing |
| `make unstow` | Remove active user symlinks |

