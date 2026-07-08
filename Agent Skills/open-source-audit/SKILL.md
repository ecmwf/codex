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
  history audit, dependency licences, CI hygiene), and requires a security
  audit. Produces a pass/fail Markdown report; does not flip visibility itself.
---

# Open-source audit

Audit a repository against the [ECMWF Codex](https://github.com/ecmwf/codex)
and general open-sourcing best practices **before** it is made public — and
**re-run it any time** to confirm an already-public repository still complies
(see "Run modes").

This skill is run as part of the ECMWF open-sourcing process described in
[`Legal/Open-Sourcing-Software.md`](../../Legal/Open-Sourcing-Software.md).
It is the final technical gate, run when a repository owner requests the
GitHub Enterprise / organisation owner to switch the repository from private
to public. The audit is normally run by, or on behalf of, that owner before
the visibility change is made.

This skill assumes the human side is done: open-sourcing approval, scope,
and maintainership have already been settled through the official ECMWF
procedure. Your job is the technical audit of the repository contents.

This file is written to be **model-agnostic** (see the portability notes in
[`Agent Skills/README.md`](../README.md)): the instructions below are
self-contained plain Markdown and work whether this skill is loaded by Claude,
GPT or Gemini agents.

Making a repo public is effectively irreversible: once pushed to a public
remote, assume every byte of every commit has been copied. The point of this
skill is to catch problems while they are still fixable.

## How to run the audit

1. Identify the run mode — initial, follow-up after fixes, or periodic
   re-audit (see "Run modes" below) — and read any previous report first.
2. Work through every section below. Do not stop at the first failure —
   collect all findings.
3. For each item record **PASS**, **FAIL**, or **N/A** (with a one-line
   reason). Classify every FAIL as a **Blocker** or **Advisory** (see below).
4. Finish with the report format described at the end. Never make the
   repository public yourself.

**Blocker vs advisory.** Not every deviation should stop publication. Classify
each FAIL:

- **Blocker** — a genuine reason not to publish yet: secrets/credentials in the
  code or history, an Apache-incompatible or missing licence, copied code
  without attribution, unresolved IPR/provenance concerns, or a **NOT_READY
  security audit**. Blockers set the verdict to NOT_READY and are counted in
  `fail_count`.
- **Advisory** — a real but low-impact hygiene deviation that should be fixed but
  is not a publication risk on its own (e.g. a missing licence header on a test
  file, README licence-section wording, leftover template cruft, missing
  `CONTRIBUTING.md`). Advisories are listed and should be fixed, but do **not**
  block publication and are **not** counted in `fail_count`.

When genuinely unsure whether something is a blocker, treat it as one — the cost
of a false "ready" is a public leak.

Checks marked **[Codex]** cite the source document in `ecmwf/codex`; read the
cited file if the requirement is ambiguous.

## Run modes

This skill is designed to be run more than once over a repository's lifetime.
Decide which mode applies before you start, and state it in the report.

- **Initial audit** — the first audit run, before publication. Work through
  every section from scratch.
- **Follow-up audit (after fixes)** — a repository that previously failed is
  being re-checked. First locate and read the previous report(s) for this
  repository in the audit store (`ecmwf/repo-audits`, under
  `audits/<org>/<repo>/`; ask an org owner if you cannot access it), never in
  the repo itself — see "Report storage". Confirm that every prior **FAIL** and
  **Unverified** item has genuinely been resolved, and watch for regressions
  introduced by the fixes. A READY verdict still requires a full pass of every
  section, not only the previously-failing items.
- **Periodic re-audit** — a re-check of an already-public repository to confirm
  it *still* complies with every directive here (licences, copied code, secrets,
  security, documentation, etc.). Recommended cadence is at least **once every
  12 months**, and after any major change. Compare against the most recent
  report, flag any drift, and record the next recommended review date.

## 1. Licensing and third-party code — [Codex: Legal/Copyright-And-Licensing.md]

- [ ] `LICENSE` exists at the repository root and is Apache License 2.0.
- [ ] The Apache licence text carries the copyright line (the Codex says to
      add it at line 178 of the standard text). The holder is either ECMWF
      or the European Union, depending on the funding of the project:

      Copyright 1996- European Centre for Medium-Range Weather Forecasts (ECMWF)

      or the equivalent European Union copyright statement for EU-funded work
      ("European Union" is the correct holder — not "European Commission").
      Either is acceptable; missing entirely is a FAIL.
- [ ] Every original source file (code and documentation) carries a licence
      header of this shape. Check **git-tracked files only** (`git ls-files`) —
      do not flag build/install artefacts such as a `setuptools_scm`-generated
      `_version.py`, which are not in version control:

      (C) Copyright <FILE-CREATED-YEAR>- ECMWF and individual contributors.

      This software is licensed under the terms of the Apache Licence Version 2.0
      which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
      In applying this licence, ECMWF does not waive the privileges and immunities
      granted to it by virtue of its status as an intergovernmental organisation nor
      does it submit to any jurisdiction.

      (again with ECMWF or European Union as the holder). Spot-check by
      grepping for `Apache Licence Version 2.0` or `intergovernmental` and
      comparing the hit count against the source file count. `ecbuild`
      ships `apply_license.sh` to add missing headers.
- [ ] No references to old ECMWF licences, GPL, or LGPL remain
      (`grep -riE "GPL|GNU General Public" . --exclude-dir=.git`, then filter
      false positives).
- [ ] Third-party dependencies (and any vendored code) have licences
      compatible with Apache 2.0. Flag GPL/LGPL/AGPL dependencies as FAIL.
      Check lockfiles and vendored directories, not just declared
      dependencies. Ecosystem tools:

      pip-licenses                      # Python (run in the project venv)
      npx license-checker --summary     # Node
      cargo deny check licenses         # Rust (needs deny.toml)
      go-licenses report ./...          # Go

      Weak-copyleft dependencies (e.g. MPL-2.0, EPL) are file-level and remain
      Apache-compatible — do not fail them. A dependency reported as `UNKNOWN`
      usually means missing licence metadata, not a bad licence; **confirm it
      manually** (check the project's repository/LICENSE) rather than
      auto-failing — some first-party or binary wheels ship Apache-2.0 code with
      no licence classifier.

- [ ] **Scan the complete codebase for copied or inlined third-party code**,
      not only declared dependencies. Sweep every source and data file (and the
      git history) for code that looks copied in from elsewhere: foreign or
      non-Apache licence headers, `SPDX-License-Identifier` tags that are not
      `Apache-2.0`, other parties' copyright lines, blocks stylistically
      inconsistent with the surrounding code, and tell-tale phrases
      (`based on`, `borrowed from`, `adapted from`, `Stack Overflow`,
      gist/blog URLs). Useful sweeps:

      grep -rniE 'SPDX-License-Identifier|copyright \(c\)|all rights reserved' --exclude-dir=.git
      grep -rniE 'GPL|LGPL|AGPL|MPL|CC[ -]BY|creative commons|proprietary|based on|borrowed from|adapted from' --exclude-dir=.git

      Where available, run a provenance/licence scanner over the whole tree:
      `scancode-toolkit`, `reuse lint`, or GitHub `licensee`. Treat these as
      **provenance leads, not a compliance gate**: ECMWF uses the prose Apache
      header above, not SPDX tags, so a `reuse lint` "not compliant" result
      (missing `SPDX-License-Identifier`) is **expected and not a FAIL** — REUSE
      compliance is optional at ECMWF.
- [ ] **Copied code under an Apache-incompatible licence is a FAIL.** Any code
      copied in under GPL/LGPL/AGPL, CC-BY-SA, a non-commercial or
      "no-derivatives" licence, or an unknown/proprietary licence must be
      removed or cleanly re-implemented — ECMWF cannot re-license it under
      Apache 2.0.
- [ ] **Copied code without attribution is a FAIL, even when the licence is
      compatible.** Permissively-licensed third-party code (MIT, BSD, ISC,
      Apache, etc.) may be included only if its original copyright and licence
      notice are preserved *and* it is recorded in the `NOTICE` file alongside
      `LICENSE` (see
      [Copyright-And-Licensing.md](../../Legal/Copyright-And-Licensing.md)).
      Stripped attribution, or a missing/incomplete `NOTICE` for included
      third-party code, is a FAIL. If the provenance or licence of a block
      cannot be established, treat it as an IPR risk: FAIL, and refer to the
      Development Section for a formal code audit.

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
      FAIL**. The Codex "Provide Documentation" principle treats undocumented
      software as effectively unusable
      [Codex: Principles/Open-Source-Principles.md]. The minimum bar is a
      `README.md` that genuinely covers purpose, installation and usage; a
      `docs/` tree, a published documentation site, or worked usage examples
      are better and expected at higher maturity levels. A stub, empty, or
      template-placeholder README does **not** satisfy this check.

## 3. Maturity badge — [Codex: Project Maturity/README.md]

The maturity badge is also the support statement: it tells users what
stability and support to expect, so no separate "level of support" wording
is needed. Public ECMWF projects at low maturity (e.g. qubed,
forecast-in-a-box) carry just the badge plus the disclaimer.

- [ ] README shows one of the maturity badges: Sandbox, Emerging,
      Incubating, Graduated, or Archived — with the matching disclaimer:

      > [!IMPORTANT]
      > This software is **<Level>** and subject to ECMWF's guidelines on
      > [Software Maturity](https://github.com/ecmwf/codex/raw/refs/heads/main/Project%20Maturity).

- [ ] The claimed level is honest. A brand-new project should almost always
      start at Sandbox or Emerging. Flag an optimistic level as FAIL with a
      note.

## 4. Secrets and sensitive information

This is the highest-stakes section. **Scan the full git history, not just
the working tree** — deleted files and old commits are published too.

- [ ] Run an automated secret scanner over all history. Prefer whichever is
      installed; install `gitleaks` if none is:

      gitleaks git .            # or: gitleaks detect --source .
      # alternatives: trufflehog git file://. ; detect-secrets scan

- [ ] Grep history for high-risk patterns the scanners can miss —
      ECMWF-internal hostnames, internal IPs, usernames, and email addresses
      are explicitly called out by the Codex audit:

      git log -p --all | grep -inE 'password|passwd|secret|api[_-]?key|token|BEGIN (RSA|OPENSSH|EC) PRIVATE' | head
      git log -p --all | grep -inE '\.ecmwf\.int|10\.[0-9]+\.[0-9]+\.[0-9]+|192\.168\.' | head

- [ ] Check for committed credential files in history:
      `.env`, `.netrc`, `.npmrc`/`.pypirc` with tokens, `id_rsa`, `*.pem`,
      `*.p12`, kubeconfigs, `credentials.json`, cloud provider config.
      `git log --all --diff-filter=A --name-only | sort -u` gives every path
      that ever existed.
- [ ] Check GitHub Actions workflows: no inlined secrets, no `echo` of
      secret values, and no `pull_request_target` triggers that run
      untrusted PR code with secret access. Also check supply-chain
      hygiene: top-level `permissions:` blocks are least-privilege, and
      third-party actions are pinned to a commit SHA rather than a mutable
      tag (`uses: some-org/action@<sha>`).
- [ ] Check issue/PR templates, docs, example configs, and test fixtures for
      real credentials or internal URLs used as "examples".
- [ ] `.gitignore` covers credential and local-config patterns so secrets
      don't arrive *after* publication.

**If anything is found**: report as FAIL and state plainly that the
credential must be rotated/revoked at the source, and history rewritten
(`git filter-repo`) or the repo re-created from a clean export before
publication. Removing the file in a new commit is not sufficient.

## 5. Git history and repo hygiene

- [ ] Review author identities: `git shortlog -s -e --no-merges`. Flag
      personal emails people may not want published, and obviously-internal
      machine accounts.
- [ ] Skim commit messages for internal ticket systems, internal URLs, or
      sensitive discussion: `git log --oneline --all | head -100` plus
      targeted greps (e.g. JIRA project keys, `confluence.ecmwf.int`).
- [ ] No large binary blobs or datasets bloating the repo:
      `git rev-list --objects --all | sort -k2` combined with
      `git cat-file --batch-check` (or `git count-objects -vH` for a quick
      size check). Flag anything unexpected over ~5 MB.
- [ ] No embedded third-party code of unknown provenance (IPR concern —
      flag suspicious vendored directories as FAIL with a note).
- [ ] Branches and tags will be published too: delete stale/experimental
      branches or confirm they're clean. `git branch -r` and `git tag`.
- [ ] No submodules pointing at private or internal repositories
      (`.gitmodules`).

## 6. Repository structure — [Codex: Repository Structure/README.md]

- [ ] Layout broadly follows the ECMWF conventions (cookiecutter-style):
      source under `src/`, tests under `tests/`, docs under `docs/`,
      examples under `examples/`. Deviations are fine if deliberate — flag
      only chaos, not taste.
- [ ] No leftover template placeholders (`<project-name>`, `TODO: fill in`,
      cookiecutter variables) in README, docs, or config files.
- [ ] No editor droppings, OS junk, or build artefacts committed
      (`.DS_Store`, `*.pyc`, `__pycache__/`, `node_modules/`, `build/`,
      `.vscode/` with local paths).

## 7. Contributions and CI — [Codex: Guidelines/External-Contributions.md]

- [ ] PR template: the ECMWF org-level template applies automatically when
      the repo has none, so absence is fine. Only flag if the repo
      **overrides** it with its own `.github/PULL_REQUEST_TEMPLATE.md` —
      then check the override is sane and doesn't drop the org template's
      substance.
- [ ] CI runs on pull requests; external-PR workflows gate on the
      `approved-for-ci` label (or equivalent) rather than auto-running
      untrusted code.
- [ ] Branch protection on the default branch: required reviews and status
      checks, no force-pushes. Check with
      `gh api repos/<org>/<repo>/branches/<default>/protection` if you have
      access; otherwise note it as unverified in the report.

## 8. Industry best practices (beyond Codex)

- [ ] Dependency and security scanning enabled or planned: Dependabot /
      Renovate, secret-scanning + push protection, CodeQL or equivalent
      where the language supports it — the Codex "Secure by Design"
      principle expects automated security scanning in CI
      [Codex: Principles/Open-Source-Principles.md]. Check repo settings
      with `gh api` where possible; otherwise note as unverified.
- [ ] Dependencies are pinned or locked (lockfile committed) so builds are
      reproducible for outside users.
- [ ] The project builds and its tests pass from a fresh clone following
      only the README instructions — run this if feasible; it is the single
      best proxy for "publishable".
- [ ] Version tags follow SemVer if the project has releases: ECMWF production
      tags use the clean `x.y.z` form (no `v` prefix)
      [Codex: Guidelines/External-Contributions.md].
- [ ] A `CHANGELOG.md` is not required — but if one exists, check it is
      sane: entries match actual tags, no placeholder sections, no internal
      references.

## 9. Security audit (mandatory) — [Codex: Principles/Open-Source-Principles.md — Secure by Design]

Publishing exposes the code to the world, so a security audit is a
**mandatory** part of the open-sourcing process, not an optional extra. The
secret/credential scanning in section 4 is necessary but not sufficient — a
dedicated security review is required before the repository goes public.

- [ ] Run the [`security-audit` skill](../security-audit/SKILL.md) against the
      repository and file its `Security-Audit` report in `ecmwf/repo-audits`
      alongside this one. That skill builds a threat model, runs SAST /
      dependency / supply-chain tooling, reviews security-sensitive surfaces
      (deserialization, injection, memory safety / FFI, crypto, ML model
      loading), and — for high-risk repositories — adds adversarial testing and
      bounded fuzzing.
- [ ] The security audit's verdict must be **READY** — that is, zero open
      CRITICAL/HIGH findings. A missing security audit, or one with open
      CRITICAL/HIGH findings, is a **FAIL**: the repository is NOT READY until
      the security audit passes.

## Post-publication recommendations (optional)

These are suggestions, not pass/fail checks. Surface them to the repository
owner, but never block publication on them.

- **Create a Zenodo DOI.** ECMWF recommends that, once the repository is
  public, the owner enables the GitHub–Zenodo integration (or mints a DOI via
  [Zenodo](https://zenodo.org)) so the software is citable and archived. Add a
  `CITATION.cff` file and the DOI badge to the README once the DOI is minted.
  This is a recommendation, not a precondition for going public.

## Report format

Always produce the report as Markdown, with the YAML front-matter required by
the audit store (see "Report storage", the `repo-audits` `SCHEMA.md`, and
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
may remain, and should be tracked for a follow-up). List anything you
could not verify under "Unverified" rather than silently passing it. When
in doubt, the verdict is NOT READY — the cost of a false "ready" is a public
leak; the cost of a false "not ready" is a short delay.

## Report storage

Reports are filed in the private store **`ecmwf/repo-audits`** (access limited
to GitHub Enterprise / organisation owners). Reports are **kept** there so that
later follow-up and periodic re-audits can read the previous report to confirm
findings were fixed and to detect drift.

A report must **never** be stored anywhere that becomes public with the
repository — not as a GitHub issue, not as a committed file in the audited repo,
not in a PR description. Even inside the private store, **redact actual secret
values**: record locations and references (e.g. `path/to/file:42 — API token
(••••redacted)`), never the live secret. Reports still contain other sensitive
context (internal hostnames, personal emails, provenance concerns), which is why
the store is private.

File each report as
`audits/<org>/<repo>/<YYYY-MM-DDThhmm>-<Type>.md` (UTC), where `<Type>` is
`Open-Source-Audit` or `Security-Audit`, prepend the YAML front-matter (including
the exact audited `commit` SHA), and update that repository's `index.md`. The
audit is run and the report committed to `main` by an org/Enterprise owner. The
authoritative naming and front-matter schema live in `SCHEMA.md` in the
`repo-audits` repository; see also `ADR-009 Repository Audit Store` in the Codex.
