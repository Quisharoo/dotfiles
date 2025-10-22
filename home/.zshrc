# VS Code shell integration
if [ -n "$VSCODE_SHELL_INTEGRATION" ]; then
  source "/Applications/Visual Studio Code.app/Contents/Resources/app/out/vs/workbench/contrib/terminal/common/scripts/shellIntegration-rc.zsh"
fi

# If this is not an interactive shell, stop early to avoid slow init in scripts
if [[ $- != *i* ]]; then
  return
fi

# Lazy-load conda on first use to keep interactive shells fast.
# This preserves conda functionality but delays sourcing the heavy init
# until the `conda` command is actually invoked.
if [ -d "$HOME/anaconda3" ] || [ -d "$HOME/miniconda3" ]; then
  _conda_init_path=""
  if [ -f "$HOME/anaconda3/etc/profile.d/conda.sh" ]; then
    _conda_init_path="$HOME/anaconda3/etc/profile.d/conda.sh"
  elif [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
    _conda_init_path="$HOME/miniconda3/etc/profile.d/conda.sh"
  fi

  if [ -n "$_conda_init_path" ]; then
    conda() {
      # remove this function and source the real conda initialization
      unset -f conda
      source "$_conda_init_path"
      # forward all arguments to the real conda
      conda "$@"
    }
  else
    # Fallback: if conda is on PATH, leave it alone; otherwise no-op
    if ! command -v conda >/dev/null 2>&1; then
      # no conda available; do nothing
      :
    fi
  fi
fi

# Node Version Manager (NVM) initialization — lazy-loaded to speed shell startup
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  # Helper that sources nvm.sh once and then removes itself
  _nvm_lazy_load() {
    unset -f _nvm_lazy_load
    # shellcheck source=/dev/null
    source "$NVM_DIR/nvm.sh"
  }

  # lazy-load nvm on first use
  nvm() {
    unset -f nvm
    _nvm_lazy_load
    nvm "$@"
  }

  # If node isn't already available, lazy-load when node/npm are invoked
  if ! command -v node >/dev/null 2>&1; then
    node() {
      unset -f node
      _nvm_lazy_load
      command node "$@"
    }
    npm() {
      unset -f npm
      _nvm_lazy_load
      command npm "$@"
    }
  fi
fi

# Editor environment
## make code CLI path portable (prefer system which, fallback to existing path)
if command -v code >/dev/null 2>&1; then
  export EDITOR="code -w"
  export VISUAL="code -w"
  code_cmd=$(command -v code)
else
  export EDITOR="code -w"
  export VISUAL="code -w"
  code_cmd="/usr/local/bin/code"
fi

export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"


# Editor aliases
alias vim='code'
alias vi='code'
alias nano='code'
# Prefer the discovered code CLI when available so this works across machines
alias code="$code_cmd"
alias cursor="$(command -v cursor 2>/dev/null || echo /usr/local/bin/cursor)"     # Cursor CLI
alias cursorapp="open -a Cursor"         # Cursor as macOS GUI app

# 'thefuck' utility alias (only enable if installed)
if command -v thefuck >/dev/null 2>&1; then
  eval "$(thefuck --alias)"
fi

# >>> oh-my-zsh begin >>>
export ZSH="$HOME/.oh-my-zsh"
# Let "pure" / prompt manager control the prompt — leave ZSH_THEME empty
ZSH_THEME=""
plugins=(git)

source $ZSH/oh-my-zsh.sh
# <<< oh-my-zsh end <<<

########## Additions for "Beautify your iTerm2 and prompt" ##########
## zplug (plugin manager used by the guide) - load if installed
if command -v brew >/dev/null 2>&1; then
  # prefer Apple Silicon prefix, fall back to Intel
  HOMEBREW_PREFIX=$(brew --prefix)
  export ZPLUG_HOME="$HOMEBREW_PREFIX/opt/zplug"
fi

if [ -d "$ZPLUG_HOME" ]; then
  source "$ZPLUG_HOME/init.zsh"

  # Async helper required by pure
  zplug "mafredri/zsh-async", from:github

  # Minimalistic "pure" prompt
  # (disabled) &

  # Bonus plugins from the article
  zplug "zsh-users/zsh-syntax-highlighting", from:github, as:plugin, defer:2
  zplug "zsh-users/zsh-autosuggestions",     from:github, as:plugin, defer:2

  # If plugins are missing, record a marker so the user can install later.
  # We intentionally do NOT auto-install here to avoid noisy background job output.
  if ! zplug check >/dev/null 2>&1; then
    mkdir -p "$HOME/.cache" 2>/dev/null || true
    touch "$HOME/.cache/zplug-missing" 2>/dev/null || true
  else
    rm -f "$HOME/.cache/zplug-missing" 2>/dev/null || true
  fi

  # Activate plugins synchronously so interactive features are available immediately
  zplug load
fi

# If a previous run detected missing plugins, show a quiet one-time hint (then remove marker)
if [ -f "$HOME/.cache/zplug-missing" ] && [ -t 1 ]; then
  # Remove marker first to avoid multiple concurrent shells printing the message
  rm -f "$HOME/.cache/zplug-missing" 2>/dev/null || true
  echo "zplug: some plugins are missing. Run 'zplug install' to install them. (Shown once until plugins are installed.)"
fi

# Optional: helper to open Snazzy iTerm2 colors (run once manually)
alias iterm-snazzy='(curl -Ls https://raw.githubusercontent.com/sindresorhus/iterm2-snazzy/main/Snazzy.itermcolors > /tmp/Snazzy.itermcolors && open /tmp/Snazzy.itermcolors)'
#####################################################################

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh" || true


# bun completions
[ -s "/Users/colm/.bun/_bun" ] && source "/Users/colm/.bun/_bun"



# zsh plugins (Homebrew paths — include Apple Silicon prefix)
if [ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
elif [ -f /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi
if [ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [ -f /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
export FPATH="/opt/homebrew/share/zsh/site-functions:/usr/local/share/zsh/site-functions:$FPATH"


### BEGIN: enhanced autocomplete setup

# Initialise completions with caching (faster startup)
autoload -U compinit
# Use compinit's cache file to avoid expensive rechecks; fall back to normal compinit
if [[ -w ${ZDOTDIR:-$HOME} ]]; then
  compinit -C
else
  compinit
fi

# Fuzzy and case-insensitive matching
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' 'r:|[._-]=**' 'l:|=* r:|=*'
zstyle ':completion:*' completer _complete _approximate
zstyle ':completion:*:approximate:*' max-errors 2 numeric

# Tab-cycling behaviour
setopt AUTO_MENU
setopt MENU_COMPLETE
setopt LIST_AMBIGUOUS
bindkey '^I' expand-or-complete

# Typo correction
setopt CORRECT
setopt CORRECT_ALL

# Extra completions (Homebrew)
if [ -d "$(brew --prefix)/share/zsh-completions" ]; then
  fpath+=("$(brew --prefix)/share/zsh-completions")
fi

### END: enhanced autocomplete setup


autoload -U promptinit; promptinit; prompt pure
