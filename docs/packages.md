# Package Management

Quick reference for [Pacman](https://wiki.archlinux.org/title/pacman) and [yay](https://github.com/Jguer/yay) - Arch's native package manager and community AUR helper.

## Installing Yay

Yay is a Pacman wrapper written in Go that makes it easy to install packages from both official repositories and the AUR (Arch User Repository).

**Install yay:**

```bash
# Install build dependencies
sudo pacman -S --needed git base-devel

# Clone from AUR
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay

# Build and install
makepkg -si
```

Once installed, verify with:
```bash
yay --version
```

You can now use `yay` instead of `pacman` for most operations—it handles both repos and AUR seamlessly.

---

## Yay Commands

Quick reference for using yay — AUR helper that wraps pacman.

### Core Commands

| Command | Purpose |
|---------|---------|
| `yay` | Update everything (repos + AUR) |
| `yay -S <package>` | Install from repos or AUR |
| `yay -Rns <package>` | Remove package + unused deps |
| `yay <pattern>` | Search & install (interactive) |
| `yay -Ss <pattern>` | Search repos + AUR |
| `yay -Qs <pattern>` | Search installed packages |

### Maintenance

| Command | Purpose |
|---------|---------|
| `yay -Qm` | List AUR/foreign packages |
| `yay -Qdt` | List orphaned dependencies |
| `yay -Yc` | Remove unneeded dependencies |
| `yay -Sc` | Clean old caches (interactive) |

---

## Pacman Essentials

Core pacman commands you'll use regularly. Yay wraps these, but here are the basics:

| Command | Purpose |
|---------|---------|
| `pacman -Syu` | Update/upgrade all packages |
| `pacman -S <package>` | Install package from repos |
| `pacman -R <package>` | Remove package (keep deps) |
| `pacman -Rs <package>` | Remove package + unused deps |
| `pacman -Qs <package>` | Search installed packages |
| `pacman -Qi <package>` | Show installed package info |
| `pacman -Ql <package>` | List files installed by package |
| `pacman -Qo <file>` | Find which package owns a file |

**Tip:** Most of the time, just use `yay` instead of `pacman` directly. The difference is yay knows about the AUR too.
