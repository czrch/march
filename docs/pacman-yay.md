# Pacman + yay helpers

## System updates

- Update everything (repos + AUR): `yay -Syu`
- Include `--devel` packages: `yay -Syu --devel --timeupdate`

## Searching & inspecting packages

| Command | Purpose |
|---------|---------|
| `yay <pattern>` | Search repos + AUR (quick) |
| `yay -Ss <pattern>` | Search repos only |
| `yay -Qs <pattern>` | Search installed packages |
| `yay -Si <package>` | Show package details |
| `yay -Ql <package>` | Show files installed by a package |

## Package management

| Command | Purpose |
|---------|---------|
| `yay -Qe` | Explicitly installed packages |
| `yay -Qm` | AUR / foreign packages |
| `yay -Qdt` | Orphaned dependencies |

## Install & remove

| Command | Purpose |
|---------|---------|
| `yay -S <package>` | Install from repos or AUR |
| `yay -Rns <package>` | Remove + unused deps |
| `pactree -r <package>` | See what depends on package |
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

## Pacman tricks

Still handy even when using `yay`:

| Command | Purpose |
|---------|---------|
| `pacman -Qo /path/to/file` | Find which package owns a file |
| `pacman -F <filename>` | Search sync database for file |
| `pacman -Qk <package>` | Verify installed files |
| `pacman -Sw <package>` | Download without installing |
| `pacman -Qnq \| sudo pacman -S -` | Reinstall all sync packages |
| `sudo paccache -r` | Clean old caches (pacman-contrib) |

