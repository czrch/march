# -----------------------------------------------------------------------------
# 0) Environment (keep this file interactive-only)
# -----------------------------------------------------------------------------
[[ -f "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"

export TERMINAL=${TERMINAL:-kitty}
export EDITOR=${EDITOR:-nvim}
export VISUAL=${VISUAL:-nvim}
export PAGER=${PAGER:-less}

# XDG-ish locations
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
export HISTSIZE=200000
export SAVEHIST=200000
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt EXTENDED_HISTORY

# -----------------------------------------------------------------------------
# 2) Completion (fast + cached)
# -----------------------------------------------------------------------------
fpath=(/usr/share/zsh/site-functions $fpath)

autoload -Uz compinit
_compdump="$XDG_CACHE_HOME/zsh/zcompdump-${ZSH_VERSION}"
compinit -d "$_compdump" -C

zmodload zsh/complist
zstyle ':completion:*' menu select
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"
zstyle ':completion:*' completer _extensions _complete _approximate
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format '%F{green}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches --%f'
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

autoload -Uz bashcompinit && bashcompinit

# -----------------------------------------------------------------------------
# 3) Keybinds (sane defaults)
# -----------------------------------------------------------------------------
bindkey -e

# Enhanced keybinds
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^K' kill-line
bindkey '^U' backward-kill-line
bindkey '^W' backward-kill-word
bindkey '^[b' backward-word
bindkey '^[f' forward-word

# History substring search bindings (set after plugin loads)
_bind_history_search() {
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
  bindkey '^P' history-substring-search-up
  bindkey '^N' history-substring-search-down
}

# -----------------------------------------------------------------------------
# 4) FZF integration (guarded)
# -----------------------------------------------------------------------------
[[ -r /usr/share/fzf/completion.zsh    ]] && source /usr/share/fzf/completion.zsh
[[ -r /usr/share/fzf/key-bindings.zsh  ]] && source /usr/share/fzf/key-bindings.zsh

# Sensible defaults if fd/rg exist
if command -v fd >/dev/null; then
  export FZF_DEFAULT_COMMAND='fd --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# Enhanced FZF options
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
    zsh-users/zsh-autosuggestions \
  blockf atpull'zinit creinstall -q .' \
    zsh-users/zsh-completions \
  atload"_bind_history_search" \
    zsh-users/zsh-history-substring-search \
    hlissner/zsh-autopair \
    Aloxaf/fzf-tab \
  atinit"zicompinit; zicdreplay" \
    zdharma-continuum/fast-syntax-highlighting

# Useful tools & OMZ plugins
zinit wait lucid for \
    wfxr/forgit \
    MichaelAquilina/zsh-you-should-use \
  nocompile \
    OMZP::sudo \
    OMZP::colored-man-pages

# Docker completion (if needed)
if command -v docker >/dev/null; then
  zinit ice lucid wait'0a' as'completion'
  zinit snippet https://raw.githubusercontent.com/docker/cli/master/contrib/completion/zsh/_docker
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
fi

command -v direnv  >/dev/null && eval "$(direnv hook zsh)"

# Starship with cache
if command -v starship >/dev/null; then
  export STARSHIP_CACHE="$XDG_CACHE_HOME/starship"
  eval "$(starship init zsh)"
fi

# -----------------------------------------------------------------------------
# 7) Node: PNPM + lazy-load NVM (huge startup win)
# -----------------------------------------------------------------------------
export PNPM_HOME="$HOME/.local/share/pnpm"
path=("$PNPM_HOME" $path)

# Lazy NVM: only load when you actually run node/npm/npx/nvm
if [[ -r /usr/share/nvm/init-nvm.sh ]]; then
  _nvm_loaded=0
  _nvm_load() {
    (( _nvm_loaded )) && return 0
    source /usr/share/nvm/init-nvm.sh
    _nvm_loaded=1
  }
  nvm()  { _nvm_load; command nvm  "$@"; }
  node() { _nvm_load; command node "$@"; }
  npm()  { _nvm_load; command npm  "$@"; }
  npx()  { _nvm_load; command npx  "$@"; }
fi

# -----------------------------------------------------------------------------
# 8) Quality-of-life aliases (optional, keep minimal)
# -----------------------------------------------------------------------------
alias ls='eza --group-directories-first --icons=auto'
alias ll='eza -lah --group-directories-first --icons=auto'
alias cat='bat --paging=never'
alias grep='rg'
alias find='fd'
alias ..='cd ..'
alias ...='cd ../..'

# Modern tool replacements (if installed)
command -v duf    >/dev/null && alias df='duf'
command -v dust   >/dev/null && alias du='dust'
command -v btop   >/dev/null && alias top='btop'
command -v procs  >/dev/null && alias ps='procs'
command -v delta  >/dev/null && alias diff='delta'

# Zoxide shortcuts
alias zi='z -i'
alias zz='z -'

# -----------------------------------------------------------------------------
# 9) Smart completions
# -----------------------------------------------------------------------------
command -v gh >/dev/null && eval "$(gh completion -s zsh)"

# -----------------------------------------------------------------------------
# 10) Useful functions
# -----------------------------------------------------------------------------
# Create and cd into directory
mkcd() { mkdir -p "$1" && cd "$1" }

# Extract any archive
extract() {
  if [ -f "$1" ]; then
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
  else
    echo "File not found: $1"
  fi
}

# Git fuzzy checkout
gco() { 
  git branch -a | fzf --height=20% --reverse | sed 's/^[* ]*//' | sed 's/remotes\/origin\///' | xargs git checkout
}

# Git fuzzy show
gshow() { 
  git log --oneline --color=always | fzf --ansi --preview 'git show --color=always {1}' | awk '{print $1}' | xargs -r git show
}

# Fuzzy kill process
fkill() {
  local pid
  pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
  if [ "x$pid" != "x" ]; then
    echo $pid | xargs kill -${1:-9}
  fi
}

# Fuzzy file search and edit
fe() {
  local file
  file=$(fd --type f --hidden --follow --exclude .git | fzf --preview 'bat --color=always {}')
  [[ -n "$file" ]] && ${EDITOR:-vim} "$file"
}

# Update everything
update-all() {
  echo "🔄 Updating system packages..."
  sudo pacman -Syu --noconfirm
  
  echo "\n🔄 Updating Zinit plugins..."
  zinit self-update && zinit update --parallel
  
  command -v cargo >/dev/null && {
    echo "\n🔄 Updating Rust tools..."
    cargo install-update -a 2>/dev/null || echo "💡 Install cargo-update: cargo install cargo-update"
  }
  
  command -v pnpm >/dev/null && {
    echo "\n🔄 Updating global npm packages..."
    pnpm update -g
  }
  
  echo "\n✅ All updates complete!"
}

# Auto-activate Python venvs on directory change
autoload -U add-zsh-hook
_venv_auto_activate() {
  if [[ -f ".venv/bin/activate" ]]; then
    source .venv/bin/activate 2>/dev/null
  elif [[ -f "venv/bin/activate" ]]; then
    source venv/bin/activate 2>/dev/null
  fi
}
add-zsh-hook chpwd _venv_auto_activate

# -----------------------------------------------------------------------------
# 11) Command-not-found handler (Arch/pacman)
# -----------------------------------------------------------------------------
[[ -r /usr/share/doc/pkgfile/command-not-found.zsh ]] \
  && source /usr/share/doc/pkgfile/command-not-found.zsh
