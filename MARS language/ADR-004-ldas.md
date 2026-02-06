# Architectural Decision Record 001: CEMS and C3S hydrology data in MARS 

## Status
[**Proposed** | <s>Accepted</s> | <s>Deprecated</s> | <s>Superseded by [ADR-XXX]</s>]

## Last Updated
2026-02-05

## Context
The Land Data Assimilation (LDAS) system provides initial conditions of land surface parameters for the different forecasting systems which run on different time scales and model resolutions.

LDAS will run in research as well as operationally. Target forecasting systems which need LDAS initial conditions are the medium-range (MR), the sub-seasonal to seasonal (s2s) and the seasonal forecasting (SEAS) systems. In operational and some research configurations, LDAS data are produced as a near-real-time (NRT) product as well as a behind-real-time-product (BRT), which need to be distinguished. Data are needed in the FDB and will be archived in MARS.

Data from LDAS include analysis values and forecast values (e.g. surface fluxes). Analysis and forecast values for a given valid time will exist for the NRT time and for the BRT at multiple lead times, since the BRT will typically run each day covering the period from 5 days previous. Additionally, diagnostic statistics such as monthly means will be produced at the end of each calendar month.

Operational configurations will run in parallel for each of MR, S2S and SEAS. The BRT component will include a reanalysis covering at least the previous 20 years. Different IFS cycles will typically (but not always) require a new reanalysis, so we need to distinguish re-analysis data produced with the same valid date for different IFS cycles as well as the different target forecast configurations. Upgrades of LDAS do not necessarily follow the release timeline of IFS cycles meaning that a newer IFS cycle still might use the LDAS system from the previous cycle/s. However, data volumes are very small and it would be possible to re-archive the data from a previous cycle with revised metadata to be consistent with a new cycle, this would be a matter for those configuring and running the operational suites and does not affect the design of the archive.


### Options Considered
1.	Data go under class od for the operational data and class rd for research data. This allows to have the same data layout in MARS for operational and for research data. Stream ldas will be created and is used for the instantaneous / high-frequency output and stream ldst for derived statistics. The distinction of behind-real-time (BRT) and near-real-time (NRT) is done using a new mars keyword mode, and data with different lead times in BRT mode will be distinguished using anoffset. The different target forecasting systems and the analysis producing cycle of the LDAS system are indexed in the mars key configuration which will be introduced for the hydrological data as well. The value of this key will be a concatenated string with first the model cycle of the LDAS analysis system and then the target model with MR for medium range, s2s for the extended range, and seas for the seasonal system.
An example of the configuration is “50r1_s2s”. 

2.	Basically, the same approach as 1., but instead of labelling the target forecasting system with MR, s2s and seas, the MARS stream to which the target forecasting system belongs is used. So enfo for the medium-range, eefo for the sub-seasonal and mmsf for the seasonal system. Examples are configuration=50r1_enfo / 50r1_eefo / 50r1_mmsf. 

3.	This option is to create a new class ld for ldas, and to use the same stream as that of the target forecasting system (enfo/eefo/mmsf).

### Analysis
It was discussed to include a new class ld for ldas operational data, but we would need either a different solution for research data, which complicates life for everyone, or else a complicated solution for safely separating operational and research data in class=ld. Using new streams for the instantaneous and derived ldas / ldst statistics allows to have the same layout under class od and rd, and even member state classes should that be required in the future. It avoids relying on specific expver ranges reserved for research experiments, and allows a clean introduction of the required mars keywords under the new streams.

For hydrology data, a similar need for distinguishing different model configurations exists and it was agreed to introduce a new mars key configuration for this purpose.
The configuration key is ideally suited for the present use case as well and re-using it will enhance the consistency of mars.

It was considered that using the names of the streams (enfo/eefo/mmsf) in the configuration string might be more stable and less ambiguous than a “name” of the relevant forecast configuration (such as mr/s2s/seas), since the preferred names of our forecast systems have been changed several times in recent years (e.g. ENS>MR, EXT>SUBS>S2S) and may change again.


## Decision



### Related Decisions

## Consequences
The data will be completely new in MARS. SEAS6 will require LDAS data to provide land initial conditions, so a prompt implementation is needed to avoid delays.

## References

## Authors
