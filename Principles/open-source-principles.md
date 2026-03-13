# Open Source Principles

ECMWF endorses and adopts the [United Nations Open Source Principles](https://opensource.un.org/en/news/united-nations-open-source-principles), a set of 8 guidelines that provide a framework to guide the use, development and sharing of open source software. As an intergovernmental organisation whose software underpins critical weather and climate services across its Member and Co-operating States, ECMWF recognises that open source is fundamental to our mission of advancing Earth system science for the benefit of society.

The principles below are applied to all ECMWF open source developments. Each principle is accompanied by an explanation of how it applies in the ECMWF context.

---

## 1 — Open by Default

*Making open source the standard approach for projects.*

ECMWF develops its software openly on [GitHub](https://github.com/ecmwf) by default. When we start a new project, the question is not *"should this be open source?"* but rather *"is there a specific reason it cannot be?"*. Open source development enables our Member and Co-operating States, the broader research community, and operational meteorological services to inspect, use, adapt, and build upon ECMWF software. It also allows the wider Earth system science community to benefit from, and contribute to, the tools that drive modern weather and climate prediction.

## 2 — Contribute Back

*Encouraging active participation in the open source ecosystem.*

ECMWF does not only publish its own software as open source — it also seeks to actively contribute back to the upstream projects and communities it depends on when it is reasonable to do so. When our developers fix bugs, improve performance, or add features in third-party open source libraries, those changes should be offered back upstream. We also support staff to participate in external open source communities and standards bodies, when those are within the sphere of ECMWF activities. Contribution is a two-way commitment: we benefit from the ecosystem and we invest in it.

## 3 — Secure by Design

*Making security a priority in all software projects.*

Software developed at ECMWF is deployed in operational forecasting chains, national meteorological services, and critical infrastructure. Security must therefore be considered from the outset, not bolted on later. This includes responsible management of dependencies, timely response to vulnerability disclosures, use of automated security scanning in CI pipelines, and following best practices for secrets management and access control.

## 4 — Foster Inclusive Participation

*Enabling and facilitating diverse and inclusive contributions.*

ECMWF's open source projects serve a global community spanning meteorological services, academic research institutions, and the private commercial sector. We welcome contributions regardless of organisational affiliation, geographic location, or background. This means maintaining clear contribution guidelines (see [External Contributions](../External%20Contributions)), responding constructively and politely to issues and pull requests. Inclusive participation strengthens the software and broadens the community that sustains it.

## 5 — Design for Reusability

*Designing projects to be interoperable across various platforms and ecosystems.*

ECMWF builds software that is intended to work beyond ECMWF's own infrastructure. Our tools — from data access libraries like Earthkit to ML frameworks like Anemoi — should be installable and usable on a wide range of platforms without requiring ECMWF-specific infrastructure. We favour well-defined APIs, standard data formats (GRIB, BUFR, netCDF, GeoTIFF, Zarr, etc), modular architectures, and minimal coupling between components. The [ESEE](../ESEE) design philosophy of opt-in, interoperable components is an expression of this principle.

## 6 — Provide Documentation

*Providing thorough documentation for end-users, integrators and developers.*

Good documentation is not optional — it is part of the deliverable. Every ECMWF open source project should provide, at minimum: a README that explains what the software does and how to get started, installation instructions, API or usage documentation, and contribution guidelines. Projects at higher [maturity levels](../Project%20Maturity) are expected to maintain comprehensive reference documentation. We recognise that undocumented software is, for practical purposes, unusable software, and we invest in documentation accordingly (see [Documentation and Training](../Documentation%20and%20Training)). Note that documentation is not only for end-users but also for integrators and developers who may want to build upon or contribute to the software. Clear documentation lowers barriers to entry and fosters a more vibrant and engaged community. Finally, good documentation is essential for AI Code Agents to understand and work with our software effectively, as it provides the necessary context and information for generating accurate and useful code contributions.

## 7 — RISE (Recognise, Incentivise, Support, Empower)

*Empowering individuals and communities to actively participate.*

ECMWF recognises that open source is made by people, and people need to be acknowledged and supported. Internally, this means recognising open source contributions as a valued part of a developer's work, not a side activity. Externally, it means acknowledging contributors, supporting community members through programmes like [Code for Earth](https://codeforearth.ecmwf.int/), and empowering Member and Co-operating States to become active participants and co-developers, in — not just consumers of — ECMWF software.

## 8 — Sustain and Scale

*Supporting the development of solutions that meet evolving needs.*

Open source software must be maintained to remain useful. ECMWF commits to the long-term sustainability of its key open source projects by applying clear [project maturity levels](../Project%20Maturity), communicating lifecycle status honestly, planning for transitions when projects are superseded, and resourcing maintenance alongside new development. As ECMWF's software ecosystem scales — through initiatives like ESEE, Destination Earth, and Copernicus — sustainability planning becomes ever more important. We aim to grow our open source portfolio in a way that is manageable, well-governed, and built to last.

---

## References

- [United Nations Open Source Principles](https://opensource.un.org/en/news/united-nations-open-source-principles)
- [ECMWF Software Strategy and Roadmap 2023-2027](https://www.ecmwf.int/en/elibrary/81334-software-strategy-and-roadmap-2023-2027)
- [ECMWF on GitHub](https://github.com/ecmwf)