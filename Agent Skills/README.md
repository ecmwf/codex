# Agent Skills

Reusable AI-agent skills that support ECMWF software governance processes. These
skills are AI agents and operate under the
[AI Contributions to Software](../Guidelines/Ai-Contributions-To-Software.md)
guidelines: they keep a human in the loop, and they **report and gate rather
than act** — they never merge, fix, or publish on their own.

## Skills

- [`open-source-audit`](./open-source-audit/SKILL.md) — technical open-source
  compliance audit of a repository. Run before it is made public, and re-run any
  time to confirm an already-public repository still complies. Checks repository
  contents against the Codex open-sourcing guidance and common publication
  risks, including licensing, README/maturity information, full-history secret
  scanning, dependency licence review, git-history hygiene, and CI
  configuration. It prompts for a separate `security-audit` (required before
  publication); a not-yet-run security audit is advisory, a NOT_READY one is a
  blocker.
- [`security-audit`](./security-audit/SKILL.md) — risk-tiered security audit of
  a repository, run before publication (the security step of the open-source
  audit) and periodically afterwards. Builds a threat model,
  runs SAST / dependency / supply-chain tooling, reviews security-sensitive
  surfaces, and for high-risk repositories adds adversarial testing and bounded
  fuzzing. Produces a CWE-tagged pass/fail report.

## Format and portability

Skills here follow the [Agent Skills](https://www.anthropic.com/news/skills)
convention: a self-contained folder with a `SKILL.md` file whose YAML
frontmatter carries a `name` and a `description` of when to use the skill,
followed by plain-Markdown instructions.

There is no cross-vendor standard for agent skills yet, so we author them to be
**model-agnostic** — the same `SKILL.md` should work with Claude, OpenAI GPT and
Google Gemini agents. To keep a skill maximally portable:

- **Treat the frontmatter as metadata, not logic.** Keep it to `name` and
  `description`. A harness that does not parse frontmatter simply sees it as
  leading text, which is harmless. Never place an instruction that appears
  *only* in the frontmatter — restate the trigger in the first paragraph of the
  body so nothing is lost if the frontmatter is ignored or stripped.
- **Keep the body self-contained plain Markdown.** It must read correctly on its
  own, using imperative prose and standard Markdown — no provider-specific
  markup (no XML-style tags, no vendor-only directives).
- **Reference tools generically.** Prefer portable shell commands (`gitleaks`,
  `git log`, `gh api`) over "use the *X* tool", so the skill does not depend on
  one agent's tool names or calling convention.
- **Avoid provider-specific frontmatter keys** (for example `allowed-tools`). If
  a capability or constraint matters, describe it in prose instead.

How to supply a skill to each agent:

- **Claude / Claude Code / Claude Agent SDK** — place the skill folder in the
  agent's skills directory; the frontmatter is discovered automatically and the
  body is loaded on demand.
- **OpenAI GPT (Assistants, custom GPTs, Codex CLI)** — provide `SKILL.md` as a
  developer/system message, or attach it as context/a file. The body works
  as-is.
- **Google Gemini (Gems, API system instructions)** — provide `SKILL.md` as a
  system instruction or attached file.
