# Requesting a New GitHub Repository

## 1. Overview

GitHub has strict rules regarding repository ownership and creation.

Because all repositories within the ECMWF GitHub Enterprise are owned by ECMWF, individual users — including members of underlying ECMWF GitHub organisations — are **not permitted** to directly create repositories within those organizations.

Instead, all repository creations and transfers must go through a centralized request process to ensure compliance and management of the single namespace. This ensures ECMWF can properly manage naming conventions, visibility, access policies, compliance requirements, billing, and security settings for all assets under Github Enterprise.

## 2. How to Request a Repository

Whether you need to create a repository from scratch, transfer an existing repository from another GitHub owner, or migrate a repository from Bitbucket, you must submit a formal request.

**Access the Request Form here:** [Form](https://forms.cloud.microsoft/pages/responsepage.aspx?id=xhG3IbeqNk2f-6wDV7wguiHmJMYpID5AlSzSoJeMPzBUNTBDQzM5RkJITDROWlBUTUNEQ1g4NlVNSS4u&route=shorturl)

### Information You Will Need to Provide

Please have the following details ready before filling out the e-form:

* **Proposed Name:** The desired name for the repository (this will be checked against availability and clarity of purpose).
* **Main Goal:** A brief description of the repository's intended use and purpose.
* **Content Type:** The kind of assets that will be stored (e.g., source code, training materials, configurations, documentation, etc).
* **Visibility Level:** The required visibility on GitHub (Private, Internal, or Public). *Note: See Section 4 for important rules regarding Public repositories.*
* **Access Permissions:** A list of users or teams who need access, specifying their required permission levels (e.g., Admin, Write, Read).

## 3. Workflow and Approval Process

Once your e-form is submitted, it follows a standard administrative workflow:

1. **Review & Approval:** The Head of Development will review your request to ensure it aligns with ECMWF's software strategy and naming conventions.
2. **Creation & Configuration:** If approved, **User Services** will manually create or transfer the repository and apply the requested access permissions.
3. **Notification:** You will receive a notification once your repository is set up and ready to use. Please check that your permissions are correctly applied and that the repository is configured as requested.
4. **Check Branch Protection Rules:** If applicable, ensure that any necessary branch protection rules are set up to maintain code quality and security standards (e.g., ensuring the main branches are protected, requiring pull request reviews, status checks, etc).

## 4. Open-Sourcing / Public Repositories

Requesting a **Public** repository (or changing an existing repository's visibility to Public) carries legal and intellectual property implications. 

If your repository requires public visibility, you must complete the official open-sourcing approval procedure.
Your repository will be first made Private and only made Public once the open-sourcing process is complete and approved.

Please review and follow the guidelines documented here: [Open Sourcing Software Procedure](https://github.com/ecmwf/codex/blob/main/Legal/open_sourcing_software.md)