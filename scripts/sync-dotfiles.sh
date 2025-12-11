#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOTFILES_DIR="$ROOT_DIR/dotfiles"

usage() {
  cat <<EOF
Usage: $(basename "$0") [--push|--pull] [--dry-run]

--push    Copy from \$HOME -> repo (update tracked dotfiles)
--pull    Copy from repo -> \$HOME (apply tracked dotfiles)
--dry-run Show what would change

Currently synced:
  zsh/.zshrc
EOF
}

MODE=""
DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    --push) MODE="push" ;;
    --pull) MODE="pull" ;;
    --dry-run) DRY_RUN=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $arg"; usage; exit 1 ;;
  esac
done

if [[ -z "$MODE" ]]; then
  usage
  exit 1
fi

sync_file() {
  local rel="$1"
  local src dst
  if [[ "$MODE" == "push" ]]; then
    src="$HOME/.${rel##*/}"
    dst="$DOTFILES_DIR/$rel"
  else
    src="$DOTFILES_DIR/$rel"
    dst="$HOME/.${rel##*/}"
  fi

  if [[ ! -f "$src" ]]; then
    echo "Skip missing source: $src"
    return 0
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    if [[ ! -f "$dst" ]]; then
      echo "Would copy $src -> $dst"
    elif ! cmp -s "$src" "$dst"; then
      echo "Would update $dst from $src"
    fi
    return 0
  fi

  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  echo "Synced $src -> $dst"
}

sync_file "zsh/.zshrc"

