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

# Install yay AUR helper
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

# Optional: Gaming
grep -h -vE '^\s*#|^\s*$' pkglists/gaming.txt | sort -u | yay -S --needed -
```

---

### 2. System Configuration

Deploy system-level configs for key remapping (`keyd`), power handling (`systemd-logind`), and CPU scheduling (`scx_lavd`):

```bash
cd ~/dots
make sysconfigs
```

> **Note:** Reboot or log out after deployment for `keyd` group permissions and Sched-EXT state to finalize.

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
