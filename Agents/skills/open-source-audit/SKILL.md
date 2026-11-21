---
name: open-source-audit
description: >
  Open-source compliance audit of a repository: run it before the repository is
  made public, and re-run it after fixes or periodically to confirm an
  already-public repository still complies. Use when asked to check, review,
  audit, or prepare a repo for open-sourcing, publication, or a switch from
  private/internal to public visibility. Checks compliance with the ECMWF
  Codex (licensing, copied/third-party code and attribution, README, maturity
  badge, contribution setup) and industry best practices (secret scanning, git
  history audit, dependency licences, CI hygiene), and prompts the operator to
  run a separate security audit. Produces a pass/fail Markdown report; does not
  flip visibility itself.
---

# Open-source audit

Audit a repository against the [ECMWF Codex](https://github.com/ecmwf/codex)
and open-sourcing best practices **before** it is made public, and **re-run it
any time** to confirm a public repository still complies (see "Run modes").

This skill is run as part of the ECMWF open-sourcing process described in
[`Legal/Open-Sourcing-Software.md`](../../../Legal/Open-Sourcing-Software.md).
It is the final technical gate, normally run by, or on behalf of, the owner who
asks the GitHub Enterprise / organisation owner to switch the repository from
private to public, before the visibility change is made. It assumes the human
side (approval, scope, maintainership) is already settled through the official
ECMWF procedure; your job is the technical audit of the repository contents.

This file is **model-agnostic** (see the portability notes in
[`Agents/skills/README.md`](../README.md)): self-contained plain Markdown.

Making a repo public is effectively irreversible: once pushed to a public
remote, assume every byte of every commit has been copied. This skill exists to
catch problems while they are still fixable.

## How to run the audit

**Work in a fresh clone.** Never use or delete an existing checkout of the
audited repository: clone it afresh under `$TMPDIR/codex-audits/<repo>` (ask if
`$TMPDIR` is unset, and before replacing a folder there that you did not create
in this session), keep all builds and tests inside it, and delete only what you
created there. See [AGENTS.md](../../../AGENTS.md).

1. Identify the run mode (initial, follow-up after fixes, or periodic re-audit;
   see "Run modes") and read any previous report first.
2. Work through every section below. Do not stop at the first failure —
   collect all findings.
3. For each item record **PASS**, **FAIL**, or **N/A** (with a one-line
   reason). Classify every FAIL as a **Blocker** or **Advisory** (see below).
4. Finish with the report format described at the end. Never make the
   repository public yourself.

**Blocker vs advisory.** Not every deviation should stop publication. Classify
each FAIL:

- **Blocker** — a genuine reason not to publish yet:
  - secrets/credentials, or **any internal information** (internal hostnames,
    IPs, filesystem paths, internal ticket references, or personal data such as
    private phone numbers, or a non-work email whose owner declines publication)
    in the code **or git history** (see sections 4 and 5);
  - an Apache-incompatible or missing licence, or **any tracked source file
    missing its per-file licence header** (see section 1);
  - copied code without attribution, or unresolved IPR/provenance concerns;
  - **committed build/install artefacts or editor/OS junk** (e.g. `*.pyc`,
    `__pycache__/`, `*.egg-info/`, `build/`, `dist/`, `.DS_Store`) (section 6);
  - software with **no genuine documentation at all** (see section 2);
  - a **security audit that has been run and is NOT_READY** (open CRITICAL/HIGH).

  Blockers set the verdict to NOT_READY and are counted in `fail_count`. A
  security audit that has simply **not been run yet is not a blocker** — remind
  the operator to run it (see section 9).
- **Advisory** — a real but low-impact hygiene deviation that should be fixed but
  is not a publication risk on its own (e.g. README licence-section wording,
  a maturity badge placed too low in the README, leftover template cruft, a
  missing `CONTRIBUTING.md`, or an absent `CITATION.cff`). Advisories are listed,
  do **not** block publication and are **not** counted in `fail_count`.

When genuinely unsure whether something is a blocker, treat it as one — the cost
of a false "ready" is a public leak.

Checks marked **[Codex]** cite the source document in `ecmwf/codex`; read it if
the requirement is ambiguous.

## Run modes

This skill can run many times over a repository's lifetime. Decide the mode
before you start, and state it in the report.

- **Initial audit** — the first audit run, before publication. Work through
  every section from scratch.
- **Follow-up audit (after fixes)** — a repository that previously failed is
  being re-checked. First read the previous report(s) in the audit store
  (`ecmwf/repo-audits`, under `audits/<org>/<repo>/`; ask an org owner if you
  cannot access it), never in the repo itself — see "Report storage". Confirm
  that every prior **FAIL** and **Unverified** item has genuinely been resolved,
  and watch for regressions. A READY verdict still requires a full pass of every
  section, not only the previously-failing items.
- **Periodic re-audit** — a re-check of an already-public repository to confirm
  it *still* complies with every directive here. Recommended at least **once
  every 12 months**, and after any major change. Compare against the most recent
  report, flag any drift, and record the next recommended review date.

## 1. Licensing and third-party code — [Codex: Legal/Copyright-And-Licensing.md]

- [ ] `LICENSE` exists at the repository root and is Apache License 2.0.
- [ ] The Apache licence text carries the copyright line (the Codex says to
      add it at line 178 of the standard text). The holder is ECMWF or, for
      EU-funded work, the European Union ("European Union" is the correct
      holder — not "European Commission"):

      Copyright 1996- European Centre for Medium-Range Weather Forecasts (ECMWF)

      Either is acceptable; missing entirely is a FAIL. In repositories adopting
      the SPDX/REUSE layout (ADR-010), the copyright line and intergovernmental
      notice live in the top-level `LICENSE` (notice at its tail) and `NOTICE`,
      while `LICENSES/Apache-2.0.txt` must remain the **unmodified** Apache text
      — do not flag that file for lacking them.
- [ ] Every original source file (code and documentation) carries a licence
      header — **any tracked source file without one is a FAIL (Blocker)**. Check
      **git-tracked files only** (`git ls-files`) — do not flag untracked
      artefacts such as a `setuptools_scm`-generated `_version.py` (which should
      not be committed at all — see section 6). Two header forms are acceptable:

      1. The **SPDX + REUSE** form — *the ECMWF standard; required for new
         files* [Codex: Legal/SPDX-and-REUSE.md; ADR-010]:

         SPDX-FileCopyrightText: <year> European Centre for Medium-Range Weather Forecasts (ECMWF)
         SPDX-License-Identifier: Apache-2.0

         plus one extra `SPDX-FileCopyrightText:` line per additional copyright
         holder (e.g. `Crown Copyright, Met Office`).

      2. The legacy **prose** header — still valid for not-yet-migrated files:

         (C) Copyright <FILE-CREATED-YEAR>- ECMWF and individual contributors.

         This software is licensed under the terms of the Apache Licence Version 2.0
         which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
         In applying this licence, ECMWF does not waive the privileges and immunities
         granted to it by virtue of its status as an intergovernmental organisation nor
         does it submit to any jurisdiction.

      (holder ECMWF or, for EU-funded work, European Union). Spot-check by
      grepping for `SPDX-License-Identifier`, `Apache Licence Version 2.0`, or
      `intergovernmental` and comparing the hit count against the source file
      count. `reuse annotate` or `ecbuild`'s `apply_license.sh` can add missing
      headers.
- [ ] No references to old ECMWF licences, GPL, or LGPL remain
      (`grep -riE "GPL|GNU General Public" . --exclude-dir=.git`, then filter
      false positives).
- [ ] Third-party dependencies (and any vendored code) have licences
      compatible with Apache 2.0. Flag GPL/LGPL/AGPL dependencies as FAIL.
      Check lockfiles and vendored directories, not just declared dependencies.
      Ecosystem tools: `pip-licenses` (Python, in the project venv),
      `npx license-checker --summary` (Node), `cargo deny check licenses`
      (Rust, needs `deny.toml`), `go-licenses report ./...` (Go).
      Weak-copyleft dependencies (e.g. MPL-2.0, EPL) are file-level and remain
      Apache-compatible — do not fail them. A dependency reported as `UNKNOWN`
      usually means missing licence metadata, not a bad licence; **confirm it
      manually** (the project's repository/LICENSE), don't auto-fail.

- [ ] **Scan the complete codebase for copied or inlined third-party code**,
      not only declared dependencies. Sweep every source and data file (and the
      git history) for foreign or non-Apache licence headers,
      `SPDX-License-Identifier` tags that are not `Apache-2.0`, other parties'
      copyright lines, blocks stylistically inconsistent with the surrounding
      code, and tell-tale phrases (`based on`, `borrowed from`, `adapted from`,
      `Stack Overflow`, gist/blog URLs). Useful sweeps:

      grep -rniE 'SPDX-License-Identifier|copyright \(c\)|all rights reserved' . --exclude-dir=.git | grep -v 'Apache-2.0'
      grep -rniE 'GPL|LGPL|AGPL|MPL|CC[ -]BY|creative commons|proprietary|based on|borrowed from|adapted from' . --exclude-dir=.git

      (SPDX-migrated repositories legitimately carry `Apache-2.0` tags and ECMWF
      `SPDX-FileCopyrightText` lines — the filter hides those; you are hunting
      *non-Apache* tags and *other parties'* copyright lines.)

      Where available, run a provenance/licence scanner over the whole tree:
      `scancode-toolkit`, `reuse lint`, or GitHub `licensee`. Treat these as
      **provenance leads, not a hard gate**. Migration to **SPDX + REUSE**
      headers (ADR-010 / [Codex: Legal/SPDX-and-REUSE.md]) is incremental: a
      repository still on prose headers fails `reuse lint`, which is **advisory,
      not a blocker** — recommend migration rather than failing the audit.
- [ ] **Copied code under an Apache-incompatible licence is a FAIL.** Code
      copied in under GPL/LGPL/AGPL, CC-BY-SA, a non-commercial or
      "no-derivatives" licence, or an unknown/proprietary licence must be
      removed or cleanly re-implemented — ECMWF cannot re-license it under
      Apache 2.0.
- [ ] **Copied code without attribution is a FAIL, even when the licence is
      compatible.** Permissively-licensed third-party code (MIT, BSD, ISC,
      Apache, etc.) may be included only if its original copyright and licence
      notice are preserved *and* it is recorded in the `NOTICE` file alongside
      `LICENSE` (see
      [Copyright-And-Licensing.md](../../../Legal/Copyright-And-Licensing.md)).
      Stripped attribution or a missing/incomplete `NOTICE` entry is a FAIL. If the
      provenance or licence of a block cannot be established, treat it as an IPR
      risk: FAIL, and refer to the Development Section for a formal code audit.

## 2. README and documentation — [Codex: Legal/Open-Sourcing-Software.md, Repository Structure/README.md, Principles/Open-Source-Principles.md]

`README.md` must exist at the root and:

- [ ] Explain the purpose and scope of the software.
- [ ] Include installation instructions and, ideally, a short usage example.
- [ ] Link to further documentation if any exists.
- [ ] Contain the licence section verbatim:

      ## License
      [Apache License 2.0](LICENSE) In applying this licence, ECMWF does not
      waive the privileges and immunities granted to it by virtue of its
      status as an intergovernmental organisation nor does it submit to any
      jurisdiction.

- [ ] Any badges at the top of the README actually work and point at this
      repository's CI/coverage/docs (copy-pasted badges from a template repo
      are a common failure).
- [ ] Some form of user-facing documentation is present — **missing is a
      FAIL (Blocker)**. The Codex "Provide Documentation" principle treats
      undocumented software as effectively unusable
      [Codex: Principles/Open-Source-Principles.md]. The minimum bar is a
      `README.md` that genuinely covers purpose, installation and usage; a
      `docs/` tree, documentation site, or worked examples are better and
      expected at higher maturity levels. A stub, empty, or template-placeholder
      README does **not** satisfy this check.
- [ ] **Citation & DOI — advisory (should).** The repository *should* make the
      software citable: mint a DOI (e.g. via the GitHub–Zenodo integration) and
      add a `CITATION.cff` file at the repository root. Example:
      [`Repository Structure/CITATION.cff`](../../../Repository%20Structure/CITATION.cff).
      **Advisory**, never a blocker (typically completed once the repository is
      public — see "Post-publication recommendations").

## 3. Maturity badge — [Codex: Project Maturity/README.md]

The maturity badge is also the support statement, so no separate "level of
support" wording is needed (e.g. qubed and forecast-in-a-box carry just the
badge plus the disclaimer).

- [ ] README shows one of the maturity badges: Sandbox, Emerging,
      Incubating, Graduated, or Archived — with the matching disclaimer:

      > [!IMPORTANT]
      > This software is **<Level>** and subject to ECMWF's guidelines on
      > [Software Maturity](https://github.com/ecmwf/codex/raw/refs/heads/main/Project%20Maturity).

- [ ] The badge and disclaimer are placed at the **top of the README** — after
      the project title and an optional short synopsis, and **before** the main
      body. One buried lower in the README is a finding (advisory).
- [ ] The claimed level is honest: a brand-new project should almost always be
      Sandbox or Emerging. Flag an optimistic level as FAIL with a note (usually
      **Advisory**, unless it materially misleads users about stability or
      support).

## 4. Secrets and sensitive information

This is the highest-stakes section. **Scan the full git history, not just
the working tree** — deleted files and old commits are published too.

- [ ] **Fetch the pull-request refs first.** GitHub keeps a read-only
      `refs/pull/<n>/head` for every pull request, publishes it with the
      repository, and a history rewrite cannot change it. It can expose
      pre-rewrite history (in two real audits a home path and internal hostnames
      survived a rewrite this way), and closed, unmerged pull requests can hold
      content that never reached the default branch. Fetch them so every sweep
      below (`--all`, `gitleaks`) covers them:

      git fetch origin '+refs/pull/*/head:refs/remotes/pr/*'

      Anything found only there is published too: rate it like a history
      finding. If history was rewritten or the repository recreated, also check
      whether GitHub still serves old commits by ID
      (`gh api repos/<org>/<repo>/commits/<sha>`). If it does, ask GitHub Support
      to purge them (it may decline non-sensitive data), or publish from a fresh
      repository holding only the rewritten history, keeping any archive of the
      old repository private.
- [ ] Run an automated secret scanner over all history (`gitleaks` if none is
      installed):

      gitleaks git .            # or: gitleaks detect --source .
      # alternatives: trufflehog git file://. ; detect-secrets scan

- [ ] Grep history for high-risk patterns the scanners can miss — the Codex
      audit calls out ECMWF-internal hostnames, internal IPs, usernames and email
      addresses. **Any such internal information found in the code or history is
      a FAIL (Blocker)**, even for an already-public repo (record it and flag that
      it should have been caught before publication):

      git log -p --all | grep -inE 'password|passwd|secret|api[_-]?key|token|BEGIN (RSA|OPENSSH|EC) PRIVATE' | head
      git log -p --all | grep -inE '\.ecmwf\.int|10\.[0-9]+\.[0-9]+\.[0-9]+|192\.168\.' | head

- [ ] Check for committed credential files in history: `.env`, `.netrc`,
      `.npmrc`/`.pypirc` with tokens, `id_rsa`, `*.pem`, `*.p12`, kubeconfigs,
      `credentials.json`, cloud provider config.
      `git log --all --diff-filter=A --name-only | sort -u` lists every path
      that ever existed.
- [ ] Check GitHub Actions workflows: no inlined secrets, no `echo` of secret
      values, and no `pull_request_target` triggers that run untrusted PR code
      with secret access. Also check supply-chain hygiene: top-level
      `permissions:` blocks are least-privilege, and third-party actions are
      pinned to a commit SHA rather than a mutable tag
      (`uses: some-org/action@<sha>`).
- [ ] Check issue/PR templates, docs, example configs, and test fixtures for
      real credentials or internal URLs used as "examples".
- [ ] `.gitignore` covers credential and local-config patterns, so secrets
      don't arrive *after* publication.

**If anything is found**: report as FAIL, state plainly that the credential must
be rotated/revoked at the source, and that history must be rewritten
(`git filter-repo`) or the repo re-created from a clean export before
publication. Removing the file in a new commit is not sufficient.

## 5. Git history and repo hygiene

- [ ] Review author identities: `git shortlog -s -e --no-merges`.
      **Internal information in identities is a FAIL (Blocker)** — internal
      hostnames (e.g. `user@lfcb-014.ecmwf.int`, `*.bullx` cluster nodes) — and
      so are private phone numbers and other personal data. A personal
      (non-work) commit address is a **Pass when its owner has evidently chosen
      to publish it** — they kept it when rewriting history, or use it in their
      public commits elsewhere; record that evidence in the report. Otherwise it
      is **Unverified until the owner consents**; never assume consent. If the
      owner declines, it is a **FAIL (Blocker)**: rewrite with
      `git filter-repo --mailmap` before publication.
- [ ] Skim commit messages for internal ticket systems, internal URLs, or
      sensitive discussion: `git log --oneline --all | head -100` plus targeted
      greps (e.g. JIRA keys, `confluence.ecmwf.int`). Internal references here
      are a FAIL (Blocker).
- [ ] No large binary blobs or datasets bloating the repo:
      `git rev-list --objects --all | sort -k2` with `git cat-file --batch-check`
      (or `git count-objects -vH` for a quick check). Flag anything unexpected
      over ~5 MB.
- [ ] No embedded third-party code of unknown provenance (IPR concern — flag
      suspicious vendored directories as FAIL with a note).
- [ ] Branches, tags and pull-request refs (`refs/pull/*`, see section 4) will
      be published too: delete stale/experimental branches or confirm they're
      clean (`git branch -r`, `git tag`).
- [ ] No submodules pointing at private or internal repositories
      (`.gitmodules`).

## 6. Repository structure — [Codex: Repository Structure/README.md]

- [ ] Layout broadly follows the ECMWF conventions (cookiecutter-style):
      `src/`, `tests/`, `docs/`, `examples/`. Deviations are fine if deliberate
      — flag only chaos, not taste.
- [ ] No leftover template placeholders (`<project-name>`, `TODO: fill in`,
      cookiecutter variables) in README, docs, or config files.
- [ ] **No committed build/install artefacts, editor droppings, or OS junk —
      any such tracked file is a FAIL (Blocker)**: `*.pyc`, `__pycache__/`,
      `*.egg-info/`, `build/`, `dist/`, `*.so`/compiled outputs, `.DS_Store`,
      `Thumbs.db`, `.vscode/`/`.idea/` with local paths, `.ipynb_checkpoints/`.
      A missing `.gitignore` is usually the root cause — require one and have the
      artefacts removed from tracking (`git rm -r --cached`).

## 7. Contributions and CI — [Codex: Guidelines/External-Contributions.md]

- [ ] PR template: the ECMWF org-level template applies automatically when the
      repo has none, so absence is fine. Only flag if the repo **overrides** it
      with its own `.github/PULL_REQUEST_TEMPLATE.md` — then check the override
      is sane and doesn't drop the org template's substance.
- [ ] CI runs on pull requests; external-PR workflows gate on the
      `approved-for-ci` label (or equivalent) rather than auto-running
      untrusted code.
- [ ] Branch protection on the default branch: required reviews and status
      checks, no force-pushes
      (`gh api repos/<org>/<repo>/branches/<default>/protection`); if you lack
      access, note it as unverified in the report.

## 8. Industry best practices (beyond Codex)

- [ ] Automated security checks run in CI — dependency-vulnerability scanning
      and static analysis (SAST), with whatever tooling the project chooses (the
      Codex "Secure by Design" principle expects it)
      [Codex: Principles/Open-Source-Principles.md]. The audit performs these
      scans itself; this item checks they also run continuously. Note as
      unverified if you cannot inspect the CI configuration.
- [ ] Dependencies are pinned or locked (lockfile committed) for reproducible
      builds.
- [ ] The project builds and its tests pass from a fresh clone following only
      the README instructions — run this if feasible; it is the best proxy for
      "publishable".
- [ ] Version tags follow SemVer if the project has releases: ECMWF production
      tags use the clean `x.y.z` form, no `v` prefix
      [Codex: Languages/Versioning.md; Guidelines/External-Contributions.md].
- [ ] A `CHANGELOG.md` is not required — but if one exists, check it is sane:
      entries match actual tags, no placeholder sections, no internal references.

## 9. Security audit — [Codex: Principles/Open-Source-Principles.md — Secure by Design]

A dedicated security audit is an important part of the open-sourcing process —
the secret scanning in section 4 is necessary but not sufficient. This audit
does **not** run it itself, and does **not** fail merely because one has not
been run yet.

- [ ] Check whether a current `Security-Audit` report exists for this commit in
      `ecmwf/repo-audits`.
      - **If one has not been run for this commit:** do **not** record a FAIL.
        List it as an **advisory**, and **ask the human operator whether to run
        the [`security-audit` skill](../security-audit/SKILL.md) next** — do not
        run it yourself as part of this audit. Publication should still wait
        for a READY security audit, but confirming that is the operator's
        decision, not a blocker recorded here.
      - **If one has been run for this commit and its verdict is NOT_READY**
        (open CRITICAL/HIGH findings): that **is** a Blocker — the repository is
        NOT READY until the security audit passes.

## Post-publication recommendations (optional)

Suggestions, not pass/fail checks. Surface them to the repository owner, but
never block publication on them.

- **Create a Zenodo DOI and add `CITATION.cff`.** Once the repository is public,
  the owner should enable the GitHub–Zenodo integration (or mint a DOI via
  [Zenodo](https://zenodo.org)) and add a `CITATION.cff` at the repository root
  plus the DOI badge in the README (template: `Repository Structure/CITATION.cff`
  in the Codex).

## Report format

Produce the report as Markdown, with the YAML front-matter required by the
audit store (see "Report storage", the `repo-audits` `SCHEMA.md`, and
`ADR-009`), in this shape:

```markdown
---
schema_version: 1
repo: <org>/<repo>
commit: <full 40-char SHA audited>
audit_type: open-source
run_type: initial            # initial | follow-up | periodic
timestamp: <YYYY-MM-DDThh:mmZ>
verdict: NOT_READY           # READY only when there are zero open Blockers
auditor_human: <github-username>
auditor_model: <model + version, or "none">
previous_report: none        # filename of previous report, or "none"
next_review: <YYYY-MM-DD>     # audit date + 12 months
fail_count: 0                # number of open Blockers (advisories not counted)
unverified_count: 0
---

# Open-source audit: <repo> @ <commit>

**Run type**: Initial / Follow-up (after fixes) / Periodic re-audit
**Date**: <YYYY-MM-DD>
**Previous report**: <reference or date, or "none">
**Verdict**: READY / NOT READY

## Blockers (must fix before publishing)
- <item> — <evidence, file paths, commands run>

## Advisory (should fix — non-blocking)
- <item> — <evidence>

## Unverified
- <item> — <why it could not be checked, e.g. no API access to repo settings>

## Status of previous findings (follow-up / periodic runs only)
- <previous item> — Fixed / Still open / Regressed

## Passed
<one line per section, e.g. "Licensing and third-party code: 7/7 PASS">

## Not applicable
- <item> — <reason>

## Recommendations (optional, non-blocking)
- <e.g. Zenodo DOI not yet minted>

**Recommended next review**: <YYYY-MM-DD, ~12 months out>
```

A repository is **READY** only when there are zero open **Blockers** (advisories
may remain, and should be tracked for a follow-up). List anything you could not
verify under "Unverified" rather than silently passing it. When in doubt, the
verdict is NOT READY — the cost of a false "ready" is a public leak; the cost of
a false "not ready" is a short delay.

## Report storage

Reports are filed in the private store **`ecmwf/repo-audits`** (writable by
GitHub Enterprise / organisation owners, who serve as the auditors; readable
only internally at ECMWF) and **kept** there, so later follow-up and periodic
re-audits can read them to confirm fixes and detect drift.

A report must **never** be stored anywhere that becomes public with the
repository — not as a GitHub issue, a committed file in the audited repo, or a
PR description. Even in the private store, **redact actual secret values**:
record locations and references (e.g. `path/to/file:42 — API token
(••••redacted)`), never the live secret. Reports still contain other sensitive
context (internal hostnames, personal emails, provenance concerns), which is why
the store is private.

File each report as `audits/<org>/<repo>/<YYYY-MM-DDThhmm>-<Type>.md` (UTC),
where `<Type>` is `Open-Source-Audit` or `Security-Audit`, prepend the YAML
front-matter (with the exact audited `commit` SHA), and update that repository's
`index.md`. An org/Enterprise owner runs the audit and commits the report to
`main`. The schema is defined in `SCHEMA.md` in `repo-audits`; see also
`ADR-009 Repository Audit Store`.
