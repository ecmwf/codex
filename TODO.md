# Codex — Gaps & Issues Tracker

This document captures known gaps, incomplete sections, and issues identified across the Codex repository.
Contributions addressing any of these items are welcome via pull request.

A consistency pass (see the `docs/consistency-pass` work) fixed the cross-document
inconsistencies, broken links, licensing contradictions, ADR status/formatting
drift, and spelling/house-style issues. The items below are the remaining
**content gaps** — sections that are advertised but not yet written. Their index
entries now flag them as work-in-progress.

---

## High Priority

- [ ] **Guidelines/Testing.md** — Still only covers test-data hosting. Needs unit, integration, and regression testing standards (the README now marks it as draft; other docs' "tests are mandatory" wording depends on this being written).
- [ ] **Languages/Versioning.md** — Still a single-line placeholder. Needs a versioning policy for multi-language repositories.

## Medium Priority

- [ ] **Languages/C++/** — Only the `.git-blame-ignore-revs` convention exists. Needs the promised C++ coding standards and clang-format / clang-tidy configuration.
- [ ] **Documentation and Training/README.md** — Skeletal. Needs documentation standards, templates, API-documentation requirements, and style guides (the SMP §7 documentation guidance should eventually be consolidated here).
- [ ] **ESEE/README.md** — Conceptual category descriptions only. Missing component listings, architecture details, and diagrams showing which packages belong to which ESEE category.
- [ ] **Guidelines/Observability.md** — Defers the full tracing specification, environment-specific collection pipelines, and a dedicated alerting specification to future revisions.

## Low Priority

- [ ] **Repository Structure/Example.md** — Provides a Python project README template only. No equivalent example for a C++ project.
- [ ] **Languages/Python-Wheels.md** — Automated release triggering is pending, and pin derivation for Python interface wheels has a known deficiency.

## Resolved by the consistency pass

- Root `LICENSE` populated (Apache 2.0 + ECMWF intergovernmental notice).
- Broken links fixed (Principles → External Contributions; ADR-Guidelines → ADR index; Example.md maturity badge).
- Licensing contradictions reconciled (NOTICE "never empty", canonical LICENSE composition, EU/partner copyright holder, "line 178" removed, `Example.md` "All rights reserved" replaced).
- ADR statuses/formatting normalised (ADR-005 title number, ADR-007 status, ADR-002/006 headings, template brackets); ADR-006 reduced to a stub linking MARS-001.
- MARS typos ("Languge"), empty bullet, strikethrough/date-format drift fixed.
- British house style applied (Containerisation, Observability, SMP, ADR-004, ESEE); "Co-operating States" standardised.
