# =============================================================================
# Simplified .zshrc Configuration - Cleaned and Error-Free
# =============================================================================

# -----------------------------------------------------------------------------
# Environment Variables
# -----------------------------------------------------------------------------
export TERMINAL=${TERMINAL:-kitty}
export EDITOR=${EDITOR:-nvim}
export VISUAL=${VISUAL:-nvim}
export PAGER=${PAGER:-less}

# XDG Base Directory compliance
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
mkdir -p "$XDG_CACHE_HOME/zsh" "$XDG_CACHE_HOME/zsh/zcompcache" "$XDG_DATA_HOME/zsh"

# PATH
typeset -gU path PATH
path=(
  "$HOME/.local/bin"
  "$HOME/bin"
  "${path[@]}"
)

[[ -o interactive ]] || return 0

# -----------------------------------------------------------------------------
# Zsh Options & History
# -----------------------------------------------------------------------------
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt EXTENDED_GLOB
setopt NO_BEEP
setopt PROMPT_SUBST
setopt INTERACTIVE_COMMENTS

# History
export HISTFILE="$XDG_DATA_HOME/zsh/history"
export HISTSIZE=50000
export SAVEHIST=50000
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt EXTENDED_HISTORY

# -----------------------------------------------------------------------------
# Completion
# -----------------------------------------------------------------------------
autoload -Uz compinit
zmodload -i zsh/complist 2>/dev/null || true
typeset -g _compdump
_compdump="$XDG_CACHE_HOME/zsh/zcompdump-${ZSH_VERSION}"

zstyle ':completion:*' menu select
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# -----------------------------------------------------------------------------
# Keybindings - Simple Vi Mode (NO PLUGIN)
# -----------------------------------------------------------------------------
if [[ -t 0 ]]; then
  bindkey -v
  export KEYTIMEOUT=1

  # Useful emacs-style bindings in insert mode
  bindkey -M viins '^A' beginning-of-line
  bindkey -M viins '^E' end-of-line
  bindkey -M viins '^K' kill-line
  bindkey -M viins '^U' backward-kill-line
  bindkey -M viins '^W' backward-kill-word
  bindkey -M viins '^R' history-incremental-search-backward

  # Edit current command line in $EDITOR from normal mode
  autoload -Uz edit-command-line
  zle -N edit-command-line
  bindkey -M vicmd v edit-command-line
fi

# -----------------------------------------------------------------------------
# FZF Integration - Simplified (No Missing Command Errors)
# -----------------------------------------------------------------------------
if [[ -t 0 && -r /usr/share/fzf/completion.zsh ]]; then
  source /usr/share/fzf/completion.zsh
fi

if [[ -t 0 && -r /usr/share/fzf/key-bindings.zsh ]]; then
  source /usr/share/fzf/key-bindings.zsh
fi

# Basic FZF options - no complex previews that might fail
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"

# Only use fd if it exists
if command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# -----------------------------------------------------------------------------
# Zinit Plugin Manager - Essential Plugins Only
# -----------------------------------------------------------------------------
ZINIT_HOME="${XDG_DATA_HOME}/zinit/zinit.git"

if [[ -f "${ZINIT_HOME}/zinit.zsh" ]]; then
  source "${ZINIT_HOME}/zinit.zsh"

  # Essential plugins only - NO zsh-vi-mode (causes keyboard issues)
  zinit ice lucid atinit'ZSH_AUTOSUGGEST_STRATEGY=(history completion)'
  zinit light zsh-users/zsh-autosuggestions

  zinit ice lucid blockf
  zinit light zsh-users/zsh-completions

  zinit ice lucid
  zinit light zsh-users/zsh-history-substring-search

  zinit ice lucid
  zinit light zdharma-continuum/fast-syntax-highlighting
fi

# Initialize completion after plugins (avoids needing to rerun compinit later)
ZSH_DISABLE_COMPFIX=true
compinit -C -d "$_compdump" 2>/dev/null || compinit -d "$_compdump"
(( $+functions[zinit] )) && zinit cdreplay -q 2>/dev/null || true

# If history-substring-search loaded, bind arrow keys to it (works well with vi mode)
if (( $+functions[history-substring-search-up] )); then
  if [[ -t 0 ]]; then
    bindkey -M viins '^[[A' history-substring-search-up
    bindkey -M viins '^[[B' history-substring-search-down
    bindkey -M vicmd '^[[A' history-substring-search-up
    bindkey -M vicmd '^[[B' history-substring-search-down
    bindkey -M viins '^P' history-substring-search-up
    bindkey -M viins '^N' history-substring-search-down
  fi
fi

# -----------------------------------------------------------------------------
# Development Tools
# -----------------------------------------------------------------------------
# Zoxide
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
  alias zx='zoxide'
fi

# Atuin (uses ZLE; skip for non-tty `zsh -ic` runs)
if [[ -t 0 ]] && command -v atuin >/dev/null 2>&1; then
  export ATUIN_NOBIND="true"
  eval "$(atuin init zsh)"
  bindkey '^r' _atuin_search_widget
fi

# Direnv
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"

# Starship prompt (uses ZLE hooks; skip for non-tty `zsh -ic` runs)
if [[ -t 0 ]] && command -v starship >/dev/null 2>&1; then
  export STARSHIP_CACHE="$XDG_CACHE_HOME/starship"
  eval "$(starship init zsh)"
fi

# -----------------------------------------------------------------------------
# Language Tools
# -----------------------------------------------------------------------------

# PNPM
export PNPM_HOME="$HOME/.local/share/pnpm"
path=("$PNPM_HOME" "${path[@]}")

# NVM (simplified lazy loading)
if [[ -r /usr/share/nvm/init-nvm.sh ]]; then
  _nvm_loaded=0
  
  _nvm_load() {
    (( _nvm_loaded )) && return 0
    unset -f nvm node npm npx 2>/dev/null
    source /usr/share/nvm/init-nvm.sh
    _nvm_loaded=1
  }
  
  nvm()  { _nvm_load; nvm  "$@"; }
  node() { _nvm_load; node "$@"; }
  npm()  { _nvm_load; npm  "$@"; }
  npx()  { _nvm_load; npx  "$@"; }
fi

# Python UV
if command -v uv >/dev/null 2>&1; then
  export UV_CACHE_DIR="$XDG_CACHE_HOME/uv"
  eval "$(uv generate-shell-completion zsh)" 2>/dev/null
fi

# Pyenv
if command -v pyenv >/dev/null 2>&1; then
  export PYENV_ROOT="$HOME/.pyenv"
  path=("$PYENV_ROOT/bin" "${path[@]}")
  eval "$(pyenv init -)"
fi

# Rust/Cargo
if [[ -d "$HOME/.cargo" ]]; then
  export CARGO_HOME="${CARGO_HOME:-$HOME/.cargo}"
  export RUSTUP_HOME="${RUSTUP_HOME:-$HOME/.rustup}"
  path=("$CARGO_HOME/bin" "${path[@]}")
fi

# -----------------------------------------------------------------------------
# Aliases - Only Created if Commands Exist
# -----------------------------------------------------------------------------

# Modern replacements (conditional)
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --group-directories-first --icons=auto'
  alias ll='eza -lah --group-directories-first --icons=auto'
  alias la='eza -a --group-directories-first --icons=auto'
  alias lt='eza --tree --level=2 --icons=auto'
else
  alias ll='ls -lah'
  alias la='ls -a'
fi

command -v bat >/dev/null 2>&1 && alias cat='bat --paging=never'
command -v rg >/dev/null 2>&1 && alias grep='rg'
command -v btop >/dev/null 2>&1 && alias top='btop'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Git shortcuts
alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias glog='git log --oneline --graph --decorate --all'

# Python shortcuts
alias py='python'
alias ve='python -m venv .venv'
alias va='source .venv/bin/activate || source venv/bin/activate'
alias vd='deactivate'

# UV shortcuts
command -v uv >/dev/null 2>&1 && alias uvs='uv sync'
command -v uv >/dev/null 2>&1 && alias uvi='uv init'
command -v uv >/dev/null 2>&1 && alias uvr='uv run'
command -v uv >/dev/null 2>&1 && alias uva='uv add'

# Node/NPM shortcuts
alias ni='npm install'
alias nr='npm run'
alias pi='pnpm install'
alias pr='pnpm run'

# Docker shortcuts
alias d='docker'
if command -v docker-compose >/dev/null 2>&1; then
  alias dc='docker-compose'
elif command -v docker >/dev/null 2>&1; then
  alias dc='docker compose'
fi
alias dps='docker ps'

# Cargo shortcuts
alias cr='cargo run'
alias cb='cargo build'
alias ct='cargo test'
alias cc='cargo check'

# Safety
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

# -----------------------------------------------------------------------------
# Useful Functions
# -----------------------------------------------------------------------------

# Create directory and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Extract archives
extract() {
  if [[ ! -f "$1" ]]; then
    echo "File not found: $1"
    return 1
  fi
  
  case "$1" in
    *.tar.bz2)  tar xjf "$1"    ;;
    *.tar.gz)   tar xzf "$1"    ;;
    *.tar.xz)   tar xJf "$1"    ;;
    *.tar)      tar xf "$1"     ;;
    *.zip)      unzip "$1"      ;;
    *.7z)       7z x "$1"       ;;
    *)          echo "Unknown archive format: $1" ;;
  esac
}

# Git add and commit
gac() {
  if [[ -z "$1" ]]; then
    echo "Usage: gac <commit-message>"
    return 1
  fi
  git add -A
  git commit -m "$1"
}

# Check port usage
port() {
  if [[ -z "$1" ]]; then
    echo "Usage: port <port-number>"
    return 1
  fi
  lsof -i ":$1" 2>/dev/null || ss -tulpn | grep ":$1"
}

# Show IPs
myip() {
  echo "Public IP:  $(curl -s ifconfig.me 2>/dev/null || echo 'N/A')"
  echo "Private IP: $(ip -4 addr show 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v 127.0.0.1 | head -1)"
}

# Quick notes
note() {
  local note_dir="$HOME/notes"
  mkdir -p "$note_dir"
  local note_file="$note_dir/$(date +%Y-%m-%d).md"
  
  if [[ -n "$1" ]]; then
    echo "- $(date +%H:%M) - $*" >> "$note_file"
    echo "Note saved to $note_file"
  else
    ${EDITOR:-nvim} "$note_file"
  fi
}

# System info
sysinfo() {
  echo "OS:       $(uname -sr)"
  echo "Hostname: $(hostname)"
  echo "User:     $USER"
  echo "Shell:    $SHELL"
  echo "Uptime:   $(uptime -p 2>/dev/null || uptime)"
}

# -----------------------------------------------------------------------------
# Completions (guarded to prevent errors)
# -----------------------------------------------------------------------------
command -v gh >/dev/null 2>&1 && eval "$(gh completion -s zsh)" 2>/dev/null
command -v cline >/dev/null 2>&1 && source <(cline completion zsh) 2>/dev/null

# -----------------------------------------------------------------------------
# Cleanup
# -----------------------------------------------------------------------------
# Compile .zshrc for faster loading
if [[ ! -f "$HOME/.zshrc.zwc" || "$HOME/.zshrc" -nt "$HOME/.zshrc.zwc" ]]; then
  zcompile "$HOME/.zshrc" &>/dev/null &!
fi

# Command-not-found handler
[[ -r /usr/share/doc/pkgfile/command-not-found.zsh ]] \
  && source /usr/share/doc/pkgfile/command-not-found.zsh

# =============================================================================
# End of .zshrc
# =============================================================================
