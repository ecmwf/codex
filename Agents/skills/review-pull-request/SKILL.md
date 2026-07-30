---
name: review-pull-request
description: >-
  Works through review feedback on a pull request until it converges: fetches
  every unresolved review thread, triages each comment as fix or reasoned
  rejection, applies focused commits, replies to and resolves each thread, and
  drives an automated reviewer (such as the GitHub Copilot review bot) around
  repeated rounds until it stops producing new findings. Use when asked to
  address PR comments, respond to a code review, or run a review loop on a pull
  request.
license: Apache-2.0
---

# Review a pull request

Use this skill when you are asked to address review comments on a pull request,
respond to reviewer feedback, or run an automated review loop until it
converges. It covers both human reviewers and review bots; the mechanics of
fetching, replying to and resolving threads are the same for each.

Two rules govern everything below:

- **The loop is the contract.** One round is not convergence. Keep going until a
  stated stop condition holds.
- **You never merge.** This skill responds to review; a human decides when the
  pull request lands. Do not merge, do not force-push, and do not push at all if
  the repository's conventions require approval first.

## Inputs

The user supplies a pull request reference. Accept any of: a number (`64`), a
full URL, or `owner/repo#number`. If only a number is given, resolve the
repository from the current checkout. If nothing is given, find the open pull
request for the current branch. Confirm the resolved target before acting.

Throughout, `<owner>`, `<repo>` and `<pr>` stand for the resolved values.

## 1. Establish the current state

Get the pull request's state, mergeability, and check status before changing
anything:

```bash
gh pr view <pr> --repo <owner>/<repo> \
  --json title,state,isDraft,mergeable,mergeStateStatus,reviewDecision,headRefName
gh pr checks <pr> --repo <owner>/<repo>
```

Note the base branch and whether the branch is behind — a review comment may
already be obsolete because the base moved.

## 2. Fetch every piece of feedback

**Inline review comments do not appear in `gh pr view`.** Use the GraphQL
`reviewThreads` query, which is also the only way to see which threads are
already resolved:

```bash
gh api graphql -f query='
query($owner:String!, $repo:String!, $pr:Int!) {
  repository(owner:$owner, name:$repo) {
    pullRequest(number:$pr) {
      reviewThreads(first:100) {
        nodes {
          id
          isResolved
          isOutdated
          path
          comments(first:20) {
            nodes { databaseId author { login } body path line originalLine }
          }
        }
      }
    }
  }
}' -f owner=<owner> -f repo=<repo> -F pr=<pr>
```

Threads where `isResolved` is `true` are done — do not reopen them. Threads
where `isOutdated` is `true` refer to code that has since changed; re-read the
current code before deciding whether the point still stands.

Also collect the review bodies and any top-level discussion, which carry
findings that are not attached to a line:

```bash
gh api repos/<owner>/<repo>/pulls/<pr>/reviews
gh api repos/<owner>/<repo>/issues/<pr>/comments
```

Build a single list of open items. Deduplicate: reviewers frequently raise the
same point inline and in the review summary.

## 3. Triage each comment

For every open item, decide one of three outcomes. Record the reason.

**Fix** — the finding is correct. Make the change.

**Reject** — the finding does not warrant a change. Legitimate grounds are:

- it is factually wrong about what the code does;
- it misreads a deliberate design decision that is documented somewhere;
- it proposes a change that would degrade correctness, clarity or performance;
- it contradicts the project's stated conventions;
- it is out of scope for this pull request and belongs in its own issue.

A rejection is never silent. It gets a reply that states the reason in one or
two sentences, and points at the evidence (a file and line, a design document, a
prior decision).

**Ask** — the intent is genuinely ambiguous, or resolving it would change public
behaviour, alter an interface, or reverse a decision you cannot verify. Put the
question to the user rather than guessing.

Never accept a suggestion just because a reviewer made it. An automated reviewer
in particular will produce confident false positives; applying them uncritically
makes the code worse. Equally, never dismiss a finding merely because fixing it
is inconvenient.

## 4. Apply the fixes

- Follow the repository's own commit conventions. Discover them from
  `CONTRIBUTING.md`, an agent-instructions file, or the existing `git log`
  style — do not impose a convention the project does not use.
- Make **focused commits**: one concern per commit. Keep renames, moves and
  reformatting in commits separate from behavioural changes, so a reviewer can
  read the diff.
- Update tests and documentation alongside the code when a fix changes
  behaviour or a public interface.
- Run the repository's own gate (its build, test and lint commands) before
  pushing. Discover it rather than assuming; see the project's contributing
  documentation or build files.

## 5. Reply and resolve

Every open thread gets a reply, whether it was fixed or rejected. Reply to the
thread rather than posting a new top-level comment, using the `databaseId` of
the comment being answered:

```bash
gh api repos/<owner>/<repo>/pulls/<pr>/comments \
  -f body='Fixed in <sha>: <one line on what changed>.' \
  -F in_reply_to=<comment_databaseId>
```

Then resolve the thread with its node `id` from the query in step 2:

```bash
gh api graphql -f query='
mutation($threadId:ID!) {
  resolveReviewThread(input:{threadId:$threadId}) {
    thread { isResolved }
  }
}' -f threadId=<thread_node_id>
```

Resolve a thread only once it is genuinely addressed — either the fix is pushed,
or the rejection reason is posted. Do not resolve threads to make a counter go
down.

## 6. Push and verify

Push the fix commits, then wait for the checks:

```bash
gh pr checks <pr> --repo <owner>/<repo> --watch
```

If a check fails, fix it and push again. A red gate is not convergence. If a
check fails for reasons unrelated to the change (known infrastructure
flakiness), say so explicitly in the report rather than quietly ignoring it.

Push the fixes **before** requesting another review round, so the reviewer sees
the current state and not the state you have already moved past.

## 7. Requesting a review from an automated reviewer

For the GitHub Copilot review bot, the literal-`[bot]`-suffix form of the REST
API is the only request that works:

```bash
gh api --method POST \
  /repos/<owner>/<repo>/pulls/<pr>/requested_reviewers \
  -f 'reviewers[]=copilot-pull-request-reviewer[bot]'
```

The alternatives fail, in ways that are easy to misread as success:

| Attempt | Result |
| ------- | ------ |
| `copilot-pull-request-reviewer` (no suffix) | `422 Reviews may only be requested from collaborators` |
| `Copilot` | returns `200` but the request is silently dropped |
| GraphQL `requestReviews` mutation | `NOT_FOUND` for the bot's node id |

A successful request responds with
`requested_reviewers: [{login: "Copilot", type: "Bot"}]`, and the review is
posted within a few minutes.

Other review bots differ. If the product is not Copilot, check its own
documentation for how a review is requested, and record what worked.

## 8. The loop and when to stop

Repeat: request a review → wait → triage → fix → reply and resolve → push →
request again.

While waiting, poll **both** endpoints together:

```bash
gh api repos/<owner>/<repo>/pulls/<pr>/reviews            # has the review count risen?
gh api repos/<owner>/<repo>/pulls/<pr>/requested_reviewers # is the bot still queued?
```

After a successful request, `requested_reviewers` lists the bot; it clears back
to `[]` when the bot has finished processing. That gives two outcomes:

- **A new review is posted** (the review count rises) — go back to triage.
- **`requested_reviewers` cleared and no new review appeared** — the reviewer
  processed the request and had nothing to add. **Stop.** The cleared list is
  itself the terminating signal; do not run a confirmation round.

Allow roughly five minutes for a bot to process a request. If the list has not
cleared by then, request again.

**Stop the loop** when any of these holds:

- the reviewer processed a request without posting a new review (the cycle
  `[bot] → []` completed and the review count did not rise);
- the latest review contains no new actionable findings — every comment is a
  duplicate of one already resolved, or a false positive already rejected with a
  stated reason;
- all threads are resolved and the checks are green, with no review pending.

The loop terminates on the reviewer's behaviour, not on a fixed number of
rounds. A single round meeting a stop condition is enough.

**Escalate to the user instead of looping** if the same finding recurs after you
have fixed it twice, if the reviewer contradicts itself between rounds, or if a
fix would require a decision from step 3's "ask" category.

## 9. Report

Finish with a summary that maps every item to its outcome:

- **Fixed** — the finding, and the commit that addresses it.
- **Rejected** — the finding, and the one-line reason given to the reviewer.
- **Asked** — anything referred back to the user, still open.
- **State** — threads resolved versus outstanding, check status, and whether the
  loop terminated or was escalated.

State plainly whether the pull request is ready for a human decision. Do not
merge it.
