# Architectural Decision Record 003: PyBind11 for C++ bindings

## Status

[<s>Proposed</s> | **Accepted** | <s>Deprecated</s> | <s>Superseded by [ADR-XXX]</s>]

## Last Updated

2025-09-18

## Decision

PyBind11 is selected to be the library of choice to create Python bindings for
C++ libraries. Existing bindings do not need to be migrated, however migration
is encouraged in case bindings need to be updated or expanded.

Developers should follow the [design guidelines](#design--usage-guidelines).

## Context

ECMWF maintains a suite of high-performance C++ libraries that are increasingly
required to be accessible from Python — for both internal workflows and
external users. Historically, this integration has been achieved using CFFI,
which requires exposing a C-compatible API and writing additional Python
wrappers.

However, this approach presents several technical and business challenges:

### Technical Challenges

- **CFFI is built for C**: CFFI loads symbols via dlsym and thus relies on C
  function declarations. This allows only direct mapping of procedural APIs.
  Creating Object Oriented or "Pythonic" interfaces requires considerable
  effort in the binding layer. This is amplified because our C++ code already
  exposes Object Oriented Interfaces which have to be mapped to a Procedural C
  interface and then have to be mapped back to an Object Oriented interface on
  again.
- **Maintenance Burden**: The different approaches to object lifetime between
  Python and C++ have to be mitigated. Fine grained RAII style object lifetime  
  management has to be reimplemented with less reliable finalizers like `__del__`
  or managed explicitly instead.
- **Performance Bottlenecks**: Indirect bindings through C layers can introduce
  overhead, which is problematic for performance-critical applications.
- **Developer Friction**: The dual-language interface (C++ → C → Python)
  increases the cognitive load and makes on-boarding more difficult for new
  developers.

### Business Challenges

- Slower Time-to-Production: The complexity of maintaining CFFI-based
  bindings delays the delivery of new features and tools to users. 
- Inconsistent User Experience: Manually wrapped APIs often lack the polish
  and consistency expected by Python users, affecting usability and
  adoption.
- Scalability Issues: As ECMWF’s software ecosystem grows, the current
  approach does not scale well in terms of maintainability, performance,
  and developer productivity.

### Goal

To adopt a modern, maintainable, and performant solution for exposing C++ code
to Python that:

- Supports direct binding of C++ constructs without intermediate C layers
- Reduces boilerplate and maintenance effort
- Integrates smoothly with ECMWF’s build and packaging systems
- Enables faster development cycles and better user experience

### Options Considered

#### Manual Binding with Python C API (CPython)

[source](https://github.com/python/cpython) |
[documentation](https://docs.python.org/3/c-api/index.html)

This approach uses the official Python C API (<Python.h>) to directly expose
C++ functions or classes to Python. It is the most low-level and native
approach and is the basis for most of the frameworks mentioned below.

The CPython C-API exposes functions, macros, and data structures for creating
and manipulating Python objects directly in C (or C++). When wrapping C++ code,
you use these APIs to:

* Create Python-visible types (`PyTypeObject`) that wrap native C++ classes.
* Map methods and attributes from the C++ side into Python-callable functions
  (`PyMethodDef` table).
* Handle reference counting, object lifetime, and GIL management explicitly.
* Declare a python module and its initialization (`PyInit_<mymodule>`)

The code is built into a shared object (.so/.pyd) using the Python development
headers and link flags. Python can then import this module directly. The module
can be imported like any native Python package and the wrapped C++ functions
can be called as normal Python functions.


**Licence**: Python Software Foundation License (PSFL), BSD-style, GPL-compatible

**Maturity**: Start in 1991 with python

#### CFFI

[source](https://github.com/python-cffi/cffi) |
[documentation](https://cffi.readthedocs.io/en/stable/)

CFFI (C Foreign Function Interface) is a Python library that allows Python code
to call C functions and use C data types. With CFFI it is possible to
 
* Extract C declarations from your to-be-wrapped API, note that this is a
  preprocessing step because CFFI cannot parse C or C++ header files.
* Load shared libraries using ffi.dlopen() and access all symbols. 
* Call C functions and manipulate C data
  structures as if they were native Python objects

Applying CFFI yields a one-to-one mapping of your procedural code, to create an
Object Oriented or even "Pythonic" interface you need to write another layer on
top.

Exposing complex mechanisms, for example an C++ iterator, requires writing and
remapping intermediate C structures. The wrapping python code usually has to
explicitly care about lifetime of objects. Python itself has no concept of
ownership as it is considered in C/C++.

CFFI does not require to distribute a native Python extension.

**Licence**: MIT

**Maturity**: Created in 2012, many releases (33 tags on github), good documentation. 

**Longevity**: 8 maintainers (pypi), 77 contributors (GitHub).

**Activity**: Multiple releases in the last years, community interaction.

**Visibility**: 204 stars on GitHub.

#### PyBind11 3.0

[source](https://github.com/pybind/pybind11) |
[documentation](https://pybind11.readthedocs.io/en/stable/)

PyBind11 is a C++ header-only library that enables seamless binding of C++ code
to Python. It allows you to expose C++ classes, functions, and data structures
to Python with minimal boilerplate. 

Pybind11 features:

* Automatically translates C++ exceptions to matching Python exceptions, see
  [details](https://pybind11.readthedocs.io/en/stable/advanced/exceptions.html).
  This includes the ability to register custom type conversions that map domain specific
  exceptions, e.g. `eckit::Exception` to `eckit.Exception`.
* Automatically maps between many std types and corresponding python types, see
  [here](https://pybind11.readthedocs.io/en/stable/advanced/cast/overview.html#conversion-table).
* Allows exchanging wrapped types across bindings, see [module local
  bindings](https://pybind11.readthedocs.io/en/stable/advanced/classes.html#module-local-class-bindings)
* Allows setting call policies that affect object lifetimes. These policies
  enable the definition of dependencies between objects whose lifetime is
  managed by python, see [keep
  alive](https://pybind11.readthedocs.io/en/stable/advanced/functions.html#keep-alive)
* Allows mapping of C++ methods to read only or read/write properties.

PyBind11 requires distribution of a native Python extension and does not
support CPython [stable API](https://docs.python.org/3/c-api/stable.html), i.e.
one extension per supported minor Python version has to be provided.

**Licence**: BSD-style

**Maturity**: Built on C++11 features, first released Oct 2015, 36 releases.

**Longevity**: 388 contributors (GitHub).

**Activity**: Recent major release 3.0.

**Visibility**: 17.3k stars on GitHub, 26.6k users, used in PyTorch and TensorFlow.

#### Nanobind

[source](https://github.com/wjakob/nanobind) |
[documentation](https://nanobind.readthedocs.io/en/latest/)

Nanobind is a rewrite of PyBind11 from the same author and claims to be "use
near identical syntax". Goal is to improve performance, reduce compile time and
binary size.

Compared to PyBind11 several key features have been
[removed](https://nanobind.readthedocs.io/en/latest/porting.html#removed-features).
Especially notable is the removal of module local bindings.

PyBind11 requires distribution of a native Python extension and
supports CPython [stable API](https://docs.python.org/3/c-api/stable.html).

**Licence**: BSD-style

**Maturity**: new project, start in 2022.

**Longevity**: 96 contributors (GitHub).

**Activity**: very new but high activity (44 Tags).

**Visibility**: 3k stars on GitHub, 485k users.

#### Boost.Python

[source](https://github.com/boostorg/python) |
[documentation](https://boostorg.github.io/python/doc/html/reference/index.html)

Boost.Python is a component of the Boost C++ Libraries designed to simplify
interoperability between C++ and Python. 

It provides a high-level, declarative API to expose C++ functions, classes, and
objects to Python with minimal boilerplate compared to the raw Python C API.

Key aspects:
- Handles type conversions, exception mapping, and reference counting
  automatically.
- Code is written entirely in C++, with bindings expressed through
  template-based syntax.

**Licence**: Boost Software Licence v1.0

**Maturity**: old project, start in 2002.

**Longevity**: 92 contributors (GitHub).

**Activity**: very new but high activity (44 Tags).

**Visibility**: 502k stars on GitHub.

#### SWIG

[source](https://www.swig.org/) |
[documentation](https://www.swig.org/doc.html)

SWIG (Simplified Wrapper and Interface Generator) is a tool that automatically
generates binding code to expose C/C++ functions and classes to multiple
languages, including Python. 

A user-specified interface file (.i) describes what should be exposed, and SWIG
generates the C/C++ glue code plus Python wrappers.

Key Points:
* Supports many languages besides Python (Java, Ruby, etc.).
* Reduces boilerplate by generating the bindings for you.
* Handles C++ classes, functions, enums, and more.
* Requires SWIG tool installation and a simple build step.

SWIGs key strength is the ability to generate bindings for multiple languages
from one definition, this comes at the cost of the bindings being in many cases
lower level than other solutions. Further swig uses code generation increasing
complexity in the build process. Due to its low level abstractions SWIG leaves
considerable design work to the binding author.

**Licence**: GPLv3, generated code has same licensing as input to SWIG.

**Maturity**: settled and mature project, initial release 1996.

**Longevity**: 272 contributors (GitHub).

**Activity**: weekly commits, few patches per year.

**Visibility**: 6.1k stars on GitHub.

#### Cython

[source](https://github.com/cython/cython) |
[documentation](https://cython.readthedocs.io/en/latest/)

Cython is a superset of Python that allows writing python-like code that is
then compiled to C (or C++) and linked as a native extension module.

Its primary goals are:
* Speed: By adding type annotations and compiling, near-C performance can be
  achieved for critical sections.
* Interoperability: it simplifies calling C/C++ code directly from Python
  without manually handling the CPython C-API in most cases
* Ease of use: Cython code closely resembles Python syntax, so Python
  developers can gradually add optimizations without switching languages.

**Licence**: Apache 2.0 License.

**Maturity**: Start in 2007.

**Longevity**: 492 contributors (GitHub).

**Activity**: almost monthly releases, community interaction.

**Visibility**: 10.3 stars on GitHub, 206k users.

### Analysis

Python use has become ever more widespread thus making functionality of our C++
stack available has become an important consideration. We are looking for a
solution that:
- Offers us to provide Python bindings that integrate well into the Python
  environment.
- Are stable, mature and have good long term maintenance outlook.
- Add the least amount of overall complexity for the most amount of development
  ease.

Overall PyBind11 fits best to the outlined criteria. PyBind11 is broadly
adopted, has a large contributor community and is one of the most active
developed options considered.

PyBind11 adds delivery complexity by requiring distribution of binary wheels
per Python minor version. Of the considered alternatives only Nanobind (Stable
API support) CFFI, and manually writing bindings could provide universal binary
wheels. This added complexity is offset by the plethora of developer
convenience features PyBind11 offers. Most noteworthy here is that is comes
with a lot of pre-defined conversions for types from std. PyBind11 offers the
widest support in this category.


CPython and SWIG are discarded for their low level abstractions and large
amount of rote and error-prone development resulting from this.

CFFI is discarded because of the additional C-API that is required to build and
the additional python code that turns Procedural APIs back into Object Oriented
APIs.

Boost.Python is primarily discarded because we do not want to pull in Boost.
Secondarily because it less fully featured than PyBind11.

Nanobind is less fully featured and explicitly chooses to not provide features
we want to use, i.e. module local bindings. Additionally it is a comparatively
younger project with a smaller contributor base.

Cython is, like SWIG and CFFI, a more verbose and manual process, although
to a lesser extend. Furthermore it does not provide automatic type conversions as
provided by PyBind11.

### Related Decisions

None

## Consequences

New bindings shall be created with PyBind11. Existing bindings may be migrated
at the maintainers discretion. When changes to existing bindings are upcoming a
migration to PyBind11 should be considered. Developers are encouraged to follow
[design guidelines](#design--usage-guidelines) outlined below.

### Design / Usage Guidelines

Keep your binding layer as thin as possible, ideally an exact mapping of the
underlying C++ API. Avoid putting custom logic into your binding layer, keep
exceptions to this at a minimum, try alternatives first, document in place why
the custom logic was necessary.

Optionally wrap your bindings in pure python. This allows you to accomplish the
following:

1. This layer can isolate users of the Python API from changes to the
   underlying C++ API. Be careful though that this is at best only temporarily
   as a migration help. Long term reliance on API remapping can crate unwanted
   complexity and impact performance.

2. Docstrings from pure python code can be seamlessly loaded into IDEs. Modern
   IDEs only load white-listed native python extensions due to security
   concerns, thus preventing displaying inline
   documentation.

3. Full support for auto completion / symbol search features. Auto completion /
   symbol search features do not work out-of-the-box for native  Python
   extensions because modern IDEs only load white-listed extensions due to
   security concerns.

4. Documentation generation with Sphinx is highly simplified when extracting
   documentation from pure python code. If you need to extract documentation
   from native Python extensions you are required to compile the C++ code as
   part of the documentation build.

5. This layer servers as a logical point to make the underlying API more
   "Pythonic", e.g. provide stateful Python iterators with pure Python code.

**A note about linking to the wrapped library**:

Our current approach to find the wrapped libraries such as `libfdb5.so` for
example has been to use '[findlibs](https://github.com/ecmwf/findlibs)'. This
mechanism can be used without changes to load the dependency into the memory
space prior to the dynamic linker loading the dependencies of the  native Python
extension. Key is here to use 'findlibs' to locate and load the dependency prior
to importing the native Python extension. To do this you need to provide a
python shim similar to this:


```python
# This is 'my-package/__init__.py'
import findlibs

findlibs.load("fdb5")

from my_native_extension import (
    MyType
    # ... and many more
)

# "Reexport" the types from the native library
__all__ = [
    "MyType",
    # ... any many many more
]
```

## References 

See the following implementations for a full integration:

**Z3FDB**:
[bindings](https://github.com/ecmwf/fdb/tree/feature/zarr-fdb-interface/src/chunked_data_view_bindings),
[python
wrapper](https://github.com/ecmwf/fdb/tree/feature/zarr-fdb-interface/src/pychunked_data_view)

**Mars2Grib**:
[bindings](https://github.com/ecmwf/multio/blob/feature/multiom-cpp-python/src/pymars2grib_bindings/pymars2grib_bindings.cc),
[python
wrapper](https://github.com/ecmwf/multio/tree/feature/multiom-cpp-python/src/pymars2grib)

*Documentation*
[CPython](https://docs.python.org/3/c-api/index.html)
[CFFI](https://cffi.readthedocs.io/en/stable/)
[PyBind11 3.0](https://pybind11.readthedocs.io/en/stable/)
[Nanobind](https://nanobind.readthedocs.io/en/latest/)
[Boost Python](https://boostorg.github.io/python/doc/html/reference/index.html)
[SWIG](https://www.swig.org/doc.html)
[Cython](https://cython.readthedocs.io/en/latest/)

*Sources*
[CPython](https://github.com/python/cpython)
[CFFI](https://github.com/python-cffi/cffi)
[PyBind11 3.0](https://github.com/pybind/pybind11)
[Nanobind](https://github.com/wjakob/nanobind)
[Boost Python](https://github.com/boostorg/python)
[SWIG](https://www.swig.org/)
[Cython](https://github.com/cython/cython)


## Authors

- Kai Kratz ([Ozaq](https://github.com/ozaq))
- Philipp Geier ([pgeier](https://github.com/pgeier))
- Simon Smart ([simondsmart](https://github.com/simondsmart))
- Tobias Kremer ([tbkr](https://github.com/tbkr))

