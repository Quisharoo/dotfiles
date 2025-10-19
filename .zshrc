# ========================================
# zplug Configuration
# ========================================

# Check if zplug is installed
if [[ ! -d ~/.zplug ]]; then
  git clone https://github.com/zplug/zplug ~/.zplug
  source ~/.zplug/init.zsh && zplug update --self
fi

# Initialize zplug
source ~/.zplug/init.zsh

# ========================================
# Plugins
# ========================================

# Async for zsh, used by pure
zplug "mafredri/zsh-async", from:github, defer:0

# Pure prompt theme
zplug "sindresorhus/pure", use:pure.zsh, from:github, as:theme

# Fish-like autosuggestions
zplug "zsh-users/zsh-autosuggestions", from:github, defer:2

# Syntax highlighting (must be loaded after other plugins)
zplug "zsh-users/zsh-syntax-highlighting", from:github, defer:3

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install zplug plugins? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# Load plugins
zplug load

# ========================================
# General Settings
# ========================================

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS

# Directory navigation
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# Completion
autoload -Uz compinit
compinit

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# ========================================
# Tool Integrations
# ========================================

# fzf - Fuzzy finder
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# zoxide - Smarter cd command
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

# thefuck - Correct previous console command
if command -v thefuck &> /dev/null; then
  eval "$(thefuck --alias)"
fi

# starship - Cross-shell prompt (optional, conflicts with pure)
# Uncomment the line below to use starship instead of pure prompt
# eval "$(starship init zsh)"

# ========================================
# Aliases
# ========================================

# Modern replacements for classic commands
if command -v eza &> /dev/null; then
  alias ls='eza'
  alias ll='eza -l'
  alias la='eza -la'
  alias lt='eza --tree'
fi

if command -v bat &> /dev/null; then
  alias cat='bat'
fi

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --all'

# Directory navigation with zoxide
if command -v zoxide &> /dev/null; then
  alias cd='z'
fi

# ========================================
# Environment Variables
# ========================================

# Set default editor
export EDITOR='vim'

# Add local bin to PATH if it exists
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"

# ========================================
# Custom Functions
# ========================================

# Create directory and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Quick search with ripgrep and fzf
rgs() {
  rg --color=always --line-number --no-heading --smart-case "${*:-}" |
    fzf --ansi \
        --color "hl:-1:underline,hl+:-1:underline:reverse" \
        --delimiter : \
        --preview 'bat --color=always {1} --highlight-line {2}' \
        --preview-window 'up,60%,border-bottom,+{2}+3/3,~3'
}
