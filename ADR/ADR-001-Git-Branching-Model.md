# Architectural Decision Record 001: Git Branching Model

## Status
[**Proposed** | <s>Accepted</s> | <s>Deprecated</s> | <s>Superseded by [ADR-XXX]</s>]

## Last Updated
2025-06-25

## Context

We would like to provide guidelines for a more consistent Git branching strategy across repositories to ensure efficient collaboration, reliable releases, and maintainable codebases. We are evaluating two well-established approaches:

Git Flow - The branching model by Vincent Driessen using both main/master and develop branches
GitHub Flow - GitHub's lightweight branch-based workflow using only main/master

We recognise that the choice of branching strategy significantly impacts development velocity, release management, code stability, and team coordination. Different repositories may have varying complexity levels and operational requirements, necessitating a flexible approach that can evolve with project needs.

**Decision Drivers**

* Development team size and experience levels
* Release frequency and deployment patterns
* Code review and quality assurance processes
* Operational complexity and risk tolerance
* Repository maturity and usage patterns
* Need for supporting multiple software versions

### Options Considered

#### Option 1: Git Flow (Vincent Driessen's Model)

Based on the branching model described at https://nvie.com/posts/a-successful-git-branching-model/

The Git Flow model has been so far the choice for many operational software packages, providing a structured approach to managing releases and features, as well as support branches for hotfixes and long-term maintenance. It has allowed for parallel development of features while maintaining a stable main branch for production releases.

**Structure**

* main/master: Production-ready code, tagged releases
* develop: Integration branch for next release containing latest delivered development changes
* feature branches: Individual feature development, branched from develop
* release branches: Preparation for production releases, branched from develop
* hotfix branches: Critical production fixes, branched from main/master
* support branches: Long-term maintenance for older releases

**Workflow Steps**

Feature Development:

* Create feature branch from develop
* Develop feature with regular commits
* When complete, merge back to develop and delete feature branch

Release Process:

* Create release branch from develop
* Bump version number and commit
* Perform final testing and bug fixes on release branch, possibly coordinating with other components
* Merge to main and tag the release
* Merge back to develop and delete release branch

Hotfix Process:

* Create hotfix branch from main
* Bump version and fix the bug(s)
* Merge to main and tag the hotfix
* Merge to develop and delete hotfix branch

**Advantages**

* Clear separation of concerns: Production code (main) vs. development integration (develop)
* Stable main branch: Always reflects production state
* Structured release process: Release branches allow final testing and bug fixes
* Parallel development: Multiple features can be developed simultaneously
* Better for complex operations: Provides safety nets for high-risk deployments
* Version management: Excellent for maintaining multiple software versions
* Audit trail: Clearer history of what went into each release
* Rollback safety: Easy to identify last known good state
* Consistent treatment of support branches: which are treated the same as other long-lived branches
* Suited for scheduled releases: Works well with planned release cycles
* Well suited for synchronised releases of multiple components as it allows to test all the packages together on develop before doing the synchronised release


**Disadvantages**

* Increased complexity: More branches to manage and understand
* Merge overhead: Additional merge operations between develop and main
* Context switching: Developers must understand which branch to use when
* Delayed feedback: Features may sit in develop longer before reaching production
* Merge conflicts: Higher likelihood due to longer-lived branches
* Slower delivery: More steps in the release process
* Overkill for simple projects: Unnecessary complexity for continuous delivery
* Requires more discipline: Teams must adhere to branching conventions
* Less common in modern open-source projects: Many external contributors prefer simpler models

#### Option 2: GitHub Flow

Based on GitHub's lightweight workflow described at https://docs.github.com/en/get-started/using-github/github-flow

GitHub Flow has gained popularity for its simplicity and alignment with continuous delivery practices, especially in web applications. It allows for rapid development and deployment cycles, but requires strong discipline to ensure the main branch remains stable and deployable.

**Structure**

* main/master: Single source of truth for all code, always deployable
* feature branches: Short-lived branches for individual features or changes
* Pull requests: Mechanism for code review and discussion before merging
* Immediate deployment: Changes are deployed directly after merging to main. By deployment here we mean that the code is ready to be deployed, not that it is automatically deployed to production.

**Workflow Steps**

* Create a branch from main
* Make changes and commit to the branch
* Create a pull request for review
* Address review comments
* Merge the pull request to main and possibly tag new version (if applicable)
* Delete the feature branch
* Deploy (possibly automatically) or Publish artifact

**Advantages**

* Simplicity: Fewer branches to manage and understand
* Faster delivery: Direct path from feature to production
* Reduced merge conflicts: Shorter-lived branches mean fewer conflicts
* Continuous integration: Encourages frequent integration with main
* Lower cognitive overhead: Developers focus on main + feature branch
* Better for small teams: Less coordination overhead
* Encourages quality: Every merge must be production-ready (although this can also increase risk)
* Ideal for continuous delivery: Aligns with systems that deploy frequently
* Pull request-centric: Built-in code review and collaboration

**Disadvantages**

* Higher risk: Main branch may become unstable during active development
* Quality gates dependency: Relies very heavily on a complete CI/CD, requiring robust automated testing to ensure main is always deployable 
* Limited release preparation: No dedicated space for release stabilization
* Coordination challenges: Requires strict discipline for production readiness
* Hotfix complexity: May interfere with ongoing feature development
* Less suitable for scheduled releases: Harder to prepare release candidates
* Not ideal for versioned software: Difficult to support multiple versions in the presence of hotfixes on previous versions
* Less structured: No clear separation between production and development code
* Requires strong team discipline: Teams must ensure main is always deployable
* Not as common in operational software: Many operational software packages use Git Flow

### Analysis

**Team Size Impact**

* Small teams (1-3 developers): GitHub Flow reduces overhead and simplifies collaboration
* Medium teams (4-8 developers): Either approach viable, depends on release cadence and software type
* Large teams (9+ developers): Git Flow provides better coordination and parallel development structure

**Release Patterns**

* Continuous deployment: GitHub Flow aligns perfectly with continuous delivery practices
* Scheduled releases: Git Flow provides better control and release preparation capabilities. Also supports synchronised releases of multiple components.
* Mixed patterns: May require different strategies per repository based on deployment needs

**Software Type Considerations**

* Web applications: GitHub Flow ideal for continuously delivered web apps (when appropriate CI/CD is in place)
* Versioned software: Git Flow better suited for software requiring multiple version support (especially if the software is operational)
* Simple applications: GitHub Flow avoids unnecessary complexity

**Operational Complexity**

* Simple applications: GitHub Flow reduces unnecessary complexity
* Critical systems: Git Flow provides additional safety measures and structured release process
* Evolving requirements: Start simple, add complexity as needed

## Decision

We will adopt a **hybrid approach** that allows repositories to evolve their branching strategy based on operational needs and complexity:

### Initial State: GitHub Flow
All new repositories will start with GitHub Flow:
* Use main/master as the primary branch
* Create feature branches for development
* Use pull requests for code review and collaboration
* Merge directly to main when features are complete and reviewed
* Deploy directly from a tag on main (manual or automated)
* Use hotfix branches for critical production issues if needed

### Evolution Trigger: GateKeeper Decision
Lead developers (GateKeepers) for each repository can decide to upgrade to Git Flow when one or more of the following conditions are met:

* Repository usage becomes operationally critical
* Team size exceeds comfortable coordination limits (typically 8+ developers)
* Software requires explicit versioning or multiple version support
* Release process requires more structured approach with dedicated release preparation
* Stakeholders require additional quality gates and formal release cycles
* Deployment risk warrants additional safeguards and staging processes
* Continuous delivery is not suitable for the software type

The reverse can also happen, where a repository using Git Flow can revert to GitHub Flow if it the assessment of the criteria reverses (e.g. becomes simpler or less critical).

### Migration Path

When upgrading from GitHub Flow to Git Flow:

* Create develop branch from current main
* Update repository documentation and contribution guidelines
* Make develop the default branch on GitHub so that PRs target it by default
* Configure branch protection rules for both main and develop
* Train team members on new workflow and branch types
* Update CI/CD pipelines to support new branching structure
* Adopt release process and ECMWF tagging conventions (if not already in place)

### Related Decisions

These decisions listed below were taken into account and they preexist this ADR.

* CI/CD pipeline configuration must support both GitHub Flow and Git Flow
* Code review exist for both branching models GitHub Flow and Git Flow
* Branch protection rules must be configured appropriately for each model, with main/master and develop branches protected for changes only by pull requests accepted by GateKeepers
* Deployment strategies may vary with the system or service and are not ncecessarily dependent on the chosen workflow, i.e. continuous vs. scheduled, where most ECMWF is deployed into operations with a scheduled release process.

## Consequences

### Positive

* **Flexibility**: Repositories can adopt complexity as needed
* **Reduced barrier to entry**: New repositories start with proven, simple GitHub Flow
* **Scalable approach**: Can grow with repository importance and team size
* **Team autonomy**: GateKeepers make decisions based on their domain expertise
* **Cost-effective**: Don't pay complexity tax until it's warranted
* **Industry alignment**: Starts with widely adopted GitHub Flow, can evolve to Git Flow

### Negative

* **Inconsistency**: Different repositories may use different strategies
* **Learning curve**: Developers need to understand both GitHub Flow and Git Flow
* **Documentation overhead**: Must maintain guidelines for both models
* **Migration complexity**: Moving from GitHub Flow to Git Flow requires coordination
* **Decision complexity**: GateKeepers must understand when to evolve workflows

### Mitigation Strategies

* Maintain clear documentation for both GitHub Flow and Git Flow workflows, and declare which model is used in each repository
* Provide training materials and examples for both models
* Create migration checklists and best practices for evolving from GitHub Flow to Git Flow
* GateKeepers to review repository complexity needs and workflow appropriateness
* Document decision rationale per software package when evolving workflow strategies

## References

* GitHub Flow: https://docs.github.com/en/get-started/using-github/github-flow
* Git Flow: https://nvie.com/posts/a-successful-git-branching-model/

## Authors
- Tiago Quintino
- James Hawkes
- Simon Smart
- Corentin Carton de Wiart
- Domokos Sarmany
- Iain Russell
- Cihan Sahin
