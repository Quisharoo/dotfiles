# dotfiles structure

This repository holds my personal dotfiles and macOS app preferences. Current top-level layout:

- `brew/`: Brewfile for Homebrew packages
- `home/`: symlinked dotfiles (.zshrc, .vimrc, .gitconfig, etc.)
- `prefs/`: macOS app preferences (iTerm2, Cursor, etc.)
- `config/`: tool config (example: `config/git/attributes`)
- `scripts/`: bootstrap and helper scripts
- `templates/`: templates such as `gitignore_global`

Note on secrets
- Do NOT commit API keys, private keys, passwords or other secrets.
- `home/.codex/tokens/` and `secrets/` are ignored by `.gitignore`.

Customize folders and add configs as needed.
