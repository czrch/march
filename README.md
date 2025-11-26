# Arch notes

Personal Arch Linux notes so I can quickly redo a sane setup after reinstalls. Focus is on `yay` and day‑to‑day package management.

## Useful links

- [Arch Linux](https://archlinux.org/)
- [Pacman tips & tricks](https://wiki.archlinux.org/title/Pacman/Tips_and_tricks)
- [Arch User Repository (AUR)](https://aur.archlinux.org/)
- [EndeavourOS](https://endeavouros.com/)

## System updates

- Update everything (repos + AUR): `yay -Syu`
- Include `--devel` packages: `yay -Syu --devel --timeupdate`

## Searching and inspecting packages (yay)

- Search repos + AUR (quick): `yay <pattern>`
- Search repos only: `yay -Ss <pattern>`
- Search installed packages: `yay -Qs <pattern>`
- Show package details: `yay -Si <package>`
- Show files installed by a package: `yay -Ql <package>`

## Installed, AUR, and orphaned packages

- Explicitly installed (not pulled as deps): `yay -Qe`
- AUR / foreign packages: `yay -Qm`
- Orphaned dependencies (removal candidates): `yay -Qdt`

## Installing, removing, cleaning (yay)

- Install from repos or AUR: `yay -S <package>`
- Remove a package + unused deps: `yay -Rns <package>`
- See what depends on a package before removing: `pactree -r <package>`
- Remove unneeded dependencies: `yay -Yc`
- Clean old package cache (interactive): `yay -Sc`
- Clean all package caches (be careful): `yay -Scc`

## Mirrors and speed

- Install mirror helper (example): `yay -S rate-mirrors-bin`
- Refresh Arch mirrors (adjust country/opts as needed):

```bash
sudo rate-mirrors --allow-root arch | sudo tee /etc/pacman.d/mirrorlist
```

For more options see:

- [rate-mirrors](https://github.com/westandskif/rate-mirrors)
- [reflector](https://wiki.archlinux.org/title/Reflector)

## Extra pacman tricks

These are still handy even if you mostly use `yay`:

- Find which package owns a file: `pacman -Qo /path/to/file`
- Search sync database for a file (after `sudo pacman -Fy`): `pacman -F <filename>`
- Verify installed files for a package: `pacman -Qk <package>` or `pacman -Qkk <package>`
- Download packages to cache without installing: `pacman -Sw <package>`
- Reinstall all sync packages:

```bash
pacman -Qnq | sudo pacman -S -
```

- Clean old package cache with `paccache` (from `pacman-contrib`): `sudo paccache -r`

## Remote desktops

- Moonlight (client for NVIDIA GameStream‑like streaming): `sudo pacman -S moonlight-qt`  
  Use this on the machine receiving the stream (your laptop/desktop).
- Sunshine (game streaming host): `yay -S sunshine`  
  Run this on the gaming host, configure games/apps and firewall, then pair Moonlight to Sunshine.

## Graphics

- NVIDIA installer: `sudo pacman -S nvidia-inst`  
  After install, run the guided installer: `sudo nvidia-inst`.
- Hybrid graphics switcher: `sudo pacman -S switcheroo`  
  After install, enable and start:

```bash
sudo systemctl enable --now switcheroo-control.service
```

## Editors – VSCodium

VSCodium is a build of VS Code without the Microsoft telemetry, branding, or license issues.

```bash
# Precompiled
yay -S --needed vscodium-bin

# From source
yay -S --needed vscodium
```

Batch‑install some favourite extensions:

```bash
# --- AI / agents ---
exts_ai=(
  saoudrizwan.claude-dev
  openai.chatgpt
)

# --- Git / GitHub tooling ---
exts_git=(
  vscode.github
  vscode.github-authentication
  mhutchie.git-graph
)

# --- Markdown / docs ---
exts_docs=(
  yzhang.markdown-all-in-one
  DavidAnson.vscode-markdownlint
  vscode.markdown-math
)

# --- Editing / UX ---
exts_editing=(
  vscodevim.vim
  kisstkondoros.vscode-gutter-preview
  johnpapa.vscode-peacock
  ArthurLobo.easy-codesnap
)

# --- Debugging ---
exts_debug=(
  vscode.debug-auto-launch
)

# Install all (VSCodium)
for e in \
  "${exts_ai[@]}" \
  "${exts_git[@]}" \
  "${exts_docs[@]}" \
  "${exts_editing[@]}" \
  "${exts_debug[@]}"
do
  codium --install-extension "$e"
done
```
