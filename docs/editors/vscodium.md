# 🎨 VSCodium

VSCodium is VS Code without Microsoft telemetry, branding, or license issues.

## Installation

**Precompiled (recommended):**
```bash
yay -S --needed vscodium-bin
```

**Or build from source:**
```bash
yay -S --needed vscodium
```

## Batch-Install Extensions

```bash
# --- AI / agents ---
exts_ai=(
  saoudrizwan.claude-dev
  openai.chatgpt
)

# --- Git / GitHub tooling ---
exts_git=(
  vscode.github
  vscode.github-authentication
  mhutchie.git-graph
)

# --- Markdown / docs ---
exts_docs=(
  yzhang.markdown-all-in-one
  DavidAnson.vscode-markdownlint
  vscode.markdown-math
)

# --- Editing / UX ---
exts_editing=(
  vscodevim.vim
  kisstkondoros.vscode-gutter-preview
  johnpapa.vscode-peacock
  ArthurLobo.easy-codesnap
)

# --- Debugging ---
exts_debug=(
  vscode.debug-auto-launch
)

# Install all (VSCodium)
for e in \
  "${exts_ai[@]}" \
  "${exts_git[@]}" \
  "${exts_docs[@]}" \
  "${exts_editing[@]}" \
  "${exts_debug[@]}"
do
  codium --install-extension "$e"
done
```

