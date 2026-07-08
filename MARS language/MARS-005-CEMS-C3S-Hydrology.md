# MARS Language Decision Record 005: CEMS and C3S hydrology data in MARS 

[~~Proposed~~ | **Accepted** | ~~Deprecated~~ | ~~Superseded by [ADR-XXX]~~]

## Last Updated

2026-06-20

## Overview

CEMS and C3S hydrological data are produced by multiple different hydrological models, and these runs are driven
by different atmospheric model and observational data. Users need to be able to identify data along these two
axes.

Currently the way that hydrological data are archived is problematic. Firstly, currently this data is indexed
according to the generating model, using the `model` keyword, but this does not contain any information about
the configuration or version of the model. For reforecast data, the same date is reforecast on multiple
occasions using different model versions and configurations, and this results in disambiguation issues and
potential overwriting of data.

To address this, we propose introducing an additional keyword `configuration` for hindcast data (specifically
stream `rfsd`, retrospective forcings and simulation data). Examples of different `configuration`s which
would be used in CEMS and C3S are:

 - `v1`
 - `v4`
 - `v1-c3s-e_catchment`
 - `v1-c3s-e_grid`
 - `v1-c3s-ww`

Note that outside of hindcast data, there is no overlap of different configurations for the same point in
time, and so this additional disambiguation is not necessary.

Secondly, the different atmospheric data used to force the hydrological simulation are currently identified
using the `origin` keyword, e.g. `origin=ecmf/edwz/cosmo`. With the introduction of the AIFS as well as the
IFS, using `origin=ecmf` is no longer sufficient to distinguish between all relevant forcings data. The same
issue is observed between the COSMO and ICON models at DWD. Sufficient data is present in the GRIB header
to identify this data further.

As such we propose a new MARS keyword `forcing` which will combine the originating centre and the associated
atmospheric model. The values will be construted of the form `<originating centre>-<model name>`.

Finally, we propose restructuring the overall archive. Currently in CEMS th edifferent hydrological versions for
the European and the global domains are archived into different `stream`s under `class` `ce`. We introduce instead
four distinct `class`es for the European CEMS / C3S and their global counterparts.

### Analysis

Only one option was considered.

## Decision

The hydrology data will be archived under the following MARS classes:

| MARS class        | Name                                   |
|:-----------------:|:---------------------------------------|
| `ef`              | EFAS (European flood awareness system) |
| `gf`              | GLOFAS (Global flood awareness system) |
| `eh`              | C3S European hydrology                 |
| `gh`              | C3S Global hydrology                   |

A new MARS key, `forcing` will be introduced. This key will identify the data used to drive the hydrological model,
combining a centre identifier with a model name resulting in values such as:

 - `ecmf-ifs`
 - `ecmf-aifs`
 - `ecmf-era5`
 - `ecmf-seas`
 - `edzw-icon`
 - `cosmo-cosmo`
 - `cmcc-sps`
 - `obs`

A new MARS key, `configuration`, will also be introduced for stream `rfsd` (retrospective forcings and simulation data). This
identifies the version and setup of the model producing this dataset. This will contain values such as:

 - `v1.0`
 - `v1.0-catchment`
 - `v1.0-grid`
 - `v1.0-c3s`
 - `v2.0`
 - `v2.1`
 - `v3.0`
 - `v3.1`
 - `v3.5`
 - `v4.0`
 - `v5.0`

### Related Decisions

 - [MARS-004 Land Data Assimilation](MARS-004-land-data-assimilation-system.md)

## Consequences

The data will be stored in newly created MARS classes, ensuring that existing datasets remain unaffected,
except for the hydrology data, which will be rearchived within the new layout.

The `forcing` and `configuration` keywords are also applicable in other contexts. For example, the fire
datasets are based on ERA5 and IFS medium-range forecasts. The `configuration` keyword can likewise be
applied to the land data assimilation system, which operates with different model versions running in
parallel to support multiple target forecasting systems that rely on this data as input.

## References

## Authors

 - Sebastien Villaume
 - Robert Osinski
 - Mohamed Azhar
 - Simon Smart

