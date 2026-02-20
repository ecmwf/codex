# Architectural Decision Record 004: Building Cascade

## Status
[<s>Proposed</s> | **Accepted** | <s>Deprecated</s> | <s>Superseded by [ADR-XXX]</s>]

## Last Updated
2025-07-28

## Context

Cascade is a workflow scheduling and execution system, a component within the wider Earthkit Workflows framework, used for example in the Forecast-In-A-Box project.

This record captures the decision making of the initial feature set and design, in particular justifying the need to write such system in the first place, as opposed to reusing some existing open-source one.

### Options Considered

Firstly, we considered using Dask as a comprehensive offering, and analyzed it in greater detail.
Other Dask-like solutions like Daft or Spark were not analysed thoroughly -- while they are presumably more performant than Dask in certain cases, the top level design and intent is very similar, and thus arguments again Dask apply equally. 
Another possible option was Ray, which is has a less restrictive model than Dask, but based on a shallow analysis of its performance and ease of extensibility, we opted not to explore it further.

After deciding to go with an in-house solution, we assessed multiple features and made a decision for each of them.

### Analysis

There are multiple options of utilizing Dask:
1. as-is, accepting performance downsides and lack of features,
2. utilize selected internals while pluging in our own frontends/backends where needed,
3. extending Dask itself with what we were missing.

The option 1 was deemed unacceptable -- at the least, we need efficient memory sharing between concurrent computing entities as well as generator-like semantics for task outputs.
Neither is possible in vanilla Dask.
Memory sharing is important because some of our computations allow for concurrent processing on top of the same data -- Dask-like engines approach computations by breaking down data into independent partitions and then computing on each concurrently in isolation. But our data cannot often be partitioned -- for example, geographical data are inherently two dimensional and computations happen on overlapping regions. Addressing that in naive Dask-like approach would require data duplication or concurrency limitation.
Similarly, generator-like semantics is crucial because our models often output forecasts in steps -- they produce 6h ahead, then 12h ahead, then 16h ahead, ... But many subsequent processing steps require only a single step as input, that is, post-processing of 6h-ahead can start while 12h-ahead is being produced. In a naive Dask-like approach, there would be a single node producing all outputs altogether after the last step is finished, needlessly prolonging the overall job duration and limiting concurrency.

The option 2 would enable us to address the aforementioned missing features, but after analysing Dask internals, architecture, structure, it would mean a large upfront cost, as well as ongoing investments due to Dask internals obviously evolving and presumably diverging.

The option 3 is, given the ratio of Dask popularity to Dask maintainer time (1k+ issues, 200+ open PRs at the time of writing) and Dask generality, not compatible with our need to deliver something in a reasonable time.

The options 1-3 would allow us to re-use all existing Dask features, but we concluded there isn't that much to it.

A relevant analogy is usage of Dask-like frameworks in training of ML models in different domains.
Data processing is often done in Dask, because of partitionable nature -- but the training itself, given its iterative nature, is not.
Ray is presumably the only contender, especially given its popularity in Reinforcement Learning, which often comes with specific computation plans.
However, benchmarks and experiments we have done in other contexts made us believe tweaking Ray would be too complicated.

Analysis of individual features we were considering for implementation is thoroughly exposed in [the project's repository](https://github.com/ecmwf/earthkit-workflows/blob/00c50b92281476537f4d83931f10679365826758/docs/cascadeFeatures.md).

## Decision

We chose to implement a custom solution, tailoring it to specific workflow characteristics of running AIFS models and processing their outputs using PProc framework.

We don't maintain any compatibility, feature parity or interoperability with Dask -- it would be too restricting and performance-degrading.
However, as Dask DAGs are simple enough, we have developed a convertor to Cascade, and most likely will be able to maintain it, although this is not required.

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

It required about 3 manmonths of investment to deliver a basic version of Cascade -- though not more than initially expected, and not order-of-magnitude more than an adapter to Dask would have required.
We then invested further to obtain better performance of the scheduler -- in a continual fashion, as we kept discovering exploitable properties of our workflows, such as fusing.
Similarly, as we discovered originally unknown constraints such as gang scheduling, we implemented accordingly, benefiting from having an in-house codebase.

We obtained expected performance gains, mostly on the scale of "would not work at all in other solutions, but works here".
For comparison/migration, we maintain the option to execute Dask graphs in Cascade.

Volume of the new codebase is roughly as expected, similarly for the resulting modularity.

In the case of the scheduler module seeing enough future requirements and development, we expect further modularization and codebase separation along that front.

## References

* [Earthkit Workflows](https://github.com/ecmwf/earthkit-workflows)
* [Forecast-In-A-Box](https://github.com/ecmwf/forecast-in-a-box)

## Authors

- Vojta Tuma
