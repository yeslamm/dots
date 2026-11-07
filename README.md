# dots

My Arch + sway laptop setup.

> [!WARNING]
> I made these for my AMD laptop, so I've changed the kernel parameters, power management, audio codec levels, and swapped the default `EEVDF` scheduler for `scx_lavd`. Read the `Makefile` before running it so it doesn't overwrite your local settings.

## Setup

You'll need `base-devel`, `git`, and `stow`:

```bash
sudo pacman -S --needed base-devel git stow
git clone https://github.com/yeslamm/dots ~/dots
```

If you don't have `yay`, build it from the AUR:

```bash
git clone https://aur.archlinux.org/yay.git /tmp/yay && cd /tmp/yay && makepkg -si
```

## Install

```bash
cd ~/dots
make bootstrap
```

Or step by step:

```bash
make pkgs        # base, desktop, and CLI packages
make system      # /etc configs and systemd services
make profile     # stow dotfiles and set audio levels

# optional package groups
make pkgs-gaming
make pkgs-virt
```

## After install

The Makefile doesn't install these, so run them once:

```bash
ya pkg install            # yazi plugins (gitignored, installed from package.toml)
zsh -i -c "zimfw install" # zsh plugins
```

## Local config

```bash
cp ~/.config/bluelight/config.example ~/.config/bluelight/config
cp ~/.config/aria2/aria2-rpc.conf.example ~/.config/aria2/aria2-rpc.conf

# Firefox userChrome.css (replace <firefox_user> with your profile folder)
mkdir -p ~/.mozilla/firefox/<firefox_user>/chrome
ln -sf ~/dots/manual/firefox/userChrome.css ~/.mozilla/firefox/<firefox_user>/chrome/userChrome.css
```

Add these kernel parameters to `/boot/loader/entries/*.conf`:

```text
options ... loglevel=3 pcie_aspm.policy=powersave nowatchdog
```

To keep the display from sleeping during long tasks, add process names (like `firefox` or `mpv`) to `~/.config/sway/idle_procs`.
