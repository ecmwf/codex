# Architectural Decision Record 004: Storing of Grid Definition Files

## Status
[**Proposed** | <s>Accepted</s> | <s>Deprecated</s> | <s>Superseded by [ADR-XXX]</s>]

## Last Updated
2026-01-20

## Context

The `eckit::geo` library used by Polytope and FDB at ECMWF implements support for the ICON native grid as a fully unstructured grid for forecast data extraction and retrieval. The definition for the grid consists of the list of cell centers and related metadata. This results in large grid definition files, which complicate software distribution and operational maintenance. The goal of the current ADR is to explore options that would help mitigate or eliminate these downsides.

At MeteoSwiss, Polytope and FDB are used to access forecasts produced on the ICON unstructured grid. In addition to the operational grid, there is a need to support additional research grids alongside it. This raises questions about efficient representation of ICON grids and about where operational and research grid definitions should be stored and managed.

This ADR distinguishes between two categories of ICON grid definitions:

- **Operational (OPR) grids**
  Grids used in production operations, with availability and stability requirements. For MeteoSwiss operations, only two grids fall into this category.

- **Custom (research) grids**
  User- or project-specific grids used for research and experimentation, with more flexibility.

The following analysis evaluates storage options separately for these two use cases.

### Decision drivers
- Operational reliability without runtime dependency on ECMWF services
- Support for both operational and research user-provided ICON grids

### Options Considered

#### Option 1: [current implementation] pull the grid definition files from ECMWF sites web service
The current solution implemented by ECMWF is to host the grid definition files on a web service and to download the files as required by the users.

##### Benefits
- Authoritative source: Grid definitions are centrally maintained by ECMWF, ensuring consistency.
- Always current: updates and corrections are available immediately without local action.
- Simpler clients: Rely on a standard service rather than custom logic

##### Drawbacks / risks
- Introduces a dependency on ECMWF service availability. In a high-availability context, any ECMWF downtime could directly impact service uptime.
- Operations related to MeteoSwiss would incur potentially significant costs (traffic) on the ECMWF infrastructure.
- Adding research grids needs to be coordinated with the ECMWF resulting in additional bureacratic overhead
- Operational state of the service depends on an external service provider which is not covered by the monitoring platform and results in an overall system which is more difficult to operate
- Changes to the API of the external service need to be coordinated with software releases to ensure operational continuity

#### Option 2: Put the grid definition files inside the container image

Ship the required ICON grid definition files inside the container image used by MeteoSwiss applications, so no download from ECMWF is needed at runtime.
The source location of the grid files is configurable, with the default defined at build time.

#####  How it works
- During image build, copy a curated set of grid definition files into the image (e.g., under /opt/grids/...).
- Configure eckit::geo (or wrapper code) to look for grid definitions locally first.
- Alternative: eckit::geo implements a caching mechanism that is prepopulated at build time.

##### Benefits
- No runtime dependency on ECMWF infrastructure (uptime + cost risk eliminated).
- Very fast at runtime (local reads).

##### Drawbacks / risks
- Image size increases (build/pull time, registry storage).
- Updating grid files requires rebuilding and redeploying images.

#### Option 3: Mirroring object store
Mirror ECMWF sites to a MeteoSwiss-managed object store (Nexus) and configure Polytope to fetch grid definition files from the mirror.
This option can support both operational (OPR) and custom (research) grids, with open questions regarding configuration and update policies for each use case.


##### Benefits
- Reduced runtime dependency on ECMWF infrastructure; availability and cost risks are bound to MeteoSwiss infrastructure.
- Grid updates do not require application rebuilds, enabling independent grid lifecycle management.


##### Drawbacks / risks
- Synchronisation requirement between ECMWF and the mirror.
- Risk of serving outdated or inconsistent grid definitions if synchronisation fails.
- Additional operational overhead to operate and monitor the mirror.
- Changes in `eckit::geo` may be required to support configurable grid sources.
- Caching strategies may be needed to reduce load on the mirror.


### Analysis
Option 3 appears to offer the best long-term maintainability by removing the runtime
dependency on ECMWF services and centralising grid management within MeteoSwiss
infrastructure. This applies to both operational (OPR) and custom (research) grids,
provided appropriate configuration and controls are defined.

This option was discussed together with James H. during the MeteoSwiss/ECMWF sync.
Open points remain regarding its implementation, in particular:
1. how synchronisation between the ECMWF source and the mirror should be implemented
   (e.g. periodic polling or event-based updates),
2. how grid source configuration and overrides should be handled in `eckit::geo`, for OPR and research grids.

[] TODO Discuss details of points 1) and 2) with Pedro M. and Mathilde L. and document
the agreed approach for Option 3.



[ ] Compared options against relevant criteria (cost, performance, maintainability, risk, etc)  
[ ] Explained trade-offs and their implications
[ ] Referenced any prototypes, benchmarks, or research conducted (if applicable)  
[ ] Considered both immediate and long-term impacts

## Decision
[ ] Stated the chosen option (clearly and unambiguously)
[ ] Avoided implementation details (unless crucial to understanding the decision)
[ ] Included any conditions or limitations on the decision

### Related Decisions
[ ] Referenced other ADRs that influenced or are influenced by this decision  
[ ] Noted any decisions this ADR modifies or supersedes  
[ ] Considered impacts on existing architectural patterns  
[ ] Referenced ECMWF previous decisions that may be relevant but not documented as ADRs

## Consequences

[ ] Listed both positive and negative expected outcomes (if applicable)
[ ] Included impacts on performance, maintainability, team productivity, operations, etc
[ ] Noted any new risks introduced or mitigated
[ ] Considered implications for future decisions

## References

[ ] Linked to any relevant documents, discussions, or resources that informed the decision  
[ ] Included links to related ADRs, design documents, or external references

## Authors

- Nina Burgdorfer (MeteoSwiss)
- Christian Kanesan (MeteoSwiss)
