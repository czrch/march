#!/bin/bash
set -euo pipefail

# Back-compat wrapper. Prefer scripts/sync-dotfiles.sh.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/sync-dotfiles.sh" --push "$@"
