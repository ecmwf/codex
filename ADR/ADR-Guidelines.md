# ECMWF Architectural Decision Records (ADR) Guidelines

This document provides a Guidelines and a template for creating Architectural Decision Records (ADRs). Each ADR should be a standalone document that captures a specific architectural decision, its context, and its consequences.

## Template for Architectural Decision Records (ADRs)

Please find the template for creatinsg ADRs in the [ADR-Template.md](./ADR-Template.md) file. This template should be used for all ADRs to ensure consistency and clarity.

## Purpose

Architectural Decision Records (ADRs) are lightweight documents that capture important architectural decisions made during the development of ECMWF systems. They provide historical context, rationale, and consequences of decisions to help current and future team members understand the evolution of our architecture.

ADRs are living documents that serve the team. We should focus on creating useful, accessible records that will help current and future team members understand and build upon the architectural decisions that shape ECMWF's systems.

## When to Write an ADR

Create an ADR when making decisions that:

- **Significantly impact system architecture** - Architectural choices, framework selections, major design patterns
- **Affect multiple teams or systems** - Cross-cutting concerns, shared libraries, integration patterns
- **Have long-term consequences** - Technology stack decisions, data models, security approaches, scalability strategies
- **Require justification and analysis** - Trade-offs between options, risk assessments, cost-benefit
- **Involve trade-offs between alternatives** - For example performance vs. maintainability, cost vs. functionality
- **Establish important conventions** - Coding standards, deployment processes, monitoring strategies
- **Address compliance or regulatory requirements** - Adherance to standards like OGC and Data governance, but also security policies and identity managment

## Writing Guidelines

### General Principles

- **Be concise but comprehensive** - Provide enough detail for understanding without unnecessary verbosity
- **Focus on the decision, not implementation details** - Explain what and why, not how
- **Use clear, jargon-free language** - Ensure accessibility to team members with different backgrounds
- **Be objective** - Present facts and analysis rather than opinions
- **Include dissenting views** - Acknowledge alternative perspectives when relevant

### Section-Specific Guidelines

#### Status
- Use **Proposed** for draft ADRs under review (only the text not the decision which should at this stage already be clear)
- Use **Accepted** for approved and implemented decisions
- Use **Deprecated** for decisions no longer valid but historically important
- Use **Superseded by [ADR-XXX]** when replaced by a newer decision

#### Context

Explain the context of the decision, including any relevant background information, constraints, and requirements. This section should provide enough detail for someone unfamiliar with the project to understand the decision.
Consider including:
- Explain the business or technical problem being solved
- Describe relevant constraints (time, budget, technology, regulatory)
- Provide sufficient background for someone unfamiliar with the project
- Include relevant ECMWF-specific considerations (operational requirements, data volumes, performance needs)

#### Options Considered

This section should list the options that were considered before making the decision. Each option should be described briefly, including its pros and cons if applicable. If no options were considered, state "None".
Consider including:
- List all seriously considered alternatives, including "do nothing"
- Provide brief descriptions of each option
- Include pros and cons for each alternative
- If only one option was viable, explain why others were dismissed early

#### Analysis

This section should provide an analysis of the options considered, including any trade-offs, risks, and implications of each option. It should explain why the chosen option was selected over the others. If no alternative options were considered, analyse the impact of the decision. 
Consider including:
- Compare options against relevant criteria (cost, performance, maintainability, risk)
- Explain trade-offs and their implications
- Reference any prototypes, benchmarks, or research conducted (if applicable)
- Consider both immediate and long-term impacts

#### Decision

This section should clearly state the decision that was made. It should be concise and unambiguous, providing a definitive answer to the problem or question at hand.
Consider including:
- State the chosen option clearly and unambiguously
- Avoid implementation details unless crucial to understanding
- Include any conditions or limitations on the decision

#### Related Decisions

This section should list any related decisions that may impact or be impacted by this decision. If there are no related decisions, state "None".
Consider including:
- Reference other ADRs that influenced or are influenced by this decision
- Note any decisions this ADR modifies or supersedes
- Consider impacts on existing architectural patterns
- Reference ECMWF previous decisions that may be relevant but not documented as ADRs

#### Consequences

This section should describe the consequences of the decision, both positive and negative. It should outline any expected outcomes, changes to the system, or implications for future work. In the unlikely case there are no expected consequences, state "No consequences to be expected".
Consider including:
- List both positive and negative expected outcomes
- Include impacts on performance, maintainability, team productivity, and operations
- Note any new risks introduced or mitigated
- Consider implications for future decisions

#### References

This section should include any references to external documents, links, or resources that provide additional context or information related to the decision. This could include links to discussions, design documents, or relevant standards.
Consider including:
- Include links to relevant documentation, RFCs, or standards
- Reference meeting notes, email threads, or other decision artifacts
- Link to prototypes, benchmarks, or analysis documents
- Cite relevant ECMWF policies or guidelines

#### Authors

List the authors of the decision record. This helps in tracking who was involved in making the decision.
Consider including:
- List all significant contributors to the decision
- Contributor roles if meaningful and when helpful for context
- Reviewers who provided substantial input

## Quality Checklist

Before finalizing an ADR, ensure it meets these criteria:

- [ ] **Clear problem statement** - The context section clearly explains what decision needed to be made
- [ ] **Justified decision** - The analysis section provides sufficient rationale for the chosen option
- [ ] **Complete consideration** - All reasonable alternatives were evaluated
- [ ] **Understandable to newcomers** - Someone joining the team could understand the decision from this document
- [ ] **Actionable consequences** - The consequences section provides useful guidance for future work
- [ ] **Proper references** - All claims and external influences are properly cited
- [ ] **Appropriate scope** - The decision is neither too broad nor too narrow for a single ADR

## Numbering and Filing

- Use sequential numbering: ADR-001-Meaningfull-Title, ADR-002-Another-Meaningfull-Title, etc.
- Store ADRs in the central **Codex** repository under `/ADR/`
- Use descriptive filenames: `ADR-001-Git-Branching-Model.md`
- Use the [ADR index](./ADR/ADR-Index.md) to track all ADRs and their statuses

## Review Process

This review process refers to the text in the ADR. It does not refer to the decision itself, which should already be clear at this stage. The review process is as follows:

1. **Draft Creation** - Author(s) create(s) ADR with status "Proposed"
2. **Technical & Architecture Review** - Relevant technical teams including GateKeeper(s) review for accuracy and completeness
4. **Stakeholder Review** - Team Leader(s) and Section head review for alignment with ECMWF strategic goals
5. **Final Approval** - Change status to "Accepted" once consensus is reached
6. **Publication** - Share with broader team and update architectural documentation

## Maintenance

- **Regular Review** - Encourage periodical assessment whether decisions remain valid
- **Status Updates** - Update status when decisions become deprecated or superseded
- **Living Documents** - Minor clarifications can be added, but major changes should trigger new ADRs
- **Traceability** - Maintain clear links between related decisions (in the "Related Decisions" and "References" sections) 

## Common Pitfalls to Avoid

- **Too much detail** - Focus on the decision rather than implementation specifics
- **Lack of alternatives** - Always consider and document alternative approaches
- **Weak justification** - Provide concrete reasoning, not just preferences
- **Missing context** - Ensure the background is clear to team members who weren't involved but keep it concise
- **Ignoring consequences** - Consider both positive and negative impacts thoroughly
- **Inconsistent format** - Use the provided template to ensure uniformity across ADRs

## Example Scenarios for ECMWF

- Deciding which language to use for a new software component
- Selecting a new data processing framework
- Deciding on API architecture for a new service
- Selecting monitoring and alerting solutions for operational service

