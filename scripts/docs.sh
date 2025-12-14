#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./scripts/docs.sh <command> [args...]

Commands:
  sync            Create/update the local virtualenv from pyproject.toml (runs: uv sync)
  serve           Run the docs server locally (runs: uv run mkdocs serve)
  build           Build the static site into ./site/ (runs: uv run mkdocs build)
  clean           Remove build artifacts (./site and ./.mkdocs_cache)
  help            Show this help

Notes:
  - Requires 'uv' on PATH.
  - The first 'sync' will generate uv.lock; committing it is recommended for reproducible installs.

Examples:
  ./scripts/docs.sh sync
  ./scripts/docs.sh serve
  ./scripts/docs.sh build
EOF
}

need_uv() {
  if ! command -v uv >/dev/null 2>&1; then
    echo "error: 'uv' not found on PATH" >&2
    echo "hint: install it (e.g. 'sudo pacman -S uv') and try again" >&2
    exit 1
  fi
}

cmd="${1:-help}"
shift || true

case "$cmd" in
  -h|--help|help)
    usage
    ;;
  sync)
    need_uv
    uv sync "$@"
    ;;
  serve)
    need_uv
    uv run mkdocs serve "$@"
    ;;
  build)
    need_uv
    uv run mkdocs build --strict "$@"
    ;;
  clean)
    rm -rf site .mkdocs_cache
    ;;
  *)
    echo "error: unknown command: $cmd" >&2
    echo >&2
    usage >&2
    exit 2
    ;;
esac

