# Architectural Decision Record 004: Storing of MeteoSwiss ICON Grid Definition Files

## Status
[**Proposed** | <s>Accepted</s> | <s>Deprecated</s> | <s>Superseded by [ADR-XXX]</s>]

## Last Updated
2026-02-03

## Context

Polytope and FDB use the `eckit::geo` library to extract and retrieve forecast data defined on the ICON native grid. ICON grids are fully unstructured, and their definition consists of large files describing cell centres, connectivity, and associated metadata. These grid definition files are required at runtime in order to correctly interpret and access forecast data.

Due to their size, these grid definition files complicate software distribution, deployment, and operational maintenance.

At MeteoSwiss, Polytope and FDB are deployed to provide production access to forecasts produced on ICON grids. Only a small number of ICON grids are used operationally, but they are critical to production services and therefore have strict availability, stability, and maintainability requirements.

In the current setup, grid definition files are retrieved from ECMWF-hosted web
services at runtime. This introduces a dependency on the availability of external services, which can directly impact MeteoSwiss service uptime. Reducing or removing this dependency is required to minimise operational downtime and improve overall service robustness.

This ADR is limited to centrally defined operational ICON grid definitions.
User-defined or client-side grids used for research purposes are explicitly out of scope, as no strategy currently exists for their identification, labelling, or lifecycle management.


## Decision Drivers

- High operational reliability
- Reduced interdependency between MeteoSwiss and ECMWF services
- Clear operational ownership of grid definitions
- Maintainable and predictable grid lifecycle management

## Options Considered

### Option 1: Pull grid definition files from ECMWF web services (current implementation)

Grid definition files are hosted by ECMWF and downloaded on demand at runtime.

#### Benefits
- Authoritative source centrally maintained by ECMWF
- Updates and corrections available immediately
- Simple client-side implementation

#### Drawbacks / risks
- Runtime dependency on ECMWF service availability
- Potential impact on MeteoSwiss service availability
- External traffic and cost implications
- External service is not covered by MeteoSwiss monitoring
- Changes to the API of the external service need to be coordinated with software releases to ensure operational continuity

---

### Option 2: Package grid definition files inside the application container image

Grid definition files are bundled into the application container image and accessed locally at runtime. The source location of the grid files is configurable, with the default defined at build time.

#### Benefits
- No runtime dependency on ECMWF infrastructure
- Predictable behaviour and fast local access
- Simple operational model

#### Drawbacks / risks
- Increased container image size
- Grid updates require rebuilding and redeploying images
- Build time dependency on the external (ECMWF) service

### Option 3: Mirror grid definition files into a MeteoSwiss-managed object store

Grid definition files are mirrored from ECMWF into a MeteoSwiss-managed object store (e.g. Nexus), and Polytope deployment at MeteoSwiss is configured to fetch operational grid definitions from this mirror.

#### Benefits
- Removes runtime dependency on ECMWF services
- Centralised management of grid definition files
- Grid updates independent of application rebuilds
- Clear operational ownership within MeteoSwiss infrastructure

#### Drawbacks / risks
- Requires reliable synchronisation between ECMWF and the mirror
- Risk of serving outdated or inconsistent grid definitions if synchronisation fails
- Additional operational overhead to operate and monitor the mirror
- Changes in `eckit::geo` may be required to support configurable grid sources
- Requires a client-side caching strategy to avoid repeated downloads and reduce load on the mirror

### Cross-cutting concern: caching of grid definition files

All options involving remote access to grid definition files benefit from client-side
caching. Caching influences operational impact but is not a primary decision driver.
---

## Analysis

Option 3 provides the most suitable long-term operational characteristics for
MeteoSwiss production use. By removing the runtime dependency on ECMWF services
and centralising grid definition management within MeteoSwiss infrastructure,
it improves availability, operational control, and maintainability for
operational ICON grids.

Options 1 and 2 do not fully satisfy MeteoSwiss operational requirements.
Option 1 introduces a runtime dependency on external services, while Option 2
tightly couples grid updates to application build and deployment cycles.

Option 3 was discussed with James H. during the MeteoSwiss/ECMWF sync. Open points
remain regarding its implementation, in particular:
1. how synchronisation between the ECMWF source and the MeteoSwiss mirror should
   be implemented (e.g. periodic polling or event-based updates),
2. how grid source configuration and overrides should be handled in `eckit::geo`
   for operational use.

These points must be clarified before the implementation of Option 3 is finalised.

This decision applies to the Polytope and FDB deployments operated at MeteoSwiss.
Users of earthkit outside the MeteoSwiss network do not have access to the
MeteoSwiss-managed object store and will continue to retrieve ICON grid definition
files from ECMWF-hosted services. For these use cases, caching of grid definition
files is required (if not already implemented) to mitigate the load on the external service.

## Decision

The decision is pending resolution of the open implementation questions identified in the Analysis section.

## Consequences

- Improved operational reliability for production services
- Clear ownership of grid definition files within MeteoSwiss
- Additional operational responsibility for maintaining the mirror infrastructure

## Authors

- Nina Burgdorfer (MeteoSwiss)
- Christian Kanesan (MeteoSwiss)
