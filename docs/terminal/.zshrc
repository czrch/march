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

# Recommended: allow '#' comments when pasting scripts
setopt INTERACTIVE_COMMENTS
# If you really want to disable interactive comments:
# unsetopt INTERACTIVE_COMMENTS

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
# System-wide completions + zsh-completions
fpath=(/usr/share/zsh/site-functions $fpath)

autoload -Uz compinit
# Use a per-version dump file in cache (faster startup, fewer permission issues)
_compdump="$XDG_CACHE_HOME/zsh/zcompdump-${ZSH_VERSION}"
# If you ever hit stale completion issues: rm -f "$_compdump"*
compinit -d "$_compdump" -C

# Helpful completion UX
zmodload zsh/complist 2>/dev/null
zstyle ':completion:*' menu select
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"
zstyle ':completion:*' completer _extensions _complete _approximate
zstyle ':completion:*:descriptions' format '%F{yellow}%d%f'
zstyle ':completion:*:messages' format '%F{green}%d%f'
zstyle ':completion:*:warnings' format '%F{red}%d%f'
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|[._-]=* r:|=*' \
  'l:|=* r:|=*'

# Enable bash completion compatibility when needed
autoload -Uz bashcompinit && bashcompinit

# -----------------------------------------------------------------------------
# 3) Keybinds (sane defaults + history substring search)
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

bindkey '^[[A' history-substring-search-up   2>/dev/null
bindkey '^[[B' history-substring-search-down 2>/dev/null

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
export FZF_DEFAULT_OPTS="
  --height 40% --layout=reverse --border
  --preview 'bat --color=always --style=numbers {}' 2>/dev/null
  --preview-window=right:60%:wrap
  --bind 'ctrl-/:toggle-preview'
  --bind 'ctrl-y:execute-silent(echo {} | xclip -selection clipboard)+abort'
"

export FZF_CTRL_T_OPTS="
  --preview 'bat --color=always --line-range :500 {}' 2>/dev/null
  --bind 'ctrl-/:change-preview-window(down|hidden|)'
"

export FZF_ALT_C_OPTS="
  --preview 'eza --tree --level=2 --color=always {} | head -200'
"

# -----------------------------------------------------------------------------
# 5) Plugins (Pacman/AUR paths) — load order matters
# -----------------------------------------------------------------------------
# Autosuggestions
[[ -r /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] \
  && source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# History substring search (nice with ↑/↓ bindings above)
[[ -r /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh ]] \
  && source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

# Autopair (optional)
[[ -r /usr/share/zsh/plugins/zsh-autopair/autopair.zsh ]] \
  && source /usr/share/zsh/plugins/zsh-autopair/autopair.zsh

# Fast syntax highlighting (preferred) OR fallback to classic syntax-highlighting
if [[ -r /usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh ]]; then
  source /usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
elif [[ -r /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  # Must be last among “visual” plugins
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
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
_nvm_loaded=0
_nvm_load() {
  (( _nvm_loaded )) && return 0
  [[ -r /usr/share/nvm/init-nvm.sh ]] && source /usr/share/nvm/init-nvm.sh
  _nvm_loaded=1
}
nvm()  { _nvm_load; command nvm  "$@"; }
node() { _nvm_load; command node "$@"; }
npm()  { _nvm_load; command npm  "$@"; }
npx()  { _nvm_load; command npx  "$@"; }

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
# GitHub CLI
command -v gh >/dev/null && eval "$(gh completion -s zsh)"

# Docker (if not in site-functions)
if command -v docker >/dev/null && [[ ! -r /usr/share/zsh/site-functions/_docker ]]; then
  mkdir -p "$XDG_DATA_HOME/zsh"
  docker completion zsh > "$XDG_DATA_HOME/zsh/_docker" 2>/dev/null
  fpath=("$XDG_DATA_HOME/zsh" $fpath)
fi

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

