# 🖥️ Terminal Index

Terminal-related setup and configs.

## Guides

- `zsh.md` — shell, plugins, prompt, CLI tooling.
- `kitty.md` — terminal emulator, keybinds, theming.

## Quick Sync

```bash
# Apply repo dotfiles to your home dir (backs up overwritten files)
./scripts/bootstrap.sh dotfiles

# Preview changes first
./scripts/bootstrap.sh dotfiles --dry-run

# Apply without prompts
./scripts/bootstrap.sh dotfiles --yes

# Check whether home differs from repo (non-zero exit if drift exists)
./scripts/sync-dotfiles.sh --push --check

# Capture home dotfiles back into repo
./scripts/sync-dotfiles.sh --pull
```
