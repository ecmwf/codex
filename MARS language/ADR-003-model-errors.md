# Architectural Decision Record 003: Model Error Coefficients Index 

## Status
[**Proposed** | <s>Accepted</s> | <s>Deprecated</s> | <s>Superseded by [ADR-XXX]</s>]

## Last Updated
2026-01-09

## Context

Initial request from RD:
As we are developing weak-constraint 4D-Var further, I would like to update the way we define and archive the model error fields.
At the moment, type=me is available for class LWDA and type=eme is available for class ELDA. They are used to archive 3D-fields for a deterministic or an ensemble of weak-constraint 4D-Var.
We are developing a new formulation where we would need to archive a set of 3D-fields, instead of a single 3D-fields per physical variable. I think the best way to implement this would be to have a new GRIB variable in the template (i.e. a metadata that contains an integer). This should be then linked to a new MARS key, similar to what is done with the "member" key.
Let me know what you think, happy to discuss this further and give more details/motivations if needed.

Assessment by Data Governance
Essentially, instead of having a single value for a model error (of temperature for instance, but it could be any other parameter), the model error is now a series E1*sin(...) + E2*cos(...) + E3*sin(...) + E4*cos(...) + ..... instead of being a single value E.
We need to store the coefficients E1, E2, E3, E4, etc. For now the truncation is at E3 but it could be anything. We can't use MARS number  to index these coefficients because number  is rightfully used for ensemble number with type=eme.
This development is needed for 50r1.

### Options Considered

Option 1
We propose a new MARS keyword, called coefficient or coeffIndex  to keep it generic so that it could be used in other context than to capture the n-th model error coefficient. 
An immediate implementation is available by extending the currently used "model error" local section 39 (and 25 for non deterministic).

```bash
# Local definition 39: 4DVar model errors for long window 4Dvar system (inspired by local def 25)
 
unsigned[1] componentIndex  : dump;
alias mars.number=componentIndex;
unsigned[1] numberOfComponents  : dump;
alias totalNumber=numberOfComponents;
unsigned[1] modelErrorType  : dump;
 
alias local.componentIndex=componentIndex;
alias local.numberOfComponents=numberOfComponents;
alias local.modelErrorType=modelErrorType;
 
# Hours
unsigned[2] offsetToEndOf4DvarWindow : dump;
unsigned[2] lengthOf4DvarWindow : dump;
alias anoffset=offsetToEndOf4DvarWindow;
```

We could create a new local section from 39 by adding 2 new keys and alias it to a mars keyword:

```bash
unsigned[1] fourierCoefficientIndex : dump;
unsigned[1] numberOfFourierCoefficients  : dump;
alias mars.coeffindex=fourierCoefficientIndex;
```

For now, this new keyword will be solely used in the context of model errors (type=me and type=eme). Those are expert fields needed for restarting model runs but are of little use for the vast majority of people.
This needs to be implemented in metkit as well and a new layout axis needs to be implemented in the MARS server.
These coefficients are not planned to be disseminated or made available to external users. They will likely be plotted and consumed by evaluation tools.

### Analysis
In terms of the information stored in the GRIBs, we did not consider options outside of option 1.
We had a wide ranging discussion about the options of coefficient , coeffindex , component , componentindex  and other options. This settled on coeffindex  fundamentally because:
* The value is not a coefficient. 
* Component is already used in a related context

## Decision
* implement a new MARS keyword coeffindex in ecCodes, metkit and mars server.
* implement in FDB schema and MARS buildRules
* review MARS client rules + metkit language rules (remove from inherited requests)


### Related Decisions

## Consequences


## References

## Authors
- Manuel Fuentes
- Sebastien Villaume
- Robert Osinski
- Mohamed Azhar
- Simon Smart
- Emanuele Danovaro
- Paul Dando
