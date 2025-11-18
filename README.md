# About

My collection of Arch packages since I'm constantly reinstalling this operating system.

## Common `pacman`

- Update package databases: `sudo pacman -Sy`
- Upgrade the whole system: `sudo pacman -Syu`
- Install a package: `sudo pacman -S <package>`
- Remove a package (keep deps): `sudo pacman -R <package>`
- Remove package and unneeded deps: `sudo pacman -Rns <package>`
- Search in official repos: `pacman -Ss <pattern>`
- List installed packages: `pacman -Qs <pattern>`
- Show package info: `pacman -Qi <package>`
- Clean old package cache: `sudo pacman -Sc`
- Force refresh of all mirrors: `sudo pacman -Syy`

## Common `yay`

- Update AUR and repo packages: `yay -Syu`
- Install from AUR or repos: `yay -S <package>`
- Search AUR and repos: `yay <pattern>`
- Remove a package (with deps): `yay -Rns <package>`
- List explicitly installed AUR packages: `yay -Qm`
