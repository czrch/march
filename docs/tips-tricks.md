# Tips & Tricks

## Pacman

Core package manager commands and utilities.

### Searching & inspecting

| Command | Purpose |
|---------|---------|
| `pacman -Ss <pattern>` | Search repos |
| `pacman -Qs <pattern>` | Search installed packages |
| `pacman -Si <package>` | Show package details (repo) |
| `pacman -Qi <package>` | Show package details (installed) |
| `pacman -Ql <package>` | Show files installed by a package |
| `pacman -Qo /path/to/file` | Find which package owns a file |
| `pacman -F <filename>` | Search sync database for file |

### Package management

| Command | Purpose |
|---------|---------|
| `pacman -Qe` | Explicitly installed packages |
| `pacman -Qd` | Dependencies |
| `pacman -Qdt` | Orphaned dependencies |
| `pacman -Qk <package>` | Verify installed files |

### Install & remove

| Command | Purpose |
|---------|---------|
| `pacman -S <package>` | Install package |
| `pacman -Sw <package>` | Download without installing |
| `pacman -Rns <package>` | Remove + unused deps |
| `pacman -Qnq \| sudo pacman -S -` | Reinstall all sync packages |
| `pactree -r <package>` | See what depends on package |

### Cache management

| Command | Purpose |
|---------|---------|
| `sudo paccache -r` | Clean old caches (pacman-contrib) |
| `pacman -Sc` | Clean old caches (interactive) |
| `pacman -Scc` | Clean all caches (careful) |

## yay

AUR helper that wraps pacman with additional features.

### System updates

- Update everything (repos + AUR): `yay -Syu`
- Include `--devel` packages: `yay -Syu --devel --timeupdate`

### Searching

| Command | Purpose |
|---------|---------|
| `yay <pattern>` | Search repos + AUR (interactive) |
| `yay -Ss <pattern>` | Search repos + AUR |
| `yay -Qs <pattern>` | Search installed packages |
| `yay -Si <package>` | Show package details |

### Package management

| Command | Purpose |
|---------|---------|
| `yay -Qe` | Explicitly installed packages |
| `yay -Qm` | AUR / foreign packages |
| `yay -Qdt` | Orphaned dependencies |

### Install & remove

| Command | Purpose |
|---------|---------|
| `yay -S <package>` | Install from repos or AUR |
| `yay -Rns <package>` | Remove + unused deps |
| `yay -Yc` | Remove unneeded dependencies |
| `yay -Sc` | Clean old caches (interactive) |
| `yay -Scc` | Clean all caches (careful) |

## Mirrors & speed

Install mirror helper:

```bash
yay -S rate-mirrors-bin
```

Refresh Arch mirrors (adjust country/opts as needed):

```bash
sudo rate-mirrors --allow-root arch | sudo tee /etc/pacman.d/mirrorlist
```