# Architectural Decision Record 002: Optional C++ Dependency CLI11 

C++ Tools may opt-in to use of CLI11 instead of `eckit::CmdArg`. When using
CLI11, developers need to adhere to the design guidelines outlined in this
document.

 ## Status

[**Proposed** | <s>Accepted</s> | <s>Deprecated</s> | <s>Superseded by [ADR-XXX]</s>]

## Last Updated

2025-08-13

## Context

So far tools from our stack relied on `eckit::CmdArg` for argument parsing.
`CmdArg` offers basic arg parsing functionality but is lacking support for
sub-commands, repeated options and built-in validation.

It is to be noted that besides any command-line argument parsing with `CmdArg`
`eckit::ResourceBase` is also parsing passed arguments for all resources
starting with a '-'.

### Command Line Argument Parsing with CLI11

CLI11 is an open-source library licensed under BSD Clause 3 License which has
been maintained by the University of Cincinnati. The library has an active
community and has recent releases. 

Documentation can be found (here)[https://cliutils.github.io/CLI11/book/]

The library is header only.

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
// Th
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
  return {};
}

int main(int argc, char **argv) {
  const auto args = parseComandLineArgs(argc, argv);
}
```

> [!NOTE] Compatibility with eckit::ResourceBase
> To retain compatibility with `eckit::Ressource` CLI11 needs to be called with
> `allow_extras()` to disable unrecognized options to be treated as an error. 

See [mars-client-cpp](https://github.com/ecmwf/mars-client-cpp) for a full integration.

#### Key Takeaways

1. Isolate use of CLI11 to ideally one `.cc` file and do not leak CLI11 headers
   outside.

2. Return from command line parsing a type containing all arguments as fields
   with types from your domain (no CLI11 types). This may be a set of custom
   structs / classes or `eckit::LocalConfiguration`

3. You _need_ to set `CLI::APP::allow_extras()` otherwise you _will break_
   `eckit::Ressource`. This is required because `eckit::Ressource` parses
   `args[]` on the fly.

## Authors

- Kai Kratz
