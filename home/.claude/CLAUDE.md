# Claude Workspace Preferences

- Model: `claude-3.5-sonnet`
- Style: concise, actionable summaries first, implementation details second.
- Default command prefix: `/`
- Slash commands live in `home/.claude/commands/` and are synced via dotfiles.

## Command Guidelines
- Keep prompts self-contained so they work outside this repo.
- Document any required environment variables or dependencies inline.
- Use placeholders like `<branch>` or `<ticket-id>` rather than hard-coded values.
