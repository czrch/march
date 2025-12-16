# =============================================================================
# Enhanced .zshrc Configuration
# Performance-optimized, security-hardened, developer-focused
# =============================================================================

# -----------------------------------------------------------------------------
# 0) Environment (keep this file interactive-only)
# -----------------------------------------------------------------------------
[[ -f "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"

export TERMINAL=${TERMINAL:-kitty}
export EDITOR=${EDITOR:-nvim}
export VISUAL=${VISUAL:-nvim}
export PAGER=${PAGER:-less}

# XDG Base Directory specification compliance
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
mkdir -p "$XDG_CACHE_HOME/zsh" "$XDG_DATA_HOME/zsh"

# Make PATH unique + allow clean appends
typeset -gU path PATH
path=(
  "$HOME/.local/bin"
  "$HOME/bin"
  $path
)

# -----------------------------------------------------------------------------
# 1) Zsh options + history
# -----------------------------------------------------------------------------
setopt AUTO_CD                  # cd by typing directory name if not a command
setopt AUTO_PUSHD              # Make cd push old dir onto dir stack
setopt PUSHD_IGNORE_DUPS       # Don't push multiple copies of same dir
setopt PUSHD_SILENT            # Don't print dir stack after pushd/popd

setopt EXTENDED_GLOB           # Use extended globbing syntax (#, ~, ^)
setopt NO_BEEP                 # No beeping
setopt PROMPT_SUBST            # Allow substitution in prompts
setopt INTERACTIVE_COMMENTS    # Allow comments in interactive shells

# History configuration - optimized for security and performance
export HISTFILE="$XDG_DATA_HOME/zsh/history"
export HISTSIZE=200000
export SAVEHIST=200000
setopt APPEND_HISTORY          # Append rather than overwrite history
setopt INC_APPEND_HISTORY      # Write to history immediately, not on exit
setopt SHARE_HISTORY           # Share history between all sessions
setopt HIST_IGNORE_ALL_DUPS    # Remove older duplicate entries from history
setopt HIST_IGNORE_SPACE       # Don't save commands starting with space (for sensitive data)
setopt HIST_REDUCE_BLANKS      # Remove superfluous blanks from history
setopt HIST_VERIFY             # Don't execute immediately upon history expansion
setopt EXTENDED_HISTORY        # Record timestamp and duration

# Security: Filter sensitive patterns from history
# Commands with these patterns won't be saved if started with space
HISTORY_IGNORE="(ls|cd|pwd|exit|date|* --password*|* --token*|*API_KEY*|*SECRET*)"

# -----------------------------------------------------------------------------
# 2) Completion (fast + cached)
# -----------------------------------------------------------------------------
fpath=(/usr/share/zsh/site-functions $fpath)

autoload -Uz compinit

# Compile zcompdump for faster loading (only if not done in last 24h)
_compdump="$XDG_CACHE_HOME/zsh/zcompdump-${ZSH_VERSION}"
if [[ -s "$_compdump" && (! -s "${_compdump}.zwc" || "$_compdump" -nt "${_compdump}.zwc") ]]; then
  zcompile "$_compdump"
fi

# Only regenerate compdump once a day for faster startup
if [[ -n ${_compdump}(#qNmh-24) ]]; then
  compinit -C -d "$_compdump"
else
  compinit -d "$_compdump"
fi

zmodload zsh/complist
zstyle ':completion:*' menu select
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"
zstyle ':completion:*' completer _extensions _complete _approximate
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format '%F{green}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches --%f'
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Group completions by type
zstyle ':completion:*' group-name ''
zstyle ':completion:*:*:-command-:*:*' group-order alias builtins functions commands

autoload -Uz bashcompinit && bashcompinit

# -----------------------------------------------------------------------------
# 3) Keybinds (Vi-Mode + Enhanced Navigation)
# -----------------------------------------------------------------------------
# Enable Vi mode
bindkey -v

# Reduce key timeout for faster mode switching (10ms)
export KEYTIMEOUT=1

# Keep useful emacs-style bindings in insert mode
bindkey -M viins '^A' beginning-of-line
bindkey -M viins '^E' end-of-line
bindkey -M viins '^K' kill-line
bindkey -M viins '^U' backward-kill-line
bindkey -M viins '^W' backward-kill-word
bindkey -M viins '^Y' yank
bindkey -M viins '^R' history-incremental-search-backward

# Allow 'jk' to exit insert mode (alternative to ESC)
bindkey -M viins 'jk' vi-cmd-mode

# Better word navigation
bindkey -M viins '^[b' backward-word
bindkey -M viins '^[f' forward-word

# History substring search bindings (set after plugin loads)
_bind_history_search() {
  bindkey -M vicmd 'k' history-substring-search-up
  bindkey -M vicmd 'j' history-substring-search-down
  bindkey -M viins '^[[A' history-substring-search-up
  bindkey -M viins '^[[B' history-substring-search-down
  bindkey -M viins '^P' history-substring-search-up
  bindkey -M viins '^N' history-substring-search-down
}

# Edit command line in $EDITOR with v in normal mode
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'v' edit-command-line

# -----------------------------------------------------------------------------
# 4) FZF integration (guarded)
# -----------------------------------------------------------------------------
[[ -r /usr/share/fzf/completion.zsh    ]] && source /usr/share/fzf/completion.zsh
[[ -r /usr/share/fzf/key-bindings.zsh  ]] && source /usr/share/fzf/key-bindings.zsh

# Use fd for better performance and .gitignore awareness
if command -v fd >/dev/null; then
  export FZF_DEFAULT_COMMAND='fd --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# Enhanced FZF options with preview
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border \
  --preview 'bat --color=always --style=numbers {} 2>/dev/null || tree -C {}' \
  --preview-window=right:60%:wrap \
  --bind 'ctrl-/:toggle-preview' \
  --bind 'ctrl-y:execute-silent(echo {} | xclip -selection clipboard)+abort'"

export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :500 {} 2>/dev/null || tree -C {}' \
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"

export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always {} 2>/dev/null || tree -C {} | head -200'"

# fzf-tab configuration
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':fzf-tab:*' switch-group '<' '>'

# -----------------------------------------------------------------------------
# 5) Zinit Plugin Manager + Plugins
# -----------------------------------------------------------------------------
ZINIT_HOME="${XDG_DATA_HOME}/zinit/zinit.git"

# Install zinit if not present
if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

# Turbo mode: wait'0a/b/c' loads after prompt (faster startup)
zinit wait lucid light-mode for \
  atload"_zsh_autosuggest_start" \
  atinit"ZSH_AUTOSUGGEST_STRATEGY=(history completion); ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20" \
    zsh-users/zsh-autosuggestions \
  blockf atpull'zinit creinstall -q .' \
    zsh-users/zsh-completions \
  atload"_bind_history_search" \
    zsh-users/zsh-history-substring-search \
    hlissner/zsh-autopair \
    Aloxaf/fzf-tab \
    changyuheng/zsh-interactive-cd \
  atinit"zicompinit; zicdreplay" \
    zdharma-continuum/fast-syntax-highlighting

# Enhanced Vi-mode plugin for better visual feedback
zinit ice depth=1
zinit light jeffreytse/zsh-vi-mode

# Useful tools & OMZ plugins
zinit wait lucid for \
    wfxr/forgit \
  atinit"export YSU_MESSAGE_POSITION=after; export YSU_HARDCORE=0" \
    MichaelAquilina/zsh-you-should-use \
  nocompile \
    OMZP::sudo \
    OMZP::colored-man-pages \
    OMZP::git-extras

# Docker & Podman completions
if command -v docker >/dev/null; then
  zinit ice lucid wait'0a' as'completion'
  zinit snippet https://raw.githubusercontent.com/docker/cli/master/contrib/completion/zsh/_docker
fi

if command -v podman >/dev/null && [[ ! -f /usr/share/zsh/site-functions/_podman ]]; then
  zinit ice lucid wait'0a' as'completion'
  zinit snippet https://raw.githubusercontent.com/containers/podman/main/completions/zsh/_podman
fi

# -----------------------------------------------------------------------------
# 6) Tooling (zoxide, atuin, starship, direnv)
# -----------------------------------------------------------------------------
command -v zoxide  >/dev/null && eval "$(zoxide init zsh)"

# Enhanced Atuin integration with better keybinds
if command -v atuin >/dev/null; then
  export ATUIN_NOBIND="true"
  eval "$(atuin init zsh)"
  bindkey '^r' _atuin_search_widget
  bindkey -M viins '^r' _atuin_search_widget
fi

command -v direnv  >/dev/null && eval "$(direnv hook zsh)"

# Starship with cache
if command -v starship >/dev/null; then
  export STARSHIP_CACHE="$XDG_CACHE_HOME/starship"
  eval "$(starship init zsh)"
fi

# -----------------------------------------------------------------------------
# 7) Language Tools: Node, Python, Rust
# -----------------------------------------------------------------------------

# === PNPM ===
export PNPM_HOME="$HOME/.local/share/pnpm"
path=("$PNPM_HOME" $path)

# === NVM (ENHANCED LAZY LOAD) ===
# Lazy-load NVM only when you actually use node/npm/npx/nvm or globally installed packages
# This provides ~200ms+ faster shell startup while maintaining access to global packages
if [[ -r /usr/share/nvm/init-nvm.sh ]]; then
  _nvm_loaded=0
  _nvm_global_packages=()
  
  _nvm_load() {
    # Return early if already loaded
    (( _nvm_loaded )) && return 0
    
    # Remove wrapper functions to allow real nvm function to take over
    unset -f nvm node npm npx ${_nvm_global_packages[@]} 2>/dev/null
    
    # Load NVM (defines nvm as a shell function)
    source /usr/share/nvm/init-nvm.sh
    _nvm_loaded=1
  }
  
  # Wrapper functions that trigger lazy loading
  # After _nvm_load, the real nvm/node/npm/npx functions are available
  nvm()  { _nvm_load; nvm  "$@"; }
  node() { _nvm_load; node "$@"; }
  npm()  { _nvm_load; npm  "$@"; }
  npx()  { _nvm_load; npx  "$@"; }
  
  # Scan for globally installed npm packages and create lazy-load wrappers
  # This allows global packages to work immediately without manually loading NVM first
  if [[ -d "$HOME/.nvm/versions/node" ]]; then
    # Find the current/default node version's global bin directory
    local nvm_current_bin=""
    
    # Try to find default or current version
    if [[ -L "$HOME/.nvm/versions/node/default" ]]; then
      nvm_current_bin="$HOME/.nvm/versions/node/default/bin"
    elif [[ -d "$HOME/.nvm/versions/node/current" ]]; then
      nvm_current_bin="$HOME/.nvm/versions/node/current/bin"
    else
      # Find most recent version
      nvm_current_bin=$(find "$HOME/.nvm/versions/node" -maxdepth 2 -type d -name "bin" 2>/dev/null | sort -V | tail -1)
    fi
    
    # Create wrapper functions for global npm packages
    if [[ -n "$nvm_current_bin" && -d "$nvm_current_bin" ]]; then
      for bin_file in "$nvm_current_bin"/*; do
        if [[ -f "$bin_file" && -x "$bin_file" ]]; then
          local cmd_name=$(basename "$bin_file")
          # Skip standard node/npm/npx commands (already wrapped above)
          if [[ "$cmd_name" != "node" && "$cmd_name" != "npm" && "$cmd_name" != "npx" && "$cmd_name" != "corepack" ]]; then
            _nvm_global_packages+=("$cmd_name")
            # Create wrapper function dynamically
            eval "${cmd_name}() { _nvm_load; command ${cmd_name} \"\$@\"; }"
          fi
        fi
      done
    fi
  fi
  
  # Scan for globally installed pnpm packages and create lazy-load wrappers
  if [[ -d "$PNPM_HOME" ]]; then
    for bin_file in "$PNPM_HOME"/*; do
      if [[ -f "$bin_file" && -x "$bin_file" ]]; then
        local cmd_name=$(basename "$bin_file")
        # Skip pnpm itself and already wrapped commands
        if [[ "$cmd_name" != "pnpm" && "$cmd_name" != "pnpx" && ! " ${_nvm_global_packages[@]} " =~ " ${cmd_name} " ]]; then
          _nvm_global_packages+=("$cmd_name")
          # Create wrapper function dynamically
          eval "${cmd_name}() { _nvm_load; command ${cmd_name} \"\$@\"; }"
        fi
      fi
    done
  fi
fi

# === Python ===
# UV (fast Python package manager) integration
if command -v uv >/dev/null; then
  export UV_CACHE_DIR="$XDG_CACHE_HOME/uv"
  export UV_PYTHON_PREFERENCE="managed"
  # UV completions
  eval "$(uv generate-shell-completion zsh)"
fi

# Pyenv integration if installed
if command -v pyenv >/dev/null; then
  export PYENV_ROOT="$HOME/.pyenv"
  path=("$PYENV_ROOT/bin" $path)
  eval "$(pyenv init -)"
fi

# Auto-activate Python venvs on directory change (supports UV and standard venvs)
autoload -U add-zsh-hook
_venv_auto_activate() {
  # Deactivate current venv if we're leaving its directory
  if [[ -n "$VIRTUAL_ENV" ]]; then
    local current_dir="$PWD"
    local venv_dir="$(dirname "$VIRTUAL_ENV")"
    case "$current_dir" in
      "$venv_dir"*) ;; # Still in venv directory tree
      *) deactivate 2>/dev/null ;;
    esac
  fi
  
  # Activate venv if present in current directory
  # Check for UV-managed venv first, then standard venvs
  if [[ -f ".venv/bin/activate" ]]; then
    source .venv/bin/activate 2>/dev/null
  elif [[ -f "venv/bin/activate" ]]; then
    source venv/bin/activate 2>/dev/null
  fi
}
add-zsh-hook chpwd _venv_auto_activate
_venv_auto_activate  # Check on shell start

# -----------------------------------------------------------------------------
# 8) Container Tools (Docker/Podman)
# -----------------------------------------------------------------------------
# Smart aliasing: prefer podman if docker not installed
if ! command -v docker >/dev/null && command -v podman >/dev/null; then
  alias docker='podman'
  alias docker-compose='podman-compose'
fi

# -----------------------------------------------------------------------------
# 9) Quality-of-life aliases
# -----------------------------------------------------------------------------
# Modern replacements for classic tools
alias ls='eza --group-directories-first --icons=auto'
alias ll='eza -lah --group-directories-first --icons=auto'
alias la='eza -a --group-directories-first --icons=auto'
alias lt='eza --tree --level=2 --icons=auto'
alias cat='bat --paging=never'
alias grep='rg'
alias find='fd'

# Navigation shortcuts
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Modern tool replacements (conditional on installation)
command -v duf    >/dev/null && alias df='duf'
command -v dust   >/dev/null && alias du='dust'
command -v btop   >/dev/null && alias top='btop'
command -v procs  >/dev/null && alias ps='procs'
command -v delta  >/dev/null && alias diff='delta'

# Zoxide shortcuts
alias zi='z -i'
alias zz='z -'

# Git shortcuts (enhanced in functions section)
alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gds='git diff --staged'
alias glog='git log --oneline --graph --decorate --all'
alias gca='git commit --amend'
alias gcane='git commit --amend --no-edit'
alias grb='git rebase'
alias grbi='git rebase -i'
alias gst='git stash'
alias gstp='git stash pop'
alias gstl='git stash list'

# Python shortcuts
alias py='python'
alias ipy='ipython'
alias ve='python -m venv .venv'
alias va='source .venv/bin/activate || source venv/bin/activate'
alias vd='deactivate'
alias pi='pip install'
alias pir='pip install -r requirements.txt'

# UV (Python package manager) shortcuts
alias uvs='uv sync'
alias uvi='uv init'
alias uvr='uv run'
alias uva='uv add'
alias uvad='uv add --dev'
alias uvl='uv lock'
alias uvt='uv tool install'
alias uvtr='uv tool run'
alias uvp='uv pip'
alias uvpi='uv pip install'
alias uvpc='uv pip compile'
alias uvps='uv pip sync'

# Node/NPM shortcuts
alias ni='npm install'
alias nr='npm run'
alias nrd='npm run dev'
alias nrb='npm run build'
alias nrt='npm run test'
alias pi='pnpm install'
alias pr='pnpm run'
alias prd='pnpm run dev'

# Docker/Podman shortcuts
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias dpa='docker ps -a'
alias di='docker images'
alias dpsa='docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'

# Safety aliases (ask before destructive operations)
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

# -----------------------------------------------------------------------------
# 10) Smart completions
# -----------------------------------------------------------------------------
command -v gh >/dev/null && eval "$(gh completion -s zsh)"
command -v kubectl >/dev/null && source <(kubectl completion zsh)
command -v helm >/dev/null && source <(helm completion zsh)

# -----------------------------------------------------------------------------
# 11) Useful functions
# -----------------------------------------------------------------------------

# === File & Directory Management ===

# Create directory and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Create temporary directory and cd into it
mktemp-cd() {
  local tmpdir=$(mktemp -d)
  cd "$tmpdir"
  echo "Created temp dir: $tmpdir"
}

# Backup file with timestamp
backup() {
  if [[ -z "$1" ]]; then
    echo "Usage: backup <file>"
    return 1
  fi
  local timestamp=$(date +%Y%m%d_%H%M%S)
  cp -r "$1" "${1}.backup_${timestamp}"
  echo "Backed up: ${1}.backup_${timestamp}"
}

# Extract any archive format
extract() {
  if [[ ! -f "$1" ]]; then
    echo "File not found: $1"
    return 1
  fi
  
  case "$1" in
    *.tar.bz2)  tar xjf "$1"    ;;
    *.tar.gz)   tar xzf "$1"    ;;
    *.tar.xz)   tar xJf "$1"    ;;
    *.bz2)      bunzip2 "$1"    ;;
    *.rar)      unrar x "$1"    ;;
    *.gz)       gunzip "$1"     ;;
    *.tar)      tar xf "$1"     ;;
    *.tbz2)     tar xjf "$1"    ;;
    *.tgz)      tar xzf "$1"    ;;
    *.zip)      unzip "$1"      ;;
    *.Z)        uncompress "$1" ;;
    *.7z)       7z x "$1"       ;;
    *)          echo "Unknown archive format: $1" ;;
  esac
}

# === Git Functions ===

# Git fuzzy checkout branch
gco() { 
  local branch=$(git branch -a | fzf --height=20% --reverse | sed 's/^[* ]*//' | sed 's/remotes\/origin\///')
  [[ -n "$branch" ]] && git checkout "$branch"
}

# Git fuzzy show commit
gshow() { 
  local commit=$(git log --oneline --color=always | fzf --ansi --preview 'git show --color=always {1}' | awk '{print $1}')
  [[ -n "$commit" ]] && git show "$commit"
}

# Git fuzzy diff file
gdiff() {
  local file=$(git diff --name-only | fzf --preview 'git diff --color=always {}')
  [[ -n "$file" ]] && git diff "$file"
}

# Git fuzzy log with graph
gflog() {
  git log --graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" | \
    fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
        --preview 'echo {} | grep -o "[a-f0-9]\{7\}" | head -1 | xargs git show --color=always' \
        --bind "enter:execute:echo {} | grep -o '[a-f0-9]\{7\}' | head -1 | xargs git show | bat --style=plain"
}

# Git worktree helpers
gwt-add() {
  [[ -z "$1" ]] && echo "Usage: gwt-add <branch-name>" && return 1
  git worktree add "../$(basename $PWD)-$1" -b "$1"
}

gwt-list() {
  git worktree list
}

gwt-remove() {
  local worktree=$(git worktree list | fzf | awk '{print $1}')
  [[ -n "$worktree" ]] && git worktree remove "$worktree"
}

# === Docker/Podman Functions ===

# Docker cleanup
dclean() {
  echo "🧹 Cleaning up Docker..."
  docker system prune -af --volumes
  echo "✅ Cleanup complete!"
}

# Docker fuzzy exec into container
dexec() {
  local container=$(docker ps --format '{{.Names}}' | fzf --height=40%)
  [[ -n "$container" ]] && docker exec -it "$container" /bin/bash
}

# Docker fuzzy logs
dlogs() {
  local container=$(docker ps --format '{{.Names}}' | fzf --height=40%)
  [[ -n "$container" ]] && docker logs -f "$container"
}

# === Development Functions ===

# Fuzzy kill process
fkill() {
  local pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
  if [[ -n "$pid" ]]; then
    echo "$pid" | xargs kill -${1:-9}
    echo "Killed process(es): $pid"
  fi
}

# Fuzzy file search and edit
fe() {
  local file=$(fd --type f --hidden --follow --exclude .git | fzf --preview 'bat --color=always {}')
  [[ -n "$file" ]] && ${EDITOR:-nvim} "$file"
}

# NPM/PNPM script runner with fzf
ns() {
  local script=$(cat package.json 2>/dev/null | jq -r '.scripts | keys[]' | fzf --height=40%)
  if [[ -n "$script" ]]; then
    if command -v pnpm >/dev/null && [[ -f "pnpm-lock.yaml" ]]; then
      pnpm run "$script"
    else
      npm run "$script"
    fi
  fi
}

# Check what's running on a port
port() {
  if [[ -z "$1" ]]; then
    echo "Usage: port <port-number>"
    return 1
  fi
  lsof -i ":$1" || ss -tulpn | grep ":$1"
}

# Show public and private IP
myip() {
  echo "🌍 Public IP:  $(curl -s ifconfig.me)"
  echo "🏠 Private IP: $(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v 127.0.0.1 | head -1)"
}

# Quick note taking
note() {
  local note_dir="$HOME/notes"
  mkdir -p "$note_dir"
  local note_file="$note_dir/$(date +%Y-%m-%d).md"
  
  if [[ -n "$1" ]]; then
    echo "- $(date +%H:%M) - $*" >> "$note_file"
    echo "✏️  Note saved to $note_file"
  else
    ${EDITOR:-nvim} "$note_file"
  fi
}

# Quick cheat.sh lookup
cheat() {
  if [[ -z "$1" ]]; then
    echo "Usage: cheat <command>"
    return 1
  fi
  curl -s "cheat.sh/$1" | bat --style=plain --language=bash
}

# CMake helpers
cmake-init() {
  local build_type="${1:-Debug}"
  mkdir -p build
  cd build
  cmake .. -DCMAKE_BUILD_TYPE="$build_type" -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
  [[ -f compile_commands.json ]] && ln -sf build/compile_commands.json ../
  cd ..
  echo "✅ CMake initialized (${build_type})"
}

cmake-build() {
  if [[ ! -d "build" ]]; then
    echo "❌ No build directory. Run cmake-init first."
    return 1
  fi
  cmake --build build -j$(nproc)
}

cmake-clean() {
  rm -rf build
  echo "✅ Build directory cleaned"
}

# Python virtualenv quick create
venv-create() {
  local name="${1:-.venv}"
  python -m venv "$name"
  source "$name/bin/activate"
  pip install --upgrade pip
  echo "✅ Virtual environment created and activated: $name"
}

# === UV (Python) Functions ===

# UV project initialization with common setup
uv-init() {
  local name="${1:-.}"
  
  if [[ ! -d "$name" && "$name" != "." ]]; then
    mkdir -p "$name"
    cd "$name"
  fi
  
  echo "🚀 Initializing UV project..."
  uv init
  uv venv
  source .venv/bin/activate
  
  # Add common dev dependencies
  echo "📦 Adding common dev dependencies..."
  uv add --dev ruff pytest pytest-cov
  
  echo "✅ UV project initialized and virtual environment activated!"
  echo "💡 Project location: $(pwd)"
}

# UV virtual environment creation and activation
uv-venv() {
  local python_version="${1:-}"
  
  if [[ -n "$python_version" ]]; then
    echo "🐍 Creating UV venv with Python $python_version..."
    uv venv --python "$python_version"
  else
    echo "🐍 Creating UV venv..."
    uv venv
  fi
  
  source .venv/bin/activate
  echo "✅ Virtual environment created and activated!"
}

# UV sync with helpful output
uv-sync-verbose() {
  echo "🔄 Syncing dependencies with UV..."
  uv sync --all-extras
  echo "✅ Dependencies synced!"
}

# Quick UV tool installation
uvti() {
  if [[ -z "$1" ]]; then
    echo "Usage: uvti <tool-name>"
    return 1
  fi
  echo "📦 Installing tool: $1"
  uv tool install "$1"
  echo "✅ Tool installed: $1"
}

# === Enhanced Development Workflow Functions ===

# Smart project initialization wizard
dev() {
  echo "🎯 Development Project Initializer"
  echo "=================================="
  echo "1) Python (UV)"
  echo "2) Python (standard venv)"
  echo "3) Node.js (npm)"
  echo "4) Node.js (pnpm)"
  echo "5) Rust"
  echo "6) C/C++ (CMake)"
  echo "=================================="
  echo -n "Select project type [1-6]: "
  read choice
  
  echo -n "Project name: "
  read project_name
  
  case $choice in
    1)
      mkdir -p "$project_name" && cd "$project_name"
      uv-init "."
      ;;
    2)
      mkdir -p "$project_name" && cd "$project_name"
      python -m venv .venv
      source .venv/bin/activate
      pip install --upgrade pip
      echo "✅ Python venv created!"
      ;;
    3)
      mkdir -p "$project_name" && cd "$project_name"
      npm init -y
      echo "✅ npm project created!"
      ;;
    4)
      mkdir -p "$project_name" && cd "$project_name"
      pnpm init
      echo "✅ pnpm project created!"
      ;;
    5)
      cargo new "$project_name"
      cd "$project_name"
      echo "✅ Rust project created!"
      ;;
    6)
      mkdir -p "$project_name" && cd "$project_name"
      cmake-init
      echo "✅ CMake project created!"
      ;;
    *)
      echo "❌ Invalid choice"
      return 1
      ;;
  esac
}

# Clean all build artifacts across languages
clean-all() {
  echo "🧹 Cleaning build artifacts..."
  
  # Python
  if [[ -d ".venv" ]] || [[ -d "venv" ]] || [[ -d "__pycache__" ]]; then
    echo "  🐍 Cleaning Python artifacts..."
    find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null
    find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null
    find . -type f -name "*.pyc" -delete 2>/dev/null
    find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null
    find . -type d -name ".ruff_cache" -exec rm -rf {} + 2>/dev/null
  fi
  
  # Node.js
  if [[ -d "node_modules" ]]; then
    echo "  📦 Cleaning Node.js artifacts..."
    rm -rf node_modules dist .next .nuxt
  fi
  
  # C/C++
  if [[ -d "build" ]]; then
    echo "  🔨 Cleaning CMake artifacts..."
    rm -rf build
  fi
  
  echo "✅ Cleanup complete!"
}

# Smart test runner (detects project type)
test-all() {
  echo "🧪 Running tests..."
  
  if [[ -f "pyproject.toml" ]] && command -v uv >/dev/null; then
    echo "  🐍 Running Python tests (UV)..."
    uv run pytest
  elif [[ -f "pytest.ini" ]] || [[ -d "tests" ]]; then
    echo "  🐍 Running Python tests..."
    pytest
  elif [[ -f "package.json" ]]; then
    echo "  📦 Running Node.js tests..."
    if [[ -f "pnpm-lock.yaml" ]]; then
      pnpm test
    else
      npm test
    fi
  elif [[ -f "Cargo.toml" ]]; then
    echo "  🦀 Running Rust tests..."
    cargo test
  else
    echo "❌ No test configuration found"
    return 1
  fi
}

# Smart dev server launcher
serve() {
  local port="${1:-3000}"
  
  echo "🚀 Starting development server..."
  
  if [[ -f "package.json" ]]; then
    # Node.js project
    if [[ -f "pnpm-lock.yaml" ]]; then
      pnpm dev
    else
      npm run dev
    fi
  elif [[ -f "pyproject.toml" ]] && command -v uv >/dev/null; then
    # Python UV project
    if grep -q "uvicorn\|fastapi" pyproject.toml; then
      uv run uvicorn main:app --reload --port "$port"
    elif grep -q "flask" pyproject.toml; then
      uv run flask run --port "$port"
    else
      echo "💡 No web framework detected. Run manually."
    fi
  elif [[ -f "manage.py" ]]; then
    # Django
    python manage.py runserver "$port"
  elif [[ -f "index.html" ]]; then
    # Static HTML
    python -m http.server "$port"
  else
    echo "❌ No development server configuration found"
    return 1
  fi
}

# === Directory Bookmarks System ===

# Bookmark current directory
mark() {
  local mark_name="${1:-}"
  if [[ -z "$mark_name" ]]; then
    echo "Usage: mark <bookmark-name>"
    return 1
  fi
  
  local marks_file="$HOME/.config/zsh/marks"
  mkdir -p "$(dirname "$marks_file")"
  
  echo "$mark_name|$PWD" >> "$marks_file"
  echo "📌 Bookmarked: $PWD as '$mark_name'"
}

# Jump to bookmark
jump() {
  local marks_file="$HOME/.config/zsh/marks"
  
  if [[ ! -f "$marks_file" ]]; then
    echo "❌ No bookmarks found. Use 'mark <name>' to create one."
    return 1
  fi
  
  local selection=$(cat "$marks_file" | fzf --height=40% --preview 'echo {2}' --delimiter='|' --with-nth=1)
  if [[ -n "$selection" ]]; then
    local path=$(echo "$selection" | cut -d'|' -f2)
    cd "$path"
  fi
}

# List all bookmarks
marks() {
  local marks_file="$HOME/.config/zsh/marks"
  
  if [[ ! -f "$marks_file" ]]; then
    echo "📌 No bookmarks yet. Use 'mark <name>' to create one."
    return
  fi
  
  echo "📌 Saved Bookmarks:"
  cat "$marks_file" | awk -F'|' '{printf "  %-20s -> %s\n", $1, $2}'
}

# Delete a bookmark
unmark() {
  local marks_file="$HOME/.config/zsh/marks"
  
  if [[ ! -f "$marks_file" ]]; then
    echo "❌ No bookmarks found."
    return 1
  fi
  
  local selection=$(cat "$marks_file" | fzf --height=40% --delimiter='|' --with-nth=1)
  if [[ -n "$selection" ]]; then
    local mark_name=$(echo "$selection" | cut -d'|' -f1)
    grep -v "^$mark_name|" "$marks_file" > "${marks_file}.tmp"
    mv "${marks_file}.tmp" "$marks_file"
    echo "🗑️  Removed bookmark: $mark_name"
  fi
}

# Quick project directory jumper
proj() {
  local projects_dir="${PROJECTS_DIR:-$HOME/projects}"
  
  if [[ ! -d "$projects_dir" ]]; then
    echo "💡 Set PROJECTS_DIR environment variable or create ~/projects"
    return 1
  fi
  
  local project=$(fd -t d -d 2 . "$projects_dir" | fzf --height=40% --preview 'eza --tree --level=2 --color=always {}')
  [[ -n "$project" ]] && cd "$project"
}

# === Enhanced Git Functions ===

# Git add and commit in one go
gac() {
  if [[ -z "$1" ]]; then
    echo "Usage: gac <commit-message>"
    return 1
  fi
  git add -A
  git commit -m "$1"
}

# Conventional commit helper
gcm() {
  echo "📝 Conventional Commit Helper"
  echo "============================="
  echo "1) feat:     New feature"
  echo "2) fix:      Bug fix"
  echo "3) docs:     Documentation"
  echo "4) style:    Formatting"
  echo "5) refactor: Code restructuring"
  echo "6) test:     Add tests"
  echo "7) chore:    Maintenance"
  echo "8) perf:     Performance"
  echo "============================="
  echo -n "Select type [1-8]: "
  read choice
  
  local prefix=""
  case $choice in
    1) prefix="feat" ;;
    2) prefix="fix" ;;
    3) prefix="docs" ;;
    4) prefix="style" ;;
    5) prefix="refactor" ;;
    6) prefix="test" ;;
    7) prefix="chore" ;;
    8) prefix="perf" ;;
    *) echo "❌ Invalid choice"; return 1 ;;
  esac
  
  echo -n "Scope (optional, press enter to skip): "
  read scope
  
  echo -n "Message: "
  read message
  
  local commit_msg="$prefix"
  [[ -n "$scope" ]] && commit_msg="${commit_msg}(${scope})"
  commit_msg="${commit_msg}: ${message}"
  
  git add -A
  git commit -m "$commit_msg"
  echo "✅ Committed: $commit_msg"
}

# Safe undo last commit
gundo() {
  echo "⚠️  This will undo the last commit (keeping changes)"
  echo -n "Continue? [y/N]: "
  read confirm
  
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    git reset --soft HEAD~1
    echo "✅ Last commit undone (changes kept in staging)"
  else
    echo "❌ Cancelled"
  fi
}

# Clean merged branches
gclean() {
  echo "🧹 Cleaning merged branches..."
  git branch --merged | grep -v "\*\|main\|master\|develop" | xargs -n 1 git branch -d
  echo "✅ Merged branches cleaned!"
}

# === System Information Functions ===

# Colorful system info
sysinfo() {
  echo "╔════════════════════════════════════════╗"
  echo "║        💻 System Information          ║"
  echo "╚════════════════════════════════════════╝"
  echo ""
  echo "🖥️  OS:        $(uname -sr)"
  echo "🏠 Hostname:  $(hostname)"
  echo "👤 User:      $USER"
  echo "🐚 Shell:     $SHELL"
  echo "⏰ Uptime:    $(uptime -p 2>/dev/null || uptime)"
  echo "💾 Memory:    $(free -h | awk '/^Mem:/ {printf "%s / %s (%.1f%%)", $3, $2, $3/$2*100}')"
  
  # Disk info - use duf if available, otherwise fall back to df
  if command -v duf >/dev/null; then
    local disk_info=$(duf / --output mountpoint,size,used,usage --hide-fs tmpfs,devtmpfs 2>/dev/null | awk 'NR==2 {printf "%s / %s (%s)", $3, $2, $4}')
    echo "💽 Disk:      ${disk_info:-N/A}"
  else
    echo "💽 Disk:      $(command df -h / 2>/dev/null | awk 'NR==2 {printf "%s / %s (%s)", $3, $2, $5}')"
  fi
  
  echo "🔋 Load Avg:  $(uptime | awk -F'load average:' '{print $2}')"
  echo ""
}

# Terminal weather
weather() {
  local location="${1:-}"
  curl -s "wttr.in/${location}?format=v2"
}

# Enhanced network info
myip() {
  echo "╔════════════════════════════════════════╗"
  echo "║        🌐 Network Information         ║"
  echo "╚════════════════════════════════════════╝"
  echo ""
  echo "🌍 Public IP:   $(curl -s ifconfig.me)"
  echo "🏠 Private IP:  $(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v 127.0.0.1 | head -1)"
  echo "📡 Gateway:     $(ip route | grep default | awk '{print $3}')"
  echo "🔌 Interface:   $(ip route | grep default | awk '{print $5}')"
  echo ""
  echo "🌐 DNS Servers:"
  grep "nameserver" /etc/resolv.conf | awk '{print "   "$2}'
  echo ""
}

# === System Functions ===

# Update everything (system, plugins, tools)
update-all() {
  echo "🔄 Updating system packages..."
  sudo pacman -Syu --noconfirm
  
  echo "\n🔄 Updating Zinit plugins..."
  zinit self-update && zinit update --parallel
  
  if command -v pnpm >/dev/null; then
    echo "\n🔄 Updating global pnpm packages..."
    pnpm update -g
  fi
  
  echo "\n✅ All updates complete!"
}

# Clean system caches
clean-cache() {
  echo "🧹 Cleaning package cache..."
  sudo pacman -Sc --noconfirm
  
  echo "🧹 Cleaning user cache..."
  rm -rf "$XDG_CACHE_HOME/thumbnails"/*
  rm -rf "$HOME/.cache/mozilla"
  
  echo "🧹 Cleaning zsh cache..."
  rm -f "$XDG_CACHE_HOME"/zsh/zcompdump*
  
  echo "✅ Cache cleaned!"
}

# -----------------------------------------------------------------------------
# 12) Security & Cleanup
# -----------------------------------------------------------------------------

# Secure sudo timeout (15 minutes)
export SUDO_TIMEOUT=15

# Clear old zsh compilation files on startup (older than 7 days)
find "$XDG_CACHE_HOME/zsh" -name "*.zwc" -mtime +7 -delete 2>/dev/null

# Compile .zshrc for faster loading on next startup
if [[ ! -f "$HOME/.zshrc.zwc" || "$HOME/.zshrc" -nt "$HOME/.zshrc.zwc" ]]; then
  zcompile "$HOME/.zshrc" &>/dev/null &!
fi

# -----------------------------------------------------------------------------
# 13) Command-not-found handler (Arch/pacman)
# -----------------------------------------------------------------------------
[[ -r /usr/share/doc/pkgfile/command-not-found.zsh ]] \
  && source /usr/share/doc/pkgfile/command-not-found.zsh

# -----------------------------------------------------------------------------
# End of .zshrc
# =============================================================================