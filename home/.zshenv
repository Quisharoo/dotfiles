. "$HOME/.cargo/env"
# Source Cargo env if present (guarded)
if [ -f "$HOME/.cargo/env" ]; then
	# shellcheck source=/dev/null
	source "$HOME/.cargo/env"
fi

# Prefer user-specified editor; fall back to VS Code CLI
export EDITOR="${EDITOR:-code -w}"
export VISUAL="${VISUAL:-code -w}"

# Ensure $HOME/.local/bin is on PATH (but avoid duplicates)
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
	PATH="$HOME/.local/bin:$PATH"
fi

# Prefer Homebrew bin (Apple Silicon) then Intel, if installed
if [ -d "/opt/homebrew/bin" ] && [[ ":$PATH:" != *":/opt/homebrew/bin:"* ]]; then
	PATH="/opt/homebrew/bin:$PATH"
elif [ -d "/usr/local/bin" ] && [[ ":$PATH:" != *":/usr/local/bin:"* ]]; then
	PATH="/usr/local/bin:$PATH"
fi

export PATH
