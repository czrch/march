# march

Personal Arch Linux setup notebook + toolbox.

This repo is meant to be a lightweight, version‑controlled reference for:

- **Docs**: guides/checklists for apps, tweaks, settings, and hardware quirks.
- **Dotfiles**: canonical configs you want to keep and re‑apply.
- **State**: exported lists of packages/services/settings to speed reinstalls.
- **Scripts**: small helpers to sync/export/apply the above.

## Structure

- `README.md` — quick global notes and links.
- `docs/` — topic guides (terminal, editors, tweaks, hardware, etc.).
- `dotfiles/` — tracked config files, organized by tool.
- `state/` — auto‑generated exports (safe to delete/rebuild).
- `scripts/` — utilities for exporting and syncing.

## Usage

- Export current system state into `state/`:
  - `./scripts/export-all.sh`
- Sync tracked dotfiles from `$HOME` into the repo:
  - `./scripts/sync-dotfiles.sh --push`
- Apply dotfiles from the repo into `$HOME`:
  - `./scripts/sync-dotfiles.sh --pull`

Keep things simple: add docs or dotfiles whenever you change your setup, and re‑export state after major updates.

