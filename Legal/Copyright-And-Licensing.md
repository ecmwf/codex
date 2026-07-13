# Copyright and Licensing

This document describes ECMWF's approach to copyright and licensing of software packages.

## Context

In December 2011, it was decided that ECMWF software packages, when open sourced, will be in future released under the Apache License to legally clarify and simplify the distribution of our software to external users.

## Steps to apply the Apache License

1. If you are not familiar with the Apache License, for background information please read [Applying the Apache License](http://www.apache.org/dev/apply-license.html)

2. Each maintainer of a package must include one copy of the full licence text by adding a `LICENSE` (note US spelling) file to the root of the repository. The ECMWF `LICENSE` is the **unmodified Apache License 2.0 text followed, at its tail, by ECMWF's intergovernmental notice**. Use the ready-made [Apache-Licence](./Apache-Licence) template in this repository (identical to this repository's own root `LICENSE`); do not hand-edit the Apache text itself. The copyright statement is asserted in the `NOTICE` file and in per-file headers (see below), not by editing the Apache text.

3. A `NOTICE` file **must** be included in the same directory as the `LICENSE`. It is **never empty for ECMWF packages**: it carries ECMWF's copyright and the intergovernmental notice, plus any third-party attributions. Use the [`NOTICE` template](./SPDX-REUSE-templates/NOTICE); follow the [Apache guidelines](http://www.apache.org/legal/src-headers.html#notice) for third-party entries.

   The copyright **holder** is normally `European Centre for Medium-Range Weather Forecasts (ECMWF)`. For work funded under an EU programme the holder is the **European Union** (the correct term — not "European Commission"). Where code is co-developed with a partner, assert each holder (e.g. add a `Crown Copyright, Met Office` line for Met Office co-development); see [SPDX and REUSE](./SPDX-and-REUSE.md) for the per-file form.

4. Each original source document (code and documentation, but excluding generated files) **must** include a short licence header at the top. To facilitate this, you may use the script provided in the [Available Tooling](#available-tooling) section below.

Each source file shall begin with the following licence and liability disclaimer:

```
(C) Copyright <FILE-CREATED-YEAR>- ECMWF and individual contributors.

This software is licensed under the terms of the Apache Licence Version 2.0
which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
In applying this licence, ECMWF does not waive the privileges and immunities
granted to it by virtue of its status as an intergovernmental organisation nor
does it submit to any jurisdiction.
```

> **Standard going forward:** new files and repositories must instead use the
> machine-readable **SPDX + REUSE** header — two tags
> (`SPDX-FileCopyrightText` and `SPDX-License-Identifier: Apache-2.0`) — per
> [ADR-010](../ADR/ADR-010-SPDX-License-Identifiers-and-REUSE-Headers.md)
> (Accepted) and the [SPDX and REUSE standard](./SPDX-and-REUSE.md). The prose
> header above remains valid for not-yet-migrated files, which are migrated per
> repository over time.

5. Please make sure that ALL references to any past ECMWF licenses ("ECMWF licence", GPL or LGPL) are removed.

## Contributors

Each repository shall maintain a `CONTRIBUTORS` file in the root of the repository
which lists all contributors. (This is distinct from a `CONTRIBUTING.md`, which is
the optional *contribution guide*; the audit skills treat a missing
`CONTRIBUTING.md` as advisory, but the `CONTRIBUTORS` list is expected here.)

Currently we do not have tooling available to generate the contributors list, but this can
be created with a bit of manual intervention with git.

The following example lists number of commits, author and email address:

```
git shortlog -s -e --no-merges
```

## Available Tooling

### License Header

For the **SPDX + REUSE** header (the standard for new files), apply and verify
headers in bulk with the `reuse` tool — `reuse annotate --copyright "European
Centre for Medium-Range Weather Forecasts (ECMWF)" --license Apache-2.0
--merge-copyrights --recursive .` then `reuse lint` (see
[SPDX and REUSE](./SPDX-and-REUSE.md)).

For the legacy prose header, [ECBuild](https://github.com/ecmwf/ecbuild/)
provides the
[apply\_license.sh](https://github.com/ecmwf/ecbuild/blob/develop/tools/apply_license.sh)
tool to add the disclaimer to source files that are missing it.
