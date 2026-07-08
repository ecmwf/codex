# Architectural Decision Record 009: Repository Audit Store

## Status

**Proposed** | <s>Accepted</s> | <s>Deprecated</s> | <s>Superseded by [ADR-XXX]</s>

## Last Updated

2026-07-08

## Decision

ECMWF adopts a dedicated, **private** GitHub repository —
[`ecmwf/repo-audits`](https://github.com/ecmwf/repo-audits) — as the single
store for the audit reports produced when a repository is prepared for
publication and when it is re-audited afterwards.

The store is governed by the following rules:

- **Visibility and access.** The repository is private. Read and write access is
  limited to **GitHub Enterprise / organisation owners**, who are the people who
  perform the audits. Repository admins do not run these audits and do not have
  access. Reports are pushed **directly to `main`** by the owner who ran the
  audit; `main` is protected against force-push and deletion.
- **Layout.** Reports are namespaced by organisation and repository:
  `audits/<org>/<repo>/`. The store covers multiple ECMWF organisations from the
  outset: `ecmwf`, `ecmwf-ifs`, and `ecmwf-training`. Further organisations are
  added by creating a folder under `audits/`.
- **File naming.** `audits/<org>/<repo>/<YYYY-MM-DDThhmm>-<Type>.md`, with the
  timestamp in UTC and `<Type>` one of `Open-Source-Audit` (from the
  `pre-publication-check` skill) or `Security-Audit` (from the planned
  `security-audit` skill).
- **Report format.** Each report is Markdown with a machine-readable YAML
  front-matter block (repository, **audited commit SHA**, audit type, run type,
  verdict, auditor, previous report, next review date, and finding counts). The
  audited commit SHA is always recorded so a report is traceable to an exact
  state of the repository.
- **Redaction.** Even though the store is private, reports **redact actual secret
  values**, recording only locations and references (paths, line numbers, SHAs).
- **Retention.** Reports are never deleted. History is kept for posterity and for
  reporting on how a repository's compliance evolves over time.

The canonical naming and schema definition live in `SCHEMA.md` in the
`repo-audits` repository.

### Scope

This ADR covers **where and how audit reports are stored**. It does not define
the audit checks themselves — those live in the Codex Agent Skills
(`pre-publication-check`, and the planned `security-audit`).

### Out of scope (for now)

- **Automation.** No scheduled reminders or status dashboard are built yet; the
  store is maintained manually. The front-matter schema is designed so these can
  be added later without reworking existing reports.
- **A dedicated auditors team.** Access deliberately reuses the existing
  org/Enterprise owner group rather than introducing a new team.

## Context

The Codex `pre-publication-check` skill (and a future `security-audit` skill)
produce audit reports that decide whether a repository can be made public. These
reports contain exactly the sensitive material that must never be published:
locations of secrets found in history, internal hostnames, personal email
addresses, and code-provenance concerns. They must therefore be stored somewhere
private and access-controlled — never in the audited repository itself.

At the same time, the reports have lasting value:

- **Traceability** — which commit was audited, by whom, with what verdict.
- **Follow-up** — a repository that fails an audit is fixed and re-checked; the
  re-check needs to read the previous report to confirm each finding was
  resolved.
- **Periodic re-audit** — an already-public repository is re-checked
  (recommended every ~12 months) to confirm continued compliance, which requires
  comparing against the previous report.
- **Reporting** — an organisation-wide view of which repositories have been
  audited, their verdicts, and when they are next due.

Before this ADR, the skill referred only to a "designated store (to be
defined)". This ADR defines it.

## Options Considered

### Option A: Do nothing — reports handled ad hoc

Auditors keep reports in personal notes, email, or internal chat.

- **Advantages:** no new infrastructure.
- **Disadvantages:** no traceability or retention; follow-up and periodic
  re-audits cannot reliably find the previous report; high risk of a sensitive
  report leaking into the wrong place; no reporting.

### Option B: Store reports inside each audited repository (private area)

Keep the report next to the code it describes.

- **Advantages:** co-located with the subject.
- **Disadvantages:** the repository is about to become **public** — the whole
  point is that the report must not travel with it. Removing it later is
  error-prone. Rejected outright.

### Option C: A dedicated private repository — `ecmwf/repo-audits`

A single private repo, namespaced by org and repo, with a defined schema.

- **Advantages:** private and access-controlled; centralised and reportable;
  natural home for follow-up/periodic history; git gives retention and an audit
  trail of the audit trail; no dependency on external systems.
- **Disadvantages:** a small amount of manual bookkeeping until automation is
  added; access must be kept tight.

### Option D: A wiki, shared drive, or ticketing system

Store reports in Confluence, a network share, or a Jira/ServiceNow ticket.

- **Advantages:** may already have fine-grained access controls.
- **Disadvantages:** weaker version history and diffing than git; harder to keep
  a machine-readable schema; splits the audit trail away from the GitHub-centric
  workflow the owners already use.

## Analysis

The dominant constraint is that reports are sensitive and must never end up in
the public repository, which eliminates Option B. Options A and D fail on
traceability, machine-readability, and/or a coherent history that follow-up and
periodic re-audits depend on.

Option C keeps everything in the tooling the owners already operate (GitHub +
git), gives strong retention and diffable history essentially for free, and lets
us attach a simple YAML schema that a future reminder job and dashboard can
consume. Reusing the org/Enterprise owner group for access — rather than a new
team — matches the reality that owners are the ones who perform audits and flip
repository visibility, and keeps the sensitive material on a strict
need-to-know basis. The residual weakness (manual bookkeeping) is acceptable at
current volumes and is explicitly a future automation target.

## Related Decisions

- The report store is the "designated store" referenced by the
  `pre-publication-check` skill in
  [`Agent Skills/pre-publication-check/SKILL.md`](../Agent%20Skills/pre-publication-check/SKILL.md).
- Reports implement part of the open-sourcing process in
  [`Legal/Open-Sourcing-Software.md`](../Legal/Open-Sourcing-Software.md).
- Supports the **Secure by Design** principle in
  [`Principles/Open-Source-Principles.md`](../Principles/Open-Source-Principles.md).

This ADR does not modify or supersede any existing ADR.

## Consequences

### Positive

- Sensitive audit evidence is retained in one private, access-controlled place
  and never travels with the published repository.
- Every report is traceable to an exact commit and auditor.
- Follow-up and periodic re-audits can reliably locate and build on prior
  reports.
- A machine-readable schema enables future reminders and an
  organisation-wide compliance dashboard.
- Works across multiple ECMWF organisations from day one.

### Negative

- Manual bookkeeping (writing reports, updating each repo's `index.md`) until
  automation is added.
- Access must be actively kept tight; the store itself is a sensitive asset.
- Reliant on discipline to redact secret values even though the store is
  private (mitigated by secret-scanning push protection on the store).

## References

- Report store: <https://github.com/ecmwf/repo-audits> (private) and its
  `SCHEMA.md`
- Pre-publication skill:
  [`Agent Skills/pre-publication-check/SKILL.md`](../Agent%20Skills/pre-publication-check/SKILL.md)
- Open-sourcing process:
  [`Legal/Open-Sourcing-Software.md`](../Legal/Open-Sourcing-Software.md)

## Authors

- Tiago Quintino
