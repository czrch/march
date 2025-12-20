#!/bin/bash
set -euo pipefail

: "${HOME:?HOME is not set}"

readonly ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly DOTFILES_DIR="$ROOT_DIR/dotfiles"
readonly DEFAULT_MANIFEST="$DOTFILES_DIR/manifest.tsv"

# Color output functions
if [[ -t 1 ]]; then
  color_red() { printf '\033[31m%s\033[0m\n' "$1"; }
  color_green() { printf '\033[32m%s\033[0m\n' "$1"; }
  color_yellow() { printf '\033[33m%s\033[0m\n' "$1"; }
  color_blue() { printf '\033[34m%s\033[0m\n' "$1"; }
else
  color_red() { printf '%s\n' "$1"; }
  color_green() { printf '%s\n' "$1"; }
  color_yellow() { printf '%s\n' "$1"; }
  color_blue() { printf '%s\n' "$1"; }
fi

usage() {
   cat <<'EOF'
Usage: dotfiles.sh [--push|--pull] [options] [-h|--help]

Sync tracked dotfiles between this repo and $HOME.

Modes (exactly one required unless using --list):
   --pull    Copy from $HOME -> repo (capture current dotfiles into the repo)
   --push    Copy from repo -> $HOME (apply repo dotfiles into your home dir)

Options:
   --manifest PATH Use a dotfiles manifest (default: dotfiles/manifest.tsv).
   --dry-run Show what would change; do not write files.
   --check   Show drift status and exit non-zero if differences exist.
   --list    Print the dotfiles manifest and exit (no mode required).
   --yes     Assume "yes" for all confirmations (non-interactive safe).
   --backup      Backup destination files before overwriting (default: on for --push).
   --no-backup   Disable backups.
   --backup-dir DIR  Where to place backups (default: $XDG_DATA_HOME/march/backups/<timestamp>).
   -h, --help Show this help.

Side effects:
   - Creates destination directories as needed.
   - Prompts before each change unless --yes is provided.
   - Overwrites destination files (optionally backed up).
   - Directory entries are synced recursively (extra destination files are left untouched).
   - Uses cp -a (files) and rsync -a (directories) to preserve permissions and symlinks.

Examples:
   ./scripts/dotfiles.sh --pull
   ./scripts/dotfiles.sh --push
   ./scripts/dotfiles.sh --push --dry-run
   ./scripts/dotfiles.sh --push --check
   ./scripts/dotfiles.sh --list
EOF
}

MODE=""
MANIFEST="$DEFAULT_MANIFEST"
DRY_RUN=0
CHECK=0
LIST=0
YES=0
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
    -y|--yes) YES=1; shift ;;
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

if [[ "$YES" -eq 0 && "$CHECK" -eq 0 && "$DRY_RUN" -eq 0 ]]; then
  if [[ ! -t 0 ]]; then
    echo "Refusing to run without confirmations in non-interactive mode; pass --yes to proceed." >&2
    exit 1
  fi
fi

if [[ -z "$BACKUP" ]]; then
  if [[ "$MODE" == "push" ]]; then
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
  if [[ "$dst" != "$HOME/"* ]]; then
    return 0
  fi
  if [[ ! -e "$dst" && ! -L "$dst" ]]; then
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

have_rsync() {
  command -v rsync >/dev/null 2>&1
}

paths_match() {
  local src="$1"
  local dst="$2"

  if [[ -L "$src" ]]; then
    [[ -L "$dst" ]] || return 1
    [[ "$(readlink "$src")" == "$(readlink "$dst")" ]] || return 1
    return 0
  fi

  if [[ -f "$src" ]]; then
    [[ -f "$dst" ]] || return 1
    cmp -s -- "$src" "$dst"
    return $?
  fi

  if [[ -d "$src" ]]; then
    [[ -d "$dst" ]] || return 1
    # For directory entries, we treat the source as authoritative but do not
    # consider extra files in the destination to be drift.
    while IFS= read -r -d '' src_item; do
      local rel="${src_item#"$src"/}"
      local dst_item="$dst/$rel"

      if [[ -L "$src_item" ]]; then
        [[ -L "$dst_item" ]] || return 1
        [[ "$(readlink "$src_item")" == "$(readlink "$dst_item")" ]] || return 1
        continue
      fi

      [[ -f "$src_item" ]] || return 1
      [[ -f "$dst_item" ]] || return 1
      cmp -s -- "$src_item" "$dst_item" || return 1
    done < <(find "$src" \( -type f -o -type l \) ! -name '.gitkeep' -print0)
    return 0
  fi

  return 1
}

confirm_sync() {
  local src="$1"
  local dst="$2"

  if [[ "$YES" -eq 1 ]]; then
    return 0
  fi

  local kind="file"
  if [[ -d "$src" ]]; then
    kind="dir"
  elif [[ -L "$src" ]]; then
    kind="symlink"
  fi

  local verb="copy"
  if [[ -e "$dst" || -L "$dst" ]]; then
    verb="update"
  fi

  local reply=""
  # Explicitly read from terminal and write prompt to stderr
  read -r -p "You are about to $verb $kind: $src -> $dst. Continue? [y/N] " reply </dev/tty >/dev/tty 2>&1
  case "$reply" in
    y|Y|yes|YES) return 0 ;;
    *) return 1 ;;
  esac
}

sync_entry() {
  local repo_rel="$1"
  local home_rel="$2"

  local home_path="$home_rel"
  if [[ "$home_path" != /* ]]; then
    home_path="$HOME/$home_path"
  fi

  local src dst
  if [[ "$MODE" == "pull" ]]; then
    src="$home_path"
    dst="$DOTFILES_DIR/$repo_rel"
  else
    src="$DOTFILES_DIR/$repo_rel"
    dst="$home_path"
  fi

  if [[ ! -e "$src" && ! -L "$src" ]]; then
    color_yellow "Skip missing source: $src"
    return 0
  fi

  if [[ "$CHECK" -eq 1 ]]; then
    if [[ ! -e "$dst" && ! -L "$dst" ]]; then
      color_red "MISSING_DST $dst"
      return 1
    fi
    if paths_match "$src" "$dst"; then
      color_green "OK $dst"
      return 0
    fi
    color_yellow "DIFF $dst"
    return 1
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    if [[ ! -e "$dst" && ! -L "$dst" ]]; then
      color_blue "Would copy $src -> $dst"
    elif ! paths_match "$src" "$dst"; then
      color_blue "Would update $dst from $src"
    fi
    return 0
  fi

  if [[ -e "$dst" || -L "$dst" ]]; then
    if paths_match "$src" "$dst"; then
      color_green "Up-to-date: $dst"
      return 0
    fi
  fi

  if ! confirm_sync "$src" "$dst"; then
    color_yellow "Skipped by user: $dst"
    return 0
  fi

  if [[ "$MODE" == "push" ]]; then
    backup_file "$dst"
  fi

  mkdir -p "$(dirname "$dst")"
  if [[ -d "$src" ]]; then
    if [[ -e "$dst" && ! -d "$dst" ]]; then
      color_red "Destination exists but is not a directory: $dst"
      return 1
    fi
    if ! have_rsync; then
      color_red "rsync is required to sync directory entries (missing on PATH)."
      return 1
    fi
    mkdir -p "$dst"
    rsync -a --exclude='.gitkeep' -- "$src/" "$dst/"
    color_green "Synced dir $src -> $dst"
    ((synced_count++))
    return 0
  fi

  if [[ -d "$dst" ]]; then
    color_red "Destination exists but is a directory: $dst"
    return 1
  fi
  cp -a -- "$src" "$dst"
  color_green "Synced $src -> $dst"
  ((synced_count++))
}

had_diff=0
total_entries=0
processed_entries=0
synced_count=0

# Count total entries first
while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  [[ "$line" =~ ^[[:space:]]*# ]] && continue
  ((total_entries++))
done < "$MANIFEST"

while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  [[ "$line" =~ ^[[:space:]]*# ]] && continue

  repo_rel=""
  home_rel=""
  read -r repo_rel home_rel _rest <<<"$line"
  if [[ -z "$repo_rel" || -z "$home_rel" ]]; then
    color_red "Invalid manifest line (expected: <repo_rel> <home_rel>): $line"
    exit 1
  fi

  ((processed_entries++))
  if [[ "$DRY_RUN" -eq 0 && "$CHECK" -eq 0 ]]; then
    echo "Processing $processed_entries/$total_entries: $home_rel"
  fi

  if ! sync_entry "$repo_rel" "$home_rel"; then
    had_diff=1
  fi
done < "$MANIFEST"

if [[ "$DRY_RUN" -eq 0 && "$CHECK" -eq 0 ]]; then
  color_green "Sync complete: $processed_entries entries processed."
  if [[ $synced_count -eq 0 ]]; then
    color_yellow "No files were synced (all up-to-date, sources missing, or skipped by user)."
  fi
fi

if [[ "$CHECK" -eq 1 && "$had_diff" -ne 0 ]]; then
  exit 1
fi
