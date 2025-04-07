{% if cookiecutter.logo_path_light != "" -%}
![{{ cookiecutter.project_slug }} logo](https://raw.githubusercontent.com/ecmwf/logos/refs/heads/main/logos/{{ cookiecutter.project_slug }}_dark.png)
{%- endif%}

[![ESEE Foundation](https://img.shields.io/badge/ESEE-Foundation-orange)]()
[![Maturity: {{ cookiecutter.maturity_badge }}](https://img.shields.io/badge/Maturity-{{ cookiecutter.maturity_badge }}-{{ {'Sandbox': 'yellow', 'Incubating': 'lightskyblue', 'Emerging': 'violet', 'Graduated': 'green', 'Archived': 'orange'}[cookiecutter.maturity_badge] }})](https://github.com/ecmwf/codex/blob/cookiecutter/Project%20Maturity/project-maturity.md)

{% if cookiecutter.ci_actions == 'y' -%}
[![CI](https://github.com/{{ cookiecutter.github_organisation }}/{{ cookiecutter.project_slug }}/actions/workflows/ci.yaml/badge.svg)](https://github.com/{{ cookiecutter.github_organisation }}/{{ cookiecutter.project_slug }}/actions/workflows/ci.yaml)
{%- endif%}

{% if cookiecutter.code_coverage == 'y' -%}
[![Code Coverage](https://codecov.io/gh/{{ cookiecutter.github_organisation }}/{{ cookiecutter.project_slug }}/branch/develop/graph/badge.svg)](https://codecov.io/gh/{{ cookiecutter.github_organisation }}/{{ cookiecutter.project_slug }})
{%- endif%}

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/apache-2-0)
[![Latest Release](https://img.shields.io/github/v/release/{{ cookiecutter.github_organisation }}/{{ cookiecutter.project_slug }}?color=blue&label=Release&style=flat-square)](https://github.com/{{ cookiecutter.github_organisation }}/{{ cookiecutter.project_slug }}/releases)
[![Documentation Status](https://readthedocs.org/projects/{{ cookiecutter.project_slug }}/badge/?version=latest)](https://{{ cookiecutter.project_slug }}.readthedocs.io/en/latest/)

# {{ cookiecutter.project_name }}

> [!TIP]
> Write here the "mission statement" of the project.
> It should be a short paragraph that describes the purpose of the project (why have we built this?) and what it does. It should be written in a way that is easy to understand for someone who is not familiar with the project.


# Features

> [!TIP]
> Ideally a bullet-point list of the key features. You can go into a bit more detail here. Try to capture _why_ this software is unique.

- **Foo**: It has Foo
- **Bar**: It has Bar

# Quick Start

> [!TIP]
> Each repository should contain a quick-start guide, which shows the quickest possible path to get something working with this package.
> Ideally a code block which can be just copy-pasted.

# Installation

{% if cookiecutter.language == 'cpp' -%}

{{ cookiecutter.project_name }} employs an out-of-source build/install based on CMake.

Make sure ecbuild is installed and the ecbuild executable script is found ( `which ecbuild` ).

Now proceed with installation as follows:

```bash
# Environment --- Edit as needed
srcdir=$(pwd)
builddir=build
installdir=$HOME/.local

# 1. Create the build directory:
mkdir $builddir
cd $builddir

# 2. Run CMake
ecbuild --prefix=$installdir -- $srcdir

# 3. Compile / Install
make -j10
make install

# 4. Check installation
$installdir/bin/{{ cookiecutter.project_slug }}-version
```
{%- elif cookiecutter.language == 'python' -%}
Install from the Github repository directly:
```
python -m pip install https://github.com/{{ cookiecutter.github_organisation }}/{{ cookiecutter.project_slug }}
```
or from PyPI:
```
python -m pip install {{ cookiecutter.package_name }}
```
{%- elif cookiecutter.language == 'rust' -%}
Install from the GitHub repository directly:
```
cargo add --git https://github.com/{{ cookiecutter.github_organisation }}/{{ cookiecutter.project_slug }}
```
or from crates.io:
```
cargo add {{ cookiecutter.project_slug }}
```
{%- elif cookiecutter.language == 'mixed' -%}
> [!TIP]
> For mixed languages repositories you need to edit the install instructions to obtain custum instructions for your repository. Standard install instruction templates for C++, Python, and Rust are included below.

> Standard instruction for C++

{{ cookiecutter.project_name }} employs an out-of-source build/install based on CMake.

Make sure ecbuild is installed and the ecbuild executable script is found ( `which ecbuild` ).

Now proceed with installation as follows:

```bash
# Environment --- Edit as needed
srcdir=$(pwd)
builddir=build
installdir=$HOME/.local

# 1. Create the build directory:
mkdir $builddir
cd $builddir

# 2. Run CMake
ecbuild --prefix=$installdir -- $srcdir

# 3. Compile / Install
make -j10
make install

# 4. Check installation
$installdir/bin/{{ cookiecutter.project_slug }}-version
```
> Standard instructions for Python
Install from the Github repository directly:
```
python -m pip install https://github.com/{{ cookiecutter.github_organisation }}/{{ cookiecutter.project_slug }}
```
or from PyPI:
```
python -m pip install {{ cookiecutter.package_name }}
```
> Standard instructions for Rust
Install from the GitHub repository directly:
```
cargo add --git https://github.com/{{ cookiecutter.github_organisation }}/{{ cookiecutter.project_slug }}
```
or from crates.io:
```
cargo add {{ cookiecutter.project_slug }}
```
{% endif %}

## License

© {{ cookiecutter.copyright_year }} {{ cookiecutter.copyright_name }}. All rights reserved.