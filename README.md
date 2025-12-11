# 🐧 Arch Linux Notes

> Personal setup reference for fast, sane reinstalls on Arch Linux

<br>

## 📚 Quick Links

- [Arch Linux](https://archlinux.org/)
- [Pacman tips & tricks](https://wiki.archlinux.org/title/Pacman/Tips_and_tricks)
- [Arch User Repository (AUR)](https://aur.archlinux.org/)
- [EndeavourOS](https://endeavouros.com/)

<br>

## System Updates

- Update everything (repos + AUR): `yay -Syu`
- Include `--devel` packages: `yay -Syu --devel --timeupdate`

<br>

## Searching & Inspecting Packages

| Command | Purpose |
|---------|---------|
| `yay <pattern>` | Search repos + AUR (quick) |
| `yay -Ss <pattern>` | Search repos only |
| `yay -Qs <pattern>` | Search installed packages |
| `yay -Si <package>` | Show package details |
| `yay -Ql <package>` | Show files installed by a package |

<br>

## Package Management

| Command | Purpose |
|---------|---------|
| `yay -Qe` | Explicitly installed packages |
| `yay -Qm` | AUR / foreign packages |
| `yay -Qdt` | Orphaned dependencies |

<br>

## Install & Remove

| Command | Purpose |
|---------|---------|
| `yay -S <package>` | Install from repos or AUR |
| `yay -Rns <package>` | Remove + unused deps |
| `pactree -r <package>` | See what depends on package |
| `yay -Yc` | Remove unneeded dependencies |
| `yay -Sc` | Clean old caches (interactive) |
| `yay -Scc` | Clean all caches (careful) |

<br>

## Mirrors & Speed

Install mirror helper:
```bash
yay -S rate-mirrors-bin
```

Refresh Arch mirrors (adjust country/opts as needed):
```bash
sudo rate-mirrors --allow-root arch | sudo tee /etc/pacman.d/mirrorlist
```

More options:
- [rate-mirrors](https://github.com/westandskif/rate-mirrors)
- [reflector](https://wiki.archlinux.org/title/Reflector)

<br>

## Pacman Tricks

Still handy even when using `yay`:

| Command | Purpose |
|---------|---------|
| `pacman -Qo /path/to/file` | Find which package owns a file |
| `pacman -F <filename>` | Search sync database for file |
| `pacman -Qk <package>` | Verify installed files |
| `pacman -Sw <package>` | Download without installing |
| `pacman -Qnq \| sudo pacman -S -` | Reinstall all sync packages |
| `sudo paccache -r` | Clean old caches (pacman-contrib) |

<br>

## Remote Desktops & Streaming

**Moonlight** (NVIDIA GameStream client):
```bash
sudo pacman -S moonlight-qt
```
Install on the machine receiving the stream (laptop/desktop).

**Sunshine** (game streaming host):
```bash
yay -S sunshine
```
Run on gaming host, configure games/apps/firewall, then pair with Moonlight.

<br>

## Graphics

**NVIDIA drivers:**
```bash
sudo pacman -S nvidia-inst
sudo nvidia-inst
```

**Hybrid graphics switcher:**
```bash
sudo pacman -S switcheroo
sudo systemctl enable --now switcheroo-control.service
```

<br>

---

💡 **Tip:** See [Editors & IDEs](./docs/editors/) for setup guides.
