{% if cookiecutter.logo_path != 'n' -%}
<h3 align="center">
<img src="./logo.png" width=100px>
</br>
</h3>
{%- else -%}
{%- endif%}


<p align="center">
  <img src="https://img.shields.io/badge/ESEE-Foundation-orange" alt="ESEE Foundation">
  <a href="https://github.com/ecmwf/codex/blob/cookiecutter/Project%20Maturity/project-maturity.md">
    <img src="https://img.shields.io/badge/Maturity-{{ cookiecutter.maturity_badge }}-{{ {'Sandbox': 'yellow', 'Incubating': 'violet', 'Graduated': 'green', 'Archived': 'orange'}[cookiecutter.maturity_badge] }}" alt="Maturity {{ cookiecutter.maturity_badge }}">
  </a>

{% if cookiecutter.ci_actions == 'y' -%}
  <a href="https://github.com/{{ cookiecutter.github_organisation }}/{{ cookiecutter.project_slug }}/actions/workflows/ci.yaml">
    <img src="https://github.com/{{ cookiecutter.github_organisation }}/{{ cookiecutter.project_slug }}/actions/workflows/ci.yaml/badge.svg" alt="CI Status">
  </a>
{%- else -%}
{%- endif%}

{% if cookiecutter.code_coverage == 'y' -%}
  <a href="https://codecov.io/gh/{{ cookiecutter.github_organisation }}/{{ cookiecutter.project_slug }}">
    <img src="https://codecov.io/gh/{{ cookiecutter.github_organisation }}/{{ cookiecutter.project_slug }}/branch/develop/graph/badge.svg" alt="Code Coverage">
  </a>
{%- else -%}
{%- endif%}

  <a href="https://opensource.org/licenses/apache-2-0">
    <img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" alt="License: Apache 2.0">
  </a>

  <a href="https://github.com/{{ cookiecutter.github_organisation }}/{{ cookiecutter.project_slug }}/releases">
    <img src="https://img.shields.io/github/v/release/{{ cookiecutter.github_organisation }}/{{ cookiecutter.project_slug }}?color=blue&label=Release&style=flat-square" alt="Latest Release">
  </a>
  <a href="https://{{ cookiecutter.project_slug }}.readthedocs.io/en/latest/?badge=latest">
    <img src="https://readthedocs.org/projects/{{ cookiecutter.project_slug }}/badge/?version=latest" alt="Documentation Status">
  </a>
</p>

<p align="center">
  <a href="#quick-start">Quick Start</a> *
  <a href="#installation">Installation</a> *
  <a href="#contributors">Contributors</a> *
  <a href="https://{{ cookiecutter.project_slug }}.readthedocs.io/en/latest/">Documentation</a>
</p>

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
{% endif %}

## License

© {{ cookiecutter.copyright_year }} {{ cookiecutter.copyright_name }}. All rights reserved.