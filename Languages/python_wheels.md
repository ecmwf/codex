# Building and Using Python Wheels with Compiled Libraries
This document describes the existing mechanism for Python Wheels to interface with ECMWF Libraries in other languages such as C++ or Fortran.

## Terminology
* Compiled library: e.g. `eckit`, `eccodes`, `mir`, `atlas`, ... code in e.g. C++ with ecbuild-based compilation
* Python interface library: e.g. `eccodes-python`, `mir-python`, `pyodc`, ... either cffi or cython interface to a Compiled library
* Python wrapper wheel: a trivial wheel containing only a Compiled library. We currently use `-lib` naming convention. For example, `eckitlib.whl` is a wheel (zip archive) of compiled `eckit`, including `lib64`, `include`, `etc`, ... everything found in install target.
* Python interface wheel: a regular wheel you can import in python and invoke code from, containing e.g. `eccodes-python` or `pyodc`. Whether its a binary wheel or pure python wheel depends on whether cython or cfii are used. Does not contain the Compiled library itself, but obviously requires it at runtime.
* Wheelmaker: utility docker image used in local or github actions builds of Python wrapper wheels
* Findlibs: python library for dynamic discovery of libraries at python import time -- this is the glue that binds together at runtime the Python interface wheel to Compiled libraries (whether via Python wrapper wheel or manually compiled).

## Core idea
Python wheels are just zips, whose installation consists of a/ platform check b/ install of dependent wheels c/ unzipping into the target directory (venv). When a python `import` statement is invoked, it only tries to find the respective python file on the PYTHONPATH (by default the target of wheel unzipping). Our Python interface libraries have in their python files a statement like `ctypes.CDLL(<path to .so of Compiled library>)` to actually load the compiled code -- so the _only_ problem we need to solve is to discover where the `.so` file is located, at import time.

The traditional python way of doing this is to bundle _everything_ into a single wheel, and then have RPATH point to the local directory, so that one just `ctypes.CDLL("./libeckit.so")` for example.  This is not acceptable here, since it would lead to rather large wheels with rather large release rate. Additionally, the developer flow would be compromised -- you would not be able to swap in your just-compiled mir.so while testing something in pymultio interface. Therefore, we need to find a way how, from e.g. `import mir`, get to "where is my libmir.so?", and from there, recursively, "where is my libeckit.so?" and "where is my libeccodes.so?". Note we can't use `LD_LIBRARY_PATH` -- modifications _after_ python process already started won't have any effect.

### Importing
We thus utilize `findlibs` and python's importing. From any place in python code, we can do `import eckitlib` -- our Python wrapper wheels contain an empty python file which can be imported. This will have python find for us the location where the wheel was installed to, and in turn, we can derive the location of `libeckit.so`, and we can `ctypes.CDLL("<path to libeckit.so>")`, which will load the library and make it globally visible. The additional trick is to do this recursively. If you want to load mir, you need to have eckit and eccodes already loaded! Therefore, each python wrapper actually declares "when you find me via findlibs, please also find these prerequisites: ...". All this logic is wrapped inside findlibs, so that when you `findlibs.find("mir")`, you can rely that _all_ has been preloaded.

Let us make this more concrete on an example. Say `mirlib.wheel` consists of two files, `mir.so` and `__init__.py`, with the latter having content `depends_on = ['eckitlib']`. The wheel itself also declares that it depends on `eckitlib.wheel`. When you do `pip install mirlib`, in your `venv/lib/python3.14/site-packages` you will end up with `mirlib` and `eckitlib` directories, each result of unzipping the respective wheel. You don't need to install eckit explicitly, pip pulls it because of the metadata on mirlib wheel.
When you then `import mirlib`, what happens is... basically nothing! Python just finds the `venv/lib/python3.14/site-packages/mirlib/__init__.py` which contains the `depends_on = ['eckitlib']`, but that's all.
The proper way of importing it is thus using `findlibs.load("mir")`. What happens then is:
1. Findlibs translates `"mir"` to `"mirlib"` (some libraries are more complicated, for example `"atlas"` is not in `"atlaslib"` wheel but in `"atlaslib-ecmwf"`, thus we need this lookup layer),
2. Findlibs does the `import mirlib`,  and peeks at the `depends_on` attribute it exposes.
3. It notices eckit is needed, thus it recurses and `import eckitlib`.
4. There are no dependencies there, so Findlibs identifies `eckitlib.__file__`, and looks on the filesystem in that location for `eckit.so`.
5. It finds them and CDLL loads them.
6. Then it proceeds to CDLL load the `mir.so`, again using the `mirlib.__file__` to point to the right directory.

However, you typically don't interact with mirlib wheel directly using findlibs as the user -- instead, you use the `mir-python` wheel, which contains the cython-based api to `mir.so`. And this wheel not only declares the mirlib wheel as its dependency, it contains inside its own `__init__` the findlibs-bootstrapping code. Therefore, if you "just wanna mir in python", you `import mir` and everything happens behind the scene.

One reason for this complexity is that your python path may be heterogeneous -- some wheels are installed to your system python, others to your conda env, others to a venv you created from that conda... and we have no guarantee that the mirlib wheel is in the same place as the eckitwheel, thus we can't do the trick of setting rpath to `../../../eckitlib` in `mir.so`, as many other python packages such as torch actually do.
(Caveat: this is true only for Linux; on MacOS there is some issue with this preloading thus we *require* homogeneous python path).

### Versioning and ABI compatibility
How do we guarantee that when you `pip install mirlib`, the consequently installed `eckitlib` is ABI-compatible with that?
One would think that when we build mir with version `x1.y1.z1` and we use eckit of version `x2.y2.z2`, we could simply publish `mirlib-x1.y1.z1.wheel` with dependency `eckitlib>=x2.y2.z2,<x2+1`.
Alas, that would not guarantee ABI compatibility, given how often is the compiled stack changing -- already `x2.y2.z2+1` could replace some symbol with another in a way that would make mir break, already at the CDLL load time.

We could thus switch to exact pinning, ie, say that the mirlib wheel in question requires `eckitlib==x2.y2.z2`.
However, that introduces a problem once we realize that our compiled stack consists of multiple libraries.
Say we release multio with version A, depending on mir B and eckit C, with exact pins.
Later on, a new version C+1 of eckit appears, and then we'd like to release multio A+1.
However, if there is no mir of version B+1, we are stuck -- the mirlib-B.wheel already exists, and it depends on eckit-A.wheel, not eckit-A+1.wheel.

To get around that limitation, we switch to 4-dimensional versioning, x.y.z.C, where C is a monotonic counter shared across all packages.
For the example above, we would first release eckit.A.1, mir.B.1 and multio.C.1.
And in the second run, we would release eckit.A+1.2, mir.B.2 and multio.C2, all with exact pins.
The mir.B.1 and mir.B.2 are seemingly the same, from the point of view of the compiled mir code -- but they actually differ in which version of eckit they were build against, and thus justify being separate wheels.

This has an additional benefit of allowing simple check of ABI compatibility of a given python environment.
List all installed wheels and check that their fourth versioning number is _exactly_ equal.
If not, you are likely to experience "Symbol not found" or worse.
The reason for this possibly happening is that pip does not necessarily guarantee to leave your environment in a correct state.
Say you first `pip install multio`, and pip notices that there is multio.C.1, which in turn brings eckit.A.1.
And then later, you `pip install gribjump` -- which is not in any relationship to multio, but depends on eckit.
And say that the most recent gribjump wheel has been released as gribjump.D.2, with eckit.A+1.2 as a dependency.
Pip dully updates eckit, while telling you "oh and btw your environment is broken, multio wheel has unsatisfied dependency".
Other package managers like `uv` would refuse to install multio in the first place, but this behaviour can't be relied upon.


## Guidelines
### I need to change CMake parameters of compilation of an existing Python wrapper wheel, how do I do it?
For each wheel / compiled package, there is currently one set of compilation flags that is published.
Inside each repo, there is `python_wrapper/buildconfig`, with `CMAKE_PARAMS` variable -- edit as needed.
If we would need multiple variants (think like `atlas-plain` and `atlas-mpi`), we would need to release multiple separate wheels.

### How do I locally test Python wrapper wheel building?
Pull/build the [wheelmaker image](https://github.com/ecmwf/ci-utils/tree/develop/wheelmaker), pull your repo (e.g., `git clone https://github.com/ecmwf/eckit /src/eckit`), and then execute `cd /src/eckit && /buildscripts/all.sh`. Last step is upload to pypi, which will fail since you don't have the key -- don't worry about that.

### How do I set up Python wrapper wheel building for my new library?
1. Create a directory, for example `python_wrapper` or `python/wrapper` in the repo, with `buildconfig` and `setup.{cfg, py}` files. The former must contain which other python wrappers this depends on, as well as cmake params. The latter is just metadata. Be careful about namings -- if your library is e.g. `mir`, then `NAME` in `buildconfig` should be `mir`, _but_ the `description` in `setup.cfg` should be `mirlib`!. Additionally, declare your dependencies with `-lib` suffix too. For example, if you depend on `eckit`, use `DEPENDENCIES='["eckitlib"]'` and `CMAKE_PARAMS="-Deckit_ROOT=/tmp/mir/prereqs/eckitlib"` in your `buildconfig`.
2. Include the reusable github action `ecmwf-actions/reusable-workflows/.github/workflows/python-wrapper-wheel.yml@main` in your yaml -- this is where you put the location of the directory from the previous step (the `python_wrapper` is a default).

If unsure, consult existing projects (eckit, mir, atlas, ...) as working examples.

Note the reusable action currently does... nothing! But we parse the yaml file in the existing release process (described below) to make sure we get the `python_wrapper` location right. This will change in the future.

You may want to test locally the wrapper wheel building in Docker, as described in the previous step -- to make sure you got the CMake parameters right in a clean environment.

### Now I have the wrapper wheel, how do I set up the python-interfacing wheel?
As you would any python wheel with cython/cffi.
Only make sure you utilize `findlibs` correctly -- consult e.g. eckit or mir examples for cython, or eccodes or pyfdb for cffi.

### How do I incorporate Python wrapper release into my regular release process? How is the release actually triggered?
Currently it is manually triggered, but we will set up an automated release for a few selected projects.

The project which drives all the releasing is called [python develop bundle](https://github.com/ecmwf/python-develop-bundle), and is capable of releasing any part of the stack with recursive dependency discovery & release, maintains the fourth-version-counter, handles both test and regular pypi, supports building from any branch, ...
Consult respective `release.yml` file in that bundle for all configurable details.

It can be configured to release _both_ wrapper wheel and python interface wheel at the same time, and for most projects it does so already.
However, there is currently a deficiency that we don't correctly derive pins for the python interface wheel -- that is, when we release `eccodes`, it just has vanilla `eccodeslib` dependency, not `eccodes>=x.y.z,<x+1`.

### I worry I have released a broken wheel, what do I do?
First, test it is indeed so -- create a new venv and install the wheel (best use `pip install --no-cache` to have a truly clean install). Usually, broken wheels manifest by not even being importible, on the grounds of not being able to load dynamic library, missing symbol, ...
Once you confirm the problem, fix the root cause, and run the release action again.
This will cause the global build counter to increase -- technically you don't even need to increase the underlying package version, ie, you don't need to trigger a regular project release just to fix a broken wheel if the issue is in the python config part.
However, users who already installed (or cached) the wheel will need to re-install, perhaps with forcefull `--upgrade`.
We don't have any process for deleting broken wheels from PyPI.

### How do I use such Python wheels?
* For python wrappers wheels -- you use them _only_ when implementing a Python interface wheel. You don't `import eckitlib` in your regular python code -- you can, but it is of no good use.
* For python interface wheels, just pip install & import.

### How do I bring external compiled dependencies?
Say, for example, you need `libcurl` or `libaec` somewhere in your Compiled library. Ideally, you actually don't. If you do, check whether said library is already available somewhere (as is the case for libcurl and libaec), and consider interfacing with that library through that -- e.g., `eckit` brings in `curl`, so you may want to have `eckit` expose a `curl` call to simplify matters.

If the library is not yet present anywhere, follow the `pre-compile.sh` and `post-build.sh` examples in `eckit/python_wrapper`/`eccodes/python_wrapper` -- those are optional customizable hooks checked for by the repeatable github action, which download and build those dependencies. Note that this process is error-prone and manual, so think twice and test thrice.

We are currently in the middle of incorporating https://github.com/ecmwf/cxx-dependencies to the wheel building stack -- ideally include your library there.
However, that will still leave in place the need to actually bundle that library somewhere into our stack, which has its own licensing and sizing problems.

### Is there a difference between MacOS and Linux?
Yes. The hope is that all differences are covered for by `findlibs` and `wheelmaker` -- so you should never be affected by it (unless you add new external compiled dependencies).
There is currently one caveat that if you have non-trivial `PYTHONPATH` with heterogeneous targets on MacOS, things won't work for you -- so you better don't have.
The detail is that there is actually less work done by `findlibs`, and more work done by MacOS loader -- we actually modify the `RPATH` at _build_ time, to locate the dependencies _assuming_ a simple python installation.
Ideally, this difference will be eliminated in the future by better understanding of the root cause and, e.g., smarter invocation of `ctypes.CDLL`.

Furthermore, we build for both x86 and aarch64 architectures in either of these two platforms -- and between these, there are no differences.
Except that the x86-Linux bundles in Intel fortran libraries, whereas the other 3 do no such thing.
The Intel fortran libraries are currently needed for making multio compilable -- but this should eventually abscond altogether.

### Can I swap in my locally compiled library when developing?
Yes -- regardless of where in the stack it is located, you can use anything on your system.
The most reliable way is to brute-force replace the `.so`/`.dylib` in the python environment -- works regardless of system.
Another option is to load your custom libraries via `ctypes.CDLL` before importing other stuff -- though not sure it will work 100%.
Lastly, `findlibs` is somehow configurable -- you can e.g. disable the recursive package search, and rely on system installations only.
However, this would assume you use _no_ python wrapper whatsoever, so that's rather heavy handed.

If there would be popular demand, more tooling can be developed for this, such as exposing per-library config granularity in findlibs.

### Do we support Windows?
No. Though WSL/Cygwin could work, or perhaps could be made working with a subtle touch to `findlibs`.

To make this work, we would need at least the following:
 - each library must be compilable on windows in the first place,
 - every external dependency must be compilable on Windows, ideally via cxx-dependencies,
 - we support Windows DLL loading, either on the recursive-findlibs level like we do on Linux or at least on the rpath-relative-hardcoding level like we do on MacOS,
 - we have a reliable building environment, either a container like we have on Linux or at least a build agent like we do with MacOS.
