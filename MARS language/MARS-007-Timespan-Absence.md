# MARS Languge Decision Record 007: Handling (absence of) timespan in post-MTG2 data

[**Proposed** | ~~Accepted~~ | ~~Deprecated~~ | ~~Superseded by [ADR-XXX]~~]

## Last Updated

2026-03-20

## Context
There are many parameters which are accumulated, or have other time-window related properties.
 - Rainfall (accumulated)
 - Mean values
The windows over which these values can be calculated vary. And this has historically been handled by adding addition `paramid` values for each of the different types. This is a bit nasty.

The proposed changes is to introduce a keyword - `timespan` - to specify this time window, which allows the use of the same `paramid` for data which is conceptually the same (except the time window).

However, the bulk of our data, and the most popular data, does not have an associated time window - that is they are *instantaneous* parameters. Thus there are data with `timespan` unspecified, `timespan` with explicit durations (`3h`, `6h`, `12h`, ...) and other specific values (`timespan=fs`, from start of simulation).

Note that there are some parameters with essentially 2 axes of time. Consider monthly means, which are averages of _something_. These can be averages of an instantaneous parameter, but (e.g. rainfall averages) are taken as averages of a time window. So these are identified by a specific `paramid` (which specifies the overall average duration), and the `timespan` which identifies the unit over which the average is carried out. There are datasets with multiple different averaging units used.

Further, there are requests for which `timespan` absent, and `timespan=Xh` are both valid with otherwise identical MARS requests. For example time-{mean,min,max,stdev}. These behave with 2 axes of time as described above.

Some details have already been agreed previously, that constrain the decision scope:
 - The keyword `timespan` will be used to describe these data
 - In contexts where a value is structurally required, the value `none` will be used.
 - `timespan=none` will be equivalent (semantically, from a users perspective) to no `timespan` keyword or value being supplied

The impact of the introduction of `timespan` will be very large. Many `paramids` in existing output have been remapped to new `paramids` combined with `timespan`, such that multiple `paramids` have been consolidated. All requests/interactions for these data will need to be updated. Depending on the choice of how absence of `timespan` is handled this could expand to being *all* data produced.

Much of the most frequently accessed and most popular data does not involve `timespan`. It is *highly desirable* that downstream systems, people and customers for this large body of data should not be impacted by breaking changes.

There are a few decision points to consider
 - Semantically `timespan=none` is equivalent to `timespan` not being present. Should `timespan=none` be included in the MARS namespace and `grib_ls`.
 - Should `timespan=none` be forbidden, allowed, or required on archiving requests
#### Impacted Systems
This needs to consider the impact of the changes on:
 - eccodes
	 - Internals and exposed behaviour
	 - Particularly what is exposed in the MARS namespace
 - MARS
	 - Language (as exposed to users and systems)
	 - Client
	 - Server (in particular indexing and build rules)
 - FDB
	 - Impact on tools and API
	 - Impact on indexing and schema
 - Catalogues
	 - MARS catalogue
	 - Qubed
	 - listing output data from MARS and FDB
 - multio/metkit
	 - On the output pathway, how do we distinguish data that should be encoded pre- or post-MTG2.
 - Data requests and product catalogue
 - Other consumers of data (PGen, PPROC, ...)

### Prior Art
#### 1. `domain=g`
As a longstanding behaviour, we have treated the absence of `domain` specified in a request, as equivalent to specifying `domain=g`. This is currently implemented in the MARS C client, and in language expansion in Metkit, such that `domain=g` is injected into any request which does not specify domain. (Note that this behaviour had to be modified recently to be contextual, as some of the newer DestinE datasets do not include `domain`).

This mechanism of injecting a value as a default in the language expansion is not appropriate in this case, as we have to support both old and new data (and ideally requests spanning both). In the old data `timespan` is not a valid keyword. It is not straightforwardly inferrable from the the request itself whether the request is for old or new data, as we will have multiple cycles running at the same time.

This does, however, provide a precedent for user requests being silently adapted to add a keyword which is strictly optional for the user to specify, unless the keyword diverges from some default value (such that `domain=h` remains untouched).
#### 2. `paramtype`
The MTG2 refactoring has introduced a new classification of different types of parameters. The different `paramids` are described different sub-classifications with different keywords (such as `chem`, `frequency`, `direction`). These need two different approaches in the FDB and MARS:
 - In the FDB we can simply introduce optional parameters into the third level of the schema. Such as `frequency?`. This means that for data that requires it, we include those values, but omit it otherwise.
 - In MARS this does not work, and we require differently ***structured*** MARS trees and leaf nodes. This implies a branch in the tree.
We introduce a new classification, `paramtype`. This can be queried directly from eccodes (as it is part of how the data is classified there). But this is not included in the `mars` namespace (and thus the output of `grib_ls -m`).

In the MARS build rules we infer the value of `paramtype` by inspection of the other values present in the request whilst the MARS tree is being constructed during an archive request. This uses two new MARS build rule capabilities; one which sets the keyword (unless explicitly overridden in a request) and the other which can test for the presence of a keyword in a request
```
if (?frequency? && ?direction?) then
    default paramtype='wave_spectra'
else if (...) then
    ...
else
    default paramtype='base'
end if
```
Which will in this case lead to the construction of a build tree with a node like:
```
                        ...─┐                                
                            │                                
  ┌─────┬──────┬────────paramtype────┬────────────────┐      
  │     │      │         │           │                │      
base  wave  optical  chemical  wave_spectra  chemical_optical
```
On archive, sufficient keys are required to be specified to infer the value of `paramtype` whilst walking the build rules.

On retrieve, the build rules are not used. If a keyword is not specified, the `PSimpleNode`class will explore all branches of the tree. ***By construction*** we have ensured that data cannot match a request in multiple of the branches (otherwise the prior inference process would not work), and as such data is retrieved/listed correctly.

This precedent is useful for the construction of the MARS tree, some assumptions of defaulting behaviour in the FDB, and an expectation that keywords can be inferred downstream of the user request internally within the service. However, this is not fully applicable for two reasons:
1. `timespan` is to be explicitly included in *some* of the user requests. It should only be inferred for `timespan=none`
2. There are parameters which can (and will) be found in multiple of the branches of the tree, 
### Options Considered

### 1. General introduction of `timespan` node with default
 - `timespan=none` becomes as internal as possible.
 - eccodes does not report `timespan=none` in `grib_ls -m`, or other queries of `mars` namespace.
 - `timespan=none` stripped from MARS requests if supplied
	 - Note this makes it invalid to combine with other walues (e.g. `timespan=none/6h`)
 - `timespan` as an *optional* key in fdb
	 - Use `timespan?` in the schema. This is then empty if `timespan` is not supplied
	 - Matching requests require this to be empty.
 - In the similar way to `paramtype`, introduce a new `default timespan=none`
	 - This will be used when archiving data which doesn't match
	 - Include `timespan` (and `paramtype`) ***everywhere***
		 - If the first field archived for a given tree has no `timespan` value, there is no mechanism to identify that we are in a post-MTG2 dataset.
	 - This works with new and old data. Note that this will cause `timespan` to appear in the MARS catalogue for all newly written data
 - Introduce a new node type `PSimpleNodeDefault`, which remembers the default value it is supplied with.
	 - Unlike with `paramtype`, we need to identify the branch unambiguously, as there may be falsely matching data in the `timespan=Xh` branches in the `timespan=none` case
	 - This new node type only explores the matching branch...
### 2. Switched behaviour based on post-MTG2 detection
This case is the same as Option 1, except:
 - When we pre-analyse the data in the MARS client, prior to submitting an archive request, we use explicit eccodes calls to determine if we are pre/post MTG2
 - We inject a private value (possibly `_wmoGRIB2`, or similar) into the MARS request
	 - This should not reference `MTG2` - that term is unlikely to have any semantic meaning to a developer in 20 years.
 - This value is the used in the build rules to determine whether we use the old or the new layouts.
 - This will need to be implemented in both the C and C++ clients
### 3.  `timespan=none` everywhere, but optional
 - eccodes should have different behaviour for the pre/post MTG2 data
	 - Existing data should be unchanged. `timespan` is not present in the `mars` namespace
	 - post-MTG2 data should always report the value of `timespan`, including `timespan=none`
 - fdb should use a defaulted-optional value
	 - `timespan?none?` in the schema
	 - On archive, this uses the value provided if supplied. This must match the `mars` namespace, and so will be absent for pre-MTG2 data, and present for post-.
	 - On retrieve, both `timespan=none` and `timespan` absent match against either `timespan=none` or `timespan` absent in the fdb index.
	 - This could be proposed as a standard behaviour going forward.
 - We pre-analyse data in the MARS client, prior to submitting an archive request using explicit eccodes calls to determine if we are pre/post MTG2
	 - If pre-MTG2, and the user supplies `timespan=none`, then `timespan` should be stripped from the request
	 - If post-MTG2, and the user does not supply `timespan`, then `timespan=none` should be injected
 - We still require the `PSimpleNodeDefault` change suggested in Option 1 to ensure that we correctly uniquely select data on retrieve.
### 4. `timespan=none` mandatory everywhere
 - Old cycles remain unchanged
 - In all contexts, for all post-MTG2 data, `timespan` becomes a mandatory keyword. `timespan=none` must be supplied explicitly in construction and use of all MARS requests.
 - `timespan?` used in the FDB to ensure this works with pre-MTG2 data.
 - No new functionality needed in MARS Server or Client.

### Option Comparison Grid
| N.  | eccodes  | MARS                                                             | FDB                                             | User RQs | Catalogue | Notes                                                                                      |
| --- | -------- | ---------------------------------------------------------------- | ----------------------------------------------- | -------- | --------- | ------------------------------------------------------------------------------------------ |
| 1   | omitted  | default timespan=none                                            | `timespan?` (schema)                            | ❌        | ✅         | `timespan` appears in catalogue and indexing for old cycles                                |
| 2   | omitted  | `_wmoGRIB2` from client                                          | `timespan?` (schema)                            | ❌        | ✅         |                                                                                            |
| 3   | included | `timespan` mandatory on archive<br>(could be injected by client) | Special defaults<br>`timespan?none`             | ❌        | ✅         | All user facing interactions treat `timespan=none` and absent as equivalent.               |
| 4   | included | `timespan` mandatory always                                      | `timespan?` (schema)<br>(required for new data) | ✅        | ✅         | ***All*** requests for ***all*** users must change on a specific date. "The date of shame" |
### Analysis
Options 1 and options 4 were relatively quickly considered to be undesirable:
 - Option 1 changes behaviour for existing cycles. The `timespan` and `paramtype` keyword would appear in the indexing, and thus in list output and in the MARS catalogue, starting from the date that the configuration change was made. Having retrospective behaviour changes is likely to be confusing for the user.
 - Option 4 forces ***all*** requests for ***all*** data to be modified by ***all*** downstream users on a single date (to be determined). This is horrible.
This leaves us to consider the tradeoffs between options 2 and 3.

Option 2 has the advantage that the control of what happens internally is very explicit, as part of a collaboration between the MARS server and the MARS client. We have a switch in behaviour that is signalled directly - "if we are post-MTG2, do post-MTG2 stuff".

The downside of option 2 is that we are essentially introducing versioning into the MARS language, in a way that is hidden to the user. And we do this by introducing something which is non-semantic into the data chain, which we will have to maintain forever. In 20 years, people will be wondering "why is this switch here, and why does everything break if we change it?"

Option 3 also introduces a semantic change to the MARS language, but one which is backwards compatible. It indicates `timespan=none` and `timespan` absent *are semantically equivalent*. This has some interesting consequences:
 - Firstly, we should consider this to be a `keyword=none` change to the semantics of the language. This could be reused in other contexts (the one that springs to mind is `number=none`)
 - This allows us to specify ranges of the form `keyword=none/a/b/c`. This is a really good thing in the context of optional values in indexing.
 - This makes handling the case of data being present in multiple branches of the tree with otherwise identical requests (except the missing keyword) explicit, and straightforward.
The ugly side is that option 3 retains a useful functionality that is a bit of a semantic hack. It enables the use of the *presence* of the `timespan` keyword to be used as a means of determining if we are in a pre- or a post-MTG2 situation. As the build rules continue to grow over time, at some point in the future this is likely to cause confusion. So this needs to be very careful noted, commented in the code, and should ideally be captured in a function somewhere such that the logic/commenting only exists in one place.

Considering systems outside of the FDB and MARS.

Overall, after *much* discussion and dispute, we believe that the best compromise position is to choose ***Option 3***
## Decision
We choose **option 3** from the selections above. That is that `timespan=none` should appear in the MARS namespace for new (post-MTG2) data, and this keyword is required to be supplied on archival. The `timespan` keyword can then be used internally to inform FDB and MARS indexing decisions. For listing and retrieval `timespan=none` and `timespan` absent are to be treated as strictly interchangeable from the user perspective.

Conceptual change
 - We introduce a new semantic for the MARS language.
	* `keyword=none` is strictly equivalent to `keyword` unspecified
	* This behaviour can be extended to other contexts in the future, where appropriate, but should be consistent in all cases.
New development required
* We introduce a new type into the MARS tree (`PSimpleNodeDefault`) 
	* This type has a specified default value for retrieve lookups if a keyword is absent from the MARS request
	* Otherwise this node is identical to `PSimpleNode`
* We introduce extended behaviour for the default functionality in the fdb schema
	* `keyword?default` supplies a default value used only in retrieval
	* Archival stores data exactly as specified (including absent values)
	* On retrieval both absence, and `default` match against either absence or `default` in the index
	* Wipe requires explicit matching in all contexts
Configuration changes required
 - In the FDB
	* We use `timespan?none` in the FDB schema
	* pre-MTG2 data will be archived with `timespan` absent
	* post-MTG2 data will be archived with `timespan=none`
	* Listing will return values as indexed (i.e. depending on pre/post-MTG2)
	* Retrieval will work for both `timespan=none` and `timespan` absent as the language semantic is updated to treat these two values the same..
* In MARS Server
	* We select on the presence of `timespan` *in an archive request* to select the tree structure.
	* 
	* We need to use `PSimpleNodeDefault` to select the correct branch during retrieve requests if `timespan` is not specified in the request.
	* In verification, we can still verify that an archive request matches *exactly* to the contents of the MARS namespace (we can run an identical check to that in the client).
Implications for workflows and other tools
* *On archive* and *delete* we require the MARS request to *exactly* match the contents of the MARS namespace in the GRIB
	* `timespan` must be specified with post-MTG2 data
	* `timespan` must not be specified with pre-MTG2 data
	* ***Note that this will require all archive requests to be updated in any suite or software writing data post-MTG2***
* For *listing* or *retrieve*
	* These should work in the same way as `domain`
	* If `timespan` has a concrete value, it must always be specified
	* Otherwise, `timespan` may be omitted, or set to `timespan=none` equivalently
	* `timespan=none` may be combined with other values, e.g. `timespan=none/3h/6h`
* In multio / metkit GRIB encoding
	* pre-MTG2 `timespan` should continue to be omitted
	* `timespan` should be used to identify data, including `timespan=none` as appropriate as this is on the generation/archive pathway
	* Note, this can be used for behavioural switching inside the metkit GRIB encoding layer if needed
* In the Product Editor
	* FDB retrieval is equivalent between absence and `timespan=none`
	* Requests can be specified in either form. Existing requests do not need to be updated
### Related Decisions

 - MARS-XXX - `paramtype` introduced as internal indirection, not exposed to users
## Consequences

 - The introduction of `timespan` will impact ***all*** fields produced after a cutoff date, which depends on the context
	 - Some new datasets will always have `timespan`
	 - Operations will have a switchover date for which this behaviour turns on
	 - Research experiments will depend on which cycle they are based on
 - `keyword=none` can be used in other contexts
	 - For example, be aware of possible use for `number=none` in describing ensemble data. The semantic of a request describing `number=none/1/to/50` is quite nice for some contexts!

## References

## Authors

- Emanuele Danovaro
- Robert Osinski
- Simon Smart
- Tiago Quintino
- Sebastien Villaume
