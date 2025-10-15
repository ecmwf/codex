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
    - [Rust](#rust)
    - [Mixed Languages](#mixed-languages)
  - [License](#license)
  - [Contributors](#contributors)
- [Using the Template](#using-the-template)
  - [Glossary](#glossary)

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


### Rust
TODO

### Mixed Languages



## License
Add a LICENSE file at the root of the project. Add following text to the README.md file:

```
## License
[Apache License 2.0](LICENSE) In applying this licence, ECMWF does not waive the privileges and immunities granted to it by virtue of its status as an intergovernmental organisation nor does it submit to any jurisdiction.
```

## Contributors
The cookiecutter template automatically generates a contributors file. External contributors are encouraged to open their Pull Requests to be added to the list.


A [Cookiecutter] template for an ECMWF project.

# Using the Template

Generate the project skeleton in a new directory:

    cookiecutter ssh://git@github.com:ecmwf/cookie-cutter.git

For adding readmes and files to existing projects, make sure to supply an additional parameter to overwrite existing directories:

    cookiecutter ssh://git@github.com:ecmwf/cookie-cutter.git --overwrite-if-exists

You will be asked to provide answers to several questions, in order to properly prepare the template for you. In case you don't know the answer, you can just leave the answer at the default value by pressing Enter.

Note that several features are optional, you can activate them by answering 'y' when prompted.

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
