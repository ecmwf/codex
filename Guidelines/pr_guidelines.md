# Pull Requests

Changes to our repository are to be approved through a peer review process
based on Pull Requests (PR). Reviewer and Reviewee have specific
responsibilities. This document aims to help both roles to understand their
responsibilities.

## Preparation

Speak with your team and/or the repository's maintainer before you open a PR,
ensure all agree on the expected size of the PR.

Try to ensure that you can provide a sufficient description of what the change
intends and why it was necessary. Provide enough context for the reviewer to
understand why this implementation was chosen.

For example: Your change uses a particularly complicated implementation for which
a much more obvious and simple implementation would be possible. However you
know that we receive inputs that exhibit worst-case run-time behaviour in the
obvious solution, hence the sophisticated solution is required. In this case
you should strongly consider providing enough context in the commit messages,
PR description and comments to explain the choice.

Self-review your code before you open the PR; you will be surprised how many
small mistakes you will find.

## As Reviewer

Be polite and maintain clarity in your comments!

Remember that it is perfectly legitimate to...
* ... deny a review if you do not feel qualified to review this change in the
required timeframe.
* ... suggest that the PR is split up into smaller individual changes if it is
too large.
* ... reject the changes if you do not feel comfortable with them. Be proactive in
finding a solution together with the author.

Please remember that our primary review tool is the GitHub web UI. Ensure that
each individual comment is concise and understandable without looking at prior
comments. They may be read in a different order.

Be explicit in your comments and avoid ambiguity about whether you are
commenting about a **blocking** issue, that must be fixed or clarified before
approval, or an **optional** issue, that is nice-to-have, a nitpick or just
informational.

## As Reviewee

Be polite and maintain clarity in your comments!

Communicate proactively with your reviewers. Let them know when you have
addressed their change requests and in what timeframe you require another
round of review.

State disagreements openly so that they can be resolved.

Once your reviewers approve, take some time to clean up your PR. Please do not
merge commits such as "WIP" or "Fix Review Comment", commits like this make it
more difficult in the future to reason about changes.

## General Guidelines

### How to Handle Very Small PRs?

Reviews do not have to be a lengthy and formal process. Depending on the size
and scope of your change they can be short and informal.

For example a PR that addresses long outdated comments or clarifies
documentation with a generally accepted explanation can be handled by Reviewer
and Reviewee having a short call and agreeing on the change. It is important,
though, to mark the PR as approved through the GitHub UI to track who approved.

### What if my PR has just too many change requests?

If your PR receives many change requests or very substantial change
requests it can be a sensible decision to close the PR, spend additional
development time on it properly and open the PR at a later time.

### What if I disagree with my reviewer?

If the reviewer and author cannot agree on a change, involve a third party for
fresh input and to help resolve the disagreement. If that does not work,
escalate the decision to a technical lead.

## Reviewers Checklist

- [ ] Do I understand the problem and agree with the solution?
- [ ] Is the change functionally correct?
- [ ] Are all GitHub checks passing?
- [ ] Are the commit messages understandable and add sufficient context as to
  why the change was done?
- [ ] Are the tests sufficient?
- [ ] Has the documentation been updated/written?


Happy Hacking!
