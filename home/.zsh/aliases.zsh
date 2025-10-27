# Common aliases sourced from ~/.zshrc

# Editor wrappers
alias vim='code'
alias vi='code'
alias nano='code'

# Prefer the discovered code CLI when available so this works across machines
alias code="$code_cmd"

# Cursor helpers
alias cursor="$(command -v cursor 2>/dev/null || echo /usr/local/bin/cursor)"
alias cursorapp="open -a Cursor"

# Optional: helper to open Snazzy iTerm2 colors (run once manually)
alias iterm-snazzy='(curl -Ls https://raw.githubusercontent.com/sindresorhus/iterm2-snazzy/main/Snazzy.itermcolors > /tmp/Snazzy.itermcolors && open /tmp/Snazzy.itermcolors)'
