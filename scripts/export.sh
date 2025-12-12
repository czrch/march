#!/bin/bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: export.sh <command> [-h|--help]

Export current Arch Linux system state into `state/`.

Commands:
  all       Export packages and enabled services (default target).
  packages  Export explicitly installed packages.
  services  Export enabled systemd services.

Outputs (overwritten on each run):
  packages:
    - state/packages/pacman-explicit.txt
    - state/packages/aur-explicit.txt
  services:
    - state/services-enabled.txt

Requirements:
  - Arch Linux with `pacman` installed for package export.
  - systemd with `systemctl` available for service export.

Examples:
  ./scripts/export.sh all
  ./scripts/export.sh packages
  ./scripts/export.sh services
EOF
}

if [[ $# -eq 0 || "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

command="$1"
shift

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -ne 0 ]]; then
  echo "Unknown args: $*" >&2
  usage
  exit 1
fi

readonly ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly STATE_DIR="$ROOT_DIR/state"
readonly PACKAGES_DIR="$STATE_DIR/packages"

export_packages() {
  if ! command -v pacman >/dev/null 2>&1; then
    echo "pacman not found; package export requires Arch Linux." >&2
    exit 1
  fi
  mkdir -p "$PACKAGES_DIR"
  pacman -Qqe > "$PACKAGES_DIR/pacman-explicit.txt"
  pacman -Qqem > "$PACKAGES_DIR/aur-explicit.txt"
  echo "Wrote:"
  echo "  $PACKAGES_DIR/pacman-explicit.txt"
  echo "  $PACKAGES_DIR/aur-explicit.txt"
}

export_services() {
  if ! command -v systemctl >/dev/null 2>&1; then
    echo "systemctl not found; service export requires systemd." >&2
    exit 1
  fi
  mkdir -p "$STATE_DIR"
  systemctl list-unit-files --state=enabled --no-pager > "$STATE_DIR/services-enabled.txt"
  echo "Wrote:"
  echo "  $STATE_DIR/services-enabled.txt"
}

case "$command" in
  all)
    export_packages
    export_services
    echo "Export complete."
    ;;
  packages)
    export_packages
    ;;
  services)
    export_services
    ;;
  *)
    echo "Unknown command: $command" >&2
    usage
    exit 1
    ;;
esac

