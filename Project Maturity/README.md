# Project Maturity

Software maturity refers to the stages a software project goes through during its lifecycle. While ECMWF runs operational services, this does not necessarily mean that the underlying software is operationally supported for external users. The following maturity levels provide an indication of how well-supported and operationally ready ECMWF software is. However, as with any open-source software, users should evaluate its suitability for their needs and use it at their own risk.

Every repository should show, near the top of its README (after the title and an optional short synopsis), a badge indicating its maturity level and the matching disclaimer:

```markdown
[![Static Badge](https://github.com/ecmwf/codex/raw/refs/heads/main/Project%20Maturity/<level>_badge.svg)](https://github.com/ecmwf/codex/raw/refs/heads/main/Project%20Maturity#<level>)

> [!IMPORTANT]
> This software is **<Level>** and subject to ECMWF's guidelines on [Software Maturity](https://github.com/ecmwf/codex/raw/refs/heads/main/Project%20Maturity).
```

Replace `<level>`/`<Level>` with the level below (e.g. `graduated` / `Graduated`).

## Graduated

[![Static Badge](https://github.com/ecmwf/codex/raw/refs/heads/main/Project%20Maturity/graduated_badge.svg)](https://github.com/ecmwf/codex/raw/refs/heads/main/Project%20Maturity#graduated)

Graduated projects are ready for operations, and typically used by ECMWF and/or its Member and Co-operating States in operations. This does not mean ECMWF gives operational support to the software itself.

## Incubating

[![Static Badge](https://github.com/ecmwf/codex/raw/refs/heads/main/Project%20Maturity/incubating_badge.svg)](https://github.com/ecmwf/codex/raw/refs/heads/main/Project%20Maturity#incubating)

Incubating projects are mostly feature-complete and the interface is mostly stable. If this software is to be used in operational systems you are **strongly advised to use a released tag in your system configuration**, and you should be willing to accept incoming changes and bug fixes that require adaptations on your part. ECMWF **may be using** this software in operations and abides by the same caveats.

## Emerging

[![Static Badge](https://github.com/ecmwf/codex/raw/refs/heads/main/Project%20Maturity/emerging_badge.svg)](https://github.com/ecmwf/codex/raw/refs/heads/main/Project%20Maturity#emerging)

Emerging projects are in the early stages of development. There is a clear project goal, but they are not yet feature-complete and not stable.

## Sandbox

[![Static Badge](https://github.com/ecmwf/codex/raw/refs/heads/main/Project%20Maturity/sandbox_badge.svg)](https://github.com/ecmwf/codex/raw/refs/heads/main/Project%20Maturity#sandbox)

Sandbox projects are experimental, proof-of-concept. Expect frequent changes, incomplete features and instability.

## Archived

[![Static Badge](https://github.com/ecmwf/codex/raw/refs/heads/main/Project%20Maturity/archived_badge.svg)](https://github.com/ecmwf/codex/raw/refs/heads/main/Project%20Maturity#archived)

Projects that have reached the end of their lifecycle. They are no longer actively maintained or developed. These projects may still be available for reference or historical purposes, but they should not be used for any active development or operational purposes.
