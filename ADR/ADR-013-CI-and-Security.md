# Architectural Decision Record 013: CI/CD and Security

## Status

**Proposed** | <s>Accepted</s> | <s>Deprecated</s> | <s>Superseded by [ADR-XXX]</s>

## Last Updated
2026-11-13

## Context

Security leaks in individual repositories or user accounts can be used to escalate via CI/CD because of:
- missing branch protections in the repos,
- too widely scoped access of users to repos,
- too widely scoped access of repos to secrets,
- too widely scoped GitHub App keys,
- too widely scoped access of repos to runner groups.

A secret is only as well protected as the weakest repository that can read it:
everyone with write access there, and every workflow running there, can read it, whatever scope was intended.
While a compromised user account or repository is already a serious security concern,
it is the aim of this ADR to add defence in depth and reduce the blast radius of a compromised user account, key, or repository.

It is not the aim of this ADR to discuss all aspects of CI/CD,
but rather to focus on the security implications of branch protection and access control within the CI/CD workflow.
Additional considerations of code quality, review processes, and the prevention of bugs in software we develop are outside the scope of this ADR.
However, these goals are sometimes aligned; branch protection and requiring approvals for pull requests have direct security implications and are within the scope of this ADR.

We will use the term `main` to refer to any protected branch of a repository, regardless of whether it is actually named `main`, `master`, or `develop`.
This ADR fully applies also to branching models, such as Git Flow, with `main` and `develop` branches.
Note that from a GitHub security perspective the default branch has special significance,
since some Actions and workflows may have elevated permissions or access to secrets when run on the default branch, or can only run from the default branch.

### Options Considered

- Status quo: per-repository settings, broad secret and runner access.
- Ad hoc hardening: only after incidents, repository by repository.
- Least privilege everywhere, as decided below.
- No bypass for maintainers: rejected, see [Branch Protection Rules](#branch-protection-rules).

### Analysis

- Status quo: one compromised account or key reaches every org-wide secret and runner.
- Ad hoc hardening: leaves gaps, drifts between repositories.
- Least privilege: limits a compromise to what one repository or app can reach; costs some setup.

## Decision

As narrowly scoped as possible, but not narrower.
If a secret or access control is scoped too broadly, it makes leaks easier.
If a secret or access control is scoped too narrowly, e.g. appearing twice in two different repos of the organisation,
it increases the management overhead and decreases security, because of harder rotations.

Any secret should have a clear owner, who will be responsible for rotating when needed.
Any secret on the organisation level should have at least two such owners.
Currently, this is logged in an internal register (Confluence).
The page should *not* contain the actual secrets, only their metadata and owners.

### Secrets should be scoped as narrowly as possible

Secrets are listed from the narrowest to the broadest scope; use the narrowest one that works.

#### Secret in environment in a repo scoped to main

If a secret is needed only in a repo and only in its `main` branch, an environment scoped to that branch is the appropriate choice.

This is the case for example for a token that publishes to `PyPI`, which should not be done from a feature branch anyway.

An environment is created in the repository settings and holds its own secrets.
The advantage of environments is that they can be scoped to specific branches,
i.e. it can be configured so that only `main` can access the environment's secrets.
Only a job that names the environment gets its secrets, and only if it runs from an allowed branch;
a workflow pushed on any other branch is rejected before the job starts.

```yaml
jobs:
  publish:
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment: pypi
    steps:
      - uses: actions/checkout@v4
      - run: ./publish.sh
        env:
          PYPI_TOKEN: ${{ secrets.PYPI_TOKEN }}
```

Here `PYPI_TOKEN` is a secret of the environment `pypi`, not of the repository.
Note that `main` only changes via pull requests, which is the only way to gain access to this secret.
See [Branch Protection Rules](#branch-protection-rules).


#### Secret in a repo

Available to every workflow run in the repository, on any branch.
Anyone who can push a branch, user or app, can read it with a workflow of their own; branch protection does not help.
Fork pull requests do not receive it, unless the workflow runs on `pull_request_target`.
Use it for credentials that are also needed on pull requests and whose misuse stays within the repository.

#### Secret in an organisation, but scoped to a subset of repositories

One secret, stored once, available to the selected repositories as if it were a repository secret in each.
Use it for a credential that a known set of repositories needs.
There is one place to rotate it, and the list of repositories shows who can read it.

#### Secret in an organisation, with organisation-wide access

Available to every repository of the organisation, including repositories created in the future, and so to everyone with write access to any of them.
This is effectively shared with the whole organisation; it is not to be used for credentials.

#### Variables instead of secrets

Variables can and should be used for non-sensitive configuration values.

An overuse of secrets for things that could have been variables makes it hard to spot the actual sensitive information
that has to be rotated in case of a breach.


### User access to repositories

Write access to a repository includes reading its repository secrets and using its runner groups.
Users should be manually added to those repositories they need access to, in order to perform their work.

The point of this rule is to ensure that the person has any work to do in a repo and
to not give access to people who never need it for their work.
The aim is not gatekeeping and should not prevent legitimate work from being done.
A real person from ECMWF requesting access can be given rights immediately by an admin.

Write access alone does not change `main`.
In order to change it, one must go through a PR.
This is enforced on a technical level by the branch protection rules in the next section.
See [Branch Protection Rules](#branch-protection-rules).

### Branch Protection Rules

Every `main` (see [Context](#context)) is protected; all other branches are unrestricted.

#### Everyone, on a protected branch

- Changes only via pull request; no direct push.
- No force-push, no deletion of a protected branch.
- Required checks green.
- Merged branches are deleted automatically.
- Auto-merge is available.
- The pull request branch does not have to be up to date with its base.

#### By role

|                                                         | admin | maintain | write | read |
|---------------------------------------------------------|:-----:|:--------:|:-----:|:----:|
| push branches, merge after approval and green CI        |   ✓   |    ✓     |   ✓   |      |
| own pull request needs an approval                      |       |          |   ✓   |      |
| approval counts                                         |   ✓   |    ✓     |   ✓   |      |
| merge red CI or out-of-date branch (bypass)             |   ✓   |    ✓     |       |      |
| push to, force-push, or delete a protected branch       |       |          |       |      |
| edit the rules                                          |   ✓   |          |       |      |


If a `CODEOWNERS` file is given, the approval of the relevant codeowner(s) is required for the pull request to be considered approved.

Admins and maintainers are bypass actors in the mode pull requests only.

Removing the maintainer bypass was considered and rejected:
security at the cost of usability costs both.
Small teams would wait for reviewers on every change, and urgent fixes would stall while CI is broken; such rules are routed around, e.g. by widening access or moving work off protected branches, which loses the security again.

### Runner groups

A self-hosted runner gives a job whatever the runner can reach: the internal network, credentials baked into its image, and HPC systems.
Any workflow that may use a runner group gets this access, including a workflow pushed on a feature branch.
A runner group is therefore scoped like a secret:

- Access is granted to selected repositories, never to all repositories of the organisation.
- Where the runners hold credentials, the group is further restricted to selected workflows,
  e.g. a reusable workflow of ci-infrastructure at a ref on `main`, so that a workflow written on a feature branch cannot use it.
- Public repositories get access only where fork pull requests cannot run on the group without a maintainer's approval.
- Repositories that build and test without internal resources use GitHub-hosted runners.

#### HPC access

- An image carries exactly one SSH key, for one purpose and one target system; a second purpose gets a second image and runner group.
- The image is pushed only to a private registry project, and pull credentials are scoped like secrets.
- Only repositories that actually submit jobs to the HPC get access to the group.
- Rotating a key means regenerating it on the HPC side, rebuilding the image, and revoking the old key.

The long-term goal is to remove static keys from images:
a job authenticates to Vault with the GitHub OIDC token of its run, restricted to repository, branch, and environment,
and receives a short-lived SSH certificate.

### GitHub Apps

The private key of a GitHub App grants everything the app may do in every installation.
Whoever can read the key, or a token minted from it, acts as the app.

#### Break into separate apps for different scopes

One app per task, each with only the permissions that task needs, e.g. the former `ci-permissions` app is split into:

- `ci-read`: reads repository contents and metadata across the stack,
- `ci-dispatch`: starts workflows in downstream repositories,
- `ci-reporter`: writes check runs and commit statuses,
- `ci-sync`: updates pull requests that belong together across repositories.

One leaked key then exposes one task.

#### How to use and set up apps

- Install the app with the least privileges necessary for its operation.
- Prefer multiple smaller apps with minimal privileges over a single app with broad privileges.
- Separate installation of the app from access to the app's key.
  Even if an app is installed in the whole organisation, the key often only has to be known to one repository.
- Mint tokens with only the repositories and permissions the job needs.

### Related Decisions

- [ADR-001 Git Branching Model](./ADR-001-Git-Branching-Model.md) — asks for branch protection rules on `main` and `develop`; the [Branch Protection Rules](#branch-protection-rules) above implement them for both GitHub Flow and Git Flow.

## Consequences

### Positive

- Smaller blast radius of a compromised account, key, or repository.
- Every secret has at least one known owner and one place to rotate it.
- Protected branches stay green and reviewed.

### Negative

- More setup: environments, teams, runner groups, and apps.
- Access must be requested before work starts.
- Publishing jobs only run from `main`.

### Risks and Mitigation

- Rules drift between repositories: audit settings regularly.
- Usability suffers and people route around rules: keep the maintainer bypass, grant access quickly.
- Credentials on self-hosted runners are readable by the code they run: few repositories per group; move to Vault with OIDC.

## References

- [About rulesets](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets)
- [Managing environments for deployment](https://docs.github.com/en/actions/how-tos/deploy/configure-and-manage-deployments/manage-environments)
- [Managing access to self-hosted runners using groups](https://docs.github.com/en/actions/how-tos/manage-runners/self-hosted-runners/manage-access)
- [OpenID Connect](https://docs.github.com/en/actions/concepts/security/openid-connect)

## Authors

- Oskar Weser
