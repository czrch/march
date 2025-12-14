# 🧰 Bootstrap / Reinstall Guide

This repo is designed to make “fresh install → your setup” fast and repeatable.

## What This Covers

- **Dotfiles**: apply the tracked configs in `dotfiles/` into `$HOME`.
- **State**: export package + service lists into `state/`.
- **Packages**: reinstall packages from `state/packages/`.

## Quickstart

### 1) Apply dotfiles (recommended)

```bash
./scripts/bootstrap.sh dotfiles
```

Preview changes first:

```bash
./scripts/bootstrap.sh dotfiles --dry-run
```

See what’s managed:

```bash
./scripts/sync-dotfiles.sh --list
```

Check drift (non-zero exit if differences exist):

```bash
./scripts/sync-dotfiles.sh --pull --check
```

### 2) Export system state

```bash
./scripts/bootstrap.sh export
```

Writes:
- `state/packages/pacman-explicit.txt`
- `state/packages/aur-explicit.txt`
- `state/services-enabled.txt`

### 3) Reinstall packages from `state/`

Dry run (prints the commands it would run):

```bash
./scripts/bootstrap.sh packages --dry-run
```

Install:

```bash
./scripts/bootstrap.sh packages
```

Requirements:
- `sudo` access (pacman installs)
- An AUR helper for AUR packages (`yay` or `paru`)

## Backups (dotfiles)

By default, `--pull` creates a timestamped backup of overwritten destination files:
- `$XDG_DATA_HOME/march/backups/<timestamp>/...` (or `~/.local/share/march/backups/...`)

Disable backups:

```bash
./scripts/sync-dotfiles.sh --pull --no-backup
```

## Adding a new dotfile

1. Add the file under `dotfiles/<tool>/...`
2. Add a mapping line to `dotfiles/manifest.tsv`:
   - format: `<repo_rel_path> <home_rel_path>`
3. Apply to home:

```bash
./scripts/bootstrap.sh dotfiles
```

## Notes / Gotchas

- `state/` is generated output; it’s safe to delete and re-export.
- `install-packages.sh` does not install `yay`/`paru` for you.

