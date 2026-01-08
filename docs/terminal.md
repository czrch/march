# Terminal

A curated collection of modern terminal emulators, shells, and utilities for a productive command-line experience on Arch Linux.

## Kitty

A GPU-accelerated terminal emulator written in C and Python that prioritizes performance and modern features. Kitty is designed for keyboard power users and offers native support for graphics, ligatures, image rendering, and advanced customization.

| | |
|---|---|
| **License** | GPLv3 |
| **Rendering** | GPU-accelerated OpenGL |
| **Key features** | Graphics protocol, ligatures, true color, scrollback, tiling layouts |
| **Use case** | Performance-focused development, image viewing, complex terminal layouts |

**Installation:**

```bash
# Binary package (recommended)
sudo pacman -S kitty

# Or from AUR
yay -S kitty-git
```

**Key features:**

- **GPU acceleration**: Uses hardware rendering for minimal latency and smooth scrolling
- **Tab and window management**: Built-in tiling window manager capabilities with multiple layout modes (stack, tall, fat, grid, and more)
- **Graphics protocol**: Display images directly in the terminal with [`kitty +kitten icat`](https://sw.kovidgoyal.net/kitty/kittens/icat/)
- **Ligatures & variable fonts**: Professional typography support with OpenType features
- **Shell integration**: Works seamlessly with bash, zsh, and fish for features like shell prompt jumping and command output browsing
- **Remote control**: Control kitty via [remote control protocol](https://sw.kovidgoyal.net/kitty/remote-control/) even over SSH

**Basic keyboard shortcuts:**

| Action | Shortcut |
|--------|----------|
| New tab | `Ctrl+Shift+T` |
| New window | `Ctrl+Shift+Enter` |
| Close tab/window | `Ctrl+Shift+Q` / `Ctrl+Shift+W` |
| Next tab | `Ctrl+Shift+Right` |
| Scroll up/down | `Ctrl+Shift+Up` / `Ctrl+Shift+Down` |
| Browse scrollback | `Ctrl+Shift+H` |

**Configuration:** Edit `~/.config/kitty/kitty.conf` or press `Ctrl+Shift+F2` in kitty to open the config file. See the [official configuration guide](https://sw.kovidgoyal.net/kitty/conf/) for all available options.

**Tips:**

- Use [`kitty +kitten ssh`](https://sw.kovidgoyal.net/kitty/kittens/ssh/) to SSH with automatic terminfo setup
- Enable shell integration in your shell config for enhanced features
- The graphics protocol works great with image viewers and file managers like [`ranger`](https://wiki.archlinux.org/title/Ranger)

---

## Zsh

A powerful shell that combines features from bash, ksh, and tcsh with additional functionality for advanced users. Zsh is highly customizable and plays well with frameworks like Oh My Zsh.

| | |
|---|---|
| **License** | MIT |
| **Compatibility** | POSIX-like, bash-compatible |
| **Key features** | Extended globbing, advanced completion, theming, plugins |
| **Use case** | Interactive shell, scripting, customizable development environment |

**Installation:**

```bash
sudo pacman -S zsh

# Set as default shell
chsh -s /usr/bin/zsh
```

**Key features:**

- **Advanced completion**: Context-aware tab completion for commands, options, and paths
- **Globbing**: Powerful pattern matching with extended globbing (`**/pattern`, recursive globs)
- **History**: Persistent command history with sharing across sessions
- **Named directories**: Quickly jump to frequently used directories
- **Aliases and functions**: Easy to define and manage custom commands

**Essential configuration:**

```bash
# ~/.zshrc - Basic setup

# Add to PATH
export PATH="$HOME/.local/bin:$PATH"

# History settings
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY

# Completion
autoload -Uz compinit && compinit

# Vi-mode (optional)
bindkey -v
```

**Popular frameworks:**

- **Oh My Zsh**: Feature-rich framework with plugins and themes (can be heavy)
- **Zinit**: Lightweight plugin manager for zsh
- **Starship**: Modern shell prompt (see below)

---

## Fish

A user-friendly shell emphasizing simplicity and discoverability. Fish provides sensible defaults out of the box and is easier to learn than bash or zsh, while still being powerful for advanced users.

| | |
|---|---|
| **License** | GPL-2.0 |
| **Approach** | User-friendly, discoverable, scripting-simple |
| **Key features** | Autosuggestions, syntax highlighting, web-based config, smart completion |
| **Use case** | Interactive shell, scripting, learning shell basics |

**Installation:**

```bash
sudo pacman -S fish

# Set as default shell
chsh -s /usr/bin/fish
```

**Key features:**

- **Autosuggestions**: Suggests commands from history as you type (press right arrow to accept)
- **Syntax highlighting**: Colors show valid commands, invalid paths, and comments in real-time
- **Smart completion**: Automatically discovers available commands and their options
- **Web-based configuration**: Access settings via `fish_config` command in a browser
- **Clean scripting**: Simpler syntax than bash for scripts (though less POSIX-compatible)

**Basic configuration:**

```bash
# ~/.config/fish/config.fish

# Add to PATH
set -gx PATH $HOME/.local/bin $PATH

# Aliases
alias ll 'ls -lah'
alias gs 'git status'

# Functions
function mkcd
    mkdir -p $argv[1]
    cd $argv[1]
end
```

**Tips:**

- Tab completion is context-aware—just press Tab
- Type `fish_config` to open the web-based configuration interface
- Most bash scripts won't run in fish—keep bash for scripting, use fish for interactive use
- Works great with `starship` prompt

---

## Starship

A minimal, blazingly fast shell prompt that works across all major shells (bash, zsh, fish, PowerShell). Starship automatically detects your environment and shows only the information you need.

| | |
|---|---|
| **License** | ISC |
| **Written in** | Rust |
| **Compatibility** | Bash, Zsh, Fish, PowerShell, Ion, Elvish, Xonsh, Cmd, NUSHELL |
| **Use case** | Modern shell prompt, git status, environment indicators |

**Installation:**

```bash
sudo pacman -S starship

# Or latest from source
cargo install starship
```

**Setup by shell:**

**For Zsh** (`~/.zshrc`):
```bash
eval "$(starship init zsh)"
```

**For Fish** (`~/.config/fish/config.fish`):
```fish
starship init fish | source
```

**For Bash** (`~/.bashrc`):
```bash
eval "$(starship init bash)"
```

**Key features:**

- **Git integration**: Shows branch, status, and commits ahead/behind at a glance
- **Language detection**: Displays versions of Node.js, Python, Rust, Go, etc. when in relevant directories
- **Time display**: Optional right-aligned UTC or local time
- **Command duration**: Shows how long the last command took
- **Multi-line support**: Keeps command inputs clean with a dedicated line for the prompt
- **Fast**: Written in Rust with minimal overhead

**Basic configuration** (`~/.config/starship.toml`):

```toml
# Timeout for commands (in milliseconds)
command_timeout = 500

# Format of the prompt
format = """
$directory\
$git_branch\
$git_status\
 $character"""

# Right-aligned line
right_format = "$cmd_duration"

# Show execution time for commands > 500ms
[cmd_duration]
min_time = 500

# Git settings
[git_branch]
symbol = "🌱 "
truncation_length = 20

[git_status]
ahead = "⇡${count}"
behind = "⇣${count}"
```

**Popular modules to enable:**

- `git_branch`, `git_status` — Git information
- `python`, `nodejs`, `rust`, `go` — Language versions
- `docker_context` — Current Docker context
- `kubernetes` — Kubernetes cluster and namespace
- `time` — Current time (CPU overhead is minimal)

---

## Utility Tools

### fzf (Fuzzy Finder)

Interactive command-line fuzzy finder that integrates with your shell for searching files, command history, and more.

```bash
sudo pacman -S fzf

# Add to ~/.zshrc or ~/.bashrc
source /usr/share/fzf/completion.zsh
source /usr/share/fzf/key-bindings.zsh
```

**Common uses:**

- `Ctrl+R` — Fuzzy search command history
- `Ctrl+T` — Fuzzy find a file to insert into command
- `Alt+C` — Fuzzy find directory and cd into it

---

### Exa (or ls)

A modern replacement for `ls` with better defaults, colors, and icons. Install `exa` for enhanced file listing, or use the newer `lsd` as an alternative.

```bash
sudo pacman -S exa

# Or the newer maintained fork
yay -S lsd
```

**Quick setup:**

```bash
# Add to ~/.zshrc or ~/.config/fish/config.fish
alias ls='exa --long --all --group-directories-first'
alias tree='exa --tree'
```

---

### Bat (Better Cat)

A `cat` clone with syntax highlighting, git integration, and automatic paging for long files.

```bash
sudo pacman -S bat
```

**Usage:**

```bash
bat ~/.config/kitty/kitty.conf    # Syntax highlighting
bat --line-range 1:50 file.txt    # Show specific lines
```

---

### Ripgrep (rg)

A fast, recursive grep alternative that respects `.gitignore` and has sensible defaults for code searching.

```bash
sudo pacman -S ripgrep
```

**Usage:**

```bash
rg "pattern" ~/projects           # Search recursively
rg --type python "TODO"           # Search by file type
rg -i "case-insensitive"         # Case-insensitive search
```

---

## Integration Example

A modern terminal setup combining kitty, zsh, starship, and utilities:

**Install packages:**

```bash
sudo pacman -S kitty zsh starship fzf exa bat ripgrep
```

**Configure zsh** (`~/.zshrc`):

```bash
# Initialize starship
eval "$(starship init zsh)"

# Source fzf
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh

# Aliases
alias ls='exa --long --all --group-directories-first'
alias cat='bat'
alias grep='rg'
alias tree='exa --tree'

# History
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY

# Completion
autoload -Uz compinit && compinit
```

**Configure starship** (`~/.config/starship.toml`):

```toml
format = """
$directory\
$git_branch\
$git_status\
 $character"""

[git_branch]
symbol = "🌱 "

[git_status]
ahead = "⇡"
behind = "⇣"
```

This combination creates a fast, visually informative, and highly customizable command-line experience perfect for development work on Arch Linux.

---

## References

- [Kitty Terminal Emulator](https://sw.kovidgoyal.net/kitty/) — Official documentation with guides and keybindings
- [Zsh Documentation](https://zsh.sourceforge.io/Doc/) — Complete zsh manual
- [Fish Shell](https://fishshell.com/) — Official fish shell site
- [Starship](https://starship.rs/) — Modern shell prompt documentation
- [ArchWiki: Kitty](https://wiki.archlinux.org/title/Kitty) — Arch Linux-specific kitty setup
