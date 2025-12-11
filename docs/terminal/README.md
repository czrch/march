# 🚀 Modern Zsh Setup

> A blazingly fast, feature-rich terminal configuration powered by Zinit

<br>

## ✨ What You Get

```
Smart completions        200K command history
Fuzzy finding (FZF)      Instant directory jumps (zoxide)
Syntax highlighting      Fish-like autosuggestions
Beautiful prompt         Auto Python venv
Lazy-loaded NVM          Auto-pairs brackets
Forgit integration       Command suggestions
```

<br>

## Quick Install

```bash
# Arch Linux - Core tools
sudo pacman -S zsh eza bat ripgrep fd fzf starship zoxide \
  direnv pkgfile atuin git-delta duf dust btop procs

# Zinit (plugin manager) auto-installs on first run
# Then copy the config
./sync-zshrc.sh
```

<br>

## ⚡ Power Commands

| Command | What it does |
|---------|--------------|
| `Ctrl+R` | Search history (Atuin) |
| `Ctrl+T` | Fuzzy find files (FZF) |
| `Alt+C` | Jump to folder (FZF) |
| `z <path>` | Smart cd (zoxide) |
| `zi` | Interactive zoxide |
| `zz` | Jump to previous dir |
| `gco` | Fuzzy git checkout |
| `gshow` | Fuzzy git show |
| `fe` | Fuzzy file edit |
| `fkill` | Fuzzy kill process |
| `extract file.zip` | Extract any archive |
| `mkcd dir` | Make & cd into dir |
| `update-all` | Update everything |

<br>

## Cool Aliases

```bash
ls      # → eza with icons & grouped dirs
ll      # → eza detailed list view
cat     # → bat (syntax highlighted)
grep    # → ripgrep (faster)
find    # → fd (faster)
df      # → duf (prettier)
du      # → dust (prettier)
top     # → btop (prettier)
ps      # → procs (prettier)
diff    # → delta (prettier)
..      # → cd ..
...     # → cd ../..
```

<br>

## Must-Have Tools

| Tool | Purpose |
|------|---------|
| **zinit** | Plugin manager (auto-installs) |
| **eza** | Better ls with icons |
| **bat** | Better cat with syntax |
| **fzf** | Fuzzy finder everywhere |
| **ripgrep** | Better grep (fast!) |
| **fd** | Better find (fast!) |
| **zoxide** | Smart cd with frecency |
| **starship** | Beautiful prompt |
| **atuin** | Enhanced history search |
| **direnv** | Auto-load env vars |
| **delta** | Better git diffs |
| **duf** | Better df |
| **dust** | Better du |
| **btop** | Better top |
| **procs** | Better ps |

<br>

## Bonus Features

### Core Features
- 🎯 Auto-complete with `Tab` (fuzzy, cached)
- 🔍 Case-insensitive completion
- ⬆️ Type any part of a command and press `↑` (substring search)
- 🐍 Python venv activates automatically on cd
- 📦 Lazy-loaded NVM (instant startup, loads on-demand)
- 🎨 Colored man pages
- 🔄 Auto-pairs brackets/quotes
- 📊 Smart command suggestions (you-should-use)

### Zinit Plugins
- `fast-syntax-highlighting` - Real-time syntax highlighting
- `zsh-autosuggestions` - Fish-like suggestions
- `zsh-completions` - Extra completions
- `zsh-history-substring-search` - Partial history search
- `zsh-autopair` - Auto-close brackets/quotes
- `fzf-tab` - FZF-powered completions
- `forgit` - Interactive git commands
- `sudo` - ESC×2 to add sudo
- `colored-man-pages` - Prettier man pages

### FZF Enhancements
- Preview files with `bat` or directory tree
- `Ctrl+/` to toggle preview
- `Ctrl+Y` to copy to clipboard
- Smart git checkout preview
- Directory navigation with live preview

<br>

## 🐛 Troubleshooting

**Completions broken?**
```bash
rm -rf ~/.cache/zsh/*
```

**Slow startup?**
```bash
# Check what's slow
zmodload zsh/zprof
# ... at top of .zshrc, then reload and check output
```

**Zinit not found?**
```bash
# Zinit auto-installs on first zsh startup
# Or manually:
git clone https://github.com/zdharma-continuum/zinit.git \
  ~/.local/share/zinit/zinit.git
```

**Command not found suggestions not working?**
```bash
sudo pacman -S pkgfile
sudo pkgfile --update
```

<br>

---

💡 **Tip:** Run `./sync-zshrc.sh` anytime to update this config
