# VSCodium Dotfiles

This directory tracks essential VSCodium configuration files.

## Files Tracked

- **settings.json**: User settings (themes, fonts, editor preferences)
- **extensions.txt**: List of installed extensions

## Usage

### Pull from system (capture current config)

```bash
./scripts/sync-dotfiles.sh --pull
```

This will:
- Copy `~/.config/VSCodium/User/settings.json` to repo
- Update `extensions.txt` with currently installed extensions

### Push to system (apply repo config)

```bash
./scripts/sync-dotfiles.sh --push
```

This will:
- Copy `settings.json` from repo to `~/.config/VSCodium/User/`
- Copy `extensions.txt` to your VSCodium config (for reference)

### Install extensions

After syncing, install all extensions from the list:

```bash
cat dotfiles/vscodium/extensions.txt | xargs -I {} codium --install-extension {}
```

Or manually review and install selectively.

## Notes

- Extensions are tracked as a text list (not synced by the script)
- Install extensions manually using the command above
- Settings are synced automatically by `sync-dotfiles.sh`
- Profiles directory is not tracked (workspace-specific)