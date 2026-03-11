# Branching Patterns

This document describes the branching patterns used across ECMWF repositories. The choice of pattern for a given repository is governed by [ADR-001: Git Branching Model](../ADR/ADR-001-Git-Branching-Model.md).

## Contents

- [Overview](#overview)
- [GitHub Flow](#github-flow)
  - [Branch Structure](#github-flow-branch-structure)
  - [Feature Development](#github-flow-feature-development)
  - [Release Process](#github-flow-release-process)
  - [Hotfix Process](#github-flow-hotfix-process)
- [Git Flow](#git-flow)
  - [Branch Structure](#git-flow-branch-structure)
  - [Feature Development](#git-flow-feature-development)
  - [Release Process](#git-flow-release-process)
  - [Hotfix Process](#git-flow-hotfix-process)
- [Choosing a Model](#choosing-a-model)
- [Migration from GitHub Flow to Git Flow](#migration-from-github-flow-to-git-flow)
- [External Contractors](#external-contractors)

---

## Overview

All ECMWF repositories adopt a **hybrid approach**: new repositories begin with GitHub Flow and may evolve to Git Flow as project needs grow. The decision to change branching model rests with the repository's GateKeepers. See [ADR-001](../ADR/ADR-001-Git-Branching-Model.md) for the full rationale.

| | GitHub Flow | Git Flow |
|---|---|---|
| **Primary branch** | `main` / `master` | `main` / `master` + `develop` |
| **Development branch** | feature branches off `main` | feature branches off `develop` |
| **Release branch** | — | `release/*` off `develop` |
| **Hotfix branch** | off `main` | off `main` |
| **Best for** | Continuous delivery, small–medium teams | Scheduled releases, large teams, multiple versions |

---

## GitHub Flow

GitHub Flow is the default for all new repositories. It uses a single long-lived branch (`main` or `master`) with short-lived feature branches.

### GitHub Flow Branch Structure

```
main  ──────────────────────────────────────────────► (production)
        \                   /        \           /
         feature/my-feature            fix/issue-42
```

| Branch | Purpose |
|---|---|
| `main` / `master` | Always deployable; all releases are tagged here |
| `feature/<name>` | Short-lived branch for a feature or change |
| `fix/<name>` | Short-lived branch for a non-critical bug fix |
| `hotfix/<name>` | Urgent fix for a production issue |

### GitHub Flow Feature Development

1. **Branch** — create a branch from `main`:
   ```
   git switch -c feature/my-feature main
   ```
2. **Develop** — commit changes to the feature branch, keeping the branch short-lived and focused.
3. **Push and open a PR** — push the branch and open a Pull Request against `main`. Follow the [PR guidelines](../Guidelines/pr_guidelines.md).
4. **Review** — address reviewer comments; all CI checks must pass.
5. **Merge** — a GateKeeper merges the PR into `main` using the merge strategy agreed by the team (merge commit or squash).
6. **Delete** the feature branch after merging.

### GitHub Flow Release Process

Releases in GitHub Flow are created directly from `main`:

1. Ensure `main` is in a releasable state — all CI checks passing, release notes prepared.
2. Create and push a **semantic version tag** on `main`:
   ```
   git tag x.y.z
   git push origin x.y.z
   ```
3. Publish any release artefacts (PyPI, container registry, GitHub Release, etc.) from the tag.

> [!NOTE]
> If the repository uses automated release pipelines, the tag push typically triggers the pipeline. Check the repository's CI/CD configuration for details.

### GitHub Flow Hotfix Process

For critical production issues:

1. Branch from the affected tag or from `main` (they are the same in GitHub Flow):
   ```
   git switch -c hotfix/critical-bug main
   ```
2. Apply the fix and push.
3. Open a PR against `main`; follow the expedited review process agreed by your team.
4. After merge, tag a new patch release on `main` (`x.y.z+1`).

---

## Git Flow

Git Flow is adopted by repositories that require structured release preparation, multiple concurrent version support, or additional stability guarantees. The model is based on [Vincent Driessen's branching model](https://nvie.com/posts/a-successful-git-branching-model/).

### Git Flow Branch Structure

```
main    ──────────────────────────────────────────────► (production tags only)
              ↑ merge                       ↑ merge
develop ──────────────────────────────────────────────► (integration)
         \               /    \          /
          feature/login-ui      feature/api-v2

release/1.2  ──────────────► (bug fixes only → merge to main + develop)

hotfix/1.1.1  ──────────────► (merge to main + develop)
```

| Branch | Branched from | Merged into | Purpose |
|---|---|---|---|
| `main` / `master` | — | — | Production-ready code; tagged releases only |
| `develop` | `main` | — | Integration branch; latest delivered development changes |
| `feature/<name>` | `develop` | `develop` | Individual feature development |
| `release/<version>` | `develop` | `main` + `develop` | Release preparation; only bug fixes allowed |
| `hotfix/<version>` | `main` | `main` + `develop` | Urgent production fixes |
| `support/<version>` | `main` | — | Long-term maintenance of older releases |

> [!IMPORTANT]
> Direct commits to `main` or `develop` are not permitted. All changes must go through Pull Requests.

### Git Flow Feature Development

1. **Branch** from `develop`:
   ```
   git switch -c feature/my-feature develop
   ```
2. **Develop** — make commits on the feature branch.
3. **Push and open a PR** against `develop`. Follow the [PR guidelines](../Guidelines/pr_guidelines.md).
4. **Review** — address reviewer comments; all CI checks must pass.
5. **Merge** into `develop` and delete the feature branch.

### Git Flow Release Process

1. **Create a release branch** from `develop` when the set of features for the release is complete:
   ```
   git switch -c release/x.y.z develop
   ```
2. **Bump the version number** in the relevant files (e.g. `VERSION`, `pyproject.toml`, `CMakeLists.txt`) and commit.
3. **Stabilise** — only bug fixes are committed to the release branch. No new features.
4. **Open a PR** from `release/x.y.z` into `main`. All CI checks must pass.
5. **Merge into `main`** and **tag** the release:
   ```
   git tag x.y.z
   git push origin x.y.z
   ```
6. **Merge `main` back into `develop`** (via PR) to incorporate any fixes made on the release branch:
   ```
   git switch develop
   git merge --no-ff main
   ```
7. **Delete** the release branch.
8. Publish any release artefacts (PyPI, container registry, GitHub Release, etc.) from the tag.

> [!NOTE]
> Steps 5 and 6 are often handled together as part of the release pipeline. Check the repository's CI/CD configuration for details.

### Git Flow Hotfix Process

For critical production issues that cannot wait for the next scheduled release:

1. **Branch from `main`** at the affected tag:
   ```
   git switch -c hotfix/x.y.z main
   ```
2. **Bump the patch version** and apply the fix.
3. **Open a PR** against `main`. Follow the expedited review process agreed by your team.
4. **Merge into `main`** and **tag** the hotfix release:
   ```
   git tag x.y.z
   git push origin x.y.z
   ```
5. **Merge `main` back into `develop`** (via PR) to ensure the fix is not lost in future releases.
6. **Delete** the hotfix branch.

---

## Choosing a Model

All repositories **start with GitHub Flow**. GateKeepers may upgrade to Git Flow when one or more of the following conditions are met:

- The repository has become operationally critical.
- The team size exceeds comfortable coordination limits (typically 8+ developers).
- The software requires explicit versioning or support for multiple simultaneous versions.
- The release process requires structured preparation with dedicated release stabilisation.
- Stakeholders require additional quality gates and formal release cycles.
- Deployment risk warrants additional safeguards and staging processes.
- Continuous delivery is not suitable for the software type.

The reverse is also possible: a repository using Git Flow may revert to GitHub Flow if the assessment of the above criteria reverses (e.g. the team shrinks or the project becomes simpler).

Refer to [ADR-001](../ADR/ADR-001-Git-Branching-Model.md) for the full analysis and decision rationale.

---

## Migration from GitHub Flow to Git Flow

When upgrading a repository from GitHub Flow to Git Flow:

1. Create a `develop` branch from the current `main`.
2. Update the repository documentation and contribution guidelines to reflect the new workflow.
3. Make `develop` the **default branch** on GitHub so that new PRs target it by default.
4. Configure **branch protection rules** for both `main` and `develop` (changes only through approved PRs by GateKeepers).
5. Update CI/CD pipelines to support the new branching structure (e.g. test on `develop`, release from `main`).
6. Train team members on the new workflow and branch types.
7. Document the decision and rationale (e.g. in the repository's CHANGELOG or wiki).

---

## External Contractors

Contractors who need a tighter development loop or internal tagging for staged testing prior to formal ECMWF acceptance should follow the [Integration Delivery Workflow](../External%20Contributions/README.md#2-integration-delivery-workflow-optional). This covers:

- **Forked development** — using the contractor's fork as a working upstream.
- **ECMWF integration branches** — using `upstream` or `upstream/<vendor>` branches within the ECMWF repository.
- **Prerelease tagging** — using the `x.y.z-upstream.N` convention for contractor-side testing.
- **Submission and approval** — how deliverables are formally accepted via PRs into `main` or `master`.
