#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_DIR="$ROOT_DIR/state"

mkdir -p "$STATE_DIR"

systemctl list-unit-files --state=enabled --no-pager > "$STATE_DIR/services-enabled.txt"

echo "Wrote:"
echo "  $STATE_DIR/services-enabled.txt"

