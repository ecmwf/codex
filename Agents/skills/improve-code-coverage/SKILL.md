---
name: improve-code-coverage
description: >-
  Measures test coverage, categorises every gap as untested-but-testable,
  defensive, dead, or environment-specific, then closes the real gaps with tests
  that assert behaviour — prioritising error paths and risky code over easy
  lines. Removes genuinely dead code rather than suppressing it, and reports a
  before-and-after comparison. Use when asked to improve or measure test
  coverage, or to find and fill gaps in a test suite.
license: Apache-2.0
---

# Improve test coverage

Use this skill when you are asked to measure test coverage, raise it, or find
what a test suite is not exercising.

The governing rule: **coverage is a proxy, not the goal.** The goal is a suite
that catches regressions. A line executed by a test that asserts nothing is
worse than an uncovered line, because it reports safety that does not exist.
Never write a test whose purpose is to move a number.

## Inputs

The user may give a target percentage and a scope. If no target is given, adopt
the project's own configured threshold if it has one; otherwise ask rather than
assuming a number. Treat any target as a direction of travel, not a quota to be
met by any means.

## 1. Find the coverage tooling

Discover how this project measures coverage rather than assuming a tool. Check,
in order:

- the CI workflows — if coverage is measured anywhere, it is usually there, with
  the exact invocation and any threshold already configured;
- the build and test configuration files, and any coverage configuration
  (exclusion lists, thresholds, report formats);
- the contributing documentation.

If the project has no coverage tooling, select the standard instrument for its
language and say clearly in the report that you introduced it, along with the
invocation you used — a baseline measured with an unfamiliar tool is not
comparable to anything the project has seen before.

Note any existing exclusions, and treat them as deliberate until shown
otherwise.

## 2. Measure the baseline

Run the full suite under coverage and record, per file: lines covered, lines
total, and the specific uncovered line ranges. Keep this baseline — the final
report compares against it.

If parts of the suite cannot run in this environment, record which and why. Their
absence will depress coverage in ways that are not real gaps, and reporting that
as a finding would be wrong.

## 3. Categorise every gap

This is the step that determines whether the work is useful. For each uncovered
region, read the code and assign one of four categories. Do not skip to writing
tests.

**(a) Untested but testable.** Reachable behaviour with no test. These are the
real gaps and the main target.

**(b) Defensive.** Guards against conditions that are hard to trigger — an
invariant violation, an impossible branch, an allocation failure. Some can be
reached with dependency injection, fault injection or a fake; those move to (a).
Those that genuinely cannot be reached without contorting the design should stay
uncovered and be excluded explicitly, with a reason.

**(c) Dead.** Genuinely unreachable: superseded branches, unused helpers,
conditions that cannot hold. The fix is deletion, not a test.

**(d) Environment-specific.** Reachable only on another platform,
architecture, or optional feature configuration. Note whether CI covers it in a
different job; if so, it is covered, just not here. If nothing covers it, that is
a real finding worth reporting even if you cannot close it locally.

## 4. Prioritise by risk, not by line count

Rank the category (a) gaps. Chasing the largest uncovered file first is the
common mistake; the largest gap is often generated code or a simple data module.

Prioritise:

1. **Error and failure paths** — the least-tested and most-likely-to-be-wrong
   code in most projects.
2. **Input parsing and validation**, especially of untrusted or external data.
3. **Boundaries** — foreign function interfaces, language bindings, serialisation,
   anything crossing a process or network edge, where failures are silent and
   expensive.
4. **Security- and correctness-critical logic** — authentication, authorisation,
   permissions, numerical kernels whose results are trusted downstream.
5. **Recently changed or historically buggy code**, which the version history
   will tell you.
6. Everything else.

## 5. Write tests that assert behaviour

- Add to the **existing** test files and follow the project's established
  patterns, fixtures and naming. A suite with two competing styles is worse than
  one with a gap.
- Each test should target a specific uncovered path and **assert an observable
  outcome** — a returned value, a raised error and its message, a recorded side
  effect. Calling a function and checking it did not crash is not a test.
- Test error paths as first-class cases: assert the *specific* failure, not
  merely that something failed.
- Use adversarial inputs for validation code — malformed, empty, boundary and
  oversized.
- Keep tests deterministic. No dependence on wall-clock time, network access,
  execution order, or unseeded randomness.
- Prefer a few tests that capture the real contract over many that restate the
  implementation. Tests that mirror the code line by line break on every
  refactor and catch nothing.

If writing a test reveals that the code is untestable without changing its
design, say so rather than forcing an awkward test. That is a finding.

If a new test fails because the **code** is wrong, stop and report it. You have
found a bug, which is a better outcome than the coverage change; do not quietly
adjust the test to match the broken behaviour.

## 6. Handle dead code and exclusions

For each (c): verify it is genuinely unreachable — search for all callers,
including dynamic dispatch, reflection, generated bindings, configuration-driven
paths, and use from other languages in the repository. Public interfaces may be
used by consumers outside the repository entirely; those are not dead, and
removing them is a breaking change requiring a human decision.

Once verified: **delete it.** Do not mark it with a coverage-suppression
comment. Suppression hides the code from measurement while leaving it to rot.

Use exclusions only for category (b) and (d), only per-region rather than
per-file, and always with a stated reason. Never widen an exclusion to make a
threshold pass — that is the coverage equivalent of deleting a failing test.

## 7. Verify and report

Run the full suite to confirm everything passes, then re-measure coverage the
same way as the baseline.

Report:

- **Before and after**, per file, plus the overall figure — measured
  identically, or the comparison is meaningless.
- **Tests added**, and which gap each closes.
- **Code deleted**, with the evidence that it was unreachable.
- **Gaps deliberately left**, by category, with the reason: defensive,
  environment-specific, or requiring a design change.
- **Bugs found** while writing tests — usually the most valuable output.
- **Anything not measured**, such as suites that could not run here.

State plainly whether the target was met, and if it was not, what remains and
why. A short honest report that says "84%, and the remaining 16% is defensive
and platform-specific code, itemised below" is worth more than reaching a
threshold by excluding what was inconvenient.
