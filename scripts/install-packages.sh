#!/bin/bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: install-packages.sh <command> [options] [-h|--help]

Install packages based on files exported into `state/` by `./scripts/export.sh packages`.

Commands:
  all     Install pacman + AUR packages.
  pacman  Install repo packages from state/packages/pacman-explicit.txt.
  aur     Install AUR packages from state/packages/aur-explicit.txt.

Options:
  --state-dir DIR     Override the repo state dir (default: <repo>/state).
  --aur-helper NAME   AUR helper to use: yay|paru (default: yay if present, else paru).
  --no-aur            Skip AUR install (useful with `all`).
  --dry-run           Print the commands that would run; do not install anything.
  --noconfirm         Pass --noconfirm to the installer (non-interactive).

Notes:
  - `pacman` installs require sudo.
  - This script does not install an AUR helper for you.

Examples:
  ./scripts/export.sh packages
  ./scripts/install-packages.sh all --dry-run
  ./scripts/install-packages.sh pacman
  ./scripts/install-packages.sh aur --aur-helper yay
EOF
}

if [[ $# -eq 0 || "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

command="$1"
shift

readonly ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_DIR="$ROOT_DIR/state"
DRY_RUN=0
NO_CONFIRM=0
NO_AUR=0
AUR_HELPER=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --state-dir)
      shift
      if [[ -z "${1:-}" ]]; then
        echo "--state-dir requires a DIR." >&2
        usage
        exit 1
      fi
      STATE_DIR="$1"
      shift
      ;;
    --aur-helper)
      shift
      if [[ -z "${1:-}" ]]; then
        echo "--aur-helper requires a NAME (yay|paru)." >&2
        usage
        exit 1
      fi
      AUR_HELPER="$1"
      shift
      ;;
    --no-aur) NO_AUR=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    --noconfirm) NO_CONFIRM=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *)
      echo "Unknown arg: $1" >&2
      usage
      exit 1
      ;;
  esac
done

readonly PACKAGES_DIR="$STATE_DIR/packages"
readonly PACMAN_FILE="$PACKAGES_DIR/pacman-explicit.txt"
readonly AUR_FILE="$PACKAGES_DIR/aur-explicit.txt"

read_list_file() {
  local path="$1"
  local -n out="$2"
  out=()
  if [[ ! -f "$path" ]]; then
    echo "Missing file: $path" >&2
    return 1
  fi
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    out+=("$line")
  done < "$path"
}

run_batches() {
  local batch_size="$1"
  local items_file="$2"
  shift 2

  local -a prefix=("$@")
  local -a items=()
  read_list_file "$items_file" items

  if [[ "${#items[@]}" -eq 0 ]]; then
    echo "Nothing to install from: $items_file"
    return 0
  fi

  local -a extra=()
  if [[ "$NO_CONFIRM" -eq 1 ]]; then
    extra+=(--noconfirm)
  fi

  local i=0
  while [[ "$i" -lt "${#items[@]}" ]]; do
    local -a chunk=("${items[@]:i:batch_size}")
    i=$((i + batch_size))

    local -a cmd=("${prefix[@]}")
    cmd+=("${extra[@]}")
    cmd+=(--needed --)
    cmd+=("${chunk[@]}")

    if [[ "$DRY_RUN" -eq 1 ]]; then
      printf 'DRY_RUN:'
      printf ' %q' "${cmd[@]}"
      printf '\n'
    else
      "${cmd[@]}"
    fi
  done
}

choose_aur_helper() {
  if [[ -n "$AUR_HELPER" ]]; then
    echo "$AUR_HELPER"
    return 0
  fi
  if command -v yay >/dev/null 2>&1; then
    echo "yay"
    return 0
  fi
  if command -v paru >/dev/null 2>&1; then
    echo "paru"
    return 0
  fi
  echo ""
}

install_pacman() {
  if ! command -v pacman >/dev/null 2>&1; then
    echo "pacman not found; this is intended for Arch Linux." >&2
    exit 1
  fi
  run_batches 200 "$PACMAN_FILE" sudo pacman -S
}

install_aur() {
  if [[ "$NO_AUR" -eq 1 ]]; then
    return 0
  fi

  local helper
  helper="$(choose_aur_helper)"
  if [[ -z "$helper" ]]; then
    echo "No AUR helper found. Install yay/paru first, or pass --no-aur." >&2
    exit 1
  fi
  if [[ "$helper" != "yay" && "$helper" != "paru" ]]; then
    echo "Unsupported AUR helper: $helper (expected: yay|paru)" >&2
    exit 1
  fi

  run_batches 200 "$AUR_FILE" "$helper" -S
}

case "$command" in
  all)
    install_pacman
    install_aur
    ;;
  pacman)
    install_pacman
    ;;
  aur)
    install_aur
    ;;
  *)
    echo "Unknown command: $command" >&2
    usage
    exit 1
    ;;
esac
