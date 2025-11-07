# Open Sourcing Software at ECMWF

When open sourcing an ECMWF software, either as an ECMWF member or as a sub-contractor with whom it was agreed to deliver software as open sourced, please follow the guidelines below.

## GitHub ECMWF package check list

- Contact point:
   - FSD contact point/admin for github.com/ecmwf: Head of Development at ECMWF
   - Seek approval for open source:
     - Verify the package is right for ECMWF GitHub page and discuss the suitablility for it to be open.
     - Discuss the scope of the software, what it does and what it does not
     - Agree the initial access, i.e. start closed and then open or start immedietly open even if incomplete.
     - Agree that only once the following check list is complete, will this software be open sourced.

- Contact GitHub space administrator, typically a Team Leader in Development:
   - Discuss access setup to space (public or private) and who can commit to code
     (Maintainer will be shown how to change this)
   - Discuss which GitHub feature should be en/disabled (e.g. issues, wiki, contributions, forking)
   - Discuss how internal codes will be synced with GitHub (if required and/or applicable)

- To give access, Maintainers and Contributors need to have a GitHub account. Currently for github.com/ecmwf this is a Github Enterprise account, for which the following applies:
   - Maintainers should be ECMWF staff
   - External contributions must follow the policy for [External Contributions](../External%20Contributions/README.md)
   - External contributors will be asked to agree with a contribution license agreement (CLA) on pull request.
   
- Ensure a `README` file exists in the root directory
   - Explains purpose and scope of code
   - Explains what kind of support is to expect (none) and how to contact ECMWF (link to Service Desk)
   - May feature a disclaimer for codes that are not officially supported or should not be used in operational context
   - Clarify the state of the software (stable, alpha, beta, obsolete, …) or, preferably, define following Software Maturity guidelines, see [Software Maturity](../Project%20Maturity/README.md)
   - Clarify the level of support (none, best effort, operational, …)
   - Link to any further documentation of the code
   - Provide instructions on how to install
   - Most packages have a short example on how to use the code
   - Use `.md` (prefered) or `.rst` format

- Ensure the relevant software licence is applied
   - One central licence file and references in each (code) file as described in [Copyright and Licensing](copyright_and_licensing.md)
   - For Apache Licence, see [Applying the Apache License](copyright_and_licensing.md)
   - For first time releases, codes should be audited for:
      - IPR violations. Contact Development Section to arrange for a code audit
      - Sensitive information that is internal to ECMWF (e.g. passwords, user names, hostanmes, emails, etc.)
      - Ensure that the code is not using any third party software that is not compatible with the Apache Licence
   - NB: "licence" is the correct spelling for the noun; "license" for the verb (so "licensing")

- If any external contributions are expected, ensure the contribution licence agreement plugin (CLA Assistant) to the repository.
   - Contact GitHub admin for this - typically is done by ensuring your PR's use a template that presents the CLA
   - Ideally some automatic CI tests should be set up, that any pull request can be checked. Contact Development section to arrange for integration into ECMWF CI/CD system.
   - Make sure to stress that any contribution should come with documentation and tests!
