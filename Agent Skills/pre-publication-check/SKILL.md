---
name: pre-publication-check
description: >
  Audit a repository before it is made public. Use when asked to check,
  review, or prepare a repo for open-sourcing, publication, or a switch from
  private/internal to public visibility. Checks compliance with the ECMWF
  Codex (licensing, README, maturity badge, contribution setup) and industry
  best practices (secret scanning, git history audit, dependency licences,
  CI hygiene). Produces a pass/fail report; does not flip visibility itself.
---

# Pre-publication check

Audit a repository against the [ECMWF Codex](https://github.com/ecmwf/codex)
and general open-sourcing best practices **before** it is made public.

This skill assumes the human side is done: open-sourcing approval, scope,
and maintainership have already been settled through the official ECMWF
procedure. Your job is the technical audit of the repository contents.

Making a repo public is effectively irreversible: once pushed to a public
remote, assume every byte of every commit has been copied. The point of this
skill is to catch problems while they are still fixable.

## How to run the audit

1. Work through every section below. Do not stop at the first failure —
   collect all findings.
2. For each item record **PASS**, **FAIL**, or **N/A** (with a one-line
   reason).
3. Finish with the report format described at the end. Never make the
   repository public yourself.

Checks marked **[Codex]** cite the source document in `ecmwf/codex`; read the
cited file if the requirement is ambiguous.

## 1. Licensing — [Codex: Legal/Copyright-And-Licensing.md]

- [ ] `LICENSE` exists at the repository root and is Apache License 2.0.
- [ ] The Apache licence text carries the copyright line (the Codex says to
      add it at line 178 of the standard text). The holder is either ECMWF
      or the European Union, depending on the funding of the project:

      Copyright 1996- European Centre for Medium-Range Weather Forecasts (ECMWF)

      or a European Union / EU-programme copyright statement. Either is
      acceptable; missing entirely is a FAIL.
- [ ] Every original source file (code and documentation, excluding
      generated files) carries a licence header of this shape:

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
      (`grep -ri "GPL\|GNU General Public" --exclude-dir=.git`, then filter
      false positives).
- [ ] Third-party dependencies (and any vendored code) have licences
      compatible with Apache 2.0. Flag GPL/LGPL/AGPL dependencies as FAIL.
      Check lockfiles and vendored directories, not just declared
      dependencies. Ecosystem tools:

      pip-licenses                      # Python (run in the project venv)
      npx license-checker --summary     # Node
      cargo deny check licenses         # Rust (needs deny.toml)
      go-licenses report ./...          # Go

## 2. README — [Codex: Legal/Open-Sourcing-Software.md, Repository Structure/README.md]

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
- [ ] Version tags follow SemVer (`x.y.z`, no `v` prefix per ECMWF
      convention) if the project has releases.
- [ ] A `CHANGELOG.md` is not required — but if one exists, check it is
      sane: entries match actual tags, no placeholder sections, no internal
      references.

## Report format

End with:

```markdown
# Pre-publication audit: <repo> @ <commit>

**Verdict**: READY / NOT READY

## Blockers (FAIL)
- <item> — <evidence, file paths, commands run>

## Unverified
- <item> — <why it could not be checked, e.g. no API access to repo settings>

## Passed
<one line per section, e.g. "Licensing: 5/5 PASS">

## Not applicable
- <item> — <reason>
```

A repository is **READY** only when there are zero FAILs. List anything you
could not verify under "Unverified" rather than silently passing it. When
in doubt, the verdict is NOT READY — the cost of a false "ready" is a public
leak; the cost of a false "not ready" is a short delay.

**Never store the report anywhere that becomes public with the repository**
— not as a GitHub issue, not as a committed file, not in a PR description.
The report contains exactly the evidence (secret locations, internal
hostnames, personal emails) that must not be published.
