# Contributing

Thanks for keeping these dotfiles tidy! Follow the guidelines below to avoid surprises when syncing across machines.

## Workflow
- Always run `./scripts/bootstrap.sh --dry-run` before applying changes; it validates symlinks without touching the filesystem.
- Stage files from `home/` only—these map directly to `$HOME`. Avoid editing symlinked targets in place.
- Use the provided commit template (`git commit` auto-populates from `home/.gitmessage`). Stick to the imperative mood and wrap at 72 chars.

## Documentation & Style
- Update `README.md` whenever you add a new dependency, bootstrap step, or troubleshooting tip.
- Prefer modular shell snippets under `home/.zsh/*.zsh`; create new files in `home/.zsh/env.d/` for host-specific overrides.
- Keep comments concise and focused on “why” rather than “what”.

## Testing
- Shell scripts: run `shellcheck scripts/*.sh` locally where possible.
- Bootstrap: after edits, run `./scripts/bootstrap.sh --dry-run` and then without `--dry-run` if you’re confident.
- Brewfile: validate with `brew bundle check --file=brew/Brewfile` to ensure formulas resolve.

## Secrets & Security
- Never commit credentials—`secrets/` and runtime Codex/Claude artifacts are ignored by default.
- If something sensitive slips into history, rotate it immediately and run `git filter-repo` (see README notes).
- Use optional tools like `git-crypt` or `age` if you need to store encrypted secrets; document usage when adding.

## Release Hygiene
- Tag meaningful milestones (e.g., after large shell or bootstrap overhauls).
- Update or append to a future `CHANGELOG.md` once version tracking lands (see roadmap).
