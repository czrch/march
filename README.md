# About

My collection of Arch packages since I'm constantly reinstalling this operating system.

## Useful links

- Arch Linux: https://archlinux.org/
- ArchWiki pacman tips & tricks: https://wiki.archlinux.org/title/Pacman/Tips_and_tricks
- Arch User Repository (AUR): https://aur.archlinux.org/
- EndeavourOS (eos): https://endeavouros.com/

## Pacman tips & tricks

- List explicitly installed packages: `pacman -Qe`
- List foreign (AUR/manual) packages: `pacman -Qm`
- List orphaned dependencies (removal candidates): `pacman -Qtdq`
- Show files installed by a package: `pacman -Ql <package>`
- Find which package owns a file: `pacman -Qo /path/to/file`
- Search sync databases for a file (update with `pacman -Fy`): `pacman -F <filename>`
- Check installed files for a package: `pacman -Qk <package>` (or `pacman -Qkk <package>` for a deeper check)
- Download packages to cache without installing: `pacman -Sw <package>`
- Reinstall all sync packages: `pacman -Qnq | pacman -S -`
- Clean old package cache with `paccache` (from `pacman-contrib`): `sudo paccache -r`

## Common `yay`

- Update AUR and repo packages: `yay -Syu`
- Install from AUR or repos: `yay -S <package>`
- Search AUR and repos: `yay <pattern>`
- Remove a package (with deps): `yay -Rns <package>`
- List explicitly installed AUR packages: `yay -Qm`

## Remote desktops

- Moonlight (client for NVIDIA GameStream-like streaming): `sudo pacman -S moonlight-qt`
  - Use this on the machine receiving the stream (your laptop/desktop).
- Sunshine (host/game streaming server): `yay -S sunshine`
  - Run this on the gaming host; configure games/apps and firewall, then pair Moonlight to Sunshine.

## Graphics

- NVIDIA installer: `sudo pacman -S nvidia-inst`
  - After install: run the guided installer with `sudo nvidia-inst` and follow the prompts.
- Hybrid graphics switcher: `sudo pacman -S switcheroo`
  - After install: enable and start the service with `sudo systemctl enable --now switcheroo-control.service`.

## Editors

### VSCodium

An awesome fork of VSCode without all the Miscrosoft rubbish.

```bash
# Precompiled
yay -S --needed vscodium-bin

# From source
yay -S --needed vscodium
```

Here is a script that will batch install some of my faviourite commands.

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
