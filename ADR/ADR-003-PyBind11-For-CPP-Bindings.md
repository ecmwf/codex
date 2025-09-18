# Architectural Decision Record 003: PyBind11 for C++ bindings

## Status
[**Proposed** | <s>Accepted</s> | <s>Deprecated</s> | <s>Superseded by [ADR-XXX]</s>]

## Last Updated
2025-09-18

## Decision

The decision is to use Pybind11 for C++ bindings (see [analysis](#analysis)). 
Developers should follow the [design guidline](#design-guidlines).


## Context

ECMWF maintains a suite of high-performance C++ libraries that are increasingly
required to be accessible from Python — for both internal workflows and
external users. Historically, this integration has been achieved using CFFI,
which requires exposing a C-compatible API and writing additional Python
wrappers.

However, this approach presents several technical and business challenges:


### Technical Challenges

- **CFFI is build for C**: CFFI loads symbols via dlsym and thus relies on C
  function declarations. This allows only direct mapping of procedural APIs.
  Creating Object Oriented or "Pythonic" interfaces requires considerable
  effort in the binding layer. This is amplified because our C++ code already
  exposes Object Oriented Interfaces which have to be mapped to a prcedural C
  interface and then have to be mapped back to an Object Oriented interface on
  again.
- **Maintenance Burden**: The different approaches to object lifetime between Python and C++ have to be mitigated. Fine grained RAII style object lifetime  
- **Performance Bottlenecks**: Indirect bindings through C layers can introduce
  overhead, which is problematic for performance-critical applications.
- **Developer Friction**: The dual-language interface (C++ → C → Python)
  increases the cognitive load and makes onboarding more difficult for new
  developers.


### Business Challenges

- Slower Time-to-Prodcution: The complexity of maintaining CFFI-based
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

[source](https://github.com/python/cpython) | [documentation](https://docs.python.org/3/c-api/index.html)

Licence: Python Software Foundation License (PSFL), BSD-style, GPL-compatible
Maturity: Start in 1991 with python

This approach uses the official Python C API (<Python.h>) to directly expose C++ functions or classes to Python. 

The workflow is:
  1. Define C++ Code:
     Write normal C++ headers and implementation files for the logic you want to expose (e.g., mylib.h, mylib.cpp).

  2. Create Binding Layer:
     Implement a small C++ file that:

       * Includes <Python.h> and your C++ headers
       * Wraps C++ functions using `PyArg_ParseTuple` (to read Python arguments) 
         and `Py_BuildValue/PyLong_FromLong` (to return values)

       * Registers methods in a `PyMethodDef` table
         Provides a `PyInit_<module>` function to initialize the Python module

  3. Compile to Shared Library:
     Build the code into a shared object (.so/.pyd) using the Python development headers and link flags. 
     Python can then import this module directly.

  4. Usage in Python:
     Once built, the module can be imported like any native Python package (import mymodule) 
     and the wrapped C++ functions can be called as normal Python functions.


#### CFFI

[source](https://github.com/python-cffi/cffi) | [documentation](https://cffi.readthedocs.io/en/stable/)

Licence: MIT
Maturity: Start in 2012, many releases (33 tags on github), good documentation 
Longevity: 8 maintainers (pypi), 77 contributors (github)
Activity: Multiple releases in the last years, community interaction
Visibility: 204 stars on Github 

CFFI (C Foreign Function Interface) is a Python library that allows Python code
to call C functions and use C data types. With CFFI it is possible to
 
 * declare C interfaces: write C declarations (function prototypes, structs,
   etc.) in a string using ffi.cdef()
 * load C libraries (like .so, .dll, .dylib) using ffi.dlopen() and access all
   symbols. 
 * call C functions: python code can now call C functions and manipulate C data
   structures as if they were native Python objects

Using CFFI usally requires to write a certain amount of wrapping code to hide
foreign structures and to make the usage of the library more pythonic. Exposing
complex mechanisms (like an C++ iterator) requires writing and remapping
intermediate C structures. The wrapping python code usually has to explicitly
care about lifetime of objects. Python itself has no concept of ownership as it
is considered in C/C++.


#### PyBind11 3.0

[source](https://github.com/pybind/pybind11) | [documentation](https://pybind11.readthedocs.io/en/stable/)

Licence: BSD-style
Maturity: Built on C++11 features, first released Oct 2015, 36 releases
Longevity: 388 contributors (github)
Activity: recent major release 3.0
Visibility: 17.3k stars on Github, 26.6k users, used in PyTorch and TensorFlow

pybind11 is a C++ header-only library that 
enables seamless binding of C++ code to Python. It allows you to expose C++ classes, 
functions, and data structures to Python with minimal boilerplate. 
The python functionaly is directly expressed in C++ by
 
 * writing a C++ wrapper using pybind11 macros (like PYBIND11\_MODULE).
 * compile the C++ code into a Python extension module (usually done via the
   buildsystem, e.g. CMake)
 * import and use the C++ code directly from Python

PyBind11 offers compatibility with most of C++ `std` (iterators, exceptions,
smart pointers, variant/tuples, ...) and commonly used modules like NumPy.


#### nanobind

[source](https://github.com/wjakob/nanobind) | [documentation](https://nanobind.readthedocs.io/en/latest/)

Licence: BSD-style
Maturity: new project, start in 2022
Longevity: 96 contributors (github)
Activity: very new but high activity (44 Tags)
Visibility: 3k stars on Github, 485k users

nanobind is similar to PyBind11 (almost the same interface) but with the purpose of
  
  * being faster & having less overhead than pybind11
  * producing smaller binary sizes

while explicitly having reduced compatibility with `std` and third party modules.
It is not header-only and requires linking to a shared or static library.


#### Boost.Python

[source](https://github.com/boostorg/python) | [documentation](https://boostorg.github.io/python/doc/html/reference/index.html)

Licence: Boost Software Licence v1.0
Maturity: old project, start in 2002
Longevity: 92 contributors (github)
Activity: very new but high activity (44 Tags)
Visibility: 502k stars on Github

Boost.Python is a component of the 
Boost C++ Libraries designed to simplify interoperability between C++ and Python. 

It provides a high-level, declarative API to expose C++ functions, classes, and objects to Python 
with minimal boilerplate compared to the raw Python C API.Key aspects:

Integration: Handles type conversions, exception mapping, and reference counting automatically.

C++-centric: Code is written entirely in C++, with bindings expressed through template-based syntax.

Stability: Mature, well-tested, and widely used, though less actively developed than newer alternatives (e.g., pybind11).

Dependencies: Requires the Boost libraries and a compatible C++ compiler.


#### SWIG

[source](https://www.swig.org/) | [documentation](https://www.swig.org/doc.html)

Licence: GPLv3, generated code has same licencing as input to SWIG
Maturity: settled and mature project, initial release 1996
Longevity: 272 contributors (github)
Activity: weekly commits, few patches per year
Visibility: 6.1k stars on Github

SWIG (Simplified Wrapper and Interface Generator) is a tool that automatically generates binding code to expose C/C++ functions and classes 
to multiple languages, including Python. 

An user-specified interface file (.i) describes what should be exposed, and SWIG generates the C/C++ glue code plus Python wrappers.

Key Points:
 * Supports many languages besides Python (Java, Ruby, etc.).
 * Reduces boilerplate by generating the bindings for you.
 * Handles C++ classes, functions, enums, and more.
 * Requires SWIG tool installation and a simple build step.


#### Cython

[source](https://github.com/cython/cython) | [documentation](https://cython.readthedocs.io/en/latest/)

Licence: Apache 2.0 License
Maturity: Start in 2007
Longevity: 492 contributors (github)
Activity: almost monthly releases, community interaction
Visibility: 10.3 stars on Github, 206k users


Cython is a superset of Python that allows writing python-like code that is then compiled
to C (or C++) and linked as a native extension module.

Its primary goals are:
  * Speed: By adding type annotations and compiling,
    near-C performance can be achieved for critical sections.
  * Interoperability: it simplifies calling C/C++ code directly from Python
    without manually handling the CPython C-API in most cases
  * Ease of use: Cython code closely resembles Python syntax,
    so Python developers can gradually add optimizations without switching languages.



### Analysis

We want to have python bindings for our whole C++ stack - this has a long term impact.
From that derived requirements for a binding framework are: 
 * longe term maintenance of the framework should be guaranteed for the foreseeable future
 * low binding complexity to reduced development and maintenance overhead
 * needs to be battle tested (due to the expected wide adoption)

According to this we compare the canditates as follows:

CPython:
 * Pros: full control, no external dependencies, stable API, flexible and lightweight
 * Cons: Boilerplate code, manual memory/error handling, steeper learning curve.

CFFI:
 * Pro: good for existing C interfaces
 * Cons: needs additional C interface, bindings can get complex, higher maintenance cost

Pybind11:
 * Pros: low binding complexity, battle test in famous frameworks, interaction with numpy array
 * Cons: higher compile-time due to code generation, larger binary size

Nanobind:
 * Pros: compensates pybind11 cons
 * Cons: not header-only anymore, fewer `std` or third party support

Boost.Python:
 * Cons: clunky, heavy dependency on boost, larger build complexity, slower compile times

Swig:
 * Pros: automates most of the binding work, supports multiple languages, mature and stable tool
 * Cons: interface files add an extra step, generated code may be harder to debug, 
   less "pythonic" feel compared to pybind11 or Boost.Python

Cython:
 * Pros: can directly wrap C++ (compared to CFFI), python-like syntax
 * Cons: limited modern C++ support, more boilerplate than alternatives,
   harder debugging for crashes, extra build step needed


Our canditate of choice is Pybind11 - compared to all the other candidates (except nanobind) it offers the 
  * lowest development complexity
  * gives direct access to complex objects like iterators
  * is well maintained & documented
  * battle-tested and widely used in famous frameworks

Depending on the development on nanobind over the next coming years. 
It might become a replacement for pybind11 - as the API is similar to pybind11, a migration will be rather simple.


### Related Decisions

None


## Consequences

Existing python bindings that are not pybind11 bindings can be migrated through the [design guidlines](#design-guidelines).


### Design guidlines

*No domain-specific/business logic* must be specified in the file. 
The C++ bindings should forward all internal logic directly without adding new.
The binding layer shall be a 1-1 layer of the existing C++ interface.
There shall be no transformations and mappings in the binding layer.

Optionally, the user can provihde an additional wrapping python module.
This has several benefit:
 * handle additional transformations & mappings
 * address compatibility problems through API changes
 * readable API and more accessable docstrings for most IDE & language servers
 * can provide more user convenience in general


### References

z3zarr: [bindings](https://github.com/ecmwf/fdb/tree/feature/zarr-fdb-interface/src/chunked_data_view_bindings), [python wrapper](https://github.com/ecmwf/fdb/tree/feature/zarr-fdb-interface/src/pychunked_data_view)
mars2grib: [bindings](https://github.com/ecmwf/multio/blob/feature/multiom-cpp-python/src/pymars2grib_bindings/pymars2grib_bindings.cc), [python wrapper)(https://github.com/ecmwf/multio/tree/feature/multiom-cpp-python/src/pymars2grib)


## Authors

- Kai Kratz
- Philipp Geier
- Simon Smart
- Tobias Kremer 
