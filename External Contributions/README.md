# External Contributions

These are the guidelines are for how external contributions to the ECMWF software stack should be managed,
delivered and maintained. This applies to any collaborator, including individuals, organisations and contractors.

This applies to any repository, including software, configuration, deployment manifests and scripts.

## Contributing to Existing Repositories

### Public Repositories

By default, contributors should fork the ECMWF repository into their own space or organisation space. Developments should be made on your fork, then delivered to us via a pull request (PR) to the original repository. The PR must be populated as requested by any PR template in place for the reposistory. ECMWF staff will then confirm that the changes are not malicious and add the label `approved-for-ci` to the PR. This will allow the github automated actions to run, ensuring that the Pull Request passed all CI/CD tests and actions that are in place.

Contributions to repositories MUST include tests which demonstrate the purpose of the code
changes, and ensure that future developments do not break the changes introduced.

### Private Repositories

If you are contributing to a private repository owned by ECMWF, you will need to be granted a license to ECMWF's GitHub enterprise. To arrange this, speak to the Technical Officer assigned to the contract/project. Internally, management of licenses is handled by User Support (@bkasic). You will then have direct access to the repository. Developments should be made to a branch, and then follow the same PR process as above.

## New repositories

If you are contributing a new repository to ECMWF, please _do not_ create this in your own space. The new repository should be created under ECMWF organisation from the beginning. This will ensure the repository evolves in line with ECMWF's standards.

New repositories will be created upon agreement with ECMWF, via the Technical Officer assigned to the contract/project. The repository will be created by ECMWF with permissions granted and visibility options set as required for the work undertaken. A decision on whether the repository is to be made public or private should be made _as early as possible_ , with a general preference towards public visibility. If the repository is aimed to be public in the future, prefer to keep all development public from the beginning.

Note that new projects can and should be marked with a [project maturity badge](../Project%20Maturity/readme.md) (e.g. Sandbox).

External contributions should then be made as described in the [Contributing to existing repositories](#contributing-to-existing-repositories) section.

The repository must be initialised following the instructions provided in the [Repository Structure](../Repository%20Structure/readme.md) codex documentation.
