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

## New Repositories

If you are contributing a new repository to ECMWF, please _do not_ create this in your own space. The new repository should be created under the ECMWF organisation from the beginning. This will ensure the repository evolves in line with ECMWF's standards.

New repositories will be created upon agreement with ECMWF, via the Technical Officer assigned to the contract/project. The repository will be created by ECMWF with permissions granted and visibility options set as required for the work undertaken. A decision on whether the repository is to be made public or private should be made _as early as possible_ , with a general preference towards public visibility. If the repository is aimed to be public in the future, prefer to keep all development public from the beginning.

Note that new projects can and should be marked with a [project maturity badge](../Project%20Maturity/README.md) (e.g. Sandbox).

External contributions should then be made as described in the [Contributing to existing repositories](#contributing-to-existing-repositories) section.

The repository must be initialised following the instructions provided in the [Repository Structure](../Repository%20Structure/README.md) codex documentation.

## Existing Repositories

There are exceptional cases where ECMWF may need to inherit a repository from another individual or organisation. For example, Code4Earth projects often begin their life outside of the ECMWF GitHub organisation. The best process for this will be made on a case-by-case basis, with three broad options in order of preference:

1. Create a [new repository](#new-repositories), run the cookie-cutter on the empty repository, and then merge the existing repository in via pull request. Fix any deviations in repository structure or best practices as part of the pull request.

2. Transfer ownership:
    * Compared to option 1, this has the advantage that the Git history, GitHub issues, list of contributors and other metadata are kept.
    * Note that the repository MUST be adapted to follow ECMWF practices BEFORE the transfer if that repository is public. This means adding the correct licences, GitHub actions, copyright notices, readme template, badges, etc. which would usually be set up by the cookie cutter. It is possible to run the cookie-cutter on existing repositories, but there may be conflicts.

3. ECMWF makes a fork:
    * Useful if the project continues to exist and evolve outside of ECMWF, but ECMWF needs its own version.
    * Note that ECMWF has limited control over the repository in this case, a particular concern for GitHub actions. It is usually sensible to disable all actions.
    * Depending on the situation, it may be best to make it clear that this is a fork. Follow these instructions:
        <details>
            <ol>
            <li>Create a new branch, which shall be empty except for a readme.md. The branch can be called `default`. You can do this with `git switch --orphan default` Follow the template below.</li>
            <li>Make that branch the default branch, so that it is the page most people land on.</li>
            <li>In the repository settings, disable all actions, because we don't know what workflows we just imported, and they now have access to internal systems and organisation secrets.</li>
            </ol>

        <pre>
            > \[!CAUTION\]
            > This is a fork of **xyz**. Please go to the original repo linked below for further information about **xyz**.
        </pre>
        </details>


