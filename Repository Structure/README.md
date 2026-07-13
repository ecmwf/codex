# Repository Structure

These are the guidelines for how a software package repository should be structured.
If creating a new software package repository you should
[use the cookiecutter template](https://github.com/ecmwf/cookie-cutter) which will create
repository following the guidelines documented below.

- [Repository Structure](#repository-structure)
  - [Readme](#readme)
  - [Badges](#badges)
  - [Code Structure](#code-structure)
    - [Python](#python)
    - [C/C++](#cc)
  - [License](#license)
  - [Contributors](#contributors)
  - [Security Policy](#security-policy)
  - [Citation](#citation)
  - [Resources](#resources)

## Readme
Each repository must contain a README.md file. The cookiecutter generates one automatically from a template file. The generated README.md must then be filled in with project specific information.

## Badges

The cookiecutter automatically adds badges at the beginning of the README.md file. Make sure that they are all working correctly, and syncing to CI, coverages and docs.

## Code Structure

### Python
Following the recommendation of the Python packaging guide, the layout should be akin to:

```
my-repo/
├── bin/
├── docs/ 
├── examples/             # optional
├── LICENSE               # Apache 2.0 + ECMWF intergovernmental notice
├── LICENSES/             # REUSE: unmodified licence texts (Apache-2.0.txt)
├── NOTICE                # ECMWF copyright + intergovernmental notice
├── REUSE.toml            # REUSE annotations for non-commentable files
├── SECURITY.md           # recommended: vulnerability-disclosure policy
├── CITATION.cff          # recommended: citation metadata
├── CONTRIBUTORS          # list of contributors
├── pyproject.toml
├── README.md            # deviation from the guide
├── setup.py              # VERY shallow, just calls setup() or something
├── src/
│   └── example_package/
│       ├── __init__.py   # omit if you plan to use a namespace package
│       ├── example.py
│       └── version.py
├── tests 
└── tox.ini 
```

The licensing artefacts (`LICENSE`, `LICENSES/`, `NOTICE`, `REUSE.toml`, per-file
SPDX headers) follow [Copyright and Licensing](../Legal/Copyright-And-Licensing.md)
and [SPDX and REUSE](../Legal/SPDX-and-REUSE.md); `SECURITY.md` and `CITATION.cff`
are described below.

Note the extra src directory. This prevents setuptool's find_package from adding unwanted code to the installation, without having to add exceptions for tests, examples, etc. It also forces the package to be pip install'ed before running the tests, which helps checking that the package will work as intended once installed. Simple use case: it won't import the local package if you run pytest in the folder.

### C/C++

```
<project-name>
├── CMakeLists.txt
├── LICENSE               # Apache 2.0 + ECMWF intergovernmental notice
├── LICENSES/             # REUSE: unmodified licence texts
├── NOTICE                # ECMWF copyright + intergovernmental notice
├── REUSE.toml            # REUSE annotations for non-commentable files
├── SECURITY.md           # recommended
├── CITATION.cff          # recommended
├── CONTRIBUTORS
├── README.md
├── VERSION
├── cmake
├── doc
|   ├── CMakeLists.txt
|   └── Doxyfile.in
├── share
└── src
|   ├── CMakeLists.txt
|   ├── <project-name>
|   ├── experimental
|   └── tools
└── tests
    ├── CMakeLists.txt
    ├── test_1
    ├── ...
    └── test_N
```

## License
Add a LICENSE file at the root of the project. Add following text to the README.md file:

```
## License
[Apache License 2.0](LICENSE) In applying this licence, ECMWF does not waive the privileges and immunities granted to it by virtue of its status as an intergovernmental organisation nor does it submit to any jurisdiction.
```

## Contributors
The cookiecutter template automatically generates a contributors file. External contributors are encouraged to open their Pull Requests to be added to the list.

## Security Policy

Each repository should contain a `SECURITY.md` file (strongly recommended) so
that anyone who finds a vulnerability knows how to report it privately rather
than in a public issue. Place it at the repository root (`.github/` or `docs/`
also work). This matches the `security-audit` skill, which recommends a
`SECURITY.md` but does not treat its absence as a blocker.

Copy the generic template — [`SECURITY.md`](./SECURITY.md) — into the new
repository. It is deliberately language- and project-agnostic: it routes
reporters to **GitHub private vulnerability reporting** first, with the
[ECMWF Support Portal](https://support.ecmwf.int) as the fallback, so it applies
unchanged to any ECMWF repository. Adjust the *Supported Versions* table only if
the project's release policy differs. What happens after a report is made is
defined in the
[Security Vulnerability Disclosure](../Guidelines/Security-Vulnerability-Disclosure.md)
procedure.

## Citation

Making the software citable is advised for every public repository: mint a DOI
once the repository is public (e.g. via the GitHub–Zenodo integration) and add a
`CITATION.cff` file at the repository root so external users and publications
can reference the software precisely. GitHub surfaces it as a "Cite this
repository" button, and Zenodo reads it directly when archiving a release. This
matches the `open-source-audit` skill, which records citation/DOI as an advisory
(never a blocker).

Copy the example — [`CITATION.cff`](./CITATION.cff) — into the repository root
and adapt the placeholders (title, abstract, authors, version, and the DOI once
minted). Validate it with `cffconvert --validate` or the online editor at
<https://citation-file-format.github.io>.

## Resources

- [Cookiecutter template](https://github.com/ecmwf/cookie-cutter)