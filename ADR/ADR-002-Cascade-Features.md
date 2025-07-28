# Architectural Decision Record 002: Cascade Features

## Status
[<s>Proposed</s> | **Accepted** | <s>Deprecated</s> | <s>Superseded by [ADR-XXX]</s>]

## Last Updated
2025-07-28

## Context

Cascade is a workflow scheduling and execution system, a component within the wider Earthkit Worflows framework, used for example in the Forecast in a Box project.

This record captures the decision making of the initial feature set and design, in particular justifying the need to write such system in the first place, as opposed to reusing some existing open-source one.

### Options Considered

We considered using Dask and analyzed it in greater detail.
We were aware of other solutions like Ray, Daft, Spark; but didn't thorougly analyse them due to resource constraints as well as assumed similarity to Dask.

### Analysis

A thorough analysis and outcome are presented in [the project's repository](https://github.com/ecmwf/earthkit-workflows/blob/00c50b92281476537f4d83931f10679365826758/docs/cascadeFeatures.md).

## Decision

We chose to implement a custom solution, tailoring it to specific workflow characteristics of running AIFS models and pprocing their outputs.

We don't maintain any compatibility, feature parity or interoperability with Dask -- it would be too restricting and performance-degrading.
However, Dask DAGs which are simple enough should be easily convertible to Cascade, and we will explore such option.

We maintain execution-independent information-rich representation of both Earthkit Workflow DAG and schedule, to possibly replace Cascade with a different execution/scheduling engine -- regardless whether in-house or open source.

### Related Decisions

We purposefully don't implement a resource negotiator inside Cascade, as we don't expect any unique needs of this kind.
Instead, we rely on external one (currently Slurm, eventually Troika), and only expect a thin wrapper to invoke the resource negotiation and bootstrap Cascade processes.

For workflow executors, there is always the question whether the workflows themselves are aware of the executor, tightly coupled to it.
We chose a middle path -- we implement lightweight adapters (organized in a plugin fashion) for each class of workflow elements.
For example, individual Anemoi or PProc functions are oblivious of Cascade, but there exists Earthkit-Workflows-Anemoi and Earthkit-Workflows-Pproc which wrap anemoi runners or pproc pipelines in a Cascade-compatible fashion.
Those are exposed to the user in a fluent-style API.
This is additionally only thinly coupled to Cascade -- thus Cascade can execute workflows declared without fluent/plugin API, and vice versa we could implement a different executor for those fluent-declared objects.

## Consequences

It required a few manmonths of investment -- though not more than initially expected, and not order-of-magnitude more than an adapter to Dask would have required.

We obtained expected performance gains, mostly on the scale of "would not work at all in other solutions, but works here".

Volume of the new codebase is roughly as expected, similary for the resulting modularity.

In the case of the scheduler module seeing enough future requirements and development, we expect further modularization and codebase separation along that front.

## References

* [Earthkit Workflows](https://github.com/ecmwf/earthkit-workflows)
* [Forecast in a Box](https://github.com/ecmwf/forecast-in-a-box)

## Authors

- Vojta Tuma
