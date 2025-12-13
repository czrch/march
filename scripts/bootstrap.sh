#!/bin/bash
set -euo pipefail

: "${HOME:?HOME is not set}"

readonly ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly DOTFILES_MANIFEST_DEFAULT="$ROOT_DIR/dotfiles/manifest.tsv"

usage() {
  cat <<'EOF'
Usage: bootstrap.sh <command> [options] [-h|--help]

Convenience entrypoint for setting up this repo on a fresh machine.

Commands:
  dotfiles   Apply repo dotfiles to $HOME (delegates to sync-dotfiles.sh --pull)
  packages   Install packages from `state/` (delegates to install-packages.sh all)
  export     Export current system state into state/ (delegates to export.sh all)

Options:
  --dry-run  Supported by dotfiles/packages (passes through).

Examples:
  ./scripts/bootstrap.sh dotfiles
  ./scripts/bootstrap.sh dotfiles --dry-run
  ./scripts/bootstrap.sh packages --dry-run
  ./scripts/bootstrap.sh export

Notes:
  - This repo’s source-of-truth dotfiles live in `dotfiles/` and are mapped in:
      dotfiles/manifest.tsv
EOF
}

if [[ $# -eq 0 || "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

command="$1"
shift

case "$command" in
  dotfiles)
    if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
      usage
      exit 0
    fi
    exec "$ROOT_DIR/scripts/sync-dotfiles.sh" --pull --manifest "$DOTFILES_MANIFEST_DEFAULT" "$@"
    ;;
  packages)
    if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
      exec "$ROOT_DIR/scripts/install-packages.sh" --help
    fi
    exec "$ROOT_DIR/scripts/install-packages.sh" all "$@"
    ;;
  export)
    if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
      usage
      exit 0
    fi
    exec "$ROOT_DIR/scripts/export.sh" all
    ;;
  *)
    echo "Unknown command: $command" >&2
    usage
    exit 1
    ;;
esac
