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

Install build tools, GNU Stow, and `yay` to pull packages from `pkglist.txt`:

```bash
# Base tools
sudo pacman -S --needed base-devel git stow

# Install yay
git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
cd /tmp/yay-bin && makepkg -si

# Install environment dependencies
cd ~/dots
yay -S --needed - < pkglist.txt

```

### 2. System Configuration

Copy system-level configs for key remapping (`keyd`) and power management (`systemd-logind`):

```bash
# Copy configs to /etc
sudo mkdir -p /etc/systemd/logind.conf.d /etc/keyd
sudo cp sysconfigs/systemd/login.conf /etc/systemd/logind.conf.d/login.conf
sudo cp sysconfigs/keyd/default.conf /etc/keyd/default.conf

# Enable keyd service and add user to group
sudo systemctl daemon-reload
sudo systemctl enable --now keyd
sudo usermod -aG keyd $USER

```

> **Note:** Reboot or log out after adding your user to the `keyd` group.

### 3. Stowing Configurations

Create common target directories first so Stow symlinks individual files inside them rather than overriding entire folders:

```bash
mkdir -p ~/.config ~/.local/share ~/.local/state ~/.local/bin

```

Stow the profiles relevant to your host:

#### Profile A: Server / CLI Only (No GUI)

```bash
cd ~/dots
stow -t ~ -R bin shell apps dev

```

#### Profile B: Full Desktop (Wayland / Sway)

```bash
cd ~/dots
stow -t ~ -R bin shell apps dev desktop

```

---

## Management

**Preview changes (Dry Run):**

```bash
stow -t ~ -nvR bin shell apps dev desktop

```

**Remove symlinks (Unstow):**

```bash
stow -t ~ -D bin shell apps dev desktop

```
