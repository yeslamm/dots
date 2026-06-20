# dots

My curated, low-bloat Arch Linux workstation environment tailored for Wayland (`sway`) and optimized terminal workflows.

---

## Deployment Architecture

### 1. Host Environment Prerequisites

Before symlinking configurations, provision the local environment with required compilation utilities and an AUR helper:

```bash
# Synchronize core deployment utilities (GNU Stow handles symlink mapping)
sudo pacman -S --needed base-devel git stow

# Bootstrap yay (AUR Helper) from source binaries
git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
cd /tmp/yay-bin && makepkg -si
```

### 2. System-Level Dependency Layer

Install the managed package manifest containing all binaries, fonts, and graphics drivers required by this ecosystem:

```bash
# Provision hardware and software applications from package manifest
yay -S --needed - < pkglist.txt
```

### 3. Privileged Infrastructure Configurations

Execute these steps to map system-level configurations (handling power layout modifiers and low-level daemon permissions):

```bash
# Initialize system configuration paths
sudo mkdir -p /etc/systemd/logind.conf.d /etc/keyd

# Copy privileged overrides to root hierarchies
sudo cp sysconfigs/systemd/login.conf /etc/systemd/logind.conf.d/login.conf
sudo cp sysconfigs/keyd/default.conf /etc/keyd/default.conf

# Reload systemd manager configuration and activate keyd hardware service
sudo systemctl daemon-reload
sudo systemctl enable --now keyd

# Append active user to the keyd hardware input group
sudo usermod -aG keyd $USER
```

> **Note:** A system logout or reboot is mandatory for user group modifications to inherit active session permissions.

### 4. User Space Configuration Symlinking

Use GNU Stow to map configuration profiles into your `$HOME` directory.

> **Critical Step:** You must explicitly initialize the core system paths first. If these target directories do not physically exist, GNU Stow will symlink the entire parent folder rather than nesting the symlinks inside it, which will break multi-package structural layouts.

```bash
# Force initialize target parent paths to prevent Stow folder trapping
mkdir -p ~/.config ~/.local/share ~/.local/state ~/.local/bin
```

Select the profile layout matching your current host machine requirements:

#### Profile A: Core CLI Only (Safe for Headless Servers, WSL, or minimal VMs)

Maps only terminal configurations and developer tools without touching graphical window managers:

```bash
cd ~/dots
stow -t ~ -R nvim tmux zsh lazygit yazi fastfetch dev
```

#### Profile B: Full Workstation Environment (Complete Wayland Desktop)

Maps the complete system environment including the window manager, audio processing layers, status bars, and notification daemons:

```bash
cd ~/dots
stow -t ~ -R icons xdg gtk fastfetch bin swayimg satty lazygit nvim \
            easyeffects zsh tmux waybar fuzzel foot mako dev yazi sway git keyd
```

---

## Maintenance & Housekeeping

### Dry-Run Verification

To simulate deployment mutations and verify path conflicts without touching the filesystem, pass the verbose simulation flags:

```bash
stow -t ~ -nvR <folder_names>
```

### Purging Symlinks

To cleanly dismantle mapped configurations and sever home directory links without deleting source data:

```bash
stow -t ~ -D <folder_names>
```
