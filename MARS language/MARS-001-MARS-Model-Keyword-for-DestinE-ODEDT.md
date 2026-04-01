# MARS Language Decision Record 001: MARS Model Keyword for DestinE ODEDT (DE330)

[~~Proposed~~ | **Accepted** | ~~Deprecated~~ | ~~Superseded by [ADR-XXX]~~]

# Last Updated

10.03.2026

# Context

### Background

The on-demand-extremes-dt routinely runs multiple models covering the same period, such as different NWP models (ALARO, AROME, HARMONIE-AROME) as well as several impact models (AQ, Hydrology, renewables, wildfire etc.).

Thus, an additional axis is needed to cope with several models running with all other mars metadata identical. To this end we would introduce the model keyword to the on-demand-extremes-dt data index, as has been introduced in other datasets and contexts such as class=ai. We would add the model keyword in the same way here. Thus this represents a consistent approach in-line with other datasets.

Values in ecCodes are currently as follows, but would be extended as the impact models become known and well formed ( `localConcepts/destine/modelNameConcept` ):

- IFS
- AIFS
- ICON
- ALARO
- AROME
- HARMONIE-AROME
- \<air-quality-impact-model\> (to be updated with value from DE330)
- \<hydrology-impact-model\> (to be updated with value from DE330)
- \<wildfire-impact-model\> (to be updated with value from DE330)
- …

### MARS archiving approach

MARS namespace:

<pre><code>{
  "messages": [
    {
      "date": 20260211,
      "time": 1200,
      "expver": "0001",
      "class": "d1",
      "dataset": "on-demand-extremes-dt",
      "georef": "u23er4",
      "type": "fc",
      "stream": "oper",
      "step": 6,
      "levtype": "sfc",
      <strong>"model": "HARMONIE-AROME",</strong>
      "timespan": "none",
      "param": 167
    }
  ]
}
</code></pre>

# Options Considered

### 1. Include model key

We believe this key is necessary to index data coming from different models within the on-demand Extremes DT project.

# Analysis

- Prototype at: [text](https://github.com/ecmwf/eccodes/tree/feature/ECC-2222-model-for-de330)
- This has been introduced in other datasets such as class=ai. We would add the model keyword in the same way here. Thus this represents a consistent approach in-line with other datasets.

# Decision

Meeting was held on 06/03/2026 to discuss the proposal with:

- Simon Smart
- Emanuele Danovaro
- Seb Villaume
- Robert Osinski
- Bojan Kasic

Following up meeting to confirm with User Services with:

- Paul Dando
- Bojan Kasic

Everyone was happy with the proposal. We will proceed with the implementation.

# Consequences

- ecCodes development to add model keyword to indexing namespace for on-demand-extremes-dt data
- metkit development to add new values of model keyword to language file.

# References

# Authors

- Matthew Griffith
- Sebastien Villaume
- Robert Osinski
