# Continuous Software Delivery to ECMWF

These guidelines define what a contractor must deliver when handing over a software service and/or product (e.g. a web application or a data production workflow) to ECMWF. They apply to all external suppliers delivering software under Copernicus and other ECMWF contracts where ECMWF will assume ownership and operation of the delivered software.

Delivery to ECMWF is a **continuous process, not a one-off event at the end of a project**. ECMWF repositories must be requested and set up at the **beginning** of a project, and code, documentation, and deployment recipes must be delivered into them incrementally throughout the work. Treating delivery as a final "handover" step risks lost history, undocumented decisions, and code that cannot be built or operated by anyone other than the contractor. Working continuously in the ECMWF organisation from the outset avoids this and keeps the software in a deliverable state at all times.

The goal is that an ECMWF team with no prior involvement in the project can take full ownership of the software at any point: hold and maintain all source code, deploy and operate every component on ECMWF infrastructure, and understand every external dependency required to run it. These requirements complement, and do not replace, the [External Contributions](./External-Contributions.md) guidelines, which govern *how* code is contributed and delivered — via the standard fork-and-pull-request workflow or, for contractors needing staged testing, the **Integration Delivery Workflow** (with `x.y.z-upstream.N` prerelease tags). Under those guidelines, **acceptance of a pull request into `main` is the point at which a deliverable is accepted for the contract**; delivering continuously into ECMWF repositories from the outset is what keeps that possible at any time, rather than only at the end.

**Technology choices require pre-agreement with ECMWF.** The technologies, languages, frameworks, and third-party services used in the delivered application — including those used to author and publish its documentation — must be agreed with ECMWF in advance, before development begins. This ensures that ECMWF can build, operate, and maintain the software and its documentation with its own teams and tooling once delivered. Contractors must not introduce technologies that ECMWF has not approved without first agreeing them with the Technical Officer.

Documentation must live with the code. The information described in these guidelines must be recorded in the **README** of the relevant repository, or in documentation linked directly from it, rather than collected in a standalone document that can become detached from the code and lost. Where a project spans several repositories, each repository's README must link to the others, so that the full set can be navigated from any one of them. Where a formal delivery or handover document is required as a contract deliverable, it need not duplicate this material — it may cross-reference the relevant repository documentation.

AI tools may be used to assist in writing this documentation — and, subject to the [AI Contributions to Software](./Ai-Contributions-To-Software.md) guidelines, in producing the code itself — but the contractor is responsible for, and must ensure, the final completeness and correctness.

---

## 1. Code Delivery

All source code must be delivered to ECMWF as one or more **GitHub repositories within the ECMWF GitHub organisation**. Code is not considered delivered if it resides only in a personal account, an organisation's own GitHub space, or any location outside ECMWF's organisation. These repositories must be created at the **start** of the project and used as the primary home for the code throughout, not populated only at its end.

* Repositories are created by ECMWF staff via the Technical Officer, following the [Requesting a New Repository](../Legal/Requesting-New-Repository.md) procedure, and should be requested as early as possible so that development happens in the ECMWF organisation from the outset.
* To enable ECMWF to create the repositories, the contractor must provide all of the information required as described in the [Software Management Plan](../Software%20Management%20Plan/README.md#5-new-repositories) guidelines.
* Each repository is initialised using the ECMWF cookiecutter template and follows the [Repository Structure](../Repository%20Structure/README.md) conventions (including a `SECURITY.md`).
* Each repository must contain a `README` describing its contents and providing instructions for building and running the component locally.
* All delivered code must comply with ECMWF [Copyright and Licensing](../Legal/Copyright-And-Licensing.md): an Apache-2.0 `LICENSE` at the repository root and per-file licence headers. New files should carry the machine-readable [SPDX/REUSE headers](../Legal/SPDX-and-REUSE.md) (see [ADR-010](../ADR/ADR-010-SPDX-License-Identifiers-and-REUSE-Headers.md)), with the copyright holder set as agreed in the contract.

## 2. Testing and Continuous Integration

Every delivered repository must carry its own tests and documentation about the continuous integration (CI) configuration that runs them, so that ECMWF can verify the software without any dependency on the contractor.

* Each repository should include an automated test suite for its components (see also the [Testing](./Testing.md) guidelines), and its README must explain how to run the tests locally.
* CI must be delivered as configuration committed to the ECMWF repository (e.g. GitHub Actions workflows) and must run there — not only in the contractor's own infrastructure — so that ECMWF can run, inspect, and maintain it after handover.
* At any point during the project, **the software must build and its tests must pass from a fresh clone, following only the README**.

## 3. Deployment on ECMWF Infrastructure

ECMWF must be able to deploy and operate every delivered component on its **own infrastructure**, independently of any environment maintained by the contractor. ECMWF will not assume responsibility for, or continue to use, contractor-hosted infrastructure.

The deployment architecture — the containerisation and orchestration approach — **must be agreed with the Technical Officer**, since the appropriate approach differs between, for example, a multi-container web application and a data-production workflow. The tooling below is ECMWF's default; agree any deviation in advance.

* **Docker** is ECMWF's standard containerisation method. Every component that is containerised must be delivered with its **Dockerfile(s)** and documentation explaining how the containerisation works — what each image contains, how images are built, and how they are run.
* **Helm** and **Kubernetes** are the tools ECMWF uses to deploy applications. For simple applications, the Dockerfiles alone are often sufficient for ECMWF to deploy the component on its own infrastructure. Where the contractor uses a more complex deployment process — for example, separately deployed backend and frontend components — the contractor must provide the **Helm Chart and ECMWF-specific configuration** they use to deploy these, so that ECMWF can reproduce the deployment. For applications with multiple containers, it is recommended that the deployment configuration is provided and documented in a **separate repository**.
* Deployment recipes must be accompanied by **detailed, step-by-step instructions** sufficient for ECMWF to deploy the software from scratch on its own cluster, without reference to, or dependency on, the contractor's environment.
* Instructions must cover deploying a change, deploying from scratch, and rolling back a deployment.
* Any configuration that differs between environments (e.g. development, staging, production) must be documented, along with every environment variable, secret, and configuration value ECMWF must supply.
* Any value, endpoint, or credential currently hardcoded or otherwise bound to the contractor's infrastructure must be clearly identified, with guidance on what ECMWF must change.

## 4. Releases and Image Provenance

* Deliveries must be marked by **tagged releases** using [Semantic Versioning](https://semver.org) (`x.y.z`), following the tagging rules in [External Contributions](./External-Contributions.md) and the release process in the [Branching](./Branching.md) guidelines, so that deployments and rollbacks reference identifiable versions rather than moving branches. Only clean `x.y.z` tags on `main` represent production software; `x.y.z-upstream.N` prerelease tags are non-production and must not be deployed beyond test environments.
* The README or deployment documentation must state **where container images are published** — the registry, the image names, and how image tags correspond to release tags. Images must be published somewhere ECMWF can pull from and, on handover, operate under its own accounts: an image that exists only in the contractor's registry is bound to the contractor's accounts in the same way as the licences and credentials covered in Sections 8 and 9, and must be flagged accordingly.
* ECMWF must be able to **rebuild every image from source** at any release tag, using the Dockerfiles and instructions delivered under Section 3, so that no deployed image is irreproducible.

## 5. Repository Documentation

* Each repository's README must list every repository delivered for the project (e.g. frontend, backend, infrastructure, data pipelines), matching the repository names provided under Section 1, with a one-line description of each, and link to the others.
* For each repository, the README must state the main branch, any branching conventions in use, and the location of build-and-run instructions.

## 6. Data

* The README must describe how the data behind the application was generated or sourced, including original sources and any scripts or pipelines used to produce it.
* It must explain how ECMWF would regenerate or refresh the data itself, identifying the repository in which the relevant scripts reside and any manual steps involved.

## 7. Supporting Services

* The README must list every external service required to run the application, including but not limited to databases, object storage (e.g. S3 buckets), caches, queues, authentication providers, and monitoring.
* For each service, the README must state its purpose, its configuration, and what ECMWF must provision on its own infrastructure to replace any instance currently running in the contractor's environment. For databases, this includes type, version, schema, and connection details.

## 8. Licences and Third-Party Services

* The README must list every commercial licence, paid API, or subscription required to run the application — for example, a Mapbox licence for mapping.
* For each, it must state its purpose, where the corresponding API keys or credentials are configured, and what ECMWF must establish under its own accounts. Anything currently bound to the contractor's accounts must be flagged.

## 9. Access, Credentials, and Configuration

* **Secret values must never be committed** to the repository or its git history — document only the *names*, *locations*, and *regeneration procedures*. Repository history is scanned for leaked secrets (e.g. with `gitleaks`) before any publication, and a leaked credential must be rotated at source, not merely deleted in a later commit.
* The README must summarise all secrets, keys, and configuration values required to run the application, and state where each should reside (e.g. Kubernetes secrets, environment variables).
* For every secret, key, or credential that can or must be re-generated (e.g. API keys, signing keys, tokens, database passwords, TLS certificates), the README must document **how ECMWF regenerates it** — the service or tool used, the exact steps to follow, and where the new value must then be configured for the application to keep working.
* Any credential bound to the contractor's personal or organisational accounts must be flagged as requiring replacement rather than transfer, with instructions for generating an equivalent value under ECMWF's own accounts.

## 10. Publication and Open-Sourcing

Delivered repositories typically start **private** within the ECMWF organisation. If and when a repository is to be made public, ECMWF does so following [Open Sourcing Software at ECMWF](../Legal/Open-Sourcing-Software.md), which includes the open-source and security audit gates. Because any repository may later be audited for publication, contractors should keep history free of secrets and internal references from the outset (see Section 9).
