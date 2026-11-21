---
name: onboard-repository
description: >-
  Builds a working mental model of an unfamiliar repository by reading its
  intent documents, mapping its structure and build system, surveying a
  representative slice of its code, and identifying the conventions and the
  build/test/lint gate that constrain any change. Produces a structured
  onboarding summary and changes nothing. Use when starting work on an
  unfamiliar codebase, or when asked to onboard, orient, or explain how a
  repository works.
license: Apache-2.0
---

# Onboard to a repository

Use this skill when you are starting work on a repository you do not know, or
when asked to explain how one is put together. The goal is a shared mental model
accurate enough to act competently — not a summary of the documentation.

Three rules:

- **Derive everything from the repository as it exists right now.** Do not rely
  on recollection of the project, on a similarly named project, or on how such
  projects usually work. If you did not read it in this repository, do not
  assert it.
- **Change nothing.** This is a read-only survey. Do not edit files, do not run
  builds that write into the tree beyond ordinary build outputs, and do not run
  anything destructive.
- **Where documents and code disagree, the code wins** — and the disagreement is
  itself one of the most valuable things to report.

## Inputs

The user may give a focus area (a subsystem, a language, an interface). If
given, go deeper there during the code survey while still doing the full
documentation and structure pass. With no focus, spread attention evenly.

## 1. Read the intent documents

These say what the project is *for* and what rules apply. Discover them rather
than assuming names — glob the repository root and any documentation directory,
and read what is actually there.

Look for:

- the root prose: `README`, `CONTRIBUTING`, `CODE_OF_CONDUCT`, `SECURITY`,
  `LICENSE`, `NOTICE`, `CHANGELOG`;
- agent or assistant instructions (`AGENTS.md`, `CLAUDE.md`, `.cursorrules`,
  `.github/copilot-instructions.md`) — these often state the project's
  non-negotiable rules most directly, and frequently one is a symlink to
  another;
- architecture and decision records: an `ADR/` or `decisions/` directory,
  `docs/design/`, `plans/`, `rfcs/`, or design documents anywhere in the docs
  tree;
- the documentation site source, if there is one.

From the changelog, read only the unreleased section and the most recent few
releases — enough to know the current direction. Do not read the whole history.

Distinguish **committed direction** from **speculation**. A document that
describes itself as ideas, brainstorming or future work is not a statement of
how the code behaves today. Treat it accordingly and say so in the report.

## 2. Map the structure and the build

Establish the layout without reading every file.

Identify the build system from its manifests, and let that tell you the
component layout — for example a workspace or monorepo manifest listing members,
a package manifest, a project or module file, or a top-level build script that
orchestrates several of these. Multi-language repositories often have one
orchestrating entry point (a `Makefile`, a task runner, a CI workflow) that
calls into per-language builds; find it and **read its target graph without
running it**.

Establish:

- the components or packages, and which language each is written in;
- how they depend on one another, and which is the core;
- where tests, examples, benchmarks and documentation live;
- how the pieces are published or deployed, if that is in scope;
- what the CI workflows actually run — this is often the most reliable
  statement of the project's real quality gate.

## 3. Survey a representative slice of the code

Read enough source to understand *how the project does what it does*. This is
deliberately not exhaustive. Aim for:

- **The public surface** of the core component: its primary types, its entry
  points, what a consumer is expected to call.
- **The central operation, traced end to end.** Pick the thing the project
  exists to do and follow it from the entry point to the result. This single
  trace is usually worth more than reading many files in isolation.
- **One integration or binding**, if the project has several — whichever is most
  relevant to the user's focus area, otherwise the richest one. This reveals the
  pattern the others follow.
- **The error model**: how failures are represented, propagated and surfaced at
  the boundaries.
- **Project-wide invariants** the code enforces — determinism, ordering,
  compatibility guarantees, thread-safety, resource ownership. Cross-check what
  the design documents claim against what the code actually does.

Prefer symbol navigation over full-text search where it is available; fall back
to searching and reading. Read tests when the intended behaviour of something is
unclear — tests state expectations more precisely than prose usually does.

## 4. Find the gate

Determine the canonical commands to build, test, format and lint — the check
that must pass before a change is considered done. Prefer a single aggregate
command if the project defines one, and note whether CI runs something broader.

Record any heavier checks that exist but are deliberately not part of the normal
gate (extended test matrices, mutation testing, fuzzing, performance runs), and
note that they are opt-in.

Do not run the gate as part of onboarding unless the user asks. Report what it
is.

## 5. Report

Produce a concise, skimmable summary. Aim for something a competent engineer
could read in a few minutes and then act on.

1. **Purpose** — what the project is and the problem it solves, in two or three
   lines.
2. **Architecture** — the components and how they relate. A short list or a
   small diagram; not a file listing.
3. **Core data flow** — the central operation traced end to end.
4. **Conventions that constrain edits** — the rules a contributor must respect:
   commit and branching conventions, the review and merge process, versioning
   and release rules, error and panic policy, compatibility guarantees, anything
   with a single source of truth that must not be edited by hand. Cite where
   each rule comes from.
5. **How to build, test and lint** — the canonical gate.
6. **Current direction and open work** — what is active versus speculative.
7. **Drift and contradictions** — where documentation disagrees with the code,
   where two documents disagree, or where a stated rule is not actually enforced.
8. **What you did not cover** — the areas left unsurveyed, so the reader knows
   the boundaries of the model.

Keep it tight. The output is a mental model, not a copy of the documentation. If
the repository is large, it is better to be accurate about a well-chosen slice
and honest about the rest than to be vague about everything.
