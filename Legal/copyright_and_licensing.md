# Copyright and Licensing Considerations

Each source file shall begin with the following license and liability discalimer:

```
(C) Copyright <FILE-CREATED-YEAR>- ECMWF and individual contributors.

This software is licensed under the terms of the Apache Licence Version 2.0
which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
In applying this licence, ECMWF does not waive the privileges and immunities
granted to it by virtue of its status as an intergovernmental organisation nor
does it submit to any jurisdiction.
```

## Contributors

Each repository shall maintain a `CONTRIBUTORS` file in the root of the repository
which lists all contributors.

## Available Tooling

### License Header

In case you already have source files that are missing above text
[ECBuild](https://github.com/ecmwf/ecbuild/) provides the
[apply\_license.sh](https://github.com/ecmwf/ecbuild/blob/develop/tools/apply_license.sh)
tool to add the above disclaimer to your source files automatically. 

### Contributors

Currently we do not have tooling available to generate the contributors list, but this can
be created with a bit of manual intervention with git.

The following example lists number of commits, author and email address:

```
git shortlog -s -e --no-merges
```
