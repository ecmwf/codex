# Architectural Decision Record 010: Adopt SPDX Licence Identifiers and REUSE-Compliant File Headers

## Status

<s>Proposed</s> | **Accepted** | <s>Deprecated</s> | <s>Superseded by [ADR-XXX]</s>

## Last Updated

2026-07-08

## Context

All ECMWF-authored source code is released under the Apache Licence, Version 2.0. The prevailing convention across ECMWF repositories — recorded in [`Legal/Copyright-And-Licensing.md`](../Legal/Copyright-And-Licensing.md) — is to embed, at the top of every source file, the full Apache 2.0 boilerplate notice (approximately eleven lines), preceded by a copyright line and followed by ECMWF's standing intergovernmental notice:

> In applying this licence, ECMWF does not waive the privileges and immunities granted to it by virtue of its status as an intergovernmental organisation nor does it submit to any jurisdiction.

This convention has three practical shortcomings. First, hand-maintained boilerplate is inconsistent and error-prone across a large estate (roughly 160 public repositories) and is difficult for tooling to validate reliably. Second, when a single file is copied, vendored, or forked into a downstream project — a common occurrence for ECMWF libraries such as eccodes and earthkit — the licence text is often the only licensing signal that travels with it, yet free-text boilerplate is not machine-identifiable. Third, ECMWF has no organisation-wide, machine-readable licensing metadata from which a Software Bill of Materials (SBOM) can be generated automatically.

The wider context reinforces the need. SPDX licence identifiers are curated by the Linux Foundation, and the SPDX specification is standardised as ISO/IEC 5962:2021. SPDX and CycloneDX are the de-facto machine-readable SBOM formats named in EU Cyber Resilience Act (CRA) guidance; of these, SPDX carries the richest licence and copyright metadata. Establishing file-level SPDX metadata now positions ECMWF and its downstream consumers (Member States and commercial users) to produce SBOMs cheaply as demand for them grows.

This decision establishes a single, machine-readable licensing convention for all ECMWF-authored source, aligned with the REUSE Specification maintained by the Free Software Foundation Europe.

### Options Considered

**Option 0 — Do nothing (retain full boilerplate per file).** Keep the current full Apache 2.0 header, copyright line, and intergovernmental notice in every file.
- Pros: no migration effort; unchanged and familiar.
- Cons: perpetuates inconsistency and validation difficulty; no machine-readable licensing metadata; no clean path to automated SBOM generation; heavier files.

**Option 1 — SPDX identifier with the intergovernmental notice retained inline.** Replace the Apache boilerplate with `SPDX-License-Identifier: Apache-2.0`, keep a copyright line, and keep the intergovernmental notice in each file header.
- Pros: machine-readable licence and copyright; smaller than full boilerplate; the notice is preserved verbatim in every file.
- Cons: each file still carries a multi-line notice; headers still vary in length; not minimal.

**Option 2 — REUSE-compliant SPDX headers, intergovernmental notice centralised (CHOSEN).** Each file carries only two tags: `SPDX-FileCopyrightText` and `SPDX-License-Identifier: Apache-2.0`. The unmodified Apache 2.0 text is held in `LICENSES/Apache-2.0.txt` for REUSE and in a top-level `LICENSE` for users and GitHub, with the intergovernmental notice appended at the tail of `LICENSE` and recorded in `NOTICE`. Repositories become verifiable with the `reuse` tool.
- Pros: minimal, uniform two-line header; full REUSE compliance and a CI-checkable state; licence and copyright travel with every file; automated SBOM generation via `reuse spdx`; the intergovernmental notice is asserted in the authoritative licence and notice files; easiest bulk maintenance.
- Cons: a one-off migration per repository; the intergovernmental notice is no longer repeated in each file (it remains in `LICENSE` and `NOTICE`); requires a `LICENSES/` directory and, for files that cannot carry a comment, a `REUSE.toml`.

**Option 3 — Add an SPDX line but keep the full boilerplate.** Insert `SPDX-License-Identifier` alongside the existing full boilerplate.
- Pros: a machine-readable identifier is present.
- Cons: the largest headers of any option; defeats the consistency and ergonomics objectives; redundant.

### Analysis

The options were assessed against machine-readability, downstream portability, SBOM-readiness, consistency, maintainability, and file ergonomics.

Options 0 and 3 fail the machine-readability and consistency objectives (Option 3 additionally enlarges every header) and are dismissed.

Options 1 and 2 both deliver machine-readable, precise, portable licensing; they differ only in where the intergovernmental notice lives. Under the Apache Licence 2.0, the per-file boilerplate is a recommendation of the Licence's appendix, not a condition of the Licence; the Licence's conditions (Section 4) concern retention of the licence, copyright, attribution, and any NOTICE file on redistribution. ECMWF's intergovernmental notice is a standing ECMWF assertion rather than a requirement of the Apache Licence, and it is preserved in full under Option 2 by placing it at the tail of the authoritative `LICENSE` file and in the `NOTICE` file — both of which travel with any redistribution that complies with Section 4. Because the SPDX identifier references the complete licence, including its warranty and liability disclaimers in Sections 7 and 8, no substantive protection is lost by removing the repeated in-file boilerplate.

Option 2 is preferred because it additionally yields a verifiable compliance state (`reuse lint`), the smallest and most uniform header, and direct SBOM generation, while still asserting the intergovernmental notice in the files that carry weight on redistribution. The reduction in bytes and tokens from shorter headers is a minor secondary benefit, not a primary driver.

Precedent for file-level SPDX adoption is extensive: the Linux kernel, U-Boot (which originated the syntax), Zephyr, Hyperledger Fabric, and KDE (which is REUSE-compliant) all use it, and GitHub's licence API recognises SPDX identifiers. Adoption can be incremental — new files immediately, existing files backfilled per repository.

## Decision

ECMWF adopts SPDX short-form licence identifiers and REUSE-compliant file headers as the organisation-wide standard for all ECMWF-authored source files.

Concretely:

1. Every ECMWF-authored file that can carry a comment MUST include, near the top:
   - `SPDX-FileCopyrightText: <year> European Centre for Medium-Range Weather Forecasts (ECMWF)`
   - `SPDX-License-Identifier: Apache-2.0`
2. Where a file has **additional copyright holders** — for example code co-developed with a partner such as the Met Office (Crown Copyright) — each holder is asserted with its own additional `SPDX-FileCopyrightText:` line above the licence identifier, for example:
   - `SPDX-FileCopyrightText: <year> European Centre for Medium-Range Weather Forecasts (ECMWF)`
   - `SPDX-FileCopyrightText: <year> Crown Copyright, Met Office`
   - `SPDX-License-Identifier: Apache-2.0`

   A co-developed file must still be released under an Apache-2.0-compatible licence, so the identifier remains `Apache-2.0`.
3. Each repository MUST contain `LICENSES/Apache-2.0.txt` holding the unmodified Apache 2.0 licence text (the machine-readable source of truth for REUSE).
4. Each repository MUST retain a top-level `LICENSE` file containing the Apache 2.0 text followed, at its tail, by ECMWF's intergovernmental notice.
5. Each repository MUST contain a `NOTICE` file recording ECMWF's copyright and intergovernmental notice, together with any third-party attributions.
6. Files that cannot carry a comment (data, generated artefacts, certain binaries) MUST be covered by a `REUSE.toml` entry or a `.license` sidecar.
7. Third-party files retain their original headers and MUST NOT be re-stamped with ECMWF identifiers.
8. Repositories SHOULD verify compliance in CI and SHOULD enable a `reuse` pre-commit hook. Neither is mandated.

Adoption is incremental: the standard applies to all new files, and existing files are migrated per repository over time. The "how to apply" detail and copy-ready templates are published alongside this ADR in [`Legal/SPDX-and-REUSE.md`](../Legal/SPDX-and-REUSE.md).

### Related Decisions

- Evolves the file-header convention recorded in [`Legal/Copyright-And-Licensing.md`](../Legal/Copyright-And-Licensing.md): the prose Apache header remains valid for not-yet-migrated files, and the SPDX/REUSE header becomes the recommended form going forward.
- Complements the open-sourcing process in [`Legal/Open-Sourcing-Software.md`](../Legal/Open-Sourcing-Software.md) and the `open-source-audit` Agent Skill, which check licensing at publication time.

## Consequences

Positive:
- A single, precise, machine-readable licensing convention across all repositories.
- Licence and copyright metadata travel with every file into downstream and vendored contexts.
- Automated SBOM generation becomes possible (`reuse spdx`), aligning with EU CRA and SBOM expectations and with Member State procurement.
- Verifiable, CI-checkable compliance (`reuse lint`); a REUSE badge is available.
- Simpler bulk maintenance (copyright years, any future relicensing) and lighter, more uniform file headers.
- Improved accuracy of third-party software-composition scanners run against ECMWF code.
- Multiple copyright holders (e.g. partner-co-developed code) are represented precisely and machine-readably.

Negative and costs:
- A one-off migration effort per repository (automatable with `reuse annotate`).
- The intergovernmental notice is no longer repeated in each file; it is preserved in `LICENSE` and `NOTICE`.
- New required artefacts per repository (`LICENSES/`, `NOTICE`, and where needed `REUSE.toml`).
- Ongoing discipline (guidance, and recommended hooks or CI) to prevent drift.

Risks mitigated:
- Loss of the licensing signal when files are copied downstream, addressed by in-file identifiers.
- Divergent, unvalidated boilerplate, addressed by a single tool-checkable convention.

## References

- SPDX — handling licence information in source files: https://spdx.dev/learn/handling-license-info/
- SPDX Licence List (ISO/IEC 5962:2021): https://spdx.org/licenses/
- REUSE Specification: https://reuse.software/spec/
- REUSE tool (FSFE): https://github.com/fsfe/reuse-tool
- Linux Foundation — Open Source Licence Best Practices: https://www.linuxfoundation.org/licensebestpractices
- Apache Licence 2.0 (appendix "How to apply the Apache License to your work"): https://www.apache.org/licenses/LICENSE-2.0
- Apache Software Foundation source-header policy (applies to ASF-owned projects): https://www.apache.org/legal/src-headers.html
- Linux kernel licensing rules: https://www.kernel.org/doc/Documentation/process/license-rules.rst
- EU Cyber Resilience Act — SBOM compliance overview: https://www.mend.io/blog/eu-cyber-resilience-act-compliance-guide/

## Authors

- Tiago Quintino
