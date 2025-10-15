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

Contributions to repositories MUST include tests which demonstrate the purpose of the code
changes, and ensure that future developments do not break the changes introduced.

## New repositories
New repositories will be granted upon agreement with ECMWF, via the Technical Officer assigned to the
contract/project.
The repository will be created by ECMWF with permissions granted and visibility options set
as required for the work undertaken.
External contributions should then be made as described
in the [Contributing to existing repositories](#contributing-to-existing-repositories) section.

The repository must be initialised following the instructions provided in the
[Repository Structure](../Repository%20Structure/readme.md) codex documentation.
