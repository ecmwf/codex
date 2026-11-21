---
name: robustness-audit
description: >-
  Audits how code behaves when things go wrong: error paths (crashes in library
  code, swallowed causes, missing diagnostic context, inconsistent mapping
  across language or API boundaries) and edge cases (empty and boundary inputs,
  NaN and infinities, index limits, concurrency, filesystem and encoding
  hazards). Classifies each finding by severity, fixes them with tests, and asks
  before changing behaviour that is ambiguous or public. Use when asked to audit
  error handling, harden edge cases, or improve robustness.
license: Apache-2.0
---

# Audit robustness: error paths and edge cases

Use this skill when you are asked to audit or improve how code behaves under
failure and at its limits — error handling, edge cases, hardening, or general
robustness.

The two halves belong together: an unhandled edge case usually surfaces as a bad
error, and a bad error usually hides an unhandled edge case. Audit them in one
pass.

Governing rules:

- **Fail loudly, never silently.** A wrong answer returned confidently is worse
  than an error. The worst outcome this audit can find is code that swallows a
  problem and continues.
- **Ask before changing intended semantics.** If it is unclear what *should*
  happen for an input — is an empty input an error or a valid no-op? — that is a
  design question. Put it to the user. Do not encode a guess as behaviour.
- **Do not change public behaviour silently.** Tightening validation on a public
  interface can break consumers. Flag it, and let a human decide.

## Inputs

The user may scope the audit to a module, a component or a language. With no
scope, cover the repository's own code, excluding vendored third-party sources.

## 1. Establish what the project already promises

Before judging anything, find the project's stated policy. Read its contributing
and design documentation for rules on error handling, on whether library code
may terminate the process, on compatibility guarantees, and on how errors cross
its public boundaries. Read a few existing error paths to learn the established
pattern.

An audit that imposes a foreign convention is noise. Judge the code against its
own stated rules first, and only then against the general principles below —
flagging where the project has no stated rule as its own finding.

## 2. Audit the error paths

Work through these categories. They are language-neutral; the specific construct
differs, the question does not.

**Crashes on the library path.** Library code should return errors to its caller
rather than terminate the process. Look for the language's abrupt-exit
constructs used outside tests, examples and entry points: unchecked unwrapping
of optional or fallible values, assertions used for input validation, explicit
abort or exit calls, uncaught arithmetic or bounds failures, unchecked casts.
Distinguish a genuine invariant violation (a bug, where terminating may be
correct) from a reachable input condition (which must be an error).

**Swallowed failures.** The highest-severity pattern in this audit. Look for:

- empty catch or ignore blocks;
- catching broadly and continuing as if nothing happened;
- discarding a return value that reports failure;
- error translation that drops the original cause, so the chain is lost;
- logging an error and then proceeding on the failure path anyway.

**Missing diagnostic context.** An error must let someone diagnose the problem
without a debugger. It should identify what failed and on what — the path, the
index, the key, the offending value, the expected versus actual. "Invalid input"
is a finding.

**Boundary mapping.** Wherever an error crosses a boundary — a foreign function
interface, a language binding, a network or process boundary, a public API —
check that it maps consistently: that every failure is representable on the far
side, that no failure can propagate as undefined behaviour across an interface
that cannot carry it, that message and category survive the crossing, and that
the same underlying failure looks the same from every binding.

**Documented failure modes.** Public operations should document what they can
fail with, and the documentation should match reality.

## 3. Audit the edge cases

Enumerate candidate inputs and states systematically. Not all categories apply
to all code; state which you considered and which were not applicable.

**Data and values**

- Empty: zero-length collections, empty strings, empty files, absent optional
  fields, empty configuration.
- Single-element and single-dimension cases, and scalar/zero-dimensional cases
  where the code otherwise assumes a shape.
- Numeric boundaries: minimum and maximum of each integer type, overflow and
  underflow on arithmetic, division by zero, precision loss on conversion.
- Floating point specifically: `NaN` (including its non-reflexive comparison),
  positive and negative infinity, negative zero, subnormals, and any comparison
  or sort that assumes a total order. This matters especially for numerical and
  scientific code, where such values arrive in real data rather than only in
  tests.
- Very large inputs: allocation limits, integer overflow in size computations,
  quadratic behaviour that only shows at scale.

**Interfaces and state**

- Indices and ranges: negative, zero, one past the end, inverted ranges.
- Absent or null arguments where a value is expected.
- Calls made out of order, or on an object already closed, consumed or moved.
- Concurrency: shared mutable state, re-entrancy, iteration during mutation,
  and any documented thread-safety claim — test the claim.
- Resource exhaustion: file descriptors, memory, connection pools; and whether
  resources are released on the *error* path, not just the success path.

**External world**

- Filesystem: missing paths, permission denied, read-only targets, a full disk,
  symlinks and path traversal, path separators and case sensitivity across
  platforms, paths with spaces or non-ASCII characters, files changing during a
  read.
- Partial and interrupted input: truncated data, short reads, cancellation
  midway, timeouts.
- Malformed input: corrupt headers, wrong magic bytes, garbage between records,
  deeply nested or pathologically large structures. Where such input is
  *untrusted*, this overlaps with security — hand those findings to a security
  audit rather than treating them as mere robustness.

**Text**

- Non-ASCII throughout, including in identifiers, keys and paths; multi-byte
  characters split across buffer boundaries; normalisation; very long strings;
  embedded null bytes; encoding mismatches.

**Across boundaries**

- Where the same logic exists in more than one language or implementation,
  check the edge cases agree. Divergence at the edges is a common and
  long-lived class of bug.

## 4. Classify every finding

| Severity | Meaning |
| -------- | ------- |
| **Critical** | Silent wrong results, data corruption, or undefined behaviour. |
| **High** | Crash or process termination reachable from valid input on a library path. |
| **Medium** | Failure is reported, but the cause is lost or the message is not diagnosable. |
| **Low** | Correct behaviour, poor ergonomics: vague wording, missing documentation. |

Record for each: location, the category above, the triggering condition, the
observed behaviour, and the behaviour you believe is correct — plus whether that
is stated by the project or inferred by you.

## 5. Fix, with tests

Work in order of severity. For each fix:

- Add a test that **fails before the fix and passes after**. An edge-case fix
  without a test will regress.
- Put tests in the existing test files, matching the project's structure and
  style.
- Make the failure explicit and diagnosable rather than merely avoiding the
  crash.
- Keep fixes focused — one concern per commit.
- Do not suppress a warning or disable a check to make a finding disappear.

Where step 3 raised a question about intended semantics, or where a fix would
change public behaviour, **stop and ask**. Present the options and their
consequences.

Consider property-based or fuzz testing for input-parsing code, where it
generates edge cases far more thoroughly than hand-written examples.

## 6. Verify and report

Run the project's full gate to confirm no regressions, and re-run the new tests
to confirm they exercise what they claim.

Report:

- findings by severity, each with location, trigger and resolution;
- fixes applied, with the test that covers each;
- **questions outstanding** — the ambiguous semantics and public-behaviour
  changes awaiting a decision, listed prominently rather than buried;
- categories considered and found not applicable, so the reader knows the scope;
- anything you could not exercise, and why.

Be honest about coverage. This audit's value is in what it examined; a clean
report over a narrow slice, presented as a clean bill of health, is misleading.
