# 🚀 Modern Zsh Setup

> A blazingly fast, feature-rich terminal configuration

<br>

## ✨ What You Get

```
🎯 Smart completions        📚 200K command history
🔍 Fuzzy finding (FZF)      ⚡ Instant directory jumps  
🎨 Syntax highlighting      🐟 Fish-like suggestions
🌟 Beautiful prompt         🐍 Auto Python venv
```

<br>

## 📦 Quick Install

```bash
# Arch Linux (one-liner)
sudo pacman -S zsh eza bat ripgrep fd fzf starship zoxide \
  zsh-autosuggestions zsh-history-substring-search zsh-syntax-highlighting

# Then copy the config
./sync-zshrc.sh
```

<br>

## ⚡ Power Commands

| Command | What it does |
|---------|--------------|
| `Ctrl+R` | 🔍 Search history |
| `Ctrl+T` | 📁 Find files |
| `Alt+C` | 📂 Jump to folder |
| `z <path>` | 🎯 Smart cd |
| `gco` | 🌿 Fuzzy git branches |
| `extract file.zip` | 📦 Unzip anything |

<br>

## 🎨 Cool Aliases

```bash
ls      # → eza with icons
ll      # → detailed list view
cat     # → bat (syntax highlighted)
grep    # → ripgrep (faster)
..      # → cd ..
```

<br>

## 🔧 Must-Have Tools

| Tool | Purpose |
|------|---------|
| **eza** | Better ls |
| **bat** | Better cat |
| **fzf** | Fuzzy finder |
| **ripgrep** | Better grep |
| **zoxide** | Smart cd |
| **starship** | Pretty prompt |

<br>

## 🎁 Bonus Features

- ✅ Auto-complete with `Tab`
- ✅ Case-insensitive search
- ✅ Type any part of a command and press `↑`
- ✅ Python venv activates automatically
- ✅ Lazy-loaded Node.js (faster startup)

<br>

## 🐛 Fix Issues

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

<br>

---

💡 **Tip:** Run `./sync-zshrc.sh` anytime to update this config
