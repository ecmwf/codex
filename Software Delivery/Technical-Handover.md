# Technical Handover Documentation

These guidelines define what a contractor must deliver when handing over a web product (or other software service) to ECMWF. They apply to all external suppliers delivering software under Copernicus and other ECMWF contracts where ECMWF will assume ownership and operation of the delivered software.

The purpose of the handover is to allow an ECMWF team with no prior involvement in the project to take full ownership of the software: to hold and maintain all source code, to deploy and operate every component on ECMWF infrastructure, and to understand every external dependency required to run it. These requirements complement, and do not replace, the [External Contributions](https://github.com/ecmwf/codex/blob/main/Guidelines/External-Contributions.md) guidelines, which govern how code is contributed and delivered.

Documentation must live with the code. The information described in these guidelines must be recorded in the **README** of the relevant repository, or in documentation linked directly from it, rather than collected in a standalone document that can become detached from the code and lost. Where a project spans several repositories, each repository's README must link to the others, so that the full set can be navigated from any one of them. Where a technical handover document is required as a contract deliverable, it need not duplicate this material — it may cross-reference the relevant repository documentation.

---

## 1. Code Delivery

All source code must be delivered to ECMWF as one or more **GitHub repositories within the ECMWF GitHub organisation**. Code is not considered delivered if it resides only in a personal account, an organisation's own GitHub space, or any location outside ECMWF's organisation.

* Repositories are created by ECMWF staff via the Technical Officer, following the [Requesting a New Repository](https://github.com/ecmwf/codex/blob/main/Legal/Requesting-New-Repository.md) procedure.
* To enable ECMWF to create the repositories, the contractor must provide:
  * the **number of repositories** required;
  * the **name of each repository**, with a brief description of its contents;
  * the **GitHub user accounts** that require access, and for each, the corresponding **ECMWF account username**. Every contributor who requires access must hold *both* a GitHub account and an ECMWF account; access cannot be granted without both.
* All code contributions must follow the workflow, copyright, and licensing requirements set out in [External Contributions](https://github.com/ecmwf/codex/blob/main/Guidelines/External-Contributions.md) and [Copyright and Licensing](https://github.com/ecmwf/codex/blob/main/Legal/Copyright-And-Licensing.md).
* Each repository must contain a `README` describing its contents and providing instructions for building and running the component locally.

## 2. Deployment on ECMWF Infrastructure

ECMWF must be able to deploy and operate every delivered component on its **own infrastructure**, independently of any environment maintained by the contractor. ECMWF will not assume responsibility for, or continue to use, contractor-hosted infrastructure.

* **Docker** is the required containerisation method. Every component that is containerised must be delivered with its **Dockerfile(s)** and documentation explaining how the containerisation works — what each image contains, how images are built, and how they are run.
* **Helm** and **Kubernetes** are the tools ECMWF uses to deploy applications. For simple applications, the Docker files alone are often sufficient for ECMWF to deploy the component on its own infrastructure. Where the contractor uses a more complex deployment process — for example, separately deployed backend and frontend components — the contractor must provide the **Helm and Kubernetes configuration** they use to deploy these, so that ECMWF can reproduce the deployment.
* Deployment recipes must be accompanied by **detailed, step-by-step instructions** sufficient for ECMWF to deploy the software from scratch on its own cluster, without reference to, or dependency on, the contractor's environment.
* Instructions must cover deploying a change, deploying from scratch, and rolling back a deployment.
* Any configuration that differs between environments (e.g. development, staging, production) must be documented, along with every environment variable, secret, and configuration value ECMWF must supply.
* Any value, endpoint, or credential currently hardcoded or otherwise bound to the contractor's infrastructure must be clearly identified, with guidance on what ECMWF must change.

## 3. Source Code

* Each repository's README must list every repository delivered for the project (e.g. frontend, backend, infrastructure, data pipelines), matching the repository names provided under Section 1, with a one-line description of each, and link to the others.
* For each repository, the README must state the main branch, any branching conventions in use, and the location of build-and-run instructions.

## 4. Data

* The README must describe how the data behind the application was generated or sourced, including original sources and any scripts or pipelines used to produce it.
* It must explain how ECMWF would regenerate or refresh the data itself, identifying the repository in which the relevant scripts reside and any manual steps involved.

## 5. Supporting Services

* The README must list every external service required to run the application, including but not limited to databases, object storage (e.g. S3 buckets), caches, queues, authentication providers, and monitoring.
* For each service, the README must state its purpose, its configuration, and what ECMWF must provision on its own infrastructure to replace any instance currently running in the contractor's environment. For databases, this includes type, version, schema, and connection details.

## 6. Licences and Third-Party Services

* The README must list every commercial licence, paid API, or subscription required to run the application — for example, a Mapbox licence for mapping.
* For each, it must state its purpose, where the corresponding API keys or credentials are configured, and what ECMWF must establish under its own accounts. Anything currently bound to the contractor's accounts must be flagged.

## 7. Access, Credentials, and Configuration

* The README must summarise all secrets, keys, and configuration values required to run the application, and state where each should reside (e.g. Kubernetes secrets, environment variables).
* Any credential bound to the contractor's personal or organisational accounts must be flagged as requiring replacement rather than transfer.