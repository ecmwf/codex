# ECMWF Source Licensing Standard (SPDX + REUSE)

Status: recommended going forward per [ADR-010](../ADR/ADR-010-SPDX-License-Identifiers-and-REUSE-Headers.md) (Proposed; becomes the organisation-wide standard on acceptance). Applies to all ECMWF-authored source.

This standard is the recommended, machine-readable form of the licensing
convention in [`Copyright-And-Licensing.md`](./Copyright-And-Licensing.md). The
prose Apache header documented there remains valid for not-yet-migrated files;
new files and repositories SHOULD use the SPDX/REUSE headers below.

## File header (every commentable, ECMWF-authored file)

Two tags near the top of the file, in the correct comment syntax:

    SPDX-FileCopyrightText: <YEAR> European Centre for Medium-Range Weather Forecasts (ECMWF)
    SPDX-License-Identifier: Apache-2.0

- `<YEAR>` is the year of first publication of the file. Keep existing years when migrating; a range (e.g. 2019-2026) is acceptable. A contact e-mail or URL MAY be appended to the copyright holder.
- Do not add the full Apache boilerplate to files.
- Third-party files keep their own headers and are never re-stamped.

### Multiple copyright holders

Where a file has more than one copyright holder — for example code
co-developed with a partner such as the Met Office (Crown Copyright) — add one
`SPDX-FileCopyrightText:` line per holder, above the single licence identifier:

    SPDX-FileCopyrightText: <YEAR> European Centre for Medium-Range Weather Forecasts (ECMWF)
    SPDX-FileCopyrightText: <YEAR> Crown Copyright, Met Office
    SPDX-License-Identifier: Apache-2.0

The `SPDX-License-Identifier` stays `Apache-2.0`; a co-developed file must be
released under an Apache-2.0-compatible licence.

### Comment syntax by language

- `#`  — Python, shell, YAML, TOML, CMake, Dockerfile, Makefile
- `!`  — Fortran
- `//` — C, C++, CUDA, Rust, Java, JavaScript/TypeScript, Go (source files)
- `/* ... */` — C/C++ **header** files (avoids tooling that mishandles `//` in generated linker scripts)
- `..` — reStructuredText
- `<!-- ... -->` — Markdown, HTML, XML
- `%`  — LaTeX

Example (Python):

    # SPDX-FileCopyrightText: 2026 European Centre for Medium-Range Weather Forecasts (ECMWF)
    # SPDX-License-Identifier: Apache-2.0

Example (C header):

    /*
     * SPDX-FileCopyrightText: 2026 European Centre for Medium-Range Weather Forecasts (ECMWF)
     * SPDX-License-Identifier: Apache-2.0
     */

## Repository files

- `LICENSES/Apache-2.0.txt` — the **unmodified** Apache 2.0 text. Obtain with `reuse download Apache-2.0`. Never edit or append to this file; REUSE matches it against the canonical text.
- `LICENSE` (top-level) — the Apache 2.0 text followed, at its tail, by ECMWF's intergovernmental notice (below). This is ECMWF's canonical, human- and GitHub-facing licence file.
- `NOTICE` — ECMWF copyright and the intergovernmental notice, plus any third-party attributions.
- `REUSE.toml` — covers files that cannot carry a comment (data, generated artefacts) and the top-level `LICENSE`/`NOTICE` files.

Copy-ready versions of `NOTICE`, the `LICENSE` tail, `REUSE.toml`, and the
advised pre-commit/CI configuration are in
[`SPDX-REUSE-templates/`](./SPDX-REUSE-templates/).

### ECMWF intergovernmental notice (verbatim)

    In applying this licence, ECMWF does not waive the privileges and immunities
    granted to it by virtue of its status as an intergovernmental organisation
    nor does it submit to any jurisdiction.

## Verifying and applying

- Apply headers in bulk: `reuse annotate --copyright "European Centre for Medium-Range Weather Forecasts (ECMWF)" --license Apache-2.0 --merge-copyrights --recursive .`
- Verify: `reuse lint`
- Generate an SBOM: `reuse spdx -o <name>.spdx`

## Enforcement (recommended, not required)

Repositories SHOULD enable a `reuse` pre-commit hook and SHOULD run `reuse lint` in CI. See [`SPDX-REUSE-templates/`](./SPDX-REUSE-templates/).

## Note on the top-level LICENSE

REUSE treats `LICENSES/` as the source of truth for licence texts, so it also expects the top-level `LICENSE` and `NOTICE` files to carry licensing metadata; these are annotated in `REUSE.toml`. ECMWF deliberately keeps a top-level `LICENSE` (Apache 2.0 + intergovernmental notice) for discoverability and GitHub detection. The intergovernmental notice at the tail of `LICENSE` must not be removed to satisfy tooling.
