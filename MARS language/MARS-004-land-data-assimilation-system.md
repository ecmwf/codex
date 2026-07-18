# MARS Language Decision Record 004: Land Data Assimilation System (LDAS)

[~~Proposed~~ | **Accepted** | ~~Deprecated~~ | ~~Superseded by [ADR-XXX]~~]

2026-06-29

## Context

The Land Data Assimilation (LDAS) system provides initial conditions of land surface parameters
for the different forecasting systems which run on different time scales and model resolutions.

LDAS will run in research as well as operationally. Target forecasting systems which need LDAS
initial conditions are the medium-range (MR), the sub-seasonal to seasonal (s2s) and the seasonal
forecasting (SEAS) systems. In operational and some research configurations, LDAS data are
produced as a near-real-time (NRT) product as well as a behind-real-time-product (BRT), both of
which need to be distinguished. Data are needed in the FDB and will be archived in MARS.

Data from LDAS include analysis values and forecast values (e.g. surface fluxes). Analysis and
forecast values for a given valid time will exist for the BRT and for the NRT at multiple lead
times. The BRT will typically run each day covering the period up to 3 days previous. The NRT
will run daily with a 5-day spinup and will be initialised from the BRT product. Additionally,
diagnostic statistics such as monthly means will be produced at the end of each calendar month.

Operational configurations will run in parallel for each of MR, S2S and SEAS. The BRT component
will include a reanalysis covering at least the previous 20 years. Different IFS cycles will typically
(but not always) require a new reanalysis, so we need to distinguish re-analysis data produced with
the same valid date for different IFS cycles as well as the different target forecast configurations.
Upgrades of LDAS do not necessarily follow the release timeline of IFS cycles meaning that a newer IFS
cycle still might use the LDAS system from the previous cycle/s. However, data volumes are very small
and it would be possible to re-archive the data from a previous cycle with revised metadata to be
consistent with a new cycle, this would be a matter for those configuring and running the operational
suites and does not affect the design of the archive.


### Options Considered

 1. Operational data are stored under `class=od`, and research data under `class=rd`. This enables
    us to use the same data layout and MARS requests for both operational and research data. Stream
    `ldas` will be created and is used for the instantaneous / high-frequency output and stream
    `ldst` for derived statistics. The distinction between behind-real-time (BRT) and near-real-time
    (NRT) is made using a new mars keyword `mode`, and data with different lead times in NRT mode will
    be distinguished using `anoffset`. The different target forecasting systems and the analysis
    producing cycle of the LDAS system are indexed in the mars key `configuration` which will be
    introduced for the hydrological data as well. The value of this key will be constructed of the
    form `<model-cycle>-<target model>`, using the value `MR` for medium range, `s2s` for the extended
    range, and `seas` for the seasonal system. An example of the `configuration` is `50r1-s2s`. 

 2. The same approach as (1), but instead of labelling the target forecasting system with `MR`,
    `s2s` and `seas`, the MARS `stream` to which the target forecasting system belongs is used
    instead. i.e. `enfo` for the medium-range, `eefo` for the sub-seasonal and `mmsf` for the
    seasonal systems. This would give `configuration values such as `50r1-enfo/50r1-eefo/50r1-mmsf`. 

 3. Create a new class `ld` for `ldas`, and use the same stream as that of the target forecasting
    system (`enfo/eefo/mmsf`).

 4. Similar to option 1. In operations/research, `class=od/rd` are used respectively. Two separate
    streams are created instead of introducing a new key to distinguish `BRT/NRT`. To archie
    statistics of the LDAS fields, two additional statistical variants of these streams are created.

### Analysis

We considered introducing a new class `ld` for ldas operational data, but this would require an
alternative solution for research data. This would either complicate life for everyone by structuring
data differently, or require a complex separation of both research and operational data within
`class=ld`. By contrast, introducing new streams for the instantaneous and derived `ldas` / `ldst`
statistics allows us to have the same layout under `class=od` and `rd`, and even for member state
data if required in the future. It avoids relying on specific `expver` ranges reserved for
research experiments, and facilitates a clean introduction of the required MARS keywords under
the new streams.

The same challenges of distinguishing between different model configurations exist in this case
as for that of hydrological data (see MARS-005), and it makes sense to introduce and use the same
keyword and language structure, `configuration`, for this purpose. The structure of the
configuration keyword should be similarly dash-delimited. Using the `configuration` keyword in
the same way will enhance the consistency of MARS.

It was considered that using the names of the streams (`enfo/eefo/mmsf`) in the `configuration`
string might be more stable and less ambiguous than a “name” of the relevant forecast configuration
(such as `mr/s2s/seas`), since the preferred names of our forecast systems have been changed 
several times in recent years (e.g. ENS>MR, EXT>SUBS>S2S) and may change again going forward.

## Decision

Option 4 is the most appropriate way to archive LDAS data. It has the advantage that research and
operations are handled in the same way.

Four new mars streams will be created for the land data assimilation system. As there is at the
moment only a distinction needed into a near-real-time and a behind-real-time configuration and
as it is also unlikely that there will be more options, the stream names include this distinction
rather adding an additional key in MARS with only two possible options. Two streams will be created
for the statistics of the near-real-time and behind-real-time ldas data. The four streams will be
the following:

| Stream mars abbreviation | Stream name |
|:------------:|:-------------|
| `ldas` | Land data-assimilation system (near real time)|
| `ldbt` | Land data-assimilation system behind real time |
| `ldst` | Land data-assimilation system statistics (near real time) |
| `ldsb` | Land data-assimilation system statistics behind real time |

The target forecasting system as well as the cycle of the LDAS system will be specified in the MARS
key `configuration` using the format `<cycle>-<stream>` corresponding to the target system. It
will contain entries such as:

 - `49r2-sfdd`
 - `50r1-oper`
 - `50r1-enfo`
 - `50r1-sfdd`
 - `50r2-oper`
 - `50r2-enfo`
 - `50r2-sfdd`

`anoffset` is included in the MARS namespace for the near-real-time case and absent in the
behind-real-time case. The MARS key `timespan` is used and the MARS key `stattype` is also
used in the statistical streams `ldst` and `ldsb`. This allows the archiving of monthly
and daily statistics, and using the `time` keyword also enables monthly synoptic statistics.

### Related Decisions

 - [MARS-005 CEMS C3S Hydrology](MARS-005-CEMS-C3S-Hydrology.md) - This decision is in
   line with the implementation for hydrological data.

## Consequences

The data will be completely new in MARS. SEAS6 will require LDAS data to provide land initial
conditions, so a prompt implementation is needed to avoid delays.

## References

## Authors

 - David Fairbairn
 - Jonathan Day
 - Robert Osinski
 - Sebastien Villaume
 - Tim Stockdale
 - Simon Smart
