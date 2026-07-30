# Agent Skills

Reusable AI-agent skills that support ECMWF software governance processes.

These skills are AI agents and operate under the
[AI Contributions to Software](../../Guidelines/Ai-Contributions-To-Software.md)
guidelines: they keep a human in the loop, and they **report and gate rather
than act** — they never merge, fix, or publish on their own.

## Contents

- [Available skills](#available-skills)
- [What a skill is](#what-a-skill-is)
- [Authoring a skill](#authoring-a-skill)
  - [Directory layout](#directory-layout)
  - [Frontmatter](#frontmatter)
  - [Writing the body](#writing-the-body)
  - [Progressive disclosure and size budgets](#progressive-disclosure-and-size-budgets)
  - [Validation](#validation)
- [ECMWF house rules](#ecmwf-house-rules)
- [Installing a skill](#installing-a-skill)
- [Contributing a skill](#contributing-a-skill)

## Available skills

- [`open-source-audit`](./open-source-audit/SKILL.md) — technical open-source
  compliance audit of a repository. Run before it is made public, and re-run any
  time to confirm an already-public repository still complies. Checks repository
  contents against the Codex open-sourcing guidance and common publication
  risks, including licensing, README/maturity information, full-history secret
  scanning, dependency licence review, git-history hygiene, and CI
  configuration. It prompts for a separate `security-audit` (required before
  publication). A not-yet-run security audit is advisory; a security audit that
  has been run and whose verdict is `NOT_READY` (i.e. it has open CRITICAL/HIGH
  findings — see the `security-audit` skill) is a blocker.
- [`security-audit`](./security-audit/SKILL.md) — risk-tiered security audit of
  a repository, run before publication (the security step of the open-source
  audit) and periodically afterwards. Builds a threat model, runs SAST /
  dependency / supply-chain tooling, reviews security-sensitive surfaces, and
  for high-risk repositories adds adversarial testing and bounded fuzzing.
  Produces a CWE-tagged pass/fail report.

## What a skill is

A skill is a self-contained folder containing a `SKILL.md` file: YAML
frontmatter carrying a `name` and a `description`, followed by plain-Markdown
instructions. Agents load skills *progressively* — the description is read at
startup so the agent knows the skill exists, and the body is loaded only when
the skill is actually needed.

Skills in this directory follow the
**[Agent Skills specification](https://agentskills.io/specification)**, an
open, cross-vendor format supported by a wide range of agent products. Writing
to the specification is what makes a skill portable: the same folder works in
Claude Code, OpenCode, GitHub Copilot, Cursor, Gemini CLI and others without
modification.

## Authoring a skill

### Directory layout

At minimum a skill is a directory with a `SKILL.md`. Everything else is
optional:

```
skill-name/
├── SKILL.md          # required: frontmatter + instructions
├── scripts/          # optional: executable helpers the agent can run
├── references/       # optional: detailed docs, loaded on demand
└── assets/           # optional: templates, schemas, lookup data
```

- **`scripts/`** — self-contained executables, with documented dependencies,
  helpful error messages, and graceful handling of edge cases.
- **`references/`** — detail that would bloat `SKILL.md`. Keep each file
  focused; the agent loads them only when required, so smaller files cost less
  context.
- **`assets/`** — static resources such as report templates or schemas.

### Frontmatter

| Field           | Required | Constraints |
| --------------- | -------- | ----------- |
| `name`          | Yes      | 1–64 characters. Lowercase letters, digits and single hyphens only. Must not start or end with a hyphen, must not contain `--`, and **must match the parent directory name**. |
| `description`   | Yes      | 1–1024 characters. Describes **what** the skill does and **when** to use it. |
| `license`       | No       | Licence name, or a reference to a bundled licence file. |
| `compatibility` | No       | Max 500 characters. Environment requirements — required tools, network access, intended product. Most skills do not need this. |
| `metadata`      | No       | Arbitrary string-to-string map. Use reasonably unique keys to avoid collisions. |
| `allowed-tools` | No       | Space-separated pre-approved tools. **Experimental** — support varies between agents; prefer describing constraints in prose. |

The regex a valid `name` must satisfy is `^[a-z0-9]+(-[a-z0-9]+)*$`.

The `description` is the single most important field: it is what an agent sees
when deciding whether the skill is relevant. State the trigger explicitly and
include the keywords a user would actually type.

```yaml
# Good — says what it does and when to reach for it
description: >-
  Audits a repository for open-source publication readiness: licensing,
  per-file headers, secret scanning across full git history, and CI
  configuration. Use before making a repository public, or to re-check an
  already-public repository.

# Poor — an agent cannot tell when this applies
description: Helps with audits.
```

### Writing the body

The Markdown after the frontmatter is the instruction set. There are no format
restrictions, but the following work well:

- **Imperative, step-by-step instructions.** Say what to do, in order.
- **Explicit decision rules.** State what is a blocker versus advisory, what
  severity applies, and what the agent must never do. Ambiguity is where agents
  drift.
- **Worked examples** of inputs and outputs, and the common edge cases.
- **Stop conditions.** For any loop, state precisely what terminates it.
- **Restate the trigger in the first paragraph.** If a harness ignores or
  strips frontmatter, an instruction that existed only there is lost.

Reference other files by relative path from the skill root, and keep references
one level deep — avoid chains of files that each point to another:

```markdown
See [the reporting format](references/REPORT-FORMAT.md) for the full schema.
Run `scripts/collect-evidence.sh` to gather the raw findings.
```

### Progressive disclosure and size budgets

Agents load a skill in three stages, so structure it accordingly:

| Stage | What loads | Budget |
| ----- | ---------- | ------ |
| 1. Metadata | `name` + `description`, for **every** installed skill, at startup | ~100 tokens |
| 2. Instructions | the whole `SKILL.md` body, once the skill is activated | < 5000 tokens recommended |
| 3. Resources | files under `scripts/`, `references/`, `assets/`, on demand | as needed |

Keep `SKILL.md` **under 500 lines**. If it grows past that, move detailed
reference material into `references/`. Stage 1 is charged against every session
whether or not the skill is used, so a bloated description has a cost across the
board.

### Validation

Validate a skill against the specification with the
[`skills-ref`](https://github.com/agentskills/agentskills/tree/main/skills-ref)
reference library:

```bash
skills-ref validate ./skill-name
```

This checks the frontmatter and the naming rules. Run it before opening a pull
request.

## ECMWF house rules

On top of the specification, skills in this directory must:

- **Report and gate, never act.** A governance skill produces a verdict and
  evidence. It does not merge pull requests, publish artefacts, rotate
  credentials, or change repository visibility. Those remain human decisions,
  per [AI Contributions to Software](../../Guidelines/Ai-Contributions-To-Software.md).
- **Be model-agnostic.** The same `SKILL.md` should work with any competent
  agent. No provider-specific markup, no XML-style tags, no vendor-only
  directives.
- **Reference tools generically.** Prefer portable commands (`git log`,
  `gh api`, `gitleaks`) over "use the *X* tool", so a skill does not depend on
  one agent's tool names or calling convention.
- **Never invent findings, and never hide them.** Distinguish what was checked
  and passed from what could not be checked. If something could not be
  verified, say so explicitly rather than reporting it as a pass.
- **Keep secrets out of output.** Redact credential values in any report; never
  reproduce a live secret, even one already committed.
- **Use British English** in prose, consistent with the rest of the Codex.
  (Field names from the specification — `license`, `allowed-tools` — keep their
  original spelling.)
- **Be project-agnostic.** A skill here is meant to be reused across ECMWF
  repositories and adapted outside them. Discover the repository's own build,
  test and documentation layout rather than hard-coding paths, tool names or
  organisation names.

## Installing a skill

A skill is installed by placing its folder where the agent looks for skills.
The layout inside the folder never changes — only the parent directory differs
between products, and several products additionally read each other's
locations.

**Common locations**

| Scope | Path | Read by |
| ----- | ---- | ------- |
| Vendor-neutral, project | `.agents/skills/<name>/SKILL.md` | OpenCode, and other agent-compatible clients |
| Vendor-neutral, global | `~/.agents/skills/<name>/SKILL.md` | as above |
| Claude-compatible, project | `.claude/skills/<name>/SKILL.md` | Claude Code, OpenCode |
| Claude-compatible, global | `~/.claude/skills/<name>/SKILL.md` | Claude Code, OpenCode |
| OpenCode, project | `.opencode/skills/<name>/SKILL.md` | OpenCode |
| OpenCode, global | `~/.config/opencode/skills/<name>/SKILL.md` | OpenCode |

Prefer the **vendor-neutral `.agents/skills/`** path where the harness supports
it, and commit project-scoped skills to the repository so the whole team gets
them.

For example, to install the `open-source-audit` skill into a repository for any
agent-compatible client:

```bash
mkdir -p .agents/skills
cp -r /path/to/codex/Agents/skills/open-source-audit .agents/skills/
```

**Per-product setup instructions**

Support and exact paths are defined by each product. Consult the official
documentation:

| Product | Setup instructions |
| ------- | ------------------ |
| Claude Code | <https://code.claude.com/docs/en/skills> |
| Claude | <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview> |
| OpenCode | <https://opencode.ai/docs/skills/> |
| GitHub Copilot | <https://docs.github.com/en/copilot/concepts/agents/about-agent-skills> |
| VS Code | <https://code.visualstudio.com/docs/copilot/customization/agent-skills> |
| Cursor | <https://cursor.com/docs/context/skills> |
| Gemini CLI | <https://geminicli.com/docs/cli/skills/> |
| OpenAI Codex | <https://developers.openai.com/codex/skills/> |
| JetBrains Junie | <https://junie.jetbrains.com/docs/agent-skills.html> |
| Goose | <https://block.github.io/goose/docs/guides/context-engineering/using-skills/> |
| Amp | <https://ampcode.com/manual#agent-skills> |
| Factory | <https://docs.factory.ai/cli/configuration/skills> |
| Roo Code | <https://docs.roocode.com/features/skills> |
| OpenHands | <https://docs.openhands.dev/overview/skills> |
| Kiro | <https://kiro.dev/docs/skills/> |

The full, current list of products supporting the format is maintained at
<https://agentskills.io/clients>.

Some harnesses gate skill loading behind permissions. OpenCode, for example,
controls this through `opencode.json`:

```json
{
  "permission": {
    "skill": { "*": "allow" }
  }
}
```

If a skill does not appear: check that the file is named `SKILL.md` in capitals,
that the frontmatter has both `name` and `description`, that `name` matches the
directory name, and that the name is unique across all searched locations.

## Contributing a skill

1. Create `Agents/skills/<name>/SKILL.md`, with `name` matching the directory.
2. Write it to the specification and to the house rules above — project-agnostic,
   language-agnostic, report-and-gate.
3. Run `skills-ref validate ./Agents/skills/<name>` and keep `SKILL.md` under
   500 lines.
4. Add the skill to [Available skills](#available-skills) in this README.
5. Open a pull request. Skills that gate a governance process (publication,
   disclosure, release) should say so explicitly, and should reference the Codex
   document they enforce.
