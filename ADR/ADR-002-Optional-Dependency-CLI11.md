# Architectural Decision Record 002: Optional C++ Dependency CLI11

 ## Status

**Proposed** | <s>Accepted</s> | <s>Deprecated</s> | <s>Superseded by [ADR-XXX]</s>

## Last Updated

2025-08-13

## Decision

C++ Tools may opt-in to use of CLI11 instead of `eckit::CmdArg`. When using
CLI11, developers need to adhere to the design guidelines outlined in this
document.

## Context

Command line parsing in out C++ stack is either done with `eckit::CmdArg` or
with custom solutions predating EcKit.

`eckit::CmdArg` is missing useful functionality such as:

- Dependant options
- Subcommands
- Auto-generated help text
- Hooks to add validation code

Need for such functionality increases because we want to improve usability of
our command line tools. This means better help text, documented options instead
of environment variables which have to be known or looked up some place else.
Moving forward we want to take on a third-party dependency because we do not
want to spend work on extending eckit::CmdArgs and generally want to reduce
maintenance burden.

## Options Considered

We considered build ourselves or take on one of several existing open source
libraries.

### Extend EcKit

Design and architecture of a command line parsing is sometimes considered a
'entry level' topic, it nevertheless requires consensus building, design,
implementation and testing work. Our development time and resources are better
spent on other topics. This includes the initial cost to build a bespoke
solution as the continued maintenance.

### Open Source Solution

Looking at the available solutions the following characteristics have been
taken into account:

- Feature richness. -> To ensure the library will serve us well even with
  changing requirements.
- Maturity. -> To ensure that the API is stable enough to build on it.
- Development activity and age. -> We want to pick something that is going to
  be maintained for a long time. Expected future lifetime of a project is
  proportional to its current age (Lindy's law).
- Compatible License -> No GPL
- Ease of integration

The considered libraries are:

#### Argprse

[argparse](https://github.com/p-ranav/argparse)

Replicates python argparse in C++.

Relative few commits in the last year, development speed seems to have slowed
down.

Development started in 2019, 733 commits to date.

Developed under MIT-License.

Distributed as a single header library.

#### CLI11

[CLI11](https://github.com/CLIUtils/CLI11)

Very close to rusts clap library. Most comprehensive list of features of all
libraries in this list. Allows arbitrary nesting of sub-commands. Out of the
box support to map configuration files / environment variables to command line
options.

Active development. Multiple feature / bug fix releases in this year.

Development started in 2017, 1357 commits to date.

Developed BSD Clause 3 License.

Distributed as a single header library.

#### Lyra

[Lyra](https://github.com/bfgroup/Lyra)

Fork of Clara, the command line parsing library used by Catch2. DSL-Style
interface. Most features can be realised but dos not feature mutually exclusive
argument groups for example.

Active but slow development.

Forked in 2019, 513 commits to date.

Developed under Boost Software License v1.

Distributed as a header only library.

#### CmdLime

[cmdlime](https://github.com/kamchatka-volcano/cmdlime)

Declarative style. No support for mutually exclusive groups.

Very little active development.

Development started in 2021, 150 commits to date.

Developed under Microsoft Public License.

Distributed as a header only library.

#### Boost Program Options

[Boost Program Options](https://www.boost.org/doc/libs/1_89_0/doc/html/program_options.html)

Most mature library of the selection but does not offer direct support for
subcommands, although this can be made to work. It comes with Boost. Only
library of this selection that is not header only. In general Boost is a
cumbersome dependency that historically had issues with compatibility. We do
not want to depend on Boost unless we have to.

Development started in 2002, 529 commits to date.

Developed under Boost Software License v1.

Distributed as compiled library.

## Analysis

The choice of library has superficial impact on longterm development as it sits
atop the application and should be almost trivially to replace if the general
deign guidelines, outlined below, are followed.

Further Given our limited development capacity we want to allow use of an existing open
source library. All candidates with the exception of boost program options are
viable. Boost program options is excluded because it is a compiled dependency
and only distributed thought the boost distribution. We strongly prefer a
header only solution here due to the ease of integration.

Of the remaining libraries CLI11 has be in development to longest, the most
active development and the largest feature set.

## Related Decisions

None.

## Consequences

If developers wish to migrate away from `eckit::CmdArg` they may do so under
the condition that they follow the design guidelines outlined below. The design
guidelines aim at isolating the use of any command line parsing library to the
using application. It is advocated to create custom types to store an forward
parsed arguments. Do not use types from the command line parsing library
outside of the actual parsing and validation code. Other parts of the program
shall use custom types instead.

The expectation is that with this design guideline we will isolate our code
from potential future replacements of said command line parsing library.

### Design / Usage Guidelines

Tools using CLI11 may do so under the condition that CLI11 type and function
usage is isolated to allow for future replacement. After parsing all options
are to be passed on to the remainder of the program as either
`eckit::LocalConfiguration` or domain specific structure.

Example:

```cpp
#include <CLI/CLI.hpp>
#include <filesystem>

// Use eckit::LocalConfiguration or custom struct.
struct CommandLineArgs {
  std::filesystem::path file{};
  bool foo{};
  bool bar{};
};

// Place this in seperate translation unit, no CLI11 headers leak
CommandLineArgs parseComandLineArgs(int argc, char *argv[]) {
  CommandLineArgs args{};
  CLI::App app{"App description"};
  // Allow extra args to stay compatible with eckit ressource comandline args
  app.allow_extras();
  argv = app.ensure_utf8(argv);

  std::string filename = "default";
  app.add_option("-f,--file", args.file, "A help string")->required();
  app.add_flag("--foo", args.foo);
  app.add_flag("-b,--bar,--some-deprecated-alias", args.bar);
  app.set_version_flag("--version", [](){return "1.33.7!";});

  try {
    app.parse(argc, argv);
  } catch (const CLI::ParseError &e) {
    // Exit the application directly
    // --help / --version result in the application to
    // exit but with the error code 0
    std::exit(app.exit(e));
  }
  return args;
}

int main(int argc, char **argv) {
  const auto args = parseComandLineArgs(argc, argv);
}
```

> [!IMPORTANT]
> **Compatibility with eckit::ResourceBase**
>
> To retain compatibility with `eckit::Resource` CLI11 needs to be called with
> `allow_extras()` to prevent unrecognized options being treated as an error.

See [mars-client-cpp](https://github.com/ecmwf/mars-client-cpp) for a full integration.

#### Key Takeaways

1. Isolate use of CLI11 to ideally one `.cc` file and do not leak CLI11 headers
   outside.

2. Return from command line parsing a type containing all arguments as fields
   with types from your domain (no CLI11 types). This may be a set of custom
   structs / classes or `eckit::LocalConfiguration`

3. You _need_ to set `CLI::APP::allow_extras()` otherwise you _will break_
   `eckit::Resource`. This is required because `eckit::Resource` parses
   `args[]` on the fly.

### Migrating from eckit::CmdArg to CLI11

Migrating to CLI11 can be done without breaking the current command line
interface in most cases. While CLI11 follows GNU style option naming, i.e.
single dash short options that can be combined and double dash long options,
CLI11 also allows to define single dash long options, e.g. `-longopt`.

It is important to note that CLI11 will interpret `-longopt` as `-l -o -n -g -o
-p -t` _unless_ `-longopt` is explicitly defined. So mixing single dash long
and short options is not recommended.

Options and flags can be created with aliases, e.g. `app.add_flag("-foo,--foo",
args.foo);`, allowing callers to migrate to GNU style options gradually.

## References

See [mars-client-cpp](https://github.com/ecmwf/mars-client-cpp) for a full integration.

Documentation for CLI11 can be found [here](https://cliutils.github.io/CLI11/book/)

*Sources:*
[CLI11](https://github.com/CLIUtils/CLI11)
[argparse](https://github.com/p-ranav/argparse)
[Lyra](https://github.com/bfgroup/Lyra)
[cmdlime](https://github.com/kamchatka-volcano/cmdlime)
[Boost Program Options](https://www.boost.org/doc/libs/1_89_0/doc/html/program_options.html)

## Authors

- Kai Kratz ([Ozaq](https://github.com/ozaq))
