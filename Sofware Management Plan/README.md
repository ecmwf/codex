# Software Management Plan Guidelines

A sofware management plan (SMP) should be provided for all projects which contribute to the ECMWF software stack.
This is to ensure that contributions are appropriate, visible, follow guidelines and there is a clear roadmap
for development and ownership.

A SMP is required for all projects where the lead developers are external contributors
and should be provided in the planning stages of the project.
For internal contributors, a SMP is required to progress a project from the *Sandbox*
to the *Emerging* [Project Maturity](../Project%20Maturity/) level.

Please use the [template SMP](./SMP-template.docx) to create your SMP, it contains much of the description
provide below.

## 1. Project Overview

Provide a concise overview to allow others to understand the project and its purpose.

Include:

- **Project name**
- **Purpose and goals**
  - What problem it solves / value it provides
  - Who is the target audience?
  - Scope and boundaries (what is included and, if useful, what is excluded)
- **Contract Number**
  - Where applicable

## 2. Alignment With ECMWF Strategy and Architecture

Explain how the software fits into ECMWF's broader organisational goals.

Address:

- **Alignment with the ECMWF software stack**
  - New components
  - An extension of existing components
  - A replacement of legacy functionality?
- **Compatibility with ECMWF architectures**
  - Identify steps that ensure consistency with other ECMWF software, e.g. APIs
- **Interoperability and portability**
- **Avoiding duplication**
  - Confirm that overly similar software does not exist elsewhere in the ECMWF software stack

## 3. Ownership, Contributors and Stakeholders

Identify the roles and responsibilities, and the estimated roadmap/timeline of these roles. Please note that an individual or group can be assigned multiple roles.

Include:

- **Project owner(s) / Technical Officer(s)**
  - This must be an ECMWF staff member(s)
  - Include names, e-mail addresses and github usernames
- **Contributors/development team**
  - The primary point of contact should be listed first
  - Include names, e-mail addresses and github usernames
- **Stakeholders**
  - Identify any specific stakeholders

Optionally include (if different from the *Project owner/Technical Officer* above):

- **Domain experts/reviewers**
- **Points of contact**
- **Long-term maintenance owner**

## 4. New Repositories

List the repositories required to develop, deliver, and maintain the software covered by the SMP.
Where possible, minimise the number of repositories and clearly justify the need for any additional ones.

For each repository, please provide:

- **Repository slug**
- **Type**
  - e.g. software package, deployment configuration,  workflow scripts
- **Description**
  - One sentence
- **Visibility**
  - Public or Private
- **Languages(s)**
  - e.g. Python
- **Primary developer**
  - Name and github username

Optional:

- **Template**
  - If using a repository template, please provide the link here.
- **Licence**
  - If not the standard [Apache 2.0 licence](../Legal/apache-licence)
- **Long-term maintenence owner**
  - If this is not consistent across all repostories

## 5. Development and Maintenance Roadmap

Provide a forward-looking plan describing how the software will be developed and subsequently maintained.

Include:

- **Milestones and deliverables**
  - Including expected delivery date and acceptance criteria
- **Development and contribution workflow**
  - Branching model
  - Merge criteria, e.g. pull requests with mandatory X reviews, all CI/CD test pass
- **Release strategy**
  - Versioning system, e.g. *"Semantic versioning (MAJOR.MINOR.PATCH)"*
- **Maintenance**
  - How will future developments, and user requests, be managed?
- **Maturity timeline**
  - What is the expected timeline for the progression through the [Project Maturity](../Project%20Maturity/) classifications
- **Performance and/or validation testing**
  - Optional. Describe any performance and/or validation testing that will be included
- **Planned extensions/enhancements**
  - Optional. List any planned extensions/enhancements that are expected beyond the timescale of the project.

## 6. Documentation and User Support

Outline how users (e.g. maintainers and operators) and developers will work with and understand the software.
Please note that the documentation developments *MUST* be in unison with software developments and follow the
[Repository Structure guidelines](../Repository%20Structure/README.md).

Include:

- **User documentation** 
  - Who are the users?
  - What will it cover? e.g. installation, usage, examples.
  - How will you ensure that evolving user needs are met?
- **Developer documentation**
  - What will it cover, e.g. API, architecture, contribution guidelines.
- **Documentation location**
  - read-the-docs/github-pages/confluence?
- **Support model**
  - Who is the point of conact for support
  - Where and how is support provided, e.g. github issues and/or jira tickets.
  - SLAs, expected response times
  - What support is and what support is not covered (optional)

## 7. Risk Management

Identify potential risks associated with the development and maintainance of the software produced.

Example risks:

- **Dependancies**
- **Loss of key personnel**
- **Insufficient documentation**
- **Performance regressions**
- **Maintenance cost**
- **Scope creep**
- **Security considerations**

## 8. Data Handling (if applicable)

If the software interacts with ECMWF data, specify:

- **Data formats** (GRIB, NetCDF, databases, etc.)
- **Storage locations**
- **Data volumes**
- **Compliance with ECMWF data governance policies**
