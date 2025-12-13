#!/bin/bash
set -euo pipefail

: "${HOME:?HOME is not set}"

readonly ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly DOTFILES_DIR="$ROOT_DIR/dotfiles"
readonly DEFAULT_MANIFEST="$DOTFILES_DIR/manifest.tsv"

usage() {
  cat <<EOF
Usage: $(basename "$0") [--push|--pull] [options] [-h|--help]

Sync tracked dotfiles between this repo and \$HOME.

Modes (exactly one required unless using --list):
  --push    Copy from \$HOME -> repo (capture current dotfiles)
  --pull    Copy from repo -> \$HOME (apply repo dotfiles)

Options:
  --manifest PATH Use a dotfiles manifest (default: $DEFAULT_MANIFEST).
  --dry-run Show what would change; do not write files.
  --check   Show drift status and exit non-zero if differences exist.
  --list    Print the dotfiles manifest and exit (no mode required).
  --backup      Backup destination files before overwriting (default: on for --pull).
  --no-backup   Disable backups.
  --backup-dir DIR  Where to place backups (default: \$XDG_DATA_HOME/march/backups/<timestamp>).
  -h, --help Show this help.

Side effects:
  - Creates destination directories as needed.
  - Overwrites destination files without prompting (optionally backed up).
  - Uses cp -a to preserve permissions and symlinks.

Examples:
  ./scripts/sync-dotfiles.sh --push
  ./scripts/sync-dotfiles.sh --pull
  ./scripts/sync-dotfiles.sh --pull --dry-run
  ./scripts/sync-dotfiles.sh --pull --check
  ./scripts/sync-dotfiles.sh --list
EOF
}

MODE=""
MANIFEST="$DEFAULT_MANIFEST"
DRY_RUN=0
CHECK=0
LIST=0
BACKUP=""
BACKUP_DIR=""
BACKUP_NOTICE_PRINTED=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --push|--pull)
      if [[ -n "$MODE" ]]; then
        echo "Only one of --push or --pull may be specified." >&2
        usage
        exit 1
      fi
      MODE="${1#--}"
      shift
      ;;
    --manifest)
      shift
      if [[ -z "${1:-}" ]]; then
        echo "--manifest requires a PATH." >&2
        usage
        exit 1
      fi
      MANIFEST="$1"
      shift
      ;;
    --dry-run) DRY_RUN=1; shift ;;
    --check) CHECK=1; shift ;;
    --list) LIST=1; shift ;;
    --backup) BACKUP="1"; shift ;;
    --no-backup) BACKUP="0"; shift ;;
    --backup-dir)
      shift
      if [[ -z "${1:-}" ]]; then
        echo "--backup-dir requires a DIR." >&2
        usage
        exit 1
      fi
      BACKUP_DIR="$1"
      shift
      ;;
    -h|--help) usage; exit 0 ;;
    *)
      echo "Unknown arg: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ "$LIST" -eq 1 ]]; then
  if [[ ! -f "$MANIFEST" ]]; then
    echo "Manifest not found: $MANIFEST" >&2
    exit 1
  fi
  cat "$MANIFEST"
  exit 0
fi

if [[ -z "$MODE" ]]; then
  usage
  exit 1
fi

if [[ "$CHECK" -eq 1 && "$DRY_RUN" -eq 1 ]]; then
  echo "Only one of --check or --dry-run may be specified." >&2
  usage
  exit 1
fi

if [[ ! -f "$MANIFEST" ]]; then
  echo "Manifest not found: $MANIFEST" >&2
  exit 1
fi

if [[ -z "$BACKUP" ]]; then
  if [[ "$MODE" == "pull" ]]; then
    BACKUP="1"
  else
    BACKUP="0"
  fi
fi

default_backup_dir() {
  local base="${XDG_DATA_HOME:-$HOME/.local/share}/march/backups"
  local ts
  ts="$(date +%Y%m%d-%H%M%S)"
  echo "$base/$ts"
}

backup_file() {
  local dst="$1"
  if [[ "$BACKUP" != "1" ]]; then
    return 0
  fi
  if [[ ! -f "$dst" ]]; then
    return 0
  fi
  if [[ -z "$BACKUP_DIR" ]]; then
    BACKUP_DIR="$(default_backup_dir)"
  fi
  if [[ "$BACKUP_NOTICE_PRINTED" -eq 0 ]]; then
    echo "Backups: $BACKUP_DIR"
    BACKUP_NOTICE_PRINTED=1
  fi
  local backup_path="$BACKUP_DIR${dst#"$HOME"}"
  mkdir -p "$(dirname "$backup_path")"
  cp -a -- "$dst" "$backup_path"
}

sync_entry() {
  local repo_rel="$1"
  local home_rel="$2"

  local home_path="$home_rel"
  if [[ "$home_path" != /* ]]; then
    home_path="$HOME/$home_path"
  fi

  local src dst
  if [[ "$MODE" == "push" ]]; then
    src="$home_path"
    dst="$DOTFILES_DIR/$repo_rel"
  else
    src="$DOTFILES_DIR/$repo_rel"
    dst="$home_path"
  fi

  if [[ ! -f "$src" ]]; then
    echo "Skip missing source: $src"
    return 0
  fi

  if [[ "$CHECK" -eq 1 ]]; then
    if [[ ! -f "$dst" ]]; then
      echo "MISSING_DST $dst"
      return 1
    fi
    if cmp -s "$src" "$dst"; then
      echo "OK $dst"
      return 0
    fi
    echo "DIFF $dst"
    return 1
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    if [[ ! -f "$dst" ]]; then
      echo "Would copy $src -> $dst"
    elif ! cmp -s "$src" "$dst"; then
      echo "Would update $dst from $src"
    fi
    return 0
  fi

  if [[ "$MODE" == "pull" ]]; then
    backup_file "$dst"
  fi

  mkdir -p "$(dirname "$dst")"
  cp -a -- "$src" "$dst"
  echo "Synced $src -> $dst"
}

had_diff=0
while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  [[ "$line" =~ ^[[:space:]]*# ]] && continue

  repo_rel=""
  home_rel=""
  read -r repo_rel home_rel _rest <<<"$line"
  if [[ -z "$repo_rel" || -z "$home_rel" ]]; then
    echo "Invalid manifest line (expected: <repo_rel> <home_rel>): $line" >&2
    exit 1
  fi

  if ! sync_entry "$repo_rel" "$home_rel"; then
    had_diff=1
  fi
done < "$MANIFEST"

if [[ "$CHECK" -eq 1 && "$had_diff" -ne 0 ]]; then
  exit 1
fi
