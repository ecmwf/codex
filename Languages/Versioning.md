# Versioning

ECMWF software is versioned with **Semantic Versioning (SemVer)**. This document
is the authoritative policy for how to version an ECMWF repository — the tag
format, when to bump each component, prerelease and production tags, and how to
version a repository that contains multiple languages or packages with a single
version number.

It consolidates the version-tag rules used in
[Branching](../Guidelines/Branching.md) and
[External Contributions](../Guidelines/External-Contributions.md); those
documents govern *how* releases are branched and delivered, while this document
defines *how the version number itself is chosen and applied*.

## Semantic Versioning

Versions have the form:

```
MAJOR.MINOR.PATCH        e.g. 2.4.1
```

Given a public interface (a library API, a CLI, a data/format contract, a wire
protocol), increment the:

- **MAJOR** version for **incompatible / breaking changes** — anything that
  requires downstream users to change their code, commands, configuration, or
  data handling.
- **MINOR** version for **backwards-compatible new functionality** (and for
  marking features as deprecated).
- **PATCH** version for **backwards-compatible bug fixes** only.

See [semver.org](https://semver.org) for the full specification.

### No `v` prefix

ECMWF version tags use the **clean `x.y.z` form with no `v` prefix** (`2.4.1`,
not `v2.4.1`). This is checked by the `open-source-audit` skill. Note that this
applies to *ECMWF release tags*; third-party GitHub Actions and other external
artefacts keep their own tag conventions (e.g. `actions/checkout@v4`).

### Initial development (`0.y.z`)

A project below `1.0.0` is in initial development: **anything may change at any
time** and the public interface is not considered stable. Reach `1.0.0` when the
interface is stable and the software is used in production. New public repositories
usually start at a low [Project Maturity](../Project%20Maturity/README.md) level,
which is a better signal of stability for users than the version number alone.

### Deprecation and compatibility

- Prefer to **deprecate before removing**: introduce the replacement, mark the
  old interface deprecated (a MINOR release), keep it working for at least one
  MINOR cycle, then remove it in a MAJOR release.
- Document breaking changes prominently (release notes / `CHANGELOG`), and a
  `CHANGELOG` is recommended so users can see what changed between versions.

## Production and prerelease tags

- **Production tags** are clean `x.y.z` tags on `main`/`master`. Only such tags
  represent production-ready software.
- **Prerelease tags** use the form `x.y.z-upstream.N` (`N` = a sequential
  prerelease number), for contractor-side testing, staging, and CI. They are
  **non-production**, must not appear on `main`/`master`, and must never be
  deployed beyond development or test environments.

The full rules, and the delivery/acceptance workflow they belong to, are in
[External Contributions → Tagging Rules](../Guidelines/External-Contributions.md).
The mechanics of creating and pushing release tags are in
[Branching](../Guidelines/Branching.md).

## Single source of truth

A repository has **one** version number. Do not maintain the version in several
places that can drift. The **git tag is authoritative**; build tooling should
derive the package/library version from it rather than hard-coding it — for
example `setuptools_scm` for Python, or a single top-level `VERSION` file (or the
`project.version` in `pyproject.toml` / the CMake `project(... VERSION ...)`)
that the build reads. A generated version file (e.g. `_version.py`) is a build
artefact and must not be committed (see [Repository Structure](../Repository%20Structure/README.md)).

## Multi-language and multi-package repositories

A repository that contains more than one language or produces more than one
artefact (for example a C/C++ library with Python bindings, or a package plus
its CLI) is versioned as **a single unit under one version number**:

- **One version for the whole repository.** All components and artefacts built
  from a commit share the same `x.y.z`, are tagged once, and are released
  together. Do not version the Python bindings independently of the C++ library
  they wrap within the same repository.
- **Bump for the repository as a whole.** A breaking change in *any* public
  component is a MAJOR bump for the repository; new backwards-compatible
  functionality in any component is a MINOR bump; and so on. This keeps a single,
  unambiguous compatibility signal for downstream users.
- **If components genuinely need to evolve on independent version lines**, that
  is a signal they should live in **separate repositories**, each with its own
  single version, rather than being force-fitted into one.

### Compiled Python wheels

Where a repository publishes compiled Python wheels split across interdependent
packages (e.g. a library wheel and its Python interface wheel), a
**four-component build identifier `x.y.z.N`** is used for the *wheels*, where `N`
is a monotonic counter shared across the packages so that ABI-compatible builds
can be pinned together. This is a **packaging/build identifier, not a SemVer
version**: the software's release version — and the authoritative git tag —
remains `x.y.z`. The mechanism, and its current limitations, are described in
[Python Wheels](./Python-Wheels.md).

## Summary

- Use SemVer `MAJOR.MINOR.PATCH` (`x.y.z`), **no `v` prefix**.
- MAJOR = breaking, MINOR = backwards-compatible feature, PATCH = backwards-compatible fix; `0.y.z` = unstable.
- Production tags are clean `x.y.z` on `main`/`master`; prereleases are `x.y.z-upstream.N` (non-production).
- One version per repository; the git tag is the single source of truth; all languages/artefacts release together.
- Compiled Python wheels may use a `x.y.z.N` build identifier for pinning (see [Python Wheels](./Python-Wheels.md)).
