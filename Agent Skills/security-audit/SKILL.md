---
name: security-audit
description: >
  Security audit of a repository, tiered by risk — run before it is made public
  and periodically afterwards. Use when asked to run a security audit or
  review, or to complete the mandatory security step of the open-source audit.
  Builds a threat model, runs SAST / dependency / supply-chain tooling,
  manually reviews security-sensitive surfaces (deserialization, injection,
  memory safety / FFI, crypto, ML model loading), and for high-risk repositories
  adds threat-model-driven adversarial tests and bounded fuzzing. Produces a
  pass/fail Markdown report with CWE-tagged findings. Reports findings and gates
  publication; it does not fix code or flip repository visibility itself.
---

# Security audit

Audit a repository for security weaknesses against a threat model and against
open-source security best practices, **before** it is made public and
**periodically** afterwards. This skill is the concrete implementation of the
**mandatory security audit** referenced by the
[`open-source-audit`](../open-source-audit/SKILL.md) skill (its section
"Security audit"). The two are complementary: `open-source-audit` covers
licensing, README/maturity, secrets-in-history and basic supply-chain hygiene;
**this** skill is the dedicated, deeper security review.

This skill is run as part of the ECMWF open-sourcing process
([`Legal/Open-Sourcing-Software.md`](../../Legal/Open-Sourcing-Software.md)),
by a GitHub Enterprise / organisation owner. Its report is filed in the private
audit store **`ecmwf/repo-audits`** as a `Security-Audit` (see that repository's
`SCHEMA.md`). It supports the **Secure by Design** principle
([`Principles/Open-Source-Principles.md`](../../Principles/Open-Source-Principles.md)).

This file is written to be **model-agnostic** (see the portability notes in
[`Agent Skills/README.md`](../README.md)): the instructions below are
self-contained plain Markdown and work whether this skill is loaded by Claude,
GPT or Gemini agents.

> **You report and gate; you do not fix or publish.** Never edit the target
> repository's code and never change its visibility. Your job is to find and
> record weaknesses and to decide READY / NOT READY. Fixes are the repository
> owner's responsibility; publication is an owner action taken only once the
> audit is READY.
>
> **A clean report is not a proof of security.** This audit is thorough but
> best-effort and time-bounded (see "Limitations"). State honestly what you did
> not or could not check.

## How to run the audit

1. Identify the **run mode** (see "Run modes") and read any previous report.
2. **Characterise the target and build a threat model** (§1).
3. Determine the **risk tier** (§2). It decides how deep you go.
4. Assign **severity** to every finding and know the **verdict rule** (§3).
5. Work through the **methodology** (§4): automated sweep (§5) → manual review
   of sensitive surfaces (§6) → supply chain & CI/CD (§7) → repository posture
   (§8). **High-risk** repositories additionally get the **deep dive** (§9).
6. Record each check as **PASS**, **FAIL** (with severity + CWE), **N/A**, or
   **Unverified** (with a one-line reason).
7. Finish with the report format at the end. Never publish the repository.

Checks marked **[Codex]** cite a source document in `ecmwf/codex`.

## Run modes

Like the open-source audit, this skill is designed to run more than once.
State the mode in the report.

- **Initial audit** — the first security audit, before publication. Work through
  every applicable section from scratch.
- **Follow-up audit (after fixes)** — the repository previously failed and is
  being re-checked. First read the previous report in `ecmwf/repo-audits`
  (`audits/<org>/<repo>/`). Confirm every prior CRITICAL/HIGH (and Unverified)
  item is genuinely resolved and watch for regressions; a READY verdict still
  requires a full pass of every applicable section.
- **Periodic re-audit** — a re-check of an already-public repository. Security
  posture decays as new CVEs land and code drifts, so re-audit at least **once
  every 12 months** and after any major change. Re-running the dependency/CVE
  sweep (§5) is the highest-value part of a periodic run. Compare against the
  most recent report, flag drift, and record the next review date.

## 1. Characterise the target and build a threat model

You cannot audit what you have not modelled. Spend the first pass understanding
the repository, then write a short threat model into the report.

- [ ] **Inventory.** Languages and build systems; artefact type (library, CLI,
      web/API service, notebook, ML training/inference, agent/LLM app,
      infrastructure); entry points; external interfaces.
- [ ] **Trust boundaries.** Where does data or control cross from untrusted to
      trusted? Identify every source of untrusted input: files, network, CLI
      args, environment, message queues, model/checkpoint files, remote object
      stores.
- [ ] **Assets.** What must be protected? Process integrity (no RCE / memory
      corruption), availability (no crash / hang / OOM), confidentiality (no
      secret or memory leakage), integrity of outputs/data.
- [ ] **Adversary.** Who attacks, and what do they control? For an ECMWF data
      library this is often *hostile bytes from a remote/compromised store*; for
      a service it is a *remote unauthenticated client*; for an ML tool it is a
      *malicious model or dataset*.

Instantiate the relevant **attack classes** (only those that apply):

| # | Class | Typical vector | Applies when |
|---|-------|----------------|--------------|
| A | Memory corruption (OOB, UAF, double-free) | `unsafe`/pointer math, FFI, native codecs | C/C++/Fortran, Rust `unsafe`, FFI |
| B | Integer overflow → undersized alloc → OOB | `size × width`, `offset + len` from the wire | binary parsers, codecs |
| C | Decompression / amplification bomb | tiny input → huge output (zip, gzip, zstd, XML) | any decompressor / expander |
| D | Unbounded allocation / OOM DoS | descriptor claims huge size/count | parsers sizing from untrusted input |
| E | Panic / abort / uncaught exception as DoS | `unwrap`, assert, index, arithmetic on hostile input | any untrusted-input path |
| F | Infinite / superlinear loop DoS | scan/recovery loops, regex (ReDoS) | parsers, regex on user input |
| G | Deserialization / code execution | `pickle`, `torch.load`, `joblib`, `yaml.load`, `marshal`, Java/PHP deser | loads serialized data / models |
| H | Injection | command/shell, SQL, path traversal, SSRF, template/SSTI, XXE, eval | builds commands/queries/paths/requests |
| I | Crypto misuse & secret handling | weak algos, hardcoded keys, no TLS verify, weak RNG | crypto, auth, secret handling |
| J | AuthN/Z flaws | missing checks, IDOR, broken session, CORS | services / APIs |
| K | Supply chain | dependency CVEs, unpinned/typosquatted deps, malicious CI | every repo |
| L | Resource-handle exhaustion | fds, threads, tasks, mmap from untrusted input | long-running / server code |
| M | ML-specific | untrusted model/checkpoint load, data-pipeline code exec | *conditional* — ML/AI repos |
| N | LLM/agent-specific | prompt injection, unsandboxed tool/command exec, secrets in prompts | *conditional* — LLM/agent apps |

Classes **M** and **N** are applied **only** when the repository actually loads
models / untrusted serialized data, or is an LLM/agent application. For N, use
the [OWASP Top 10 for LLM Applications](https://owasp.org/www-project-top-10-for-large-language-model-applications/)
as the reference catalogue.

## 2. Risk tier

Set the tier from the threat model; it decides whether the deep dive (§9) runs.

**High-risk triggers** (any one ⇒ high-risk):

- contains **repo-owned** code that parses untrusted input or decodes a binary
  format (a hand-written GRIB/BUFR/netCDF/Zarr or custom-format decoder). Note:
  merely *using* an audited upstream library (`earthkit`, `xarray`, `netCDF4`,
  `eccodes`, …) to read data is **not** by itself a high-risk trigger — review
  that data-handling code as a surface (§6), but it does not force the deep dive;
- contains C/C++/Fortran, Rust `unsafe`, or any FFI boundary;
- is network-facing or a service/API;
- performs deserialization or model/checkpoint loading (classes G / M);
- implements or configures cryptography;
- executes subprocesses / shells / privileged operations.

- **Every repository** gets: automated sweep (§5), manual sensitive-surface
  review (§6), supply chain & CI/CD (§7), posture (§8).
- **High-risk repositories** additionally get the **deep dive** (§9).
- **Low-risk repositories** (e.g. a pure-Python/JS library with no untrusted
  input and no native code) may mark §9 **N/A** with a one-line justification.

Record the tier and the trigger(s) in the report.

## 3. Severity and verdict rule

Rate every finding, tagging the relevant **CWE** where possible:

- **CRITICAL** — remote code execution, memory-corruption with a plausible
  exploit, secret/key compromise, or auth bypass on a network-facing path.
- **HIGH** — memory-safety violation / UB, trivially-triggered crash/abort/hang
  on small untrusted input, injection, unsafe deserialization of untrusted data,
  a known CVE with a practical exploit path in the project's usage.
- **MEDIUM** — DoS requiring large/crafted input, resource exhaustion mitigable
  by an opt-in limit, weak-but-not-broken crypto, a CVE not clearly reachable.
- **LOW** — defence-in-depth, hardening, hygiene.

**Verdict:** the repository is **READY** only when there are **zero open
CRITICAL or HIGH** findings. In the report front-matter, `fail_count` is the
number of open CRITICAL + HIGH findings; `verdict` is `READY` only when that is
`0`. MEDIUM and LOW findings are **logged with remediation advice but do not
block** publication. Iterate until zero HIGH remain. When in doubt, the verdict
is NOT READY.

The severity that governs the verdict is **your triaged severity, not the raw
label a tool prints**. Scanners apply blanket policies that can over- or
under-rate a finding in context — for example a workflow auditor may flag an
unpinned *first-party* reusable workflow as "high" when the practical risk is a
medium hardening item. Down- or up-rate each finding for the actual threat model
and record the reasoning; the verdict follows the triaged severity.

If the audited repository is **already public** and you confirm a CRITICAL or
HIGH vulnerability, additionally recommend that the owner tracks the fix as a
**draft security advisory** (private fork, coordinated release) per the
[Security Vulnerability Disclosure](../../Guidelines/Security-Vulnerability-Disclosure.md)
procedure — do not describe the vulnerability in any public issue or PR. You
still only report and recommend; opening the advisory is the owner's action.

## 4. Methodology

For each surface, work like an attacker and prove each concern:

```
1. SWEEP    — run the automated tooling for the ecosystem (§5) and collect
              raw findings.
2. TRIAGE   — dedupe, discard false positives, and rate each real finding by
              severity + CWE. Automated output is a lead, not a verdict.
3. REVIEW   — manually trace untrusted values from source to sink across the
              sensitive surfaces (§6); confirm or refute each tool lead and
              find what the tools miss.
4. CONFIRM  — for a suspected HIGH/CRITICAL, demonstrate it: a minimal input,
              PoC, or (deep dive) a failing test / fuzz crash. A confirmed,
              reproducible issue is far more actionable than a hunch.
5. RECORD   — log the finding (ID, severity, CWE, surface, evidence, suggested
              remediation). Do NOT fix the code — recommend the fix.
6. NEXT     — continue until every surface is covered and every HIGH is either
              refuted or recorded.
```

## 5. Automated tooling sweep

Run the tools that match the repository's ecosystems; prefer whatever is
installed and install lightweight scanners as needed. Always **triage** output
(step 2 above) — scanners produce false positives and miss logic bugs.

**Cross-ecosystem:**

```
semgrep --config auto            # multi-language SAST (auto REQUIRES metrics on)
# metrics-free alternative:  semgrep --config p/python --config p/security-audit
osv-scanner scan --recursive .   # dependency CVEs across many ecosystems
trivy fs --scanners vuln,misconfig,secret .
syft . -o spdx-json | grype             # SBOM piped into vulnerability match
scorecard --repo=github.com/<org>/<repo>   # OpenSSF repo-posture heuristics
```

Note: `semgrep --config auto` errors under `--metrics off`; use the `p/...` rule
packs above when metrics must stay disabled. For dependency CVEs, unpinned
Python projects resolve best after an install — `pip-audit` against the project's
environment (or a `uv pip freeze` requirements file) is more reliable than
lockfile-only scanners.

Secret scanning (`gitleaks`, `trufflehog`) is covered by the
`open-source-audit` skill's Secrets section; re-run it here only if this is a
standalone security audit, and cross-reference rather than duplicate.

**Per ecosystem:**

```
# Python
bandit -r . ;  pip-audit ;  ruff check --select S ;  # (safety as alt to pip-audit)
# JavaScript / TypeScript
npm audit --omit=dev ;  npx eslint --plugin security . ;
# Go
govulncheck ./... ;  gosec ./...
# Rust
cargo audit ;  cargo deny check ;  cargo geiger        # + miri / cargo-fuzz in §9
# C / C++
cppcheck --enable=all . ;  flawfinder . ;  clang-tidy   # + ASan/UBSan/fuzz in §9
# Java / JVM
dependency-check ;  spotbugs + find-sec-bugs
# Infrastructure / containers
hadolint Dockerfile ;  trivy config . ;  checkov -d .
# GitHub Actions workflows
zizmor .github/workflows/ ;  actionlint
# Jupyter notebooks: run a linter over them via nbqa — the linter must be
# installed in nbqa's OWN environment, e.g. `uv tool install nbqa --with bandit`
nbqa bandit notebooks/ ;  nbqa ruff notebooks/
```

Where a stronger engine is available, prefer **CodeQL** (`codeql database
create` + `codeql database analyze` with the security-extended query suite) for
the primary language.

## 6. Manual review — security-sensitive surfaces

Read the code as an attacker. For each surface present, trace untrusted input to
its sink and record findings with CWE tags.

- [ ] **Untrusted-input parsing & memory safety** — integer overflow/underflow
      in size/offset math (CWE-190/191), out-of-bounds read/write (CWE-125/787),
      decompression bombs (CWE-409), unbounded allocation from wire-controlled
      sizes (CWE-789). Highest priority for binary-format decoders.
- [ ] **Deserialization & model loading** (CWE-502) — `pickle`, `torch.load`,
      `joblib`, `numpy.load(allow_pickle=True)`, `yaml.load` (non-safe),
      `marshal`, `jsonpickle`, Java/PHP deserialization. Loading an untrusted
      artefact is arbitrary code execution — a CRITICAL unless the source is
      demonstrably trusted.
- [ ] **Injection** — command/shell (CWE-78: `os.system`, `subprocess(...,
      shell=True)`, backticks), SQL (CWE-89), **path traversal** (CWE-22:
      user-controlled paths, archive **zip-slip**/tar traversal), **SSRF**
      (CWE-918: user-controlled URLs in fetchers), template/SSTI, **XXE**
      (CWE-611: XML parsers with external entities), dynamic `eval`/`exec`
      (CWE-95).
- [ ] **Cryptography & secret handling** — broken/weak algorithms (MD5/SHA1 for
      security, DES) (CWE-327), hardcoded keys/credentials (CWE-798), disabled
      TLS/cert verification (CWE-295), insecure randomness for security tokens
      (CWE-330). Cross-reference the open-source audit's secret scan.
- [ ] **FFI / `unsafe` boundaries** — raw pointers, `from_raw_parts`, `ctypes`,
      `cffi`, Cython, JNI: unchecked lengths, NULL/dangling pointers, missing
      UTF-8/encoding validation, lifetime/double-free across the boundary
      (CWE-476/416).
- [ ] **AuthN/Z (services only)** — missing/incorrect authorization (CWE-862/863),
      IDOR, broken session handling, permissive CORS, mass assignment.
- [ ] **Concurrency** — data races, TOCTOU (CWE-367), unsafe shared state.
- [ ] **Error handling & logging** — secrets or PII written to logs (CWE-532),
      panics/aborts as DoS on hostile input, sensitive data in stack traces.
- [ ] **ML/AI specifics** *(conditional — class M)* — untrusted checkpoint/model
      loading, unsafe config deserialization, data-pipeline code execution,
      model/data provenance. Treat "download model and run" paths as untrusted
      deserialization.
- [ ] **LLM/agent specifics** *(conditional — class N)* — prompt injection into
      tool-calling, unsandboxed tool/command/`eval` execution, secrets exposed
      in prompts or system messages, missing output validation. Use the OWASP
      LLM Top 10.

## 7. Supply chain & CI/CD security

- [ ] **Dependencies pinned / locked** — a committed lockfile; direct deps
      constrained. Unpinned or floating deps are a supply-chain risk (CWE-1104).
- [ ] **No dependency confusion / typosquatting** — internal package names not
      resolvable from public indices; scopes/namespaces claimed.
- [ ] **Workflow least privilege** — top-level `permissions:` is minimal;
      `GITHUB_TOKEN` is read-only by default.
- [ ] **No dangerous workflows** — no `pull_request_target` running untrusted PR
      code with secrets; no unsanitised `${{ github.event.* }}` in `run:` blocks
      (script injection). Prefer `zizmor` to catch these.
- [ ] **Third-party actions pinned to a commit SHA**, not a mutable tag.
- [ ] **Release integrity** — releases signed / provenance attested where
      applicable (Sigstore, SLSA); artefacts reproducible.
- [ ] **Dependencies kept up to date** — an automated dependency-update process
      is in place (whatever tooling the project chooses).
- [ ] **SBOM** — generated or generable (`syft`), for downstream consumers.

## 8. Repository security posture — [Codex: Principles/Open-Source-Principles.md — Secure by Design]

Check settings with `gh api` where you have access, otherwise note as Unverified.

- [ ] **CI runs security checks** — the project's CI runs SAST and
      dependency-vulnerability scanning (whatever tooling the project uses), so
      regressions are caught continuously, not only at audit time.
- [ ] **Branch protection** on the default branch: required reviews, required
      checks, no force-push, no deletion.
- [ ] **No checked-in binaries** of unknown provenance (CWE-506 risk).
- [ ] **`SECURITY.md` present** *(recommendation, not a blocker)* — a
      vulnerability-disclosure policy. ECMWF's reporting route is **GitHub
      private vulnerability reporting (PVR) first**, with the Support Portal
      (<https://support.ecmwf.int>) as fallback, per the
      [Security Vulnerability Disclosure](../../Guidelines/Security-Vulnerability-Disclosure.md)
      procedure; recommend adding a `SECURITY.md` that points reporters there. A
      ready-to-use, generic template is in the Codex at
      [`Repository Structure/SECURITY.md`](../../Repository%20Structure/SECURITY.md).
      Its absence is a **LOW** recommendation, never a FAIL.
- [ ] **Private vulnerability reporting enabled** *(advisory, non-blocking
      during rollout)* — public ECMWF repositories must have PVR enabled per the
      disclosure procedure (organisation-wide default preferred). Check with
      `gh api repos/<org>/<repo>/private-vulnerability-reporting` where you have
      access; record as an advisory finding if disabled, and as Unverified if
      you cannot check.

## 9. Deep dive (high-risk repositories) — threat-model-driven

For high-risk repositories (§2), go beyond tooling and checklists. A strong
worked exemplar is ECMWF Tensogram's
[`SECURITY_ANALYSIS.md`](https://github.com/ecmwf/tensogram/blob/main/plans/SECURITY_ANALYSIS.md)
— a hostile-remote-bytes audit of a parser/native-code library.

- [ ] **Per-surface adversarial analysis.** In leverage order (highest untrusted
      exposure first), trace every attacker-controlled value from input to use
      (alloc, slice, pointer math, codec, loop) and write down each suspected
      weakness as a concrete attack.
- [ ] **Targeted adversarial tests.** For each hypothesis, feed the malicious
      input and assert *secure* behaviour (clean error / bounded work). A crash,
      hang, UB, or OOB confirms a HIGH/CRITICAL.
- [ ] **Bounded fuzzing.** Run short, time-boxed smoke fuzzing on parser/codec
      entry points: `cargo-fuzz` (libFuzzer + AddressSanitizer) for Rust,
      `atheris` for Python, `go test -fuzz` for Go, `libFuzzer`/AFL++ for C/C++.
      Property to assert: **no panic, no hang, no leak, no UB** on any input.
      In-audit runs are smoke-level (minutes); recommend a CI/nightly deep-fuzz
      job as a follow-up.
- [ ] **Sanitizers / UB detection.** Build and test under ASan/UBSan (C/C++/FFI)
      and run `miri` on pure-Rust `unsafe` where feasible.
- [ ] **Native / vendored code.** Treat upstream vendored C/C++ as an untrusted
      black box contained at the shim; deeply audit *your own* glue/FFI code.
- [ ] **Findings log with stable IDs.** Record confirmed issues as `SEC-001`,
      `SEC-002`, … each with surface, class, attack, severity, evidence, and a
      recommended minimal fix. Recommend a **permanent regression test** per
      finding — but the owner implements the fix and the test, not you.

## Limitations (state these honestly in the report)

- **Best-effort, not a guarantee.** Absence of findings does not prove the code
  is secure.
- **Bounded fuzzing.** In-audit fuzzing is a smoke run, not an exhaustive
  campaign; deep/continuous fuzzing is a CI follow-up.
- **No live DAST / penetration testing** of a deployed service, and **no formal
  verification**.
- **Business-logic authorization** may need human/domain review beyond this
  audit.
- **Upstream dependencies** are assessed for known CVEs and boundary containment,
  not line-audited.

## Report format

Always produce the report as Markdown with this front-matter and shape, ready to
file as `audits/<org>/<repo>/<YYYY-MM-DDThhmm>-Security-Audit.md` in
`ecmwf/repo-audits` (see that repo's `SCHEMA.md`):

```markdown
---
schema_version: 1
repo: <org>/<repo>
commit: <full 40-char SHA audited>
audit_type: security
run_type: initial            # initial | follow-up | periodic
timestamp: <YYYY-MM-DDThh:mmZ>
verdict: NOT_READY           # READY only when zero open CRITICAL/HIGH
auditor_human: <github-username>
auditor_model: <model + version>
previous_report: none
next_review: <YYYY-MM-DD>    # audit date + 12 months
fail_count: 0                # open CRITICAL + HIGH
unverified_count: 0
---

# Security audit: <org>/<repo> @ <short-sha>

**Run type**: Initial / Follow-up / Periodic
**Risk tier**: High / Low — <trigger(s) or "no high-risk triggers">
**Verdict**: READY / NOT READY

## Threat model (summary)
- Assets / adversary / trust boundaries / attack classes in scope.

## Tools run
- <tool> <version> — <one-line result>

## Findings
### SEC-001 — CRITICAL|HIGH|MEDIUM|LOW — Open|Fixed — CWE-XXX
- **Surface:** <file / module / endpoint>
- **Class:** <A–N>
- **Description & attack:** <what, and how it is triggered>
- **Evidence:** <path:line, command, PoC — secret values REDACTED>
- **Recommended remediation:** <the fix the owner should make>
- **Suggested regression test:** <what should guard it>

## Unverified
- <item> — <why it could not be checked>

## Status of previous findings (follow-up / periodic only)
- <SEC-id> — Fixed / Still open / Regressed

## Passed / reviewed clean
- <surface> — <one line>

## Not applicable
- <surface> — <reason, e.g. "no native code; deep dive N/A">

## Recommended follow-ups (non-blocking)
- Run SAST and dependency-vulnerability scanning in CI so regressions are caught
  continuously (whatever tooling the project chooses).
- Add SECURITY.md routing reporters to PVR first (Support Portal fallback), per
  the Security Vulnerability Disclosure procedure; enable PVR if not inherited.
- Wire a nightly/weekly deep-fuzz job for parser/codec entry points.
- Report any upstream third-party vulnerability to its maintainers.

**Recommended next review**: <YYYY-MM-DD, ~12 months out>
```

A repository is **READY** only when there are zero open CRITICAL/HIGH findings.
List anything you could not verify under "Unverified" rather than silently
passing it.

## Report storage

Security reports follow the same rules as the open-source audit: they are
filed in the private store **`ecmwf/repo-audits`**, **kept** for follow-up and
periodic re-audits, and **never** stored anywhere that becomes public with the
repository. **Redact actual secret values** and trim exploit payloads to what is
needed to locate and fix the issue — record paths, line references and a short
description, not live secrets. The audit is run and the report committed to
`main` by an org/Enterprise owner. See the `open-source-audit` skill's
"Report storage" section and `ADR-009 Repository Audit Store` in the Codex.
