# Architectural Decision Record 008: Stack Dependencies - Dependencies from Source

## Status

<s>Proposed</s> | **Accepted** | <s>Deprecated</s> | <s>Superseded by [ADR-XXX]</s>

## Last Updated

2026-04-07

## Decision

ECMWF adopts the `stack-dependencies` repository as the standard mechanism for
provisioning approved third-party C++ dependencies across all build
environments (CI on VMs, CI on HPC, and HPC production).

Adoption is **transitionary**: dependencies move into `stack-dependencies`
gradually, dependency-by-dependency, as each is incorporated and validated.
Projects are not required to migrate overnight. During the transition,
environments may continue to use system-installed versions of dependencies that
have not yet been incorporated.

Each managed dependency is pinned as a git submodule at a specific version tag.
All builds — CI and production — use the from-source build rather than
system-installed packages for dependencies that `stack-dependencies` manages.

### Scope

This ADR covers **third-party libraries** only — libraries developed and
maintained outside ECMWF that our stack consumes (e.g. CLI11, libfmt, libaec,
pybind11, qhull).

**Out of scope — internal ECMWF libraries** (eckit, atlas, mir, fdb, etc.) are
not managed by `stack-dependencies`. They have their own release and integration
processes.

### Permanent Exemptions

The following system-level dependencies are **permanently exempt** from
`stack-dependencies`. They are provided by the operating system, HPC
environment, or site administrator and must not be built from source via this
mechanism:

- **Compilers**: GCC, Clang, Intel (oneAPI/icc), NVHPC, Cray compiler wrappers
- **MPI implementations**: OpenMPI, MPICH, Cray MPICH, Intel MPI
- **OpenMP**: part of the compiler runtime
- **Python interpreter**: CPython
- **OS-provided system libraries**: libc, libm, libpthread, etc.

These dependencies are tightly coupled to the host environment — the scheduler,
interconnect, filesystem, and hardware. Building them from source would
introduce more problems than it solves.

### Governance

#### Adding a New Dependency

1. **Approval via ADR**: the dependency must first be approved through its own
   ADR, following the precedent of [ADR-002](./ADR-002-Approved-Dependency-CLI11.md),
   [ADR-003](./ADR-003-PyBind11-For-CPP-Bindings.md), and
   [ADR-007](./ADR-007-Approved-Dependency-libfmt.md). The individual ADR
   evaluates *what* library to adopt; this ADR governs *how* it is provisioned.

2. **Integration**: once approved, a build script is added to `build-scripts/`
   and the library is added as a git submodule pinned to the approved version.
   A corresponding `STACK_DEP_<NAME>` toggle is added.

3. **Validation**: the new dependency must build successfully across all CI
   environments (VM and HPC) before being merged.

#### Version Updates

- **Patch/minor updates**: submodule pointer changes go through standard PR
  review.
- **Major version upgrades**: must be discussed with the team before merging, as
  they may introduce breaking API changes affecting downstream projects.

#### Retirement

If a dependency is deprecated (via its ADR being superseded), it is removed from
`stack-dependencies` after all downstream projects have migrated off.

## Context

ECMWF's software stack is deployed across a wide range of environments:

1. **CI on virtual machines** — GitHub Actions runners, internal VMs (typically
   Ubuntu or Rocky Linux).
2. **CI on HPC** — build and test against the production toolchain.
3. **HPC production** — operational workloads on ECMWF's HPC systems.
4. **Non-HPC production** — containers, VMs, and bare-metal machines that are
   not HPC nodes.
5. **Distribution artefacts** — RPM/DEB packages and tarballs with binaries
   (e.g. installed to `/opt`).

Third-party C++ dependencies are currently installed as system packages in each
environment — via `apt` or `dnf` on VMs, via administrator-managed module
installations on HPC, and via whatever mechanism is available in the target
packaging or container image. This creates several problems:

- **Version drift**: a CI VM running Ubuntu 24.04 may ship a different version
  of a library than the HPC module system provides. Code that compiles and
  passes tests in CI can fail or behave differently in production.
- **Release lag**: when the team approves a new dependency version (e.g. via
  an ADR), the delay until that version appears in distribution repositories
  varies from weeks to months. On HPC systems with long module refresh cycles,
  it can take even longer. This blocks adoption.
- **ABI mismatches**: when an ECMWF library is compiled against dependency
  version X in CI but linked against version Y in production, the result ranges
  from link errors to silent ABI incompatibilities.
- **Blocked testing**: evaluating a dependency upgrade currently requires
  coordinating with system administrators in each environment to install the
  new version, or using ad-hoc workarounds.

## Options Considered

### Option A: Status Quo — System-Installed Packages

Continue relying on OS package managers on VMs and administrator-managed module
installations on HPC.

**Advantages:**
- Familiar to all developers and system administrators.

**Disadvantages:**
- All problems described in Context persist.
- High cost to introduce or upgrade a dependency

### Option B: From-Source Builds via `stack-dependencies`

A single git repository containing approved third-party libraries as git
submodules, each pinned to a specific tag. A `build.sh` script orchestrates
per-dependency build scripts. A `CMakeLists.txt` supports three integration
modes: standalone build, ecbuild bundle inclusion, and plain
`add_subdirectory`. Dependencies install to a prefix with headers, libraries,
and CMake/pkg-config metadata.

**Advantages:**
- Version-pinned: every environment builds the same dependency versions from the
  same source with the same flags.
- Reproducible: same source + same compiler + same flags = same binaries.
- Self-contained: no reliance on external package managers or administrator
  intervention.
- ecbuild-native: produces `find_package()`-compatible install trees and
  integrates directly as an ecbuild bundle component.
- Selective: environments can skip a dependency via `STACK_DEP_<NAME>=OFF`.
- Auditable: submodule pins and build scripts are version-controlled, reviewable
  in PRs, and traceable in `git log`.
- Environment-agnostic: works on HPC, VMs, containers, and bare-metal. Equally
  suited for producing RPM/DEB packages or tarballs installed to `/opt`.
- Uses only tools already present everywhere: git, CMake, and a C/C++ compiler.

**Disadvantages:**
- Build time: from-source compilation adds minutes to CI pipelines. Mitigated by
  CI caching and a sentinel file mechanism that skips redundant rebuilds.
- Maintenance burden: each dependency needs a build script (~10–20 lines of
  CMake invocation). Upstream CMake quirks must be handled.
- Git submodule friction: developers must remember `--recurse-submodules` when
  cloning. CI scripts must be configured accordingly.
- Compiler matrix: must be tested across all target compilers, though this also
  surfaces toolchain-specific issues early.

### Option C: Spack / Conan / vcpkg / lmod

Use a dedicated package manager — Spack for HPC, Conan or vcpkg for non-HPC —
or lmod modules to provide dependencies.

Spack is the most relevant candidate: it is purpose-built for HPC, supports
building from source with configurable compilers and variants, and handles
complex dependency graphs. Conan and vcpkg are widely adopted in the broader
C++ ecosystem but have limited HPC presence.

However, all of these tools solve a **different problem** than
`stack-dependencies`. Package managers manage installed software across an
environment — resolving versions, handling transitive dependencies, and
providing environment modules or activation scripts. By contrast,
`stack-dependencies` produces a **self-contained, version-pinned source bundle**
that builds alongside the ECMWF stack using only git, CMake, and a compiler.
It is orthogonal to package managers: the output of a `stack-dependencies` build
could itself be packaged as a Spack spec, a Conan recipe, or an lmod module.

**Advantages:**
- Designed for dependency management.
- Supports multiple concurrent installations with different configurations.
- Spack specifically handles HPC toolchains and module generation.

**Disadvantages:**
- Requires different tooling for HPC (Spack/lmod) and non-HPC (Conan/vcpkg)
  environments — no single solution spans all targets.
- Introduces a tool dependency (Spack, Conan, or vcpkg) that is not universally
  available or configured across all ECMWF environments today.
- Still requires administrator intervention on HPC to install and maintain the
  package manager itself and its configuration.
- Need to maintain separate build recipes or package definitions per tool, in
  addition to the upstream CMake build.
- Does not directly integrate with ecbuild bundles or produce
  `find_package()`-compatible install trees without additional wrapper work.

### Option D: Docker / Container-Based Isolation

Build and ship a Docker image containing all required dependencies.

**Advantages:**
- Complete environment reproducibility.
- Already used for python wheel builds.

**Disadvantages:**
- **Singularity** available but no operational experience on HPC, not trusted yet.
- Forces developers to work inside containers for local development, or maintain
  a separate native build path.
- Suitable as a complementary strategy (for VM CI and wheel builds) but not as
  the primary strategy.

### Option E: Git Submodules Directly in Each Project

Each ECMWF project adds needed dependencies as git submodules and builds them
via `add_subdirectory()`.

**Advantages:**
- Simple, self-contained per project.
- No shared infrastructure.

**Disadvantages:**
- Non-trivial CMake integration due to multiple ECMWF libraries requiring the same dependency
- Possibly multiple submodules of the same dependency

## Analysis

### Key Observations

1. Options C and D introduce tool dependencies not universally available
   across all target environments. Option C (Spack/Conan/vcpkg) solves a
   different problem — environment-level package management — whereas
   `stack-dependencies` produces self-contained source bundles that are
   orthogonal to and composable with any package manager. The HPC production
   constraint eliminates containers (D) as a primary strategy.

2. Option B uses only tools already present everywhere: git, CMake, and a C/C++
   compiler. It adds no new tool dependency.

3. Option B's main weakness — build time — is addressable through CI caching.
   The sentinel file mechanism already exists for this purpose.

4. Option B and D are complementary, as the stack-dependencies build can be used
   to pre-populate a Docker image.

5. Option E would lead to multiple copies of the same dependency across projects,
   with no centralised version control or build scripts. This would increase
   maintenance burden and risk of version drift between projects.
   In particular, the caching of build artifacts would have to be replicated everywhere
   potentially deteriorating the build time issue.

6. The python_wheels documentation already identifies this approach as the
   intended path forward for compiled dependencies in wheel builds, indicating
   organisational alignment.

7. If the dependency count grows significantly (beyond ~30 libraries), adopting
   a full package manager such as Spack may warrant re-evaluation. This should
   be treated as a reassessment trigger, not a near-term concern.

8. Fortran is currently out of scope for `stack-dependencies` as typical
   Fortran libraries, such as BLAS and LAPACK, are tightly coupled to the
   compiler and HPC environment. However, if a need arises to manage Fortran
   dependencies in the future, the repository's build scripts and CMake
   integration could be extended to support Fortran libraries as well.

9. The libraries and versions provided by `stack-dependencies` are not to be
   considered the only versions of those libraries compatible with the ECMWF
   stack, but rather a curated set of commonly used libraries that are
   guaranteed to be available across all environments.

### Trade-Off Summary

The core trade-off is between a small, bounded maintenance burden (build scripts
for each dependency) and the larger, unpredictable burden of diagnosing
environment-specific build failures. The former is version-controlled and
reviewable; the latter is opaque and unbounded.

## Related Decisions

- [ADR-002 Approved Dependency CLI11](./ADR-002-Approved-Dependency-CLI11.md) —
  CLI11 is managed by `stack-dependencies`. ADR-002 approves the dependency;
  this ADR addresses how it is provisioned.
- [ADR-003 PyBind11 for C++ Bindings](./ADR-003-PyBind11-For-CPP-Bindings.md) —
  pybind11 is managed by `stack-dependencies`.
- [ADR-007 Approved Dependency libfmt](./ADR-007-Approved-Dependency-libfmt.md) —
  libfmt is managed by `stack-dependencies`. ADR-007 notes that libfmt is
  "trivially built from source with CMake" — `stack-dependencies` provides the
  `find_package(fmt)`-compatible install tree.
- The python_wheels infrastructure (`Languages/python_wheels.md`) references
  this repository as the intended mechanism for external compiled dependencies
  in wheel builds.

This ADR does not modify or supersede any existing ADR. It fills an orthogonal
gap: existing ADRs approve *what* dependencies to use; this ADR decides *how* to
provision them.

## Consequences

### Positive

- **Reproducibility**: every environment builds the same dependency versions
  from the same source with the same flags.
- **CI/production parity**: integration issues surface in CI rather than
  production.
- **Version control**: dependency version changes are explicit git commits
  (submodule pin updates), reviewable in PRs and attributable in `git log`.
- **Unblocked adoption**: new dependency versions approved by ADR can be adopted
  immediately, without waiting for distribution packaging or HPC module updates.
- **ecbuild native**: three integration modes (shell, CMake, ecbuild bundle)
  cover all existing build workflows.
- **Auditability**: the exact source of every dependency is available in the
  repository, satisfying compliance and licence audit requirements.
- **Python wheel alignment**: unifies the dependency provisioning strategy
  between the C++ build pipeline and the python_wheels pipeline.

### Negative

- **Build time increase**: from-source compilation adds time to CI pipelines.
  Mitigated by CI caching, the sentinel file mechanism, and selective dependency
  building.
- **Maintenance burden**: each dependency requires a build script. When upstream
  changes their CMake configuration, the script may need updating. Build scripts
  are typically 10–20 lines, so per-dependency cost is low.
- **Git submodule friction**: developers must remember `--recurse-submodules`.
  CI templates should enforce this.
- **Compiler matrix testing**: from-source builds must be validated across all
  target compilers. This also catches issues that system packages would hide.

## References

- `stack-dependencies` repository: https://github.com/ecmwf/stack-dependencies
- Python wheels documentation: `Languages/python_wheels.md`
- ecbuild: https://github.com/ecmwf/ecbuild
- Spack: https://spack.io/
- Conan: https://conan.io/
- vcpkg: https://vcpkg.io/

## Authors

- Kai Kratz
- Oskar Weser
