# 🐱 Kitty Terminal

> GPU‑accelerated, modern terminal emulator with great UX.

## What You Get

- Fast rendering and low latency.
- Good font/ligature support.
- Built‑in tabs/splits.
- Easy theme switching.

## Install

```bash
sudo pacman -S kitty
```

## Config Files

- `~/.config/kitty/kitty.conf`
- `~/.config/kitty/current-theme.conf` (managed by the themes kitten)

Repo copies live in `dotfiles/kitty/`.

## Apply From Repo

```bash
./scripts/sync-dotfiles.sh --pull
```

## Push Local Changes To Repo

```bash
./scripts/sync-dotfiles.sh --push
```

## Useful Keybinds

### Your Custom Bindings (from `kitty.conf`)

- Font size: `Ctrl+=` increase, `Ctrl+-` decrease, `Ctrl+0` reset.
- Tabs: `Ctrl+Tab` next, `Ctrl+Shift+Tab` previous, `Ctrl+1..9` jump to tab.
- New tab in same directory: `Ctrl+Shift+T`.
- Scrollback search/view: `Ctrl+Shift+H`.
- Splits: `F5` horizontal split, `F6` vertical split, `F4` smart split.
- Rotate split axis: `F7`.
- Move active split: `Shift+↑/↓/←/→`.
- Snap split to screen edge: `Ctrl+Shift+↑/↓/←/→`.
- Focus neighboring split: `Ctrl+↑/↓/←/→`.
- Bias current split to 80%: `Ctrl+.`.

### Handy Kitty Defaults (unless you remapped)

- Copy / paste: `Ctrl+Shift+C` / `Ctrl+Shift+V`.
- New window: `Ctrl+Shift+Enter` (new OS window), `Ctrl+Shift+N` (new window in tab).
- Close tab/window: `Ctrl+Shift+W`.
- Search in scrollback: `Ctrl+Shift+F`.
- Open URL under cursor: `Ctrl+Shift+E` (or right‑click).

## Theming

You currently use Kitty’s built‑in themes kitten:

```bash
kitty +kitten themes
```

- Pick a theme interactively.
- Kitty writes the selected theme to `current-theme.conf`.
- Your `kitty.conf` includes it via `include current-theme.conf`.

If you want to track a new theme, re‑run the kitten then `--push`.

## Notes / Gotchas

- If `current-theme.conf` changes often, treat it as “generated”; it’s still synced so your setup stays consistent.
- On Wayland, Kitty is a good default (works well with fractional scaling).
