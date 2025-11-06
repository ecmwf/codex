# External Contributions

These guidelines define how all external contributions to the ECMWF software stack must be developed, delivered, and maintained. They apply to all collaborators, including individuals, partner organisations, and contracted suppliers, across all ECMWF-managed repositories (software, configuration, deployment manifests, and scripts).

Two contribution pathways exist, depending on the nature of the work:

1. **Standard Contributions** — the default method for all collaborators, using a fork and pull request workflow.  
2. **Integration Delivery Workflow** — an optional process for contractors who require tighter integration loops or internal tagging for staged testing prior to formal ECMWF review.

---

## 1. Standard Contributions (Default Method)

### Public Repositories

Public contributions follow the normal GitHub workflow.

- Fork the ECMWF repository into your own or your organisation’s GitHub space.  
- Develop on your fork.  
- When ready, open a Pull Request (PR) to the ECMWF repository.  
- Follow the repository’s PR template and provide sufficient description, issue references, and rationale.
- Note that all contributions must comply with ECMWF’s copyright and licensing policies, as outlined in [Copyright and Licensing](Legal/copyright_and_licensing.md).
- By creating a PR, you agree to the terms of the [Contributor License Agreement (CLA)](codex/Legal/contributor_license_agreement.md) and this should be part of the PR template.
- ECMWF staff will review for safety and apply the label `approved-for-ci`, which enables automated CI/CD checks.  
- The PR must pass all required tests, code-quality checks, and workflows before merge.  
- All contributions must include tests demonstrating correct behaviour and preventing regressions.

This process applies equally to **contractors** unless following the Integration Delivery Workflow (Section 2).

### Private Repositories

For private repositories owned by ECMWF:

- Access requires an ECMWF GitHub Enterprise license.  
- The project’s Technical Officer coordinates access requests.  
- License management is handled by User Support (@bkasic).  
- Development should occur on branches within the repository, using the same PR and review workflow as public repositories.
- Even for an internal/private repository, by creating a PR, you agree to the terms of the [Contributor License Agreement (CLA)](Legal/contributor_license_agreement.md) and this should be part of the PR template.

### New Repositories

When a new repository is needed:

- It must be created under the **ECMWF GitHub organisation**, not a personal or external account.  
- Creation is handled by ECMWF staff via the Technical Officer.  
- Visibility (public or private) should be decided early, preferring public where feasible.
- If the project will eventually be public, start development publicly to avoid migration overhead.
- For public repositories or that eventually will be made public, all contributions must comply with ECMWF’s copyright and licensing policies, as outlined in [Copyright and Licensing](Legal/copyright_and_licensing.md).
- Initialise the repository using the ECMWF cookie-cutter template and follow the [Repository Structure](../Repository%20Structure/README.md).  
- Add an appropriate [Project Maturity Badge](../Project%20Maturity/README.md) (e.g., *Sandbox*).
- Ensure the PR template includes the CLA agreement, so that all contributors agree to it when submitting contributions.

### Existing Repositories

If ECMWF inherits an external repository (e.g., a Code4Earth project), one of three paths is used, to be decided case-by-case by ECMWF staff, typically the Technical Officer in agreement with Head of Development:

1. **Recreate and Import** — create a new ECMWF repository using the cookie-cutter template, then import existing content via PR.  
2. **Transfer Ownership** — transfer the repository into ECMWF’s organisation once it complies with ECMWF’s licensing, copyright, and workflow requirements. This must include:  
   - Adding the CLA agreement to the PR template.  
   - Ensuring all past contributions comply with ECMWF’s [Copyright and Licensing](Legal/copyright_and_licensing.md).  
   - Ensuring the open sourcing guidelines in [Open Sourcing Software at ECMWF](Legal/open_sourcing_software.md) are followed.
3. **Fork** — ECMWF forks the repository to maintain its own variant while the original remains active.  
   - Create an empty `default` branch containing a notice linking to the original project.  
   - Make `default` the default branch so that it shows as the main entrypoint to the repository.  
   - Disable all GitHub Actions to prevent execution of unverified workflows.
   - Where applicable, ensure the forked repository complies with ECMWF’s [Copyright and Licensing](Legal/copyright_and_licensing.md).
   - Where applicable, ensure the open sourcing guidelines in [Open Sourcing Software at ECMWF](Legal/open_sourcing_software.md) are followed.


---

## 2. Integration Delivery Workflow (Optional)

This workflow is **only** for external contractors who need a tighter development loop, internal tagging, or pre-delivery staging. It defines a controlled structure for interim releases before formal ECMWF acceptance. This should be used, for example, for systems or services which will be deployed (in a test or development environment ONLY) as part of the testing and acceptance process.

### Development and Branch Model

Contractors may work in one of two ways:

1. **Forked Development** — using the contractor’s fork of the ECMWF repository.  
   - The fork’s `main` branch serves as the contractor’s working “upstream” branch.  
   - Tags and iterations remain isolated to the contractor’s fork.

2. **ECMWF Integration Branch** — when working directly in the ECMWF repository.  
   - The contractor creates their own integration branch named `upstream` or namespaced as `upstream/<vendor>`.
   - Direct commits to ECMWF’s `main` or `master` are not permitted.  
   - Force-pushes are prohibited.  
   - All changes are proposed to ECMWF `main` or `master` via Pull Requests from the integration branch.

### Tagging Rules

Contractors using this model may create prerelease tags for internal testing and staging:

```
x.y.z-upstream.N
```


Where:  
- `x.y.z` = semantic version (major.minor.patch), which is the target release version upon acceptance
- `N` = sequential prerelease number (1, 2, 3, …)

Rules:
- These prerelease tags are **non-production**.  
- They must not appear on ECMWF’s `main` or `master` branches.  
- They are valid only for contractor-side testing, packaging, or CI pipelines.  
- ECMWF production tags must use the clean [Semantic Versioning](https://semver.org) form:

```
x.y.z
```

### Submission and Approval

When ready for delivery:

1. Open a PR from the contractor’s fork `main` or from the ECMWF integration branch (`upstream` or `upstream/<vendor>`) into ECMWF’s `main` or `master`.  
2. ECMWF staff perform review, validation, and compliance checks.  
   - **Note:** at this stage, all contributions must comply with ECMWF’s copyright and licensing policies, as outlined in [Copyright and Licensing](Legal/copyright_and_licensing.md) and for open source projects, the [Open Sourcing Software at ECMWF](Legal/open_sourcing_software.md) guidelines.

3. Upon acceptance, ECMWF merges the PR. When appropriate, ECMWF can apply a **production tag**:

```
x.y.z
```

**Note:** Acceptance of the PR into `main` or `master` is the point at which a contractor's deliverable is accepted for the purposes of the contract.

Only a production tag marks the release as production-ready.

### Production Control

- Upstream tags are explicitly **non-production**.  
- Only clean ECMWF-issued tags (`x.y.z`) on `main` or `master` represent production software.  
- Non-production tags must never be deployed beyond development or test environments.

