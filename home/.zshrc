# VS Code shell integration
if [ -n "$VSCODE_SHELL_INTEGRATION" ]; then
  source "/Applications/Visual Studio Code.app/Contents/Resources/app/out/vs/workbench/contrib/terminal/common/scripts/shellIntegration-rc.zsh"
fi


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/colm/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/colm/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/colm/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/colm/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# Node Version Manager (NVM) initialization
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Editor environment
export EDITOR="code -w"
export VISUAL="code -w"

export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"


# Editor aliases
alias vim='code'
alias vi='code'
alias nano='code'
alias code="/usr/local/bin/code"         # Official VS Code CLI
alias cursor="/usr/local/bin/cursor"     # Cursor CLI
alias cursorapp="open -a Cursor"         # Cursor as macOS GUI app

# 'thefuck' utility alias
eval $(thefuck --alias)

# >>> oh-my-zsh begin >>>
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)

# Disable OMZ theme so "pure" can control the prompt (addition)
ZSH_THEME=""

source $ZSH/oh-my-zsh.sh
# <<< oh-my-zsh end <<<

########## Additions for "Beautify your iTerm2 and prompt" ##########
# zplug (plugin manager used by the guide) - load if installed
if command -v brew >/dev/null 2>&1; then
  export ZPLUG_HOME="$(brew --prefix)/opt/zplug"
fi

if [ -d "$ZPLUG_HOME" ]; then
  source "$ZPLUG_HOME/init.zsh"

  # Async helper required by pure
  zplug "mafredri/zsh-async", from:github

  # Minimalistic "pure" prompt
  zplug "sindresorhus/pure", use:pure.zsh, from:github, as:theme

  # Bonus plugins from the article
  zplug "zsh-users/zsh-syntax-highlighting", from:github, as:plugin, defer:2
  zplug "zsh-users/zsh-autosuggestions",     from:github, as:plugin, defer:2

  # Install on first run (interactive shells)
  if ! zplug check --verbose; then
    if [ -t 1 ]; then
      printf "zplug: install plugins? [y/N]: "
      read -r -q && echo && zplug install
    fi
  fi

  # Activate
  zplug load
fi

# Optional: helper to open Snazzy iTerm2 colors (run once manually)
alias iterm-snazzy='(curl -Ls https://raw.githubusercontent.com/sindresorhus/iterm2-snazzy/main/Snazzy.itermcolors > /tmp/Snazzy.itermcolors && open /tmp/Snazzy.itermcolors)'
#####################################################################

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh" || true


# bun completions
[ -s "/Users/colm/.bun/_bun" ] && source "/Users/colm/.bun/_bun"

# Homebrew plugin sourcing with guards
if command -v brew >/dev/null 2>&1; then
  BREW_PREFIX="$(brew --prefix)"
  AUTOSUG="$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  HILITE="$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  [ -f "$AUTOSUG" ] && ! typeset -f _zsh_autosuggest_start >/dev/null && source "$AUTOSUG"
  [ -f "$HILITE" ] && ! typeset -f _zsh_highlight >/dev/null && source "$HILITE"
fi

export PATH=/opt/homebrew/bin:/opt/homebrew/sbin:$PATH
export PATH=/opt/homebrew/bin:/opt/homebrew/sbin:$PATH

# zsh plugins (Intel Homebrew paths)
if [ -f /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi
if [ -f /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
export FPATH="/usr/local/share/zsh/site-functions:$FPATH"
