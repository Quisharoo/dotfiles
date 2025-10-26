# ---------------------------------------
# Fast, stable shell. No NVM. No wrappers.
# Prereqs once:
#   brew install node@22 && brew link --overwrite --force node@22
#   mkdir -p ~/.npm-global && echo "prefix=$HOME/.npm-global" >> ~/.npmrc
# ---------------------------------------

# VS Code shell integration
if [ -n "$VSCODE_SHELL_INTEGRATION" ]; then
  source "/Applications/Visual Studio Code.app/Contents/Resources/app/out/vs/workbench/contrib/terminal/common/scripts/shellIntegration-rc.zsh"
fi

# Exit early for non-interactive shells
[[ $- != *i* ]] && return

# Core PATH. Apple Silicon first. User npm globals next.
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$HOME/.npm-global/bin:$PATH"

# Docker and Bun
export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Editor defaults and aliases
if command -v code >/dev/null 2>&1; then
  export EDITOR="code -w"
  export VISUAL="code -w"
  code_cmd=$(command -v code)
else
  export EDITOR="nano"
  export VISUAL="nano"
  code_cmd="/usr/local/bin/code"
fi
alias vim='code'
alias vi='code'
alias nano='code'
alias code="$code_cmd"
alias cursor="$(command -v cursor 2>/dev/null || echo /usr/local/bin/cursor)"
alias cursorapp="open -a Cursor"

# thefuck (optional)
if command -v thefuck >/dev/null 2>&1; then
  eval "$(thefuck --alias)"
fi

# Oh My Zsh - lean
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
plugins=(git)
source "$ZSH/oh-my-zsh.sh"

# zplug (optional, fast)
if command -v brew >/dev/null 2>&1; then
  HOMEBREW_PREFIX="$(brew --prefix 2>/dev/null)"
  export ZPLUG_HOME="$HOMEBREW_PREFIX/opt/zplug"
fi
if [ -d "$ZPLUG_HOME" ]; then
  source "$ZPLUG_HOME/init.zsh"
  zplug "zsh-users/zsh-syntax-highlighting", from:github, as:plugin, defer:2
  zplug "zsh-users/zsh-autosuggestions",     from:github, as:plugin, defer:2
  zplug load
fi

# Fallback plugin sourcing if zplug not present
[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Completions
if command -v brew >/dev/null 2>&1 && [ -d "$(brew --prefix)/share/zsh/site-functions" ]; then
  fpath+=("$(brew --prefix)/share/zsh/site-functions")
fi
autoload -U compinit
compinit -C

# Completion tuning
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' 'r:|[._-]=**' 'l:|=* r:|=*'
zstyle ':completion:*' completer _complete _approximate
zstyle ':completion:*:approximate:*' max-errors 2 numeric
setopt AUTO_MENU MENU_COMPLETE LIST_AMBIGUOUS
bindkey '^I' expand-or-complete
setopt CORRECT

# Prompt once
autoload -U promptinit; promptinit
prompt pure

# fzf + fd
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh) 2>/dev/null || true
  if command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND="fd --type f --strip-cwd-prefix"
  fi
fi

# iTerm2 integration and dynamic badge
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh" || true
itab() { printf "\033]1337;SetBadgeFormat=%s\a" "$(printf "%s" "$1" | base64)"; }
precmd() {
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    local repo branch
    repo=$(basename "$(git rev-parse --show-toplevel)")
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    itab "${repo}:${branch}"
  else
    itab ""
  fi
}

# Conda lazy source without wrappers
if [ -f "$HOME/anaconda3/etc/profile.d/conda.sh" ]; then
  . "$HOME/anaconda3/etc/profile.d/conda.sh"
elif [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
  . "$HOME/miniconda3/etc/profile.d/conda.sh"
fi
