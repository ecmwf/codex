# Repositories

A [Cookiecutter] template for an ECMWF project.

## Using the Template

Generate the project skeleton in a new directory:

    cookiecutter ssh://git@github.com:ecmwf/codex.git --directory Repositories

For adding readmes and files to existing projects, make sure to supply an additional parameter to overwrite existing directories:

    cookiecutter ssh://git@github.com:ecmwf/codex.git --directory Repositories --overwrite-if-exists

You will be asked to provide answers to several questions, in order to properly prepare the template for you. In case you don't know the answer, you can just leave the answer at the default value by pressing Enter.

Note that number of features are optional, you can activate them by answering 'y' when prompted.

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
* `logo_path`: Filepath to a logo, leave default if there is none

## Repository Structure
