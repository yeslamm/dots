# dots

Personal Arch Linux dotfiles tailored for Wayland (`sway`) and terminal-centric workflows, managed with GNU Stow.

---

## Repository Structure

Configurations are split into modular Stow packages:

* **`bin/`** — Executable user scripts (`~/.local/bin`)
* **`shell/`** — Zsh runtime, Powerlevel10k, `.gitconfig`, and XDG defaults
* **`apps/`** — CLI applications (`nvim`, `tmux`, `yazi`, `lazygit`, `fastfetch`, `swayimg`, `aria2`)
* **`dev/`** — Formatters and linters (`clang-format`, `prettier`, `stylua`, `taplo`)
* **`desktop/`** — Wayland desktop stack (`sway`, `waybar`, `foot`, `mako`, `fuzzel`, `easyeffects`)

---

## Installation

### 1. Prerequisites & Packages

Install base build tools, GNU Stow, and clone this repository:

```bash
# Base tools and Stow
sudo pacman -S --needed base-devel git stow

# Clone dotfiles
git clone https://github.com/r3dr3d007/dots ~/dots
```

Add CachyOS repositories (for optimized kernels, `scx_lavd`, and `x86-64-v4` packages):

```bash
cd /tmp
curl -O https://mirror.cachyos.org/cachyos-repo.tar.xz
tar -xvf cachyos-repo.tar.xz
cd cachyos-repo && sudo ./cachyos-repo.sh
cd ~/dots
```

Install the `yay` AUR helper:

```bash
git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
cd /tmp/yay-bin && makepkg -si
```

Install packages from the pkglists:

```bash
cd ~/dots

# Profile A: Headless / CLI only
grep -h -vE '^\s*#|^\s*$' pkglists/{base,apps}.txt | sort -u | yay -S --needed -

# Profile B: Full Desktop Workstation (Wayland / Sway)
grep -h -vE '^\s*#|^\s*$' pkglists/{base,apps,desktop,fonts}.txt | sort -u | yay -S --needed -

# Enhancements: CachyOS optimizations & Gaming (Optional)
grep -h -vE '^\s*#|^\s*$' pkglists/cachyos.txt | sort -u | yay -S --needed -
grep -h -vE '^\s*#|^\s*$' pkglists/gaming.txt | sort -u | yay -S --needed -
```

---

### 2. System Configuration

Deploy system-level configurations to `/etc` (key remapping with `keyd`, power handling via `systemd-logind`, `scx_lavd` CPU scheduling, dynamic 16G `zram` + MGLRU memory sysctls, and `cgroup` user delegation):

```bash
cd ~/dots
make sysconfigs
```

#### Optional: Kernel Parameters (PCIe Power Savings & Low Latency)

Append the following to the `options` line in your bootloader entry (e.g. `/boot/loader/entries/cachyos.conf`):

```text
pcie_aspm.policy=powersave nowatchdog
```

> **Note:** Reboot after deployment for `keyd` group permissions, PCIe ASPM policy, and Sched-EXT daemons to finalize.

---

### 3. Stowing Configurations

Stow the configuration profile matching your machine:

#### Profile A: Server / Headless CLI (No GUI)

```bash
cd ~/dots
make server
```

#### Profile B: Full Desktop Workstation (Wayland / Sway)

```bash
cd ~/dots
make desktop
```

---

## Management

Run maintenance commands from `~/dots`:

* **Preview changes (Dry Run):** `make dry-run`
* **Re-stow desktop profile:** `make desktop`
* **Remove symlinks (Unstow):** `make unstow`
* **Update /etc system configs:** `make sysconfigs`
* **View all commands:** `make` or `make help`
