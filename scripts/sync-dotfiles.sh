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
  zsh/.zshrc               <-> ~/.zshrc
  kitty/kitty.conf         <-> ~/.config/kitty/kitty.conf
  kitty/current-theme.conf <-> ~/.config/kitty/current-theme.conf
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
  local home_path="$2"
  local src dst
  if [[ "$MODE" == "push" ]]; then
    src="$home_path"
    dst="$DOTFILES_DIR/$rel"
  else
    src="$DOTFILES_DIR/$rel"
    dst="$home_path"
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

sync_file "zsh/.zshrc" "$HOME/.zshrc"
sync_file "kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
sync_file "kitty/current-theme.conf" "$HOME/.config/kitty/current-theme.conf"

