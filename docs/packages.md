# Package Management

Quick reference for using [yay](https://github.com/Jguer/yay) — AUR helper that wraps pacman.

## Core Commands

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
