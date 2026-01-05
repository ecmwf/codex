# Software Management Plan

A sofware management plan should be provided for all projects which contribute to the ECMWF software stack.
This is to ensure that contributions are appropriate, visible, follow guidelines and there is a clear roadmap
for development and ownership.

A software management plan is required for all projects where the lead developers are external contributors
and should be provided in the planning stages of the project.
For internal contributors, a software management plan is required to progress your project from the Sandbox
to Emerging [Project Maturity](../Project%20Maturity/).

## 1. Project Overview

Provide a concise overview to allow others to understand the project and its purpose.

Include:

- **Project name**
- **Purpose and goals**
  - What problem it solves / value it provides
  - Scope and boundaries (what is included and excluded)
- **Relationship to the ECMWF software stack**  
  - New components?
  - Extension?
  - Replacement of legacy functionality?

---

## 2. Alignment With ECMWF Strategy and Architecture

Explain how the software fits into ECMWF's broader technical and organisational goals.

Address:

- **Alignment with ECMWF technical strategy**
- **Fit with ECMWF architecture, APIs, data formats, workflows, and coding standards**
- **Avoiding duplication**
- **Interoperability and portability**

---

## 3. Ownership and Stakeholders

Identify the roles and responsibilities, and the estimated roadmap/timeline of these roles. Please note that an individual or group can be assigned multiple roles.

Include:

- **Project owner(s) / maintainer(s)**
  - If these roles are expected to change, e.g. when the project/contract comes to an end, please include an estimated timeline.
- **Contributors/development team**
- **Stakeholders**
  - Identify the users and/or beneficiaries

Optionally include (if different from the *Project owner/maintainer* above):

- **Domain experts / reviewers**
- **Points of contact**
- **Long-term maintenance owner**

---

## 4. Development and Maintenance Roadmap

Provide a forward-looking plan describing how the software will be developed and subsequently maintained.

Include:

- **Milestones and deliverables**
- **Release strategy**
  - Frequency, versioning, branching model
- **Dependency management**
- **Maintenance**
  - Who is the maintainer of the delivered software, both during and after the project?
  - How will future developments, and user requests, be managed?
- **Maturity timeline**
  - What is the expected timeline for the progression through the [Project Maturity](../Project%20Maturity/) classifications

Optionally include:

- **Any planned extensions and/or enhancements**

---

## 5. Compliance With ECMWF Development Guidelines

Ensure the project contributions are managed visibly and according to ECMWF standards and software practices.

Address:

- **Repository requirements** 
  - Required repositories
  - Type and purpose of each
  - Visibility (public/private)
- **Coding style standards** (per language)
- **Quality assurance**
  - Unit, integration, regression testing
  - CI/CD setup
  - Code review process
- **Performance expectations**
- **Security considerations**
- **License choice** (with justification if non-standard)
- **Contribution workflow**
  - Branching model
  - Merge/pull request requirements
  - Mandatory reviews

---

## 6. Documentation and User Support

Outline how users (e.g. maintainers and operators) and developers will work with and understand the software.
Please note that the documentation developments *MUST* be in unison with software developments and follow the
[Repository Structure guidelines](../Repository%20Structure/README.md).

Include:

- **User documentation** 
  - What will it cover, e.g. installation, usage, examples.
  - How will you ensure that user needs are met?
- **Developer documentation**
  - What will it cover, e.g. API, architecture, contribution guidelines.
- **Documentation location**
- **Support model**
  - Issue tracking
  - Expected response times
  - Communication channels

---

## 7. Risk management

Identify potential risks associated with the development and maintainance of the software produced.

Where applicable, include:

- **Dependancies**
- **Loss of key personnel**
- **Insufficient documentation**
- **Performance regressions**
- **Maintenance cost**
- **Scope creep**

---

## 8. Data Handling (if applicable)

If the software interacts with ECMWF data, specify:

- **Data formats** (GRIB, NetCDF, databases, etc.)
- **Storage locations**
- **Data volumes**
- **Compliance with ECMWF data governance policies**

---

## 9. AOB

If useful, applicable and/or specifically requested, it may also be useful to include aspects related to:

- **Definition of “done” and/or Acceptance criteria**
- **Performance/testing/validation criteria**
- **Description of future changes will be governed**
  - Feature request workflows
  - Backwards compatibility policy
  - Release notes and changelog management
