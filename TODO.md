# Codex — Gaps & Issues Tracker

This document captures known gaps, incomplete sections, and issues identified across the Codex repository.
Contributions addressing any of these items are welcome via pull request.

---

## High Priority

- [ ] **Guidelines/Testing.md** — File opens with an explicit `TODO`. No actual testing guidelines exist beyond test data hosting via `sites.ecmwf.int`. Needs unit, integration, and regression testing standards.
- [ ] **Languages/versioning.md** — Entire file is a single-line placeholder: *"How do we manage multi-language repositories with a single version number?"*. Needs a versioning policy.
- [ ] **LICENSE** (root) — File is empty. The licence text exists in `Legal/apache-licence` but the root `LICENSE` file that GitHub uses for badge detection and display contains no content.

## Medium Priority

- [ ] **Languages/C++/** — Only covers `.git-blame-ignore-revs` configuration. The Languages README promises coding standards, clang-format, and clang-tidy configuration, but none of these are present.
- [ ] **Documentation and Training/README.md** — Skeletal (16 lines). No documentation standards, templates, API documentation requirements, or style guides. The Software Management Plan section contains more documentation guidance than this dedicated section.
- [ ] **ESEE/README.md** — Conceptual category descriptions only. Missing component listings, architecture details, and diagrams showing which software packages belong to which ESEE category.
- [ ] **Guidelines/Observability.md** — Explicitly defers several areas to future revisions: full tracing specification, environment-specific collection pipelines, and an alerting section (referenced but not included).

## Low Priority

- [ ] **ADR/ADR-005-Storing-Of-ICON-Grid-Files.md** — Title inside the document reads "ADR 004" but the filename is `ADR-005`. Numbering mismatch needs correcting.
- [ ] **MARS language/MARS-Template.md** — Typo in title: "Languge" should be "Language".
- [ ] **MARS language/MARS-007-Timespan-Absence.md** — Same "Languge" typo in title. Also contains an empty bullet point (`* `) around line 200.
- [ ] **Contributing Upstream/README.md** — Single-line index file. Could benefit from a brief introductory paragraph explaining the purpose of the section.
- [ ] **Repository Structure/example.md** — Only provides a Python project README template. No equivalent example for a C++ project.
- [ ] **Languages/python_wheels.md** — Notes that automated release triggering is pending and pin derivation for Python interface wheels has a known deficiency.
