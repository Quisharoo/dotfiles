# Dotfiles

Personal macOS dotfiles, bootstrap script, and app preferences.

## Repository Layout
- `brew/`: Homebrew formulas, casks, and VS Code extensions
- `home/`: files symlinked into `$HOME` (shell configs, git settings, Claude prefs)
- `prefs/`: macOS application preferences (Cursor, iTerm2, etc.)
- `config/`: misc tool configs (e.g. git attributes)
- `scripts/`: bootstrap and helper scripts
- `templates/`: templates such as `gitignore_global`
- `docs/`: additional documentation (`docs/secrets.md`, `docs/inspirations.md`)

## Quick Start
### Prerequisites
- macOS (tested on Sonoma; other platforms exit early)
- Git
- Homebrew (recommended; optional steps are skipped if unavailable)
- `fd` (installed automatically via Brewfile) to support the default `fzf` command

### Setup
1. Clone the repo and enter it:
   ```bash
   git clone git@github.com:colm/dotfiles.git ~/code/dotfiles
   cd ~/code/dotfiles
   ```
2. Run the bootstrap script (use `--dry-run` first if you want a preview):
   ```bash
   ./scripts/bootstrap.sh --dry-run
   ./scripts/bootstrap.sh
   ```
3. When prompted, symlinked files will replace existing ones after creating timestamped backups.
4. The script offers to run `brew bundle --file=brew/Brewfile`; accept to install CLI tools, casks, and VS Code extensions in one go.

### Brewfile Notes
- Sections are grouped by purpose (CLI essentials, developer tooling, shell enhancements, AI utilities).
- Commented hints mark optional installs such as `git-quick-stats`; remove lines you do not need before running `brew bundle`.
- Re-run `brew bundle check --file=brew/Brewfile` periodically to catch missing formulae or taps.

### Secrets & Sensitive Files
- `secrets/`, Codex runtime data (tokens, auth, sessions), and Claude cache files are ignored by git.
- Claude workspace preferences live in `home/.claude/CLAUDE.md` and `home/.claude/settings.json` so they sync across machines; keep other Claude outputs local.
- Keep API keys, tokens, and private keys out of the repo; use `secrets/` or your preferred secret manager.
- If sensitive files were committed previously, rotate the credentials and run `git filter-repo --path secrets/<file>` (or BFG) to scrub history.
- Optional encryption: consider `git-crypt` or `age` + `sops` for sharing secret files; document key distribution in `CONTRIBUTING.md` if adopted. See `docs/secrets.md` for workflow details and cleanup commands.

### Host-Specific Overrides & Apple Silicon
- Drop per-machine exports into `home/.zsh/env.d/*.zsh`; they load after the shared config (see `host-example.zsh`).
- Homebrew paths prefer `brew --prefix`, so `/opt/homebrew` (Apple Silicon) is automatic with `/usr/local` as fallback.
- Node shells use `fnm` when available and fall back to the bundled `node@22`, eliminating manual version toggles.

## Troubleshooting
| Symptom | Fix |
| --- | --- |
| `Unsupported platform` error | Run on macOS or adjust the bootstrap script to handle your OS. |
| `Missing required dependency: git` | Install Git (`xcode-select --install` or `brew install git`) before running bootstrap. |
| `brew: command not found` warning | Install Homebrew to enable package installs, or ignore if you plan to manage packages manually. |
| Links not created in dry-run | Dry-run mode logs planned actions but skips filesystem changes—rerun without `--dry-run`. |

## Maintenance Tips
- Keep aliases and shell customizations modular in `home/.zsh/*.zsh`.
- Update `CONTRIBUTING.md` when you add new processes or tooling expectations.
- After updating ignore rules, double-check `git status` to ensure no secrets are tracked.
- Install `oh-my-zsh` and (optionally) `zplug`; the prompt uses Pure via zplug, but oh-my-zsh still manages core plugins.
