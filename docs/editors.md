# Editors

## VSCodium

[VSCodium](https://vscodium.com/) is a community-driven, freely-licensed binary distribution of Microsoft's VS Code editor.

**Key differences from VS Code:**
- No telemetry, tracking, or proprietary licensing
- Uses Open VSX Registry instead of Microsoft's marketplace
- Same features, UI, and functionality as VS Code
- 100% open source

### Installation

Install from AUR:

```bash
yay -S vscodium-bin
```

Or the source build (slower):

```bash
yay -S vscodium
```

### Features

- **IntelliSense**: Smart code completion and suggestions
- **Debugging**: Built-in debugger for multiple languages
- **Git Integration**: Source control management built-in
- **Extensions**: Thousands of extensions via Open VSX
- **Terminal**: Integrated terminal with shell support
- **Multi-cursor**: Edit multiple locations simultaneously
- **Vim mode**: Available via extension (vscodevim.vim)

### Tracked Configuration

This repo tracks essential VSCodium configs in `dotfiles/vscodium/`:

| File | Purpose |
|------|---------|
| `settings.json` | User settings (theme, fonts, editor behavior) |
| `extensions.txt` | List of installed extensions |

### Syncing Config

Pull current config into repo:

```bash
./scripts/sync-dotfiles.sh --pull
```

Apply repo config to system:

```bash
./scripts/sync-dotfiles.sh --push
```

### Installing Extensions

After syncing to a new machine, install all tracked extensions:

```bash
cat dotfiles/vscodium/extensions.txt | xargs -I {} codium --install-extension {}
```

Or install selectively:

```bash
codium --install-extension <extension-id>
```

### Useful Extensions

Some extensions tracked in this setup:

- **vscodevim.vim** - Vim keybindings
- **pkief.material-icon-theme** - Material Design icons
- **usernamehw.errorlens** - Inline error highlighting
- **mhutchie.git-graph** - Visual git history
- **saoudrizwan.claude-dev** - AI coding assistant (Cline)
- **dbaeumer.vscode-eslint** - JavaScript/TypeScript linting
- **llvm-vs-code-extensions.vscode-clangd** - C/C++ language server
- **ms-python.python** - Python development tools

### Command Line Usage

Launch VSCodium:

```bash
codium                    # Open VSCodium
codium /path/to/project   # Open specific directory
codium file.txt           # Open specific file
```

Manage extensions:

```bash
codium --list-extensions              # List installed
codium --install-extension <id>       # Install extension
codium --uninstall-extension <id>     # Remove extension
```

### Tips

- **Settings Sync**: Not recommended - use this repo's dotfile sync instead
- **Keybindings**: Access via `Ctrl+K Ctrl+S` or track in `keybindings.json`
- **Command Palette**: `Ctrl+Shift+P` for all commands
- **Quick Open**: `Ctrl+P` for file navigation
- **Integrated Terminal**: `` Ctrl+` `` to toggle