# External Contributions

These are the guidelines are for how external contributions to the ECMWF software stack should be managed,
delivered and maintained.

## Contributing to existing repositories
If contractors are contributing to existing ECMWF repositories, then contractors should fork the repository
to their personal/company github organisation. Developments are made on their fork of the repository, then
delivery is made via a pull request (PR) to the original ECMWF repository. The PR must be populated as
requested by any PR template in place for the reposistory. ECMWF staff will then confirm that the changes
are not malicious and add the label `approved-for-ci` to the PR. This will allow the github automated actions
to run, ensuring that the Pull Request passed all CI/CD tests and actions that are in place.

New contributions to existing repositories MUST include tests which demonstrate the purpose of the code
changes, and ensure that future developments do not break the changes introduced.

TODO: What can the contractor do prior to opening PR?

## New repositories
If contractors are developing a new github repository, then they should create a repository in their
personal/company github organisation following the instructions provided in the
[Repository Structure](../Repository%20Structure/readme.md) codex documentation.
The ECMWF staff member following the contract (Technical Officer), and in some cases supporting ECMWF
colleagues, must be added with at least read permissions so that they can follow progress throughout
the contract.

Upon delivery, the repository should include the CI/CD tests and actions provided in the cookiecutter template/as documented in [Repository Structure](../Repository%20Structure/readme.md). The actions must run successfully, the delivery will then be reviewed by the Technical Officer.

Delivery of the software will be done in one of two ways, decision is made on a case-by-case basis, but more often than not it will be option 1:

1. Transfer ownership of the github repository to an ECMWF github organisation. This requires that an owner of the ECMWF github organisation is added to the repository with an admin role to make the transfer. At this point the contractors will lose the admin role of the original repository. Future developments should then follow the [Contributing to existing repositories](#contributing-to-existing-repositories).
2. Fork the repository to an ECMWF organiation. This requires an owner of the ECMWF github organisation to make the fork to the ECMWF github organisation. In this scenario, the contractor maintains the admin role of the upstream repository.


## Glossary

* `project_name`: Official name of the project, used as input for project_slug
* `project_slug`: Used as name of the project directory, alphanumerics only
* `project_description`: Textual description of the project
* `maturity_badge`: Level of maturity of the repository
* `docs_dir`: Subdirectory for the documentation, supply a dot (.) for none
* `copyright_year`: Official start year of copyright
* `copyright_name`: Official copyright holder name
* `github_organisation`: Github space where the repository lives
* `language`: The main language of the repository, used for structure and guidelines generation
* `fail_on_warning`: Fail build when warning is encountered
* `additional_formats`: Whether to generate PDF/EPUB/single HTML formats for the docs
* `use_github_workflow`: Whether to add Github workflow to test doc builds
* `use_include`: Whether to include upper directories in documentation
* `use_autodoc`: Whether to document Python code automatically
* `use_version_file`: Whether to infer release version from VERSION file
* `use_doxygen`: Whether to document C/C++ code automatically
* `use_ipynb`: Whether to add support for Jupyter Notebooks
* `use_copybutton`: Whether to add copy to clipboard button for code blocks
* `use_tabs`: Whether to add tabs for switchable content
* `use_todo`: Whether to add TODO comment blocks
* `use_fortran`: Whether to add support for documenting Fortran code
* `use_ecflow_lexer`: Whether to add support for ecFlow syntax highlighting
* `open_source_license`: Project licence
* `logo_path_light`: Filepath to a logo for light mode, skipped if not provided
* `logo_path_dark`: Filepath to a logo for dark mode, use light if not provided
