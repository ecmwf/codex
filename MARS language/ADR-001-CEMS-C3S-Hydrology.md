# Architectural Decision Record 001: CEMS and C3S hydrology data in MARS 

## Status
[**Proposed** | <s>Accepted</s> | <s>Deprecated</s> | <s>Superseded by [ADR-XXX]</s>]

## Last Updated
2025-15-16

## Context

For CEMS and C3S, hydrological data are produced with different hydrological models which are driven by different atmospheric model and observational data.
The layout of the current way hydrological data is archived will change. In CEMS, the different hydrological versions for the European and the global domain go into different streams under class ce. The new layout has four distinct classes for the European CEMS / C3S and the global counterparts.
The hydrological model in the current layout is stored in the ‘model’ keyword. This proposed layout will also use the model keyword for the hydrological model. One problem with the existing layout is that different model configurations used for producing the climatologies were referenced through the keyword date, which caused overwriting issues with the reforecast data. Therefore, the proposal includes introducing a new MARS keyword, configuration, which specifies not only the model version but also additional information about the setup.
Examples of different configurations used in CEMS and C3S are:
* v1, v4
* v1-c3s-e_catchment
* v1-c3s-e_grid
* v1-c3s-ww

The forcing is in the old layout specified by the origin mars keyword, e.g., origin=ecmf/edwz/cosmo. 
As for ECMWF forcings will include IFS as well as AIFS. origin=ecmf is no longer sufficient to distinguish between the two models. With the specific post-processing templates, we are using in GRIB2 to encode the data, it is possible to distinguish the data and a string can be created for ecmf_ifs and ecmf_aifs, In general, this follows the format "centre_model", which provides more information than the current origin key.
For this reason, we propose introducing a new MARS keyword called ‘forcing’, which would more accurately represent the model used to produce the data.


### Options Considered

We propose two new mars keywords. The configuration keyword keeps the information about the model version and the setup running. 
The 2nd proposed key is the forcing keyword which contains the centre identifier together with the modelName. This is needed to distinguish AIFS and IFS for ECMWF, but also Cosmo and ICON.


### Analysis

We did not consider other options than option 1.

## Decision



### Related Decisions

## Consequences


## References

## Authors
- Sebastien Villaume
- Robert Osinski
- Mohamed Azhar

