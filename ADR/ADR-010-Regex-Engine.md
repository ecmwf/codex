# Decision Record 010: Regex Engine for C++

## Decisions

EcKit will provide a new Regex wrapper around *PCRE2* in parallel to the current implementation. The current implementation will be marked as deprecated and removed in EcKit 3.0. *PCRE2* offers the best combination of performance, features, and dialect completeness, see [Choices](#choices).

If your project does not depend on EcKit, you should follow the [Usage Guidelines](#usage-guidelines).

Stack-dependencies provide *PCRE2*.

## Context

Our stack currently relies on glibc POSIX regex and std::regex, the two worst performing regex implementations available. To quote the C++ standards committee on using std::regex:
> std::regex performance is very poor relative to other available solutions.  We don't want to spend resources enhancing std::regex when our present guidance is ***to use something else*** if at all possible.
> --[P1844R1 - Enhancement of Regex, Section VII Review](https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2019/p1844r1.html)

### Analysis

#### Immediately Disqualified Alternatives

| Library | Reason for Disqualification | Source |
| ------- | --------------------------- | ------ |
| Boost.Regex | Vulnerable to ReDoS.</br>Requires all of boost. | [GitHub](https://github.com/boostorg/regex) |
| Oniguruma | Archived | [GitHub](https://github.com/kkos/oniguruma) |
| TRE | Unclear maintenance status. | [GitHub](https://github.com/laurikari/tre) |

#### Choices

| Dimension | glibc POSIX regex | std::regex | PCRE2 | RE2 | CTRE |
|---|---|---|---|---|---|
| **API** | C (`regcomp`/`regexec`) | C++ (`<regex>`) | C | C++ | C++ (header-only) |
| **Dialect** | POSIX BRE + ERE | ECMAScript (default), POSIX optional | Full Perl-compatible | Restricted (no backrefs, no lookahead) | ECMA-like subset |
| **Backreferences** | BRE only | Yes | Yes | No | No |
| **Lookahead/behind** | No | Lookahead yes, lookbehind no | Yes | No | No |
| **Non-greedy quantifiers** | No | Yes | Yes | Yes | Yes |
| **Unicode** | No (locale-dependent) | Locale-dependent, inconsistent | Full (UTF-8/16/32) | UTF-8 | UTF-8 |
| **ReDoS safety** | Vulnerable | Vulnerable | Vulnerable (mitigated by match limits) | Safe (linear time) | Safe (compile-time) |
| **Performance** | Poor | Worst (libc++ ~10x slower than libstdc++) | Fastest (with JIT) | ~2x slower than PCRE2-JIT | Matches PCRE2-JIT for compile-time patterns |
| **Runtime compilation** | Yes | Yes | Yes | Yes | No |
| **JIT** | No | No | Yes | No (DFA, no JIT needed) | N/A (compile-time) |
| **Dependencies** | None (libc) | None (stdlib) | None (standalone) | Abseil (or standalone) | None |
| **Thread safety** | Compiled regex read-only safe | Compiled regex read-only safe | Yes | Yes | Yes |
| **License** | LGPL (glibc) | (stdlib) | BSD-3 | BSD-3 | Apache-2.0 |

Neither std::regex nor glibc POSIX regex are suitable. 

##### std::regex Issues

  - Performance is 50-100x slower than PCRE2-JIT, with libc++ (clang/macOS) another ~10x worse than libstdc++ (gcc/Linux)
  - Performance varies across standard library implementations — code that works on gcc may be unusable on clang
  - No lookbehind support despite claiming ECMAScript compatibility
  - No `char8_t` / `char16_t` / `char32_t` support — only `char` and `wchar_t`
  - Pattern compilation is expensive with no way to JIT or cache efficiently
  - Vulnerable to ReDoS with no mitigation mechanism
  - The C++ committee's own guidance is to not use it (P1844R1)

##### glibc POSIX regex Issues

  - No JIT, no DFA fast path, no literal string optimizations — consistently the slowest option after std::regex
  - POSIX ERE dialect is limited: no lookahead/behind, no non-greedy quantifiers, no `\d`, `\w` or `\s` shorthand
  - Backreferences only in BRE mode, which uses archaic `\(` grouping syntax
  - Unicode support is effectively absent — works through locales, behavior varies across systems
  - `\` before a letter is undefined behavior per POSIX spec — glibc silently treats it as literal, other implementations may differ
  - Vulnerable to ReDoS with no mitigation mechanism
  - Known bugs that persisted for years — not a focus area for glibc maintainers

##### Discussion

*CTRE* only supports compile-time regular expressions and therefore cannot be used to replace std::regex in JSON schema validation. 

*RE2's* safety guarantee matters when patterns come from untrusted users. For us, they come from schema and config files authored by engineers. *RE2's* restricted dialect and ~2x performance gap are costs without a corresponding benefit. *PCRE2* offers the most features and highest performance. 

*PCRE2* is vulnerable to ReDoS, but match limits (`pcre2_set_match_limit`) bound execution time and prevent pathological backtracking. See [ReDoS vulnerability](https://owasp.org/www-community/attacks/Regular_expression_Denial_of_Service_-_ReDoS).

## Related Decisions

This allows *PCRE2* to be used when validating JSON files with *Valijson*, see [ADR-009](./ADR-009-JSON-Support.md)

## Consequences

### EcKit Migration Path

EcKit will provide a new API-compatible implementation for `Regex.h`. Since *PCRE2's* Perl-compatible syntax differs from POSIX ERE, every caller must verify that its patterns still match correctly.

#### Potential Issues

| Pattern | POSIX ERE | PCRE2 | Risk |
| ------- | --------- | ----- | ---- |
| `\` before a letter (e.g., `\d`, `\w`) | Undefined — glibc treats `\d` as literal `d` | Interprets as escape sequence: `\d` = `[0-9]`, `\w` = `[a-zA-Z0-9_]` | Silent behavior change. `file\draft` matches "filedraft" in POSIX, matches "file3raft" in PCRE2. Grep for `\\[dDwWsS]` in existing patterns. |
| `{` without count | Matches literal `{` | Syntax error | Regex rejected where it would match |
| Newline handling | `.` matches `\n` by default | `.` does not match `\n` unless compiled with `PCRE2_DOTALL` | Only affects patterns where `.` crosses newline boundaries |

This list is not exhaustive. Inspect every known regex pattern, including those in configuration files. This will be a breaking change for some libraries if patterns are not compatible.

#### Risk Assessment

Regular expressions from our code are safe to migrate. Each can be tested in isolation and migrated.

Regular expressions contained in configuration files, such as for FDB, pose a risk. They require careful migration and coordinated updates to our deployments.

#### Do Not Use pcre2posix

*PCRE2* provides a POSIX compatibility shim. The shim API should be avoided for two reasons:

1. The shim API is not thread-safe according to *PCRE2* documentation. Our stack runs multithreaded.
2. We want downstream projects to migrate to EcKit's *PCRE2*-native Regex types rather than adopting a POSIX-compatible surface over a different engine.

### Usage Guidelines

*PCRE2* is a C library. Wrap PCRE2 pointers in RAII types to prevent resource leaks.

```cpp
// Set PCRE2 to use UTF-8 / byte-width characters
#define PCRE2_CODE_UNIT_WIDTH 8
#include <pcre2.h>

#include <memory>
#include <string>
#include <string_view>
#include <stdexcept>

constexpr auto code_deleter = [](pcre2_code* p) { pcre2_code_free(p); };
constexpr auto mctx_deleter = [](pcre2_match_context* p) { pcre2_match_context_free(p); };
constexpr auto md_deleter   = [](pcre2_match_data* p) { pcre2_match_data_free(p); };

using Code    = std::unique_ptr<pcre2_code, decltype(code_deleter)>;
using Context = std::unique_ptr<pcre2_match_context, decltype(mctx_deleter)>;
using Match   = std::unique_ptr<pcre2_match_data, decltype(md_deleter)>;

bool match(std::string_view pattern, std::string_view subject)
{
    int errcode = 0;
    PCRE2_SIZE erroffset = 0;
    Code re(
        pcre2_compile(
            reinterpret_cast<PCRE2_SPTR>(pattern.data()),
            pattern.size(), 
            // Set PCRE2_DOTALL when migrating POSIX patterns 
            // that expect to match newlines with '.'.
            0,
            &errcode, &erroffset, nullptr),
        code_deleter);

    if (!re) {
        PCRE2_UCHAR errbuf[256];
        pcre2_get_error_message(errcode, errbuf, sizeof(errbuf));
        throw std::runtime_error(
            std::string("PCRE2 compile error: ") +
            reinterpret_cast<const char*>(errbuf));
    }

    // Enable JIT
    pcre2_jit_compile(re.get(), PCRE2_JIT_COMPLETE);

    // Set match limits to mitigate ReDoS
    Context mctx(pcre2_match_context_create(nullptr), mctx_deleter);
    pcre2_set_match_limit(mctx.get(), 100000);
    pcre2_set_depth_limit(mctx.get(), 1000);

    // Match
    Match md(
        pcre2_match_data_create_from_pattern(re.get(), nullptr),
        md_deleter);
    int rc = pcre2_match(
        re.get(),
        reinterpret_cast<PCRE2_SPTR>(subject.data()),
        subject.size(), 0, 0,
        md.get(), mctx.get());

    if (rc == PCRE2_ERROR_MATCHLIMIT || rc == PCRE2_ERROR_DEPTHLIMIT) {
        // Pattern is pathological — treat as no match
        return false;
    }

    return rc >= 0;
}
```

## References

### Libraries
- [PCRE2](https://github.com/PCRE2Project/pcre2) — [API documentation](https://www.pcre.org/current/doc/html/pcre2api.html)
- [RE2](https://github.com/google/re2)
- [CTRE](https://github.com/hanickadot/compile-time-regular-expressions)
- [Boost.Regex](https://github.com/boostorg/regex)
- [Oniguruma](https://github.com/kkos/oniguruma) (archived)
- [TRE](https://github.com/laurikari/tre)

### Performance Comparisons
- [SLJIT regex performance benchmark](https://zherczeg.github.io/sljit/regex_perf.html) — PCRE2-JIT vs RE2 across 15 patterns (by PCRE2-JIT maintainer)
- [CTRE Meeting C++ 2019 slides](https://www.compile-time.re/meeting-cpp-2019/slides/) — CTRE vs PCRE2-JIT vs RE2 throughput (by CTRE author)
- [HFTrader/regex-performance](https://github.com/HFTrader/regex-performance) — 11 engines, updated Sep 2025, independent
- [rust-leipzig/regex-performance](https://github.com/rust-leipzig/regex-performance) — Multi-engine benchmark with reproducible setup

### Standards and Vulnerability References
- [P1844R1 — Enhancement of regex (WG21)](https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2019/p1844r1.html) — Committee feedback on std::regex shortcomings
- [P1433R0 — Compile Time Regular Expressions (WG21)](https://www.open-std.org/JTC1/SC22/WG21/docs/papers/2019/p1433r0.pdf) — CTRE proposal with benchmarks
- [ReDoS — Regular expression Denial of Service (OWASP)](https://owasp.org/www-community/attacks/Regular_expression_Denial_of_Service_-_ReDoS)

## Authors

- Kai Kratz

---
> *I can't remember  
> The best haiku in the world:  
> This is a tribute.*
> ~ Jack Black, probably
