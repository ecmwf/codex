{% if cookiecutter.logo_path != 'n' -%}
<h3 align="center">
<img src="{{ cookiecutter.logo_path }}" width=100px>
</br>
</h3>
{%- else -%}
# Do not add logo.
{%- endif%}


<p align="center">
  <img src="https://img.shields.io/badge/{{ cookiecutter.esee_badge }}" alt="ESEE Foundation">
  <img src="https://img.shields.io/badge/Maturity-{{ cookiecutter.maturity_badge }}-{{ {'Sandbox': 'yellow', 'Incubating': 'violet', 'Graduated': 'green', 'Archived': 'orange'}[cookiecutter.maturity_badge] }}?link=.%2Fproject-maturity.md" alt="Maturity {{ cookiecutter.maturity_badge }}">

{% if cookiecutter.ci_actions == 'y' -%}
# Add CI badge
  <a href="https://github.com/{{ cookiecutter.github_organisation }}/{{ cookiecutter.project_slug }}/actions/workflows/ci.yaml">
    <img src="https://github.com/{{ cookiecutter.github_organisation }}/{{ cookiecutter.project_slug }}/actions/workflows/ci.yaml/badge.svg" alt="CI Status">
  </a>
{%- else -%}
# Do not add ci.
{%- endif%}

{% if cookiecutter.code_coverage == 'y' -%}
# Add code coverage badge
  <a href="https://codecov.io/gh/{{ cookiecutter.github_organisation }}/{{ cookiecutter.project_slug }}">
    <img src="https://codecov.io/gh/{{ cookiecutter.github_organisation }}/{{ cookiecutter.project_slug }}/branch/develop/graph/badge.svg" alt="Code Coverage">
  </a>
{%- else -%}
# Do not add code coverage.
{%- endif%}

{% if cookiecutter.open_source_license == 'Not open source' -%}
  <a href="https://opensource.org/licenses/{{ cookiecutter.open_source_license }}-{{ {'Apache Software License 2.0': 'apache-2-0', 'BSD license': 'bsd-3-clause', 'GNU General Public License v3': 'gpl-3-0', 'ISC license': 'isc-license-txt', 'MIT license': 'mit'} }}">
    <img src="https://img.shields.io/badge/License-{{ cookiecutter.open_source_license }}-{{ {'Apache Software License 2.0': 'Apache%202.0', 'BSD license': 'BSD%203', 'GNU General Public License v3': 'GPL%20v3.0', 'ISC license': 'ISC', 'MIT license': 'MIT'} }}-blue.svg" alt="License: {{ cookiecutter.open_source_license }}">
  </a>
{%- else -%}
# Not open source
{%- endif%}
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

{{ cookiecutter.project_description }}

# Quick Start

## Requirements

## Installation

## First Example

# Features

## Author

{{ cookiecutter.author_name }}

## Contributors



## License

© {{ cookiecutter.year }} {{ cookiecutter.copyright_name }}. All rights reserved.