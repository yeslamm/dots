# dots

My curated, low-bloat Arch Linux workstation

## Installation Strategy

### 1. Prerequisites (Run Manually)
Before running the deployment layers, ensure you have basic development utilities and an AUR compiler layer present on the system:

```bash
sudo pacman -S --needed base-devel git stow make
git clone [https://aur.archlinux.org/yay.git](https://aur.archlinux.org/yay.git) /tmp/yay
cd /tmp/yay && makepkg -si
