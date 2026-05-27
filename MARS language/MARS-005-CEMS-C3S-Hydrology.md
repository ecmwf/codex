# MARS Language Decision Record 005: CEMS and C3S hydrology data in MARS 

## Status
[~~Proposed~~ | **Accepted** | ~~Deprecated~~ | ~~Superseded by [ADR-XXX]~~]

## Last Updated
2025-05-19

## Context

CEMS and C3S hydrological data are produced with different hydrological models which are driven by different atmospheric model and observational data.
The layout of the current way hydrological data is archived will change. In CEMS, the different hydrological versions for the European and the global domain go into different streams under class ce. The new layout has four distinct classes for the European CEMS / C3S and the global counterparts.
The hydrological model in the current layout is indexed using the ‘model’ keyword. This new proposed layout will also use the model keyword for indexing the hydrological model. One problem with the existing layout is that different model configurations used for producing the climatologies were referenced through the keyword date, which caused overwriting issues with the reforecast data. Therefore, the proposal includes introducing a new MARS keyword, configuration, which specifies not only the model version but also additional information about the setup. This configuration keyword is intended to be used only for the hindcasts as for all other data, there is no overlapping of different configurations at the same point in time.
Examples of different configurations used in CEMS and C3S are:
* v1, v4
* v1-c3s-e_catchment
* v1-c3s-e_grid
* v1-c3s-ww

The hydrological data are driven by different atmospheric data. In the old layout this was specified by the origin mars keyword, e.g., origin=ecmf/edwz/cosmo. As for ECMWF forcings will include IFS as well as AIFS, origin=ecmf is no longer sufficient to distinguish between the two models. With the specific post-processing templates, we are using in GRIB2 to encode the data, it is possible to distinguish the data and a string can be created like for example ecmf_ifs or ecmf_aifs. In general, this follows the format "centre_model", which provides more information than the current origin key.
For this reason, we propose introducing a new MARS keyword called ‘forcing’, which would more accurately represent the model used to produce the data.


### Options Considered

We propose introducing two new MARS keywords.
The configuration keyword stores information about the model version and the current runtime setup within a single key. The second proposed keyword, forcing, combines the centre identifier with the modelName to describe the data used to drive the hydrological model.
This distinction is required to differentiate between AIFS and IFS at ECMWF, as well as between the COSMO and ICON models at DWD, which is not possible using the existing origin keyword alone.


### Analysis

We did not consider other options than option 1.

## Decision
The hydrology data will be archived under the following MARS classes:

| MARS class        | Name                                   |
|:-----------------:|:---------------------------------------|
| ef                | EFAS (European flood awareness system) |
| gf                | GLOFAS (Global flood awareness system) |
| eh                | C3S European hydrology                 |
| gh                | C3S Global hydrology                   |

A MARS key forcing will be introduced which will get values like
* ecmf-ifs
* ecmf-aifs
* ecmf-era5
* ecmf-seas
* edzw-icon
* cosmo-cosmo
* cmcc-sps
* obs

This is the centre abbreviation dash the modelName. A configuration key will be introduced as well but only used in stream rfsd. It will contain the following values:
* v1.0
* v1.0-catchment
* v1.0-grid
* v1.0-c3s
* v2.0
* v2.1
* v3.0
* v3.1
* v3.5
* v4.0
* v5.0


### Related Decisions

## Consequences
The data will be stored in newly created MARS classes, ensuring that existing datasets remain unaffected, except for the hydrology data, which will be rearchived within the new layout.
The forcing and configuration MARS keywords are also applicable in other contexts. For example, the fire datasets are based on ERA5 and IFS medium-range forecasts. The configuration keyword can likewise be applied to the land data assimilation system, which operates with different model versions running in parallel to support multiple target forecasting systems that rely on this data as input.

## References

## Authors
- Sebastien Villaume
- Robert Osinski
- Mohamed Azhar

