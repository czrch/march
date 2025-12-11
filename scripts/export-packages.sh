#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_DIR="$ROOT_DIR/state/packages"

mkdir -p "$STATE_DIR"

pacman -Qqe > "$STATE_DIR/pacman-explicit.txt"
pacman -Qqem > "$STATE_DIR/aur-explicit.txt"

echo "Wrote:"
echo "  $STATE_DIR/pacman-explicit.txt"
echo "  $STATE_DIR/aur-explicit.txt"

