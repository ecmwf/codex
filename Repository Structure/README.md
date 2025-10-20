# Repository Structure

These are the guidelines for how a software package repository should be structured.
If creating a new software package repository you should
[use the cookiecutter template](https://github.com/ecmwf/cookie-cutter) which will create
respository following the guidelines documented below.

- [Repository Structure](#repository-structure)
  - [Readme](#readme)
  - [Badges](#badges)
  - [Code Structure](#code-structure)
    - [Python](#python)
    - [C/C++](#cc)
  - [License](#license)
  - [Contributors](#contributors)
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
├── LICENSE
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

Note the extra src directory. This prevents setuptool's find_package from adding unwanted code to the installation, without having to add exceptions for tests, examples, etc. It also forces the package to be pip install'ed before running the tests, which helps checking that the package will work as intended once installed. Simple use case: it won't import the local package if you run pytest in the folder.

### C/C++

```
<project-name>
├── CMakeLists.txt
├── LICENSE
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

## Resources

- [Cookiecutter template](https://github.com/ecmwf/cookie-cutter)