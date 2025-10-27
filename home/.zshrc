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

# --- Node versioning (fnm) ---
if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd --version-file-strategy recursive --shell zsh)"
else
  export PATH="/opt/homebrew/opt/node@22/bin:$PATH"
fi

export NPM_CONFIG_PREFIX="$HOME/.npm-global"
export PATH="$HOME/.npm-global/bin:$PATH"


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


# Editor aliases live in ~/.zsh/aliases.zsh to keep this file slim
ALIASES_FILE="$HOME/.zsh/aliases.zsh"
[ -f "$ALIASES_FILE" ] && source "$ALIASES_FILE"

# Host- / project-specific environment overrides in ~/.zsh/env.d/*.zsh
if [ -d "$HOME/.zsh/env.d" ]; then
  for env_file in "$HOME/.zsh/env.d"/*.zsh; do
    [ -f "$env_file" ] || continue
    source "$env_file"
  done
fi

# 'thefuck' utility alias (only enable if installed)
if command -v thefuck >/dev/null 2>&1; then
  eval "$(thefuck --alias)"
fi

# --- oh-my-zsh + plugins ---
export ZSH="$HOME/.oh-my-zsh"
# Keep oh-my-zsh theme disabled because Pure handles the prompt
ZSH_THEME=""
plugins=(git colored-man-pages colorize pip python brew macos)

if [ -d "$ZSH" ]; then
  source "$ZSH/oh-my-zsh.sh"
else
  echo "oh-my-zsh not found at $ZSH" >&2
fi

# --- zplug (for Pure + extra plugins) ---
if command -v brew >/dev/null 2>&1; then
  HOMEBREW_PREFIX=$(brew --prefix)
  export ZPLUG_HOME="$HOMEBREW_PREFIX/opt/zplug"
fi
export ZPLUG_HOME="${ZPLUG_HOME:-$HOME/.zplug}"

if [ -d "$ZPLUG_HOME" ]; then
  source "$ZPLUG_HOME/init.zsh"

  zplug "mafredri/zsh-async", from:github
  zplug "sindresorhus/pure", from:github, use:pure.zsh, as:theme

  # Only load syntax highlighting/autosuggestions via zplug if oh-my-zsh plugin is inactive
  if ! [[ " ${plugins[*]} " == *" zsh-syntax-highlighting "* ]]; then
    zplug "zsh-users/zsh-syntax-highlighting", from:github, as:plugin, defer:2
  fi
  if ! [[ " ${plugins[*]} " == *" zsh-autosuggestions "* ]]; then
    zplug "zsh-users/zsh-autosuggestions",     from:github, as:plugin, defer:2
  fi

  if ! zplug check >/dev/null 2>&1; then
    mkdir -p "$HOME/.cache" 2>/dev/null || true
    touch "$HOME/.cache/zplug-missing" 2>/dev/null || true
  else
    rm -f "$HOME/.cache/zplug-missing" 2>/dev/null || true
  fi

  zplug load
else
  echo "zplug not detected; skipping plugin load." >&2
fi

# If a previous run detected missing plugins, show a quiet one-time hint (then remove marker)
if [ -f "$HOME/.cache/zplug-missing" ] && [ -t 1 ]; then
  # Remove marker first to avoid multiple concurrent shells printing the message
  rm -f "$HOME/.cache/zplug-missing" 2>/dev/null || true
  echo "zplug: some plugins are missing. Run 'zplug install' to install them. (Shown once until plugins are installed.)"
fi

# Optional: helper to open Snazzy iTerm2 colors (run once manually)
# (moved to ~/.zsh/aliases.zsh)
#####################################################################

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh" || true


# bun completions
[ -s "/Users/colm/.bun/_bun" ] && source "/Users/colm/.bun/_bun"



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


autoload -U promptinit; promptinit; prompt pure  # Pure handled via zplug
source <(fzf --zsh)
# Use fd for faster file listings in fzf (requires fd to be installed)
export FZF_DEFAULT_COMMAND="fd --type f --strip-cwd-prefix"
