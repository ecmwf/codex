# MARS Language Decision Record 008: Handling of Short Names for New `paramid`s with WMO Units

[**Proposed** | ~~Accepted~~ | ~~Deprecated~~ | ~~Superseded by [ADR-XXX]~~]

## Last Updated

2026-05-13

## Context
For some parameters, ECMWF has been providing values in units which are not the official WMO units for many years. These are typically surface parameters in units of metres or metres of water equivalent or as fractional values in the range 0-1. The WMO-standardised units for these data are kg m**-2 and % respectively.

As part of the GRIB2 migration, we intend to update and standardise these fields. As we uniquely associate a unit with a `paramid` in the GRIB parameters database, and to avoid sharp numerical changes impacting downstream users with existing MARS requests, the fields with local units and their counterparts with WMO units will carry separate `paramid`s.

There are three main categories of downstream challenges and decisions that need to be made:

**Parameter Short Names**

Parameters have corresponding short names which can be used in MARS requests, and other contexts, to identify data rather than using the `paramid` directly. Many of these short names are not unique - but for all data currently served at ECMWF it is possible to identify the short name within any MARS request as all short names are unique within *a context*. That is, in combination with other keys in the request (typically `class` and `stream`) the short name to `paramid` mapping is unique.

This latest change has the potential to break this mapping. Other than the `paramid`, *nothing* in the metadata description of the field changes. As such, if the short names are preserved the only factor determining which `paramid` is appropriate is whether the request corresponds to data from before or after the implementation date. For research data, even this is insufficient, and the corresponding MARS requests become underspecified.

The technically straightforward solution here is to enforce that each new `paramid` is assigned a new short name - which will require inventing a new set of short names (an annoying process, as in many cases the obvious ones are already in use for the existing data).

Some of the new `paramid`s are not new - see those belonging to table 228 - but have not previously been used for operational data. They have, however, been used for existing data within Destination Earth and for AI models. For these uses they have used short names which are the same as for the old `paramid`s (an example of this is `tp` which maps to both 228 and 228228). At this point it has not caused any problem mapping short names to `paramid` values as it can be disambiguated by context (e.g. `class=od` vs `class=ai`).

We note, that if the short names are preserved but the `paramid`s are not, we end up with a slightly odd situation where *some* existing MARS requests will continue to work, and some will be deprecated, for requests for exactly the same data.

**MARS Request Continuity**

There are many downstream consumers who are already consuming this data. Changes to the MARS requests have a likelihood to break downstream workflows.

There are use cases where data series are requested, which will span the implementation date of the new `paramid`s. The default solution will require downstream users to know the date of the induced discontinuity in the data, and split their workflows to request the data piecemeal across that boundary. If that can be avoided, this is beneficial. However, it is anticipated that many workflows will already need to be adjusted on this implementation date because of other changes for the GRIB2 migration.

**Data compatibility and comparison**

Users are likely to make datasets spanning the transition date, and to make comparisons between datasets using old and new conventions (e.g. between era5 and era6). For most of the changes resulting from the GRIB2 migration, this has required some boilerplate changes to the MARS requests to assemble data which is labelled differently piecewise.

This data is different -- to be scientifically comparable requires converting units and a resulting (numerical) scaling of the values. Requiring all downstream users to do this themselves is tedious and error prone.

To make this transition straightforward, it will be important to provide a mechanism for users to easily convert this data to the form they need it in.

### Prior Art
1. Winds. A previous forecast cycle (***when?***) changed the output wind fields from directional `u/v` wind components, to a vorticity/divergence (`vo/d`) representation. To support downstream users in maintaining continuity of workflows, in all cases a user may request one or both of `u/v` or `vo/d`. The underlying system will retrieve the field(s) requested, or both of the fields corresponding to the alternate representation if not, and the fields will be transformed if appropriate.

   This is widely considered to have been a poor solution for long-term maintainability. It adds significant overall complexity, and requires the front-end client language manipulation and handling behaviour to depend on inspection of what field are available in the underlying system. It also breaks a fundamental constraint that it is possible for the number of fields retrieved from storage to not match the number of fields requested, making verification more difficult.
2. Other metadata changes in the GRIB2 migration. There has been significant restructuring of field metadata in many areas. Where this has resulted in new `paramid`s the responsibility has been placed on the end consumer (with appropriate communication from ECMWF) to adjust requests to handle the new implementation, and to build piecemeal requests to bridge the discontinuity in the datasets.

### Options Considered
1. Map unique new short names for each of the new unique `paramid`s, making no additional change to the system.
2. The MARS client (and the server where necessary) could know about the mapping. For a request for either the new, or old `paramid` whichever form of the data exists could be retrieved and automatically converted to the form supplied in the request. This would follow the precedent (and similar mechanism) to the handling of winds data in `vo/d` or `u/v` forms.
    a) Mapping unique new short names for each of the new unique `paramid`s
    b) If an ambiguous short name is supplied, data is returned as archived
    c) If an ambiguous short name is supplied, a default representation is selected
3. Double archiving. The model, or post-processing of model data, could write both forms of data into the FDB and/or the archive. This could be a transitional or a permanent measure.
    a) Mapping unique new short names for each of the new unique `paramid`s
    b) If an ambiguous short name is supplied, a default representation is selected
4. Provide explicit data conversion functionality, enabling the user to select if data should be returned as archived, or in specifically the new or old representation.
    a) Mapping unique new short names for each of the new unique `paramid`s
    b) If an ambiguous short name is supplied, the data which exists is returned, with an assertion that only one form of the data is present.
    c) If an ambiguous short name is supplied, a default selection of source data is selected

### Analysis
Taking no action is not an option. If we switch the new cycle to start producing data with the new `paramid`s, then the (existing) short name to `paramid` mapping becomes ambiguous. This would mean that it would become mandatory for the user to use `paramid` values directly for accessing this data reliably, and that existing requests which use the short names (such as `tp`) would cease to work correctly.

#### 1. Unique Short Name Mapping
This approach is the simplest/most natural approach. It maintains the contextually unique mapping of short names to `paramid`s in the MARS language expansion, and as a result ensures that the old/new behaviour of the language will be the same for requests using short names as for `paramid`s.

The biggest issue with this approach is that we already have data produced in production systems (DE/AI) which use the ambiguous short names. A remapping to change this would result in systems that either need to hard code the date to support this old data, to rearchive this old data after processing, or would break access to it. Further, it would require changing user requests for unchanged data queries.

This approach provides no support to the user for identifying continuity of datasets, and no support for data conversion/rescaling to assist scientific use of the data.

#### 2. Automagical Data Conversion
There is precedent to maintaining continuity of requests for users where it is possible, scientifically and semantically, to provide continuity across discontinuities in the datasets. The most clear example of this is the handling of wind data in the MARS ecosystem. In that case the entire stack of calls from the Client, through the FDB or MARS server, are aware that wind data needs to be treated specially, such that the data requested or *both* fields of the other representation are retrieved, and the client then does automatic conversion when required.

Notably this is not the approach taken for other parameters which have conceptual continuity within the GRIB2 migration - even where there is not only a possible conversion but the data is functionally identical. It is not clear that this unit conversion is sufficiently distinct from all other parts of the migration that we should actively support automagical continuity here when we have decided not to elsewhere.

There is a fundamental problem with this approach in this case, which does not apply for winds. For winds there is a unique mapping between the parameter names and the underlying `paramid`s - as such all requests are fully specified in terms of the data desired. For these new units, if we do not have a unique mapping, then any requests made using short names are under specified. This leads to three options:

   (a) Mapping unique new short names for each of the new unique `paramid`s. This has the same issues as discussed under (1), and would break existing Destination Earth/AI workflows.
   (b) If an ambiguous short name is supplied, data is returned as archived. This is straightforward, but significantly reduces the value of this mechanism as it means that continuity is not provided if requests are made in terms of short names.
   (c) If an ambiguous short name is supplied, a default representation is selected. Both possible defaults are undesirable, but possible - if we default to the local units then this sharply undermines the transition to modern units, but if we default to the new units then we lose all continuity with existing pipelines.

Because this automatic conversion becomes a function of the language, it becomes important to support it properly. This means that we implicitly support conversion to WMO or local units for all data in the archive, and for all forthcoming data. This is a much larger scope of work both for implementation and for maintenance than other options.

#### 3. Double Archiving
For each of the pairs of parameters with local and WMO units we can generate both forms of output data (either directly from the model, or, more likely, by post-processing the data). This allows downstream users to request the form of data which they desire.

The obvious downside of this approach is the need to produce and archive double the data. There is no obvious window for when this double archiving should cease - both in terms of user support (if we don't wish to break user requests now, will there be a date in the future where we will), and more generally that scientific comparison of data to old contexts will continue to be valuable. Further, this entirely removes the (desirable) pressure on downstream consumers to update their workflows to use WMO units.

This comes with an implicit requirement to support production of old and new versions of this data indefinitely.

When considering 3(a) or 3(b), the same considerations apply as between 2(a) and 2(c).

#### 4. Explicit Data Conversion
One of the principles of the MARS ecosystem is that being explicit is better than being implicit. In this option we achieve this by separating the selection of which data is retrieved, and any coercion of the form of the data returned.

For the selection of which data to retrieve we have two options:
    (a) Map unique new short names for each of the new unique `paramid`s. This has the same downsides as option (1) and 2.(a).
    (b) If an ambiguous short name is supplied, we expand this request to contain both possible `paramid`s such that all possible matching data is retrieved. We rely on the (enforced) fact that we never produce both `paramid`s with all other MARS keys equivalent to ensure that the request can be handled to give the same result as the user specified (such that the `expect` value does not change with the expansion). Option 4(b) is analysed further below.
    (c) If an ambiguous short name is supplied, rely on a default. This has the same issues as option 2.(c).

Coercion of the form of data desired can be carried out as a post-processing operation. We specify this with a new post-processing keyword, `units`, which (if present) instantiates a post-processing filter.

This filter can be specified to leave data untouched (value `av`, for "archived version"), or to coerce appropriate data to WMO units (value `wmo`). For non-matching data this filter takes no action.

#### 4.(b) Handling of Ambiguous Short Name Expansion

We have two proposals for how to handle short name expansion:

**Simple expansion, and `expect manipulation`**

In MARS retrieve, list and similar requests, these ambiguous short names will be expanded to both of the contextually matching
`paramid`s. For example `tp` will be expanded to `228/228228`. The MARS expansion will track the number of parameters which
have been expanded in this way.

When the `expect` value is calculated for the request, this value will *not* be updated as per the expanded list. The 'original'
value will be used. This is in line with the constraint that for each other combination of MARS values *one and only one*
of the matching `paramid`s is permitted.

It is up to the implementation whether this `expect` value is directly calculated from the original request, or whether the
tracked number of expanded parameters above is used to calculate an equivalent value.


**An "Alternatives" Language Type**

We introduce a new notation to the MARS language, `|`, which acts as a separator between two mutually
exclusive alternatives. For example:

```param = 2t/tp```
would be expanded to
```param = 2t/228228|228```

In terms of request handling, this new unit `a|b` acts as one 'unit' for the perspective of counting,
matching, and hypercube manipulation. This avoids the need to manipulate the `expect` value. It also
makes enforcement of the restriction that `a` and `b` may not both be present, as both `a` and `b`
will match to the same entry in a hypercube.

This would require implementing a new type in the metkit type handling system. It comes with
the challenge that it would need to be implemented for each of the supported underlying types
(e.g. Alternative<Param> is not the same as Alternative<String>).

This type may also need to be implemented in the FDB's type system, used for schema navigation.
But it is possible this can be avoided, by fully expanding the request into a flat list as in
the previous option at some point in the call stack, and checking that the results match.

Explicit thought is needed about how this new functionality would be supported for programmatically
constructing MARS requests, especially through the Python and Rust wrappers. Consider a construction
such as:

```
{
    'param': [131, [228228, 228], ...]
    ...
}
```

## Decision
***To Discuss: Which mechanism of implementing option 4(b) is the right one?***
We choose option 4(b).
 - Permit old and new `paramid`s to share short names, even if they cannot be disambiguated by context, if (and only if) this is only to permit changes of units.
	 - Add a constraint that either the old or the new `paramid`s may be produced and archived within the same context, never *both*.
 - In MARS retrieve, list and similar requests, these ambiguous short names will be expanded to both of the contextually matching `paramid`s
	 - The calculated `expect` value will *not* be updated with this expansion (the 'original' value will be used), summarised in the constraint that for each other combination of MARS values *one and only one* of the matching `paramid`s is permitted.
	 - Archival will not be permitted with these ambiguous short names. This data must be archived using the `paramid` directly.
 - Introduce a new post-processing keyword `units`
	 - ***To Discuss: `unit` or `units`***
	 - Available values `av` (archived version) or `wmo`
	 - This introduces a new post-processing action
		 - If `units` is absent, `units=av`, a message is already in `wmo` form, or there is no units mapping available for the specified parameter, then this action is a NOP.
		 - If a message is mappable, this action re-encodes the (source) data into the post-MTG2 metadata encoding and units, and scales the numerical values appropriately.
		 - Note that we do not provide a mapping from WMO units to local units.
 - To facilitate this conversion, the existing conversion functionality will be migrated from MultIO to MetKit.

### Sample Requests
Explicitly retrieve all matching data (old and new paramid) across implementation date, with conversion to the WMO format. `expect=any` required as only one of the two parameters will be present at each step.
```
retrieve,
    ...
    param  = 228/228228,
    units  = wmo,
    expect = any
```

Retrieve parameter `tp` - either as `paramid` 228 or 228228. The fields will be returned as archived (`av`). If both 228 and 228228 are present this results in an error. Although `tp` will be expanded to `228/228228`, the implied value of `expect` will be the same as if only one param were requested.
```
retrieve,
    ...
    param  = tp,  # ==> 228/228228
    units  = av
```

Retrieve parameter `tp` - either as `paramid` 228 or 228228. If the archived value is `paramid=228` this will be converted into 228228 (WMO units) on the fly. If both 228 and 228228 are present this results in an error. Although `tp` will be expanded to `228/228228`, the implied value of `expect` will be the same as if only one param were requested.
```
retrieve,  
    ...  
    param  = tp, ==> 228/228228  
    units  = wmo
```

### Related Decisions

## Consequences
Data Governance
 - We can remove the guidance to create unique short names for each of the new `paramid`s created as part of this WMO unit conversion process
	 - This will allow Data Governance to use judgement as to where retaining the same short name, or changing it, is clearest for the user in a scientifically driven case-by-case analysis.

Software implementations
 - eccodes
	 - Choices around short names need to be implemented
 - Metkit
	 - For retrieval and similar requests, metkit will contextually expand the created ambiguous short names into a list containing *both* resulting `paramid`s
	 - New implementation of conversion of fields from local units to WMO units, with proper encoding into WMO-compliant GRIB2. (Transferred from MultIO)
 - MultIO
	 - Transfer re-encoding of fields to Metkit, and use this functionality where required.
 - MARS Client
	 - Implement `units=` functionality as a post-processing target
	 - Adopt the additional short name expansion changes in metkit, and integrate with the hypercubes/expect testing of the returned fields
	 - Note that these changes will be needed for the C and the C++ clients. To the extent possible, implement the functionality in Metkit and use it from both contexts.
 - FDB
	 - Only change required is expansion of short names to both matching `paramid`s in the request expansion, and compatible verification of the correct number/hypercube of returned fields.
	 - The FDB will not perform conversion of fields itself.
 - PGen
	 - Implement `units=` functionality. This could be implemented as a 'filter' between the retrieve from the FDB and the disptach to Mir, or as a post-processing on the output of Mir. ***Will need a careful design discussion.***
	 - Need a hard check to ensure that the expanded short names only ever resolve to one field from the FDB. Note that we will be making a *request* to the FDB for more than one field.
 - PProc
     - Introduces a potential assymetry between the MARS data source, and the FDB data source, that would require implementing support for `units=` directly in PProc.
 - Catalogues
	- ***Discussion/decision to make:*** Where old and new `paramid`s differ, but share a common short name, should catalogues be aware of the equivalence of these products?
 - Product Editor
	 - Add support for the `units` keyword in the requests

## References
 - [DPRODGOV-32](https://jira.ecmwf.int/browse/DPRODGOV-32) - IFS only produces GRIB2 with WMO units from Cy50r2. How to handle transition is unresolved (may or may not involve MARS/FDB)
 - [Migration to GRIB2 - changes to encoding of parameters](https://confluence.ecmwf.int/display/MTG2US/Migration+to+GRIB2+-+changes+to+encoding+of+parameters)

## Authors
 - Emanuele Danovaro
 - Domokos Sarmany
 - Simon Smart
