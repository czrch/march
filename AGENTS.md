# march

Personal Arch Linux setup notebook + toolbox.

This repo is meant to be a lightweight, version‑controlled reference for:

- **Docs**: guides/checklists for apps, tweaks, settings, and hardware quirks.
- **Dotfiles**: canonical configs you want to keep and re‑apply.
- **State**: exported lists of packages/services/settings to speed reinstalls.
- **Scripts**: small helpers to sync/export/apply the above.

## Structure

- `README.md` — short entrypoint.
- `docs/` — MkDocs pages (currently just an index + pacman/yay helpers).
- `dotfiles/` — tracked config files, organized by tool.
- `state/` — auto‑generated exports (safe to delete/rebuild).
- `scripts/` — utilities for exporting and syncing.
- `mkdocs.yml` — MkDocs site config.
- `pyproject.toml` / `uv.lock` — Python docs tooling (uv).

## Usage

- Export current system state into `state/`:
  - `./scripts/export.sh all`
- Sync tracked dotfiles from `$HOME` into the repo:
  - `./scripts/sync-dotfiles.sh --pull`
- Apply dotfiles from the repo into `$HOME`:
  - `./scripts/sync-dotfiles.sh --push`

- Work on the docs site locally:
  - `./scripts/docs.sh sync`
  - `./scripts/docs.sh serve`

Keep things simple: add docs or dotfiles whenever you change your setup, and re‑export state after major updates.
