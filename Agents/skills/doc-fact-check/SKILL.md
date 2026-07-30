---
name: doc-fact-check
description: >-
  Verifies documentation against the code it describes: executes the runnable
  code examples in the docs and checks falsifiable prose claims (API names,
  signatures, defaults, enum values, counts, CLI flags, configuration keys)
  against the actual source. Reports each mismatch as an error, a stale claim or
  a drift, and proposes fixes without applying them. Use when asked to
  fact-check documentation, find documentation drift, or verify that docs and
  code still agree.
license: Apache-2.0
---

# Fact-check documentation against the code

Use this skill when you are asked to verify that a project's documentation still
matches its code — to run the examples in the docs, to find stale or drifted
claims, or to check the docs before a release.

The governing rule: **the code is the truth**. Where documentation and code
disagree, the documentation is wrong until a human says otherwise. Report the
disagreement; do not "fix" the code to match the docs.

This skill **proposes fixes but does not apply them**. Documentation wording is
an editorial decision. Present findings for review unless the user explicitly
asks you to apply them.

## Inputs

The user may narrow the scope to particular files or directories. With no scope
given, check all prose documentation in the repository.

## 1. Locate the documentation and the source

Discover both rather than assuming a layout. Look for, in no particular order:

- a documentation directory (`docs/`, `doc/`, `documentation/`, `site/`,
  `website/`, `book/`, `manual/`);
- a documentation generator's configuration, which names the source directory
  (Sphinx `conf.py`, MkDocs `mkdocs.yml`, mdBook `book.toml`, Docusaurus,
  Jekyll `_config.yml`, Doxygen `Doxyfile`, Quarto `_quarto.yml`);
- top-level prose: `README`, `CONTRIBUTING`, `CHANGELOG`, and any guide or
  tutorial files;
- documentation embedded in source as docstrings or API doc comments, if the
  user's scope includes it.

Identify the languages in the repository from its build manifests, so you know
which examples you can execute and where to look for the definitions a claim
refers to.

## 2. Prepare an environment

Work out how the project is built and made importable, from its own contributing
documentation and build files. Build or install what the examples need.

If a setup step fails, **that is not a documentation bug**. Report it separately
as an environment problem, then continue with whatever parts of the project do
work. Never report a block as failing when the real cause is a missing tool or
an unbuilt dependency.

## 3. Classify every fenced code block

For each fenced block in the selected documents, decide one of three:

- **Runnable** — self-contained: it has whatever imports, includes or entry
  point its language needs, and contains no elided placeholders (`...`,
  `<your-value-here>`, `TODO`).
- **Continuation** — it depends on state established by an earlier runnable
  block on the same page. Concatenate it with its predecessors and run the
  combined program.
- **Skip** — anything else. Skip: partial fragments, signature-only listings,
  sample *output* rather than input, blocks with no language tag, installation
  and setup commands, and anything requiring user-specific data, credentials,
  network access to a private service, or hardware the environment lacks.

Record the classification for every block, including the skips and why.

## 4. Execute the runnable blocks

Run each runnable (or concatenated) block in an isolated temporary location,
with a per-block timeout — around 30 seconds is a reasonable default. Capture
the exit status and the output.

General approach by language family:

- **Interpreted languages** (Python, JavaScript, Ruby, R, shell): write the
  block to a temporary file and execute it with the project's own interpreter
  or environment.
- **Compiled languages** (Rust, C, C++, Go, Java, Fortran): only blocks that
  form a complete compilable unit. Create a scratch project that depends on the
  library **by path within the repository**, so the local build is what gets
  tested rather than a published release. Build it, run it if it produces a
  binary, then clean up.
- **Shell examples**: only those that can run without user-specific data and
  without mutating the user's system. Check for a zero exit status. Never run a
  command that writes outside the temporary area, deletes data, publishes, or
  contacts a production service.

Two absolute rules:

- **Never invent missing imports, variables or arguments** to make a block run.
  If it is not self-contained, it is a skip — and if the documentation presents
  it as complete, that itself is a finding.
- **Never modify the documentation to make a block pass.** Record the failure.

## 5. Check falsifiable claims against the source

Read the prose and extract claims that can be mechanically checked. In practice
these appear as inline code spans, numbers, and table cells — not as
paragraphs of explanation.

**Check:**

| Claim type | How to verify |
| ---------- | ------------- |
| API names and signatures — types, functions, methods, fields, parameters, return types | Find the definition in the source and compare, using symbol navigation where available |
| Enum members, constants, magic values, error codes | Compare against the actual definitions |
| Default values ("defaults to 60 seconds", "row-major by default") | Read the default in the code — the constructor, the default implementation, the argument declaration |
| Counts ("supports 12 formats", "over 200 tests") | Count them |
| CLI commands, subcommands and flags | Run the tool's `--help` and compare |
| Configuration and environment variable names | Find where they are read |
| Feature or build flags | Compare against the build manifests |
| Supported versions ("requires Python 3.9+") | Compare against the declared metadata |
| Cross-references and links | Resolve them; a link to a moved or deleted file is a finding |

**Do not check** subjective or architectural statements: "fast", "efficient",
"designed for scale", explanations of *why* something works a certain way.
These are not falsifiable and flagging them produces noise.

When a claim is ambiguous — you cannot tell what would make it true or false —
leave it alone and say so rather than inventing an interpretation.

## 6. Report

Report each finding in a consistent form, with the file and line, what the
documentation asserts, and what the source actually shows:

```
[ERROR] guide/api.md:42 — documented parameter does not exist
  Docs say: connect(host, port, timeout=30)
  Code says: connect(host, port, timeout_seconds=30.0)   src/client.py:88
```

Classify each finding:

- **ERROR** — a code example fails, or a documented name, signature or command
  does not exist. The documentation is actively misleading.
- **STALE** — the documented thing existed once but has been renamed, removed or
  replaced.
- **DRIFT** — a small mismatch: a count that is slightly off, a default that
  changed, a version bound that has moved.

Close with a summary:

- files checked;
- blocks classified runnable / continuation / skipped, and how many ran, passed
  and failed;
- claims checked, and findings by category;
- environment problems, listed separately from documentation findings;
- anything you could not verify, and why.

For each ERROR, propose a concrete fix — the exact replacement text — but do not
apply it. Present the set for review.

Be explicit about coverage. "All examples pass" must mean every runnable block
was executed, not that none were attempted. If most blocks were skipped, say so
prominently: a green report over an unexecuted corpus is worse than no report.
