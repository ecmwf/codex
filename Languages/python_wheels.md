# Building and Using Python Wheels with Compiled Libraries
This document describes the existing mechanism for Python Wheels to interface with ECMWF Libraries in other languages such as C++ or Fortran.

## Terminology
* Compiled library: e.g. `eckit`, `eccodes`, `mir`, `atlas`, ... code in e.g. C++ with ecbuild-based compilation
* Python interface library: e.g. `eccodes-python`, `mir-python`, `pyodc`, ... either cffi or cython interface to a Compiled library
* Python wrapper wheel: a trivial wheel containing only a Compiled library. We currently use `-lib` naming convention. For example, `eckit.whl` is a wheel (zip archive) of compiled `eckit`, including `lib64`, `include`, `etc`, ... everything found in install target.
* Python interface wheel: a regular wheel you can import in python and invoke code from, containing e.g. `eccodes-python` or `pyodc`.
* Wheelmaker: utility docker image used in local or github actions builds of Python wrapper wheels
* Findlibs: python library for dynamic discovery of libraries at python import time -- this is the glue that binds everything above together

## Core idea
Python wheels are just zips, whose installation consists of a/ platform check b/ install of dependent wheels c/ unzipping into the target directory (venv). When a python `import` statement is invoked, it only tries to find the respective python file on the PYTHONPATH (by default the target of wheel unzipping). Our Python interface libraries have in their python files a statement like `ctypes.CDLL(<path to .so of Compiled library>)` to actually load the compiled code -- so the _only_ problem we need to solve is to discover where the `.so` file is located, at import time.

The traditional python way of doing this is to bundle _everything_ into a single wheel, and then have RPATH point to the local directory, so that one just `ctypes.CDLL("./libeckit.so")` for example.  This is not acceptable here, since it would lead to humongeous wheels with absurd release rate. Therefore, we need to find a way how, from e.g. `import mir`, get to "where is my libmir.so?", and from there, recursively, "where is my libeckit.so?" and "where is my libeccodes.so?". Note we can't use `LD_LIBRARY_PATH` -- modifications _after_ python process already started won't have any effect.

We thus utilize `findlibs` and python's importing. From any place in python code, we can do `import eckit` -- our Python wrapper wheels contain an empty python file which can be imported. This will have python find for us the location where the wheel was installed to, and in turn, we can derive the location of `libeckit.so`, and we can `ctypes.CDLL("<path to libeckit.so>")`, which will load the library and make it globally visible. The additional trick is to do this recursively. If you want to load mir, you need to have eckit and eccodes already loaded! Therefore, each python wrapper actually declares "when you find me via findlibs, please also find these prerequisites: ...". All this logic is wrapped inside findlibs, so that when you `findlibs.find("mir")`, you can rely that _all_ has been preloaded.

## Guidelines
### I need to change CMake parameters of compilation of an existing Python wrapper wheel, how do I do it?
Inside each repo, there is `python_wrapper/buildconfig`, with `CMAKE_PARAMS` variable -- edit as needed.

### How do I locally test Python wrapper wheel building?
Pull/build the [wheelmaker image](https://github.com/ecmwf/ci-utils/tree/develop/wheelmaker), pull your repo (e.g., `git clone https://github.com/ecmwf/eckit /src/eckit`), and then execute `cd /src/eckit && /buildscripts/all.sh`. Last step is upload to pypi, which will fail since you don't have the key -- don't worry about that.

### How do I enable Python wrapper building for my new library?
1. Create the `python_wrapper` directory there, with `buildconfig` and `setup.cfg/py` files. The former must contain which python wrappers this depends on, as well as cmake params. The latter is just metadata. Be careful about namings -- if your library is e.g. `mir`, then `NAME` in `buildconfig` should be `mir`, _but_ the `description` in `setup.cfg` should be `mirlib`!. Additionally, declare your dependencies with `-lib` suffix too. For example, if you depend on `eckit`, use `DEPENDENCIES='["eckitlib"]'` and `CMAKE_PARAMS="-Deckit_ROOT=/tmp/mir/prereqs/eckitlib"` in your `buildconfig`.
2. Include the reusable github action `ecmwf-actions/reusable-workflows/.github/workflows/python-wrapper-wheel.yml@main` in your yaml.

You may want to test locally the wrapper wheel building in Docker -- to make sure you got the CMake parameters right in a clean environment.

### How do I incorporate Python wrapper release into my regular release process?
The reusable github action for build & publish can be used anywhere in your yml files -- it makes no assumptions about triggers, dependencies, follow-ups, ...

### I worry I have released a broken wheel, what do I do?
First, test it is indeed so -- create a new venv and install the wheel (best use `pip install --no-cache` to have a truly clean install). Usually, broken wheels manifest by not even being importible, on the grounds of not being able to load dynamic library, missing symbol, ...
Once you confirm the problem, fix it, and release the wheel again.
There is the question whether you want to bump up the version or not -- if you _don't_, our pypi publish script will simply increase build number, which will make the original broken wheel hidden. Of course, users who already installed (or cached) the wheel will need to re-install.
If you do increase version number, it's a regular release of a new version. In either case, you _may_ want to ask an admin to delete the wheel from pypi -- there is no automation, apparently not even possible.

### How do I create a new Python interface wheel?
1. Decide between cffi and cython (at the time of writing, cffi is preferred), and implement the interface. All Compiled library dependencies like "eckit" should be directly used via imports.
2. Declare your requirements in your `setup.py`, relying on regular pypi installs/downloads.
3. Create your github action.

There is much less standardization compared to Python wrapper building -- for now.

### How do I use such Python wheels?
* For python wrappers wheels -- you use them _only_ when implementing a Python interface wheel. You don't `import eckitlib` in your regular python code -- you can, but it is of no use.
* For python interface wheels, just pip install & import.

### How do I bring external compiled dependencies?
Say, for example, you need `libcurl` or `libaec` somewhere in your Compiled library. Ideally, you actually don't. If you do, check whether said library is already available somewhere (as is the case for libcurl and libaec), and consider interfacing with that library through that -- e.g., `eckit` brings in `curl`, so you may want to have `eckit` expose a `curl` call to simplify matters.

If the library is not yet present anywhere, follow the `pre-compile.sh` and `post-build.sh` examples in `eckit/python_wrapper`/`eccodes/python_wrapper` -- those are optional customizable hooks checked for by the repeatable github action, which download and build those dependencies. Note that this process is error-prone and manual, so think twice and test thrice.

### What if I need two different CMake configurations?
Say you'd like to build two wheels for your Python wrapper, one with MPI, one without. This is a conceivable scenario, but we have no support for it at the moment.
We would either release two wheels (`<name>mpilib` and `<name>lib`), or handle it with a feature (`<name>lib[mpi]`) -- but it needs quite a few touches to the Wheelmaker and `buildconfig` schema.
Aim for having a single configuration, that additionally makes it more pleasant for the end users.

### Is there a difference between MacOS and Linux?
Oh yea. The hope is that all differences are covered for by `findlibs` and `wheelmaker` -- so you should never be affected by it (unless you add new external compiled dependencies).
There is currently one caveat that if you have non-trivial `PYTHONPATH` with heterogeneous targets on MacOS, things won't work for you -- so you better don't have.
The detail is that there is actually less work done by `findlibs`, and more work done by MacOS loader -- we actually modify the `RPATH` at _build_ time, to locate the dependencies _assuming_ a simple python installation.
Ideally, this difference will be eliminated in the future by, e.g., smarter invocation of `ctypes.CDLL`.

### Can I swap in my locally compiled library when developing?
Yes -- regardless of where in the stack it is located, you can use anything on your system.
The most reliable way is to brute-force replace the `.so`/`.dylib` in the python environment -- works regardless of system.
Another option is to load your custom libraries via `ctypes.CDLL` before importing other stuff -- though not sure it will work 100%.
Lastly, `findlibs` is somehow configurable -- you can e.g. disable the recursive package search, and rely on system installations only.
However, this would assume you use _no_ python wrapper whatsoever, so that's rather heavy handed.

If there would be popular demand, more tooling can be developed for this.

### Do we support Windows?
Oh nay. Though WSL/Cygwin could work, or perhaps could be made working with a subtle touch to `findlibs`.
