#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$SCRIPT_DIR/export-packages.sh"
"$SCRIPT_DIR/export-services.sh"

echo "Export complete."

