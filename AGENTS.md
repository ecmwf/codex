# AGENTS.md

Instructions for AI coding agents working in this repository.

## Checkouts of other repositories

Some skills here, such as `open-source-audit`, `security-audit` and
`review-pull-request`, work on another repository. For that work:

- **Never use an existing checkout of that repository.** The user's own clones
  may hold uncommitted work, or another session may be using them. Do not run
  commands in them, and never move, overwrite or delete them.
- **Make a fresh, temporary checkout** under `$TMPDIR/codex-audits/<repo>`. If
  `$TMPDIR` is not set, ask the user where temporary checkouts should go; do not
  guess.
- **If that folder already exists** and you did not create it in this session,
  ask before replacing it: another session may be using it.
- **Keep all side effects inside it.** Run installs, builds and tests there, and
  put scratch copies (for example, to test a suggested fix) under
  `$TMPDIR/codex-audits/` too.
- **Delete only what you created.** Before removing or replacing a folder,
  check that its path is inside `$TMPDIR/codex-audits/`. Never run `rm -rf` on
  any other path.
