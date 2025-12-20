<INSTRUCTIONS>
# scripts/

This directory contains small helpers for exporting, syncing, applying repo state, and serving the docs site.

## Script standards

- Every script must provide clear, detailed help for users.
  - Support `-h`/`--help` (and/or a `help` subcommand for multi‑command scripts).
  - Describe purpose, inputs, outputs, side effects, and examples.
  - Fail fast on invalid args and point users to `--help`.

- Prefer modern, safe programming techniques and tooling.
  - Use strict modes where relevant (e.g., `set -euo pipefail` in bash).
  - Quote variables, avoid word‑splitting/globbing surprises, and handle errors explicitly.
  - Keep dependencies minimal and documented.

- Value simplicity.
  - Favor small, readable scripts over clever abstractions.
  - Keep behavior obvious and predictable.
  - If a script grows complex, consider splitting or documenting the rationale.

- Dotfiles manifest format requirements:
  - `dotfiles/manifest.tsv` is tab-separated: `<repo_rel>\t<home_rel>`.
  - Use tabs to allow paths with spaces; whitespace-only separation is legacy and should be avoided.

</INSTRUCTIONS>
