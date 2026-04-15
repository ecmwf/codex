# Architectural Decision Record 007: Approved C++ Dependency libfmt

## Status

<s>Proposed</s> | **Accepted** | <s>Deprecated</s> | <s>Superseded by [ADR-XXX]</s>

## Last Updated

2026-03-18

## Decision

C++ projects may opt-in to use of [libfmt](https://github.com/fmtlib/fmt) for
string formatting. Projects that adopt libfmt may treat it as a required
dependency — "opt-in" refers to the project-level decision to adopt, not to a
build-time toggle. libfmt is an approved dependency — not a stopgap until
C++20/23. It remains an approved alternative even after the codebase migrates to
C++20 or later, given its superset of features that have no standard equivalent
at any horizon. When C++20/23 is adopted, projects *may* migrate core formatting
calls from `fmt::` to `std::` (a mechanical change), but are not required to.

libfmt shall **not** require an isolation wrapper. The rationale for this is
detailed in the [Analysis](#analysis) section.

Developers should follow the [design guidelines](#design--usage-guidelines).

## Context

String formatting in our C++ stack currently relies on a mix of approaches:

- **`printf`-family** (`printf`, `sprintf`, `snprintf`, `fprintf`): not
  type-safe, format string mismatches are undefined behaviour, `sprintf` risks
  buffer overflow, no support for user-defined types.
- **`std::ostringstream`**: type-safe but poor performance (heap allocation per
  use, locale-dependent by default), verbose syntax, no compile-time validation.
- **String concatenation** (`std::string` + operator, `std::to_string`): no
  numeric formatting control (precision, padding, hex), unreadable for
  non-trivial cases, inefficient when multiple copies occur.

C++20 introduced `std::format` to address these shortcomings. However, our
codebase targets C++17 and the migration to C++20 is in progress with an unknown
timeline. Even once C++20 is available, `std::format` provides only the core
formatting API — features like `std::print` arrived in C++23, and several
libfmt features (named arguments, custom join separators, terminal colours,
`fmt::memory_buffer`) have no standard equivalent at any horizon.

libfmt is the reference implementation from which `std::format` was
standardized. Its author, Victor Zverovich, is also the author and editor of the
C++ formatting papers (P0645 for `std::format`, P2093 for `std::print`). The
libfmt API and the standard API are the same by design.

### Why act now

- Developers lack a good formatting solution today. The alternatives are
  type-unsafe (`printf`), verbose and slow (`std::ostringstream`), or
  unreadable (concatenation).
- Performance matters for log-heavy operational systems.
- Readability matters for a codebase maintained by scientists and engineers
  with varying C++ experience levels.
- libfmt provides the standard's benefits immediately, with a trivial migration
  path when the standard catches up.

## Options Considered

### Option A: Status Quo

Continue using the current mix of `printf`/`snprintf`, `std::ostringstream`,
and string concatenation.

**Advantages:**
- No new dependency.
- Familiar to all C/C++ developers.
- `printf` is fast for simple cases.

**Disadvantages:**
- `printf` family: not type-safe, format/argument mismatches are undefined
  behaviour, no support for user-defined types, `sprintf` has buffer overflow
  risk, `snprintf` is verbose.
- `std::ostringstream`: poor performance, verbose syntax for even simple
  formatting, no positional arguments, locale-dependent by default.
- String concatenation: no numeric formatting control, becomes unreadable for
  non-trivial cases, inefficient with multiple allocations.
- No compile-time validation for any of these approaches.
- Inconsistent formatting conventions across the codebase.

### Option B: Wait for C++20 `std::format`

Defer until the codebase migrates to C++20, then use `std::format` directly.

**Advantages:**
- No external dependency.
- Standard library feature with guaranteed long-term support.

**Disadvantages:**
- C++20 migration timeline is unknown, potentially years away.
- Developers lack a good formatting solution in the interim.
- Even C++20 `std::format` provides only the core API (see [Feature
  Comparison](#feature-comparison-c20-vs-c23-vs-libfmt) — Tier 1). It does not
  include `std::print` (C++23), range formatting (C++23), or features like
  named arguments, custom join separators, and terminal colours (never
  standardized).
- Some `std::format` implementations have been slower and produced larger
  binaries than libfmt. The gap is narrowing but was significant in early
  GCC libstdc++ releases.
- Compiler support for `<format>` has historically been incomplete. GCC
  `<format>` was not fully available until GCC 13; LLVM libc++ was late to
  implement it.

### Option C: Build an Internal Formatting Abstraction

Write an ECMWF-internal formatting library or wrapper layer.

**Advantages:**
- Full control over API and features.
- Could unify existing formatting approaches.

**Disadvantages:**
- Significant development and maintenance cost for a solved problem.
- Would inevitably converge on the same design as `std::format`/libfmt — it is
  the de facto industry standard API.
- Development resources are better spent on domain problems (same reasoning as
  [ADR-002](./ADR-002-Approved-Dependency-CLI11.md) for CLI parsing).
- Would lack the testing breadth and optimisation maturity of libfmt.

### Option D: Other Formatting Libraries

#### Boost.Format

[Boost.Format](https://www.boost.org/doc/libs/1_89_0/libs/format/)

`printf`-like syntax with `%` operators. Requires pulling in Boost (undesirable
per ADR-002 precedent). Slower than libfmt, no compile-time format string
checking, verbose syntax. Not on a standardisation path.

Developed under Boost Software License v1.

Distributed as part of the Boost distribution.

#### tinyformat

[tinyformat](https://github.com/c42f/tinyformat)

Type-safe `printf`-compatible wrapper. Limited feature set, not actively
developed (last significant update circa 2020). Uses `printf` format syntax,
not the `{}` syntax that has become the standard. No compile-time checking.

Development started in 2011, ~160 commits.

Developed under Boost Software License v1.

Distributed as a single header.

#### FastFormat

[FastFormat](http://www.fastformat.org/)

Effectively abandoned. Last meaningful update circa 2014. Not a viable option.

### Option E: libfmt

[libfmt](https://github.com/fmtlib/fmt)

The reference implementation that was standardized as `std::format` in C++20 and
`std::print` in C++23. Provides a type-safe, performant, and expressive
formatting API with features that go beyond any current or proposed C++ standard
revision.

**Licence:** MIT

**Maturity:** Development started in 2012, 14+ years of active development.

**Longevity:** 300+ contributors (GitHub).

**Activity:** Regular releases, active development. Victor Zverovich (author) is
also the editor of the C++ formatting standards papers (P0645, P2093).

**Visibility:** 21k+ stars on GitHub. Used by spdlog, folly (Meta), TensorFlow,
Windows Terminal, MongoDB, and many others.

**Distribution:** Compiled library (shared or static) or header-only mode.

**Advantages:**
- Type safety: format arguments are type-checked at compile time. Mismatches are
  compile errors, not undefined behaviour.
- Performance: benchmarked faster than `printf` in many cases, dramatically
  faster than `std::ostringstream`.
- Compile-time format string checking: default for literal format strings in
  libfmt 10+. Also available on C++17 via the `FMT_STRING()` macro.
- Readability: Python-style `{}` format strings are concise and familiar.
- Custom type formatting: `fmt::formatter<T>` specializations integrate
  user-defined types cleanly. These convert 1:1 to `std::formatter<T>`.
- No buffer overflow risk: output is always memory-safe.
- Locale-independent by default: consistent behaviour across platforms (opt-in
  locale support via `L` specifier).
- Feature superset: provides everything `std::format` (C++20) and `std::print`
  (C++23) offer, plus features with no standard equivalent (see [Feature
  Comparison](#feature-comparison-c20-vs-c23-vs-libfmt)).
- Battle-tested: 14+ years of development, used in production by major projects.
- Clear migration path: API is the same as the standard by design.

**Disadvantages:**
- Adds an external compiled dependency.
- Must be available on all target build platforms (widely packaged on Linux
  distributions; trivially built from source with CMake).

## Analysis

### Evaluation Criteria

Following the evaluation approach from ADR-002:

- Feature richness
- Maturity and stability
- Development activity and age (Lindy's law)
- Compatible licence (no GPL)
- Ease of integration
- Migration path / lock-in risk

### Why libfmt

1. The status quo (Option A) is demonstrably inferior on type safety,
   performance, and readability.
2. Waiting for C++20 (Option B) leaves developers without a good solution for
   an indefinite period. Even C++20 `std::format` is a subset of what libfmt
   offers (see Tier 1 vs Tier 4 in the feature comparison).
3. Building an internal solution (Option C) is unjustifiable when a mature,
   MIT-licensed, industry-standard solution exists.
4. Other libraries (Option D) lack maturity and create genuine lock-in because
   their APIs diverge from the standard. Choosing Boost.Format or tinyformat
   means a full rewrite when the standard becomes available.
5. libfmt (Option E) provides the `std::format` API today, plus additional
   features, with a mechanical migration path when C++20/23 is adopted.

### Why No Isolation Wrapper

A "replacement" for libfmt is `std::format`, which has the **same API by
design**. libfmt is not merely "similar to" `std::format` — it is the reference
implementation from which the standard was derived, by the same author.

A wrapper around libfmt would be one of two things:

- **A thin namespace alias** (e.g., `namespace ecmwf::format = fmt;`) — this is
  pointless indirection. The migration it "protects" against is already a
  mechanical namespace change (`fmt::` to `std::`).
- **A restrictive API subset** — this actively destroys value by preventing use
  of the features that justify adoption (custom formatters, compile-time
  checking, `fmt::join`, `fmt::print`, `fmt::memory_buffer`, etc.).

The actual migration from libfmt to `std::format` when C++20/23 arrives:

1. `#include <fmt/format.h>` becomes `#include <format>`
2. `fmt::format(...)` becomes `std::format(...)`
3. `fmt::formatter<T>` specializations become `std::formatter<T>`
4. `fmt::print(...)` becomes `std::print(...)` (C++23)

This is automatable with `sed` or `clang-tidy` and can be done incrementally,
one translation unit at a time.

**Migration complexity by feature tier:**

- **Tier 1 features** (core `fmt::format`, `fmt::formatter<T>`): pure
  mechanical migration to C++20 `std::format`.
- **Tier 2 features** (`fmt::print`, range formatting): mechanical migration to
  C++23, except `fmt::join` with custom separators has no direct C++23
  equivalent.
- **Tier 4 features** (named arguments, colours, `fmt::memory_buffer`,
  `fmt::printf`, OS utilities): no standard equivalent exists or is proposed.
  These remain libfmt-only indefinitely.

For Tier 4 usage, documentation-based tracking (comments) is recommended
over code wrappers. Projects using only Tier 1–2 features get a fully
mechanical migration.

## Feature Comparison: C++20 vs C++23 vs libfmt

### Tier 1 — C++20 `std::format` (P0645R10)

C++20 provides the core formatting API:

| Feature | Available |
|---------|-----------|
| `std::format(fmt, args...)` → `std::string` | Yes |
| `std::format_to(out, fmt, args...)` → output iterator | Yes |
| `std::format_to_n(out, n, fmt, args...)` → bounded output | Yes |
| `std::formatted_size(fmt, args...)` → size computation | Yes |
| `std::vformat` / `std::vformat_to` → runtime format strings | Yes (clunky API via `std::make_format_args`) |
| `std::formatter<T>` customization point | Yes |
| Compile-time format string validation | Yes (via `consteval` on `std::basic_format_string`) |
| Format spec mini-language (fill, align, sign, `#`, `0`, width, precision, `L`, type) | Yes |
| Built-in formatters for arithmetic types, `bool`, `char`, strings, `void*` | Yes |
| `std::chrono` formatters | Yes |

**Not in C++20:**

- No `std::print` / `std::println` — must use `std::cout << std::format(...)`
- No range/container formatting — `std::format("{}", vec)` does not compile
- No tuple/pair formatting
- No `std::thread::id` / `std::stacktrace` formatting
- No named arguments
- Runtime format strings require the clunky
  `std::vformat(str, std::make_format_args(a, b, c))` API

### Tier 2 — C++23 Additions

| Feature | Paper | Notes |
|---------|-------|-------|
| `std::print` / `std::println` | P2093R14 | Output to `stdout`, `FILE*`, or `std::ostream` |
| Range formatting | P2286R8 | `std::format("{}", vec)` → `[1, 2, 3]`. Supports `:n` (no brackets). **Separator fixed at `, `** |
| Tuple/pair formatting | P2286R8 | `std::format("{}", tup)` → `(1, "hi", 3.14)` |
| `std::formatter<std::thread::id>` | P2693 | — |
| `std::formatter<std::stacktrace_entry>` | P2693 | — |

**Still not in C++23:**

- No named arguments
- No custom range separators — the separator between elements is always `, `.
  No format spec changes this. `fmt::join(range, " | ")` has no C++23 equivalent.
- No `std::runtime_format` (clean runtime format string syntax — that is C++26)
- No memory buffer type
- No colour/terminal styling
- No printf-compatible formatting bridge

### Tier 3 — C++26 (Adopted/Proposed, Years Away)

| Feature | Paper |
|---------|-------|
| `std::runtime_format(str)` — cleaner runtime format strings | P2918R2 |
| Pointer formatting improvements | P2510 |

### Tier 4 — libfmt-Only Features (No Standard Equivalent at Any Horizon)

These features have no standard counterpart and no active standardisation
proposals:

**Named arguments:**

```cpp
fmt::format("{name} is {age}", fmt::arg("name", "Alice"), fmt::arg("age", 30));
// → "Alice is 30"
```

Improves readability for format strings with many parameters. Useful for
i18n-style patterns and log message templates. Never proposed for
standardisation.

**`fmt::memory_buffer`** — stack-allocated buffer (~500 bytes on stack, spills
to heap):

```cpp
fmt::memory_buffer buf;
fmt::format_to(std::back_inserter(buf), "{}: {:.2f}", label, value);
// Use buf.data() / buf.size() — no heap allocation for small outputs
```

Avoids heap allocation per format call in hot paths (log lines, message
construction). No standard equivalent; `std::format_to` with a pre-allocated
`std::string` is the closest workaround.

**Colour and text styling** (`<fmt/color.h>`):

```cpp
fmt::print(fg(fmt::color::red) | fmt::emphasis::bold, "Error: {}\n", msg);
```

Full ANSI colour palette. Emphasis: bold, italic, underline, strikethrough.
Useful for CLI tools. No standard equivalent, no proposals.

**`fmt::printf`** (`<fmt/printf.h>`) — type-safe printf-compatible formatting:

```cpp
fmt::printf("%.2f\n", 3.14);  // printf syntax, but type-safe
```

Drop-in for gradual migration from printf-heavy code. No standard equivalent
(`std::format` uses `{}` syntax exclusively).

**`fmt::join` with custom separators:**

```cpp
std::vector<int> v = {1, 2, 3};
fmt::format("{}", fmt::join(v, " | "));  // → "1 | 2 | 3"
fmt::format("{}", fmt::join(v, "\n"));   // → "1\n2\n3"
```

C++23 range formatting uses a fixed `, ` separator. The `:n` spec removes
brackets but does not change the separator. `fmt::join` accepts arbitrary
separator strings — strictly more flexible.

**OS utilities** (`<fmt/os.h>`):

- `fmt::output_file("out.txt")` — direct file output bypassing `std::ostream`,
  significantly faster for bulk writes.
- `fmt::ostream` — ostream wrapper with better performance characteristics.

**`fmt::format_int`** — specialised fast integer-to-string:

```cpp
fmt::format_int(42).str();  // faster than std::to_string or fmt::format("{}", 42)
```

**`fmt::to_string(value)`** — convenience shorthand, simpler than
`std::format("{}", value)`.

### Behavioural Differences Where APIs Overlap

Even where libfmt and `std::format` offer the same API surface, practical
differences exist:

1. **Compile-time checking on C++17**: libfmt provides the `FMT_STRING()` macro
   for compile-time format string validation on C++17. `std::format` relies on
   C++20 `consteval` — unavailable to us. In libfmt 10+, compile-time checking
   is the default for string literals even without the macro.

2. **Performance**: libfmt has 12+ years of optimisation. Early GCC libstdc++
   `<format>` was notably slow; MSVC STL is competitive; LLVM libc++ was late to
   implement `<format>` at all. libfmt consistently benchmarks faster or equal.

3. **Binary size**: libfmt (compiled mode) tends to produce smaller binaries
   than `std::format` implementations that rely heavily on template
   instantiation.

4. **Error messages**: Format string errors in libfmt produce clear, targeted
   messages. `consteval` failures in some `std::format` implementations produce
   deep template instantiation errors that are harder to read.

5. **Runtime format strings**: libfmt's `fmt::runtime(str)` is cleaner than
   C++20's `std::vformat(str, std::make_format_args(...))`. C++26 adds
   `std::runtime_format` to close this gap, but that is years away.

## Related Decisions

- [ADR-002 Optional Dependency CLI11](./ADR-002-Approved-Dependency-CLI11.md)
  establishes precedent for adopting third-party C++ dependencies.

## Consequences

### Positive

- **Immediate benefit**: type-safe, performant formatting available now on
  C++17.
- **Consistency**: a single formatting approach across the codebase.
- **Standard alignment**: Tier 1–2 features migrate mechanically to C++20/23
  when the time comes (namespace + header change).
- **Custom type formatting**: `fmt::formatter<T>` specializations convert 1:1
  to `std::formatter<T>`.

### Negative

- **External compiled dependency**: must be available on all build platforms.
  Mitigated: MIT licence, CMake integration is trivial, widely packaged on
  Linux distributions, trivially built from source.
- **Learning curve**: mitigated — format syntax is identical to Python's
  `str.format()` and the C++ standard.
- **Tier 4 features have no migration target**: projects using named arguments,
  colours, `fmt::memory_buffer`, or OS utilities remain dependent on libfmt
  indefinitely. This is acceptable given that libfmt is an approved long-term
  dependency, not a stopgap.
- **`fmt::join` with custom separators**: no C++23 equivalent. Code using this
  would need manual attention if a project chose to migrate away from libfmt
  (which is not required).

### Design / Usage Guidelines

#### Compiled Library Mode Required

Header-only mode (`FMT_HEADER_ONLY`) is not suitable for ECMWF's multi-project
stack of shared libraries:

- **ODR violations**: each `.so` gets its own instantiation of fmt internals.
  Symbol interposition across `.so` boundaries with mismatched versions causes
  subtle crashes.
- **Binary bloat**: every `.so` carries a full copy of fmt's compiled code.
- **Version skew**: different CMake projects could pin different libfmt versions,
  leading to conflicting definitions in the same process.

**Recommendation**: link against a compiled `libfmt` (shared `.so` or static
`.a`). For a shared library stack, a single `libfmt.so` installed centrally
(system package or internal build) ensures one version, one copy, no ODR issues.

Header-only mode remains acceptable for standalone tools, single-binary
applications, or prototyping.

#### Integration

Integrate via CMake `find_package(fmt)`.

#### Custom Formatters

Define `fmt::formatter<T>` specializations in the header that defines `T`, so
they are available wherever the type is used. These convert directly to
`std::formatter<T>` when migrating.

#### New Code

Prefer `fmt::format` / `fmt::print` over `printf`-family for new code. There is
no mandate to migrate existing `printf` usage unless the surrounding code is
being substantially modified.

#### Compile-Time Checking

Compile-time format string checking is the default in libfmt 10+ for literal
format strings. No additional macros or annotations are needed.

#### Example

```cpp
#include <fmt/format.h>
#include <fmt/ranges.h>

#include <vector>

// Basic formatting
std::string msg = fmt::format("Grid has {} points, resolution {:.2f}",
                              npoints, resolution);

// Direct output (no intermediate string)
fmt::print("Processing step {}/{}\n", current, total);

// Formatting collections with custom separator
std::vector<int> levels = {1000, 850, 500, 200};
fmt::print("Levels: {}\n", fmt::join(levels, ", "));
// → "Levels: 1000, 850, 500, 200"

// Custom formatter for a domain type
template <>
struct fmt::formatter<LatLon> {
    constexpr auto parse(format_parse_context& ctx) { return ctx.begin(); }

    auto format(const LatLon& ll, format_context& ctx) const {
        return fmt::format_to(ctx.out(), "({:.4f}N, {:.4f}E)",
                              ll.lat, ll.lon);
    }
};

// LatLon now works in any format call
LatLon point{51.4769, -0.0005};
fmt::print("Location: {}\n", point);
// → "Location: (51.4769N, -0.0005E)"
```

## References

- libfmt documentation: https://fmt.dev/
- libfmt source: https://github.com/fmtlib/fmt
- P0645R10 — Text Formatting (`std::format`, C++20): https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2019/p0645r10.html
- P2093R14 — Formatted Output (`std::print`, C++23): https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2022/p2093r14.html
- P2286R8 — Formatting Ranges (C++23): https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2022/p2286r8.html
- P2918R2 — Runtime Format Strings (C++26): https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2023/p2918r2.html
- [ADR-002 Optional Dependency CLI11](./ADR-002-Approved-Dependency-CLI11.md)

## Authors

- Kai Kratz
- Marcos Bento
