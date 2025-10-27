# Secrets & Sensitive Config Handling

Use this guide whenever you introduce files that contain credentials, tokens, or machine-specific secrets.

## Default Layout
- `secrets/`: local-only secrets. Files stay untracked because `.gitignore` ignores the directory.
- `home/.codex/` & `home/.claude/`: only the configuration files committed in git are synced. Runtime logs, auth tokens, and history remain ignored.
- `home/.zsh/env.d/`: host overrides. Keep secrets out of these files unless they are encrypted (see below).

## Recommended Workflow
1. **Keep secrets out of git** – prefer environment variables, password managers, or `secrets/` files that never leave your machine.
2. **If you must share secrets**, encrypt them before committing:
   - `git-crypt` for transparent encryption tied to GPG or symmetric keys.
   - `rage/age` + `sops` for file-level encryption managed in code.
3. **Document key distribution** – record who has access and where keys live (not in the repo).
4. **Rotate immediately** if a secret leaks. Update the secret, then purge history.

## Purging Accidental Commits
Use [`git filter-repo`](https://github.com/newren/git-filter-repo) (recommended) or BFG Repo-Cleaner.

Example: remove a leaked token file everywhere in history.
```bash
git filter-repo --path secrets/api-key.txt --invert-paths
```
Afterwards:
1. Rotate the compromised secret.
2. Force-push (`git push --force-with-lease`).
3. Ask collaborators to run `git fetch --all` followed by `git reset --hard origin/<branch>`.

## Pre-Commit Hygiene
- Add file patterns to `.gitignore` and `templates/gitignore_global` when you notice new secret formats.
- Run `git status --ignored` if you want to confirm sensitive files stay untracked.
- Consider enabling a pre-commit hook that blocks commits containing `AWS_SECRET_ACCESS_KEY`, `PRIVATE KEY-----`, etc. (e.g., `detect-secrets`).
