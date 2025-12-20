#!/bin/bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: packages.sh <command> [options] [-h|--help]

Manage system packages and services for Arch Linux.

Commands:
  export     Export current system state (packages + services) to state/
  install    Install packages from exported state files

Options:
  --state-dir DIR     Override the repo state dir (default: <repo>/state)
  --aur-helper NAME   AUR helper to use: yay|paru (default: yay if present, else paru)
  --no-aur            Skip AUR packages during install
  --dry-run           Show what would be done; do not modify system
  --noconfirm         Pass --noconfirm to pacman (non-interactive)
  --help              Show this help

Requirements:
  - Arch Linux with pacman installed
  - systemd with systemctl for service export
  - AUR helper (yay/paru) for AUR package installation

Examples:
  ./scripts/packages.sh export
  ./scripts/packages.sh install --dry-run
  ./scripts/packages.sh install --aur-helper paru
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
readonly SERVICES_FILE="$STATE_DIR/services-enabled.txt"

export_packages() {
  if ! command -v pacman >/dev/null 2>&1; then
    echo "error: pacman not found on PATH" >&2
    echo "hint: this script is designed for Arch Linux systems with pacman installed" >&2
    exit 1
  fi
  mkdir -p "$PACKAGES_DIR"
  pacman -Qqen > "$PACMAN_FILE"
  pacman -Qqem > "$AUR_FILE"
  echo "Exported packages to:"
  echo "  $PACMAN_FILE ($(wc -l < "$PACMAN_FILE") packages)"
  echo "  $AUR_FILE ($(wc -l < "$AUR_FILE") packages)"
}

export_services() {
  if ! command -v systemctl >/dev/null 2>&1; then
    echo "error: systemctl not found on PATH" >&2
    echo "hint: this script requires systemd" >&2
    exit 1
  fi
  mkdir -p "$STATE_DIR"
  systemctl list-unit-files --state=enabled --no-legend --no-pager \
    | awk '{print $1}' \
    | sed '/^$/d' \
    | sort -u > "$SERVICES_FILE"
  echo "Exported services to:"
  echo "  $SERVICES_FILE ($(wc -l < "$SERVICES_FILE") services)"
}

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
    echo "error: pacman not found on PATH" >&2
    echo "hint: this script is designed for Arch Linux systems" >&2
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
    echo "error: no AUR helper found" >&2
    echo "hint: install yay or paru, or pass --no-aur to skip AUR packages" >&2
    exit 1
  fi
  if [[ "$helper" != "yay" && "$helper" != "paru" ]]; then
    echo "error: unsupported AUR helper: $helper (expected: yay|paru)" >&2
    exit 1
  fi

  run_batches 200 "$AUR_FILE" "$helper" -S
}

case "$command" in
  export)
    export_packages
    export_services
    echo "Export complete."
    ;;
  install)
    install_pacman
    install_aur
    ;;
  *)
    echo "Unknown command: $command" >&2
    usage
    exit 1
    ;;
esac