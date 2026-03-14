# Testing

TODO: Guidelines for unit, integration and regression testing, and for test suites for services

## Test Data

Various tests in testing repositories require fixed datasets. This data should be made available
by static web hosting at ECMWF. Data should be stored in a Data Repository, hosted in the ECMWF
[sites infrastructure](https://sites.ecmwf.int). This data is made available at a url matching
`https://sites.ecmwf.int/repository/<package-name>/test-data/<path>`.

Data can be uploaded to the test repository via the web interface, located at
`https://sites.ecmwf.int/repository/<package-name>/s/admin/files/`. There are other interfaces
(CLI, python, REST) available according to [the documentation](https://confluence.ecmwf.int/display/UDOC/Website+as+Data+Repository).

For any new packages, the 
[linked instructions](https://confluence.ecmwf.int/display/UDOC/Website+as+Data+Repository)
should be followed to create a new package data repository. Once created, you will need to
request that the data repository be made public, in the repository settings, and then contact
the administrators in Computing to request an expiry period for the data which is longer
than 1 year.

Ecbuild contains support to directly access test data in an efficient manner. The macro
`ecbuild_get_test_multidata`

```
ecbuild_get_test_multidata(
        TARGET <target-name>
        NAMES <file1> [ file2 ... ]
)
```

This will retrieve a file with the path `<current-dir-in-repo>/<filename>` from the relevant data
repository. Any tests which make use of this data should depend on `<target-name>`.
