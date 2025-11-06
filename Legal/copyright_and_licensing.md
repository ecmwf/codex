# Copyright and Licensing

This document describes ECMWF's approach to copyright and licensing of software packages.

## Applying the Apache License

## Context

In December 2011, it was decided that ECMWF software packages, when open sourced, will be in future released under the Apache License to legally clarify and simplify the distribution of our software to external users.

## Steps to apply the Apache License

1. If you not familiar with the Apache license, for background information please read [Applying the Apache License](http://www.apache.org/dev/apply-license.html)

2. Each maintainer of a package must include once copy of the full license text by adding the `LICENSE` (note US spelling) file to the root of your repository. You can find the text of the Apache License [here](https://www.apache.org/licenses/LICENSE-2.0.txt). However, you need to make one change to the file (line 178) by adding the Centre and the year for the copyright statement. 
```
        Copyright 1996- European Centre for Medium-Range Weather Forecasts (ECMWF)
```

Alternatively, you can use the [apache-licence](Legal/apache-licence) file provided in this repository as a template.

3. A correct `NOTICE` file **must** be included in the same directory as the `LICENSE` file and list ALL external code contributions (if any). Please follow the instructions the [Apache guidelines](http://www.apache.org/legal/src-headers.html#notice). Typically, the `NOTICE` file will be empty for ECMWF packages unless you have included third-party code.

4. Each original source document (code and documentation, but excluding generated files) **must** include a short license header at the top. To facilitate this, please you may use the script provided in the [Available Tooling](#available-tooling) section below.

Each source file shall begin with the following license and liability discalimer:

```
(C) Copyright <FILE-CREATED-YEAR>- ECMWF and individual contributors.

This software is licensed under the terms of the Apache Licence Version 2.0
which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
In applying this licence, ECMWF does not waive the privileges and immunities
granted to it by virtue of its status as an intergovernmental organisation nor
does it submit to any jurisdiction.
```

5. Please make sure that ALL references to any past ECMWF licenses ("ECMWF licence", GPL or LGPL) are removed.

## Contributors

Each repository shall maintain a `CONTRIBUTORS` file in the root of the repository
which lists all contributors.

Currently we do not have tooling available to generate the contributors list, but this can
be created with a bit of manual intervention with git.

The following example lists number of commits, author and email address:

```
git shortlog -s -e --no-merges
```

## Available Tooling

### License Header

In case you already have source files that are missing above text
[ECBuild](https://github.com/ecmwf/ecbuild/) provides the
[apply\_license.sh](https://github.com/ecmwf/ecbuild/blob/develop/tools/apply_license.sh)
tool to add the above disclaimer to your source files automatically. 
