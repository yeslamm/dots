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

# 1. Install core dependencies
grep -vE '^\s*#|^\s*$' pkglist.txt | yay -S --needed -

# 2. (Optional) Install gaming related packages
grep -vE '^\s*#|^\s*$' gaming_pkglist.txt | yay -S --needed -

```

---

### 2. System Configuration

Copy system-level configs for key remapping (`keyd`) and power management (`systemd-logind`):

```bash
# Copy configs to /etc
sudo mkdir -p /etc/systemd/logind.conf.d /etc/keyd
sudo cp ~/dots/sysconfigs/systemd/login.conf /etc/systemd/logind.conf.d/login.conf
sudo cp ~/dots/sysconfigs/keyd/default.conf /etc/keyd/default.conf

# Enable keyd service and grant user permissions
sudo systemctl daemon-reload
sudo systemctl enable --now keyd
sudo usermod -aG keyd $USER

```

> **Note:** Reboot or log out after adding your user to the `keyd` group for permissions to take effect.

---

### 3. Stowing Configurations

Create common target directories first so Stow symlinks individual configuration files instead of whole directories:

```bash
mkdir -p ~/.config ~/.local/share ~/.local/state ~/.local/bin ~/.icons

```

Stow the profiles relevant to your machine:

#### Profile A: Server / Headless CLI (No GUI)

```bash
cd ~/dots
stow -t ~ -R bin shell apps dev

```

#### Profile B: Full Desktop Workstation (Wayland / Sway)

```bash
cd ~/dots
stow -t ~ -R bin shell apps dev desktop

```

---

## Management

Run Stow commands from any directory by passing `-d ~/dots`:

**Preview changes (Dry Run):**

```bash
stow -d ~/dots -t ~ -nvR bin shell apps dev desktop

```

**Re-stow all packages:**

```bash
stow -d ~/dots -t ~ -R bin shell apps dev desktop

```

**Remove symlinks (Unstow):**

```bash
stow -d ~/dots -t ~ -D bin shell apps dev desktop

```
