---
slug: shadow-ide/decision/DECISION_NAME
project_slug: shadow-ide
kind: decision
audience: [dev, agent]
version: 1
last_updated:
mapped_date:
status: stub
decision_status: proposed
superseded_by:
components: []
tags: []
---

<!--
STRUCTURAL CONTRACT — READ BEFORE EDITING

A decision page is an Architecture Decision Record (ADR). It captures a
significant architectural or design choice, why it was made, and what the
consequences are. Decisions never expire — superseded ones get marked but
preserved for context.

When creating a new decision page:

1. Read frontmatter-schema.md.
2. Copy this entire file to OUTPUT_PATH/decisions/[name].md.
3. Replace shadow-ide and DECISION_NAME (kebab-case action-style — e.g.
   "use-amplify-for-auth", "deprecate-objc-controllers").
4. Set decision_status:
   - proposed — under discussion, not yet adopted
   - accepted — currently in force
   - superseded — replaced by a later decision (set superseded_by to its slug)
   - rejected — considered but not adopted
5. The universal `status` field (stub/partial/complete) tracks PAGE completeness;
   `decision_status` tracks the decision itself. Both are required.
6. Audience: [dev, agent] — decisions are inherently dev/architectural concerns.

Lint validates: required frontmatter, decision_status from enum, superseded_by
points to a real decision page IFF decision_status is `superseded`.

Section order: Status → Context → Decision → Consequences → Alternatives considered → Related → Open questions
-->

# Decision Name

> One-line summary of the decision in active voice. "We chose X because Y."

## Status

<!-- Echo the frontmatter `decision_status` here in human form, with date.
     Example:
     "**Accepted** — adopted 2026-04-25.
      Supersedes [[decisions/use-firebase-for-auth]]." -->

## Context

<!-- What problem does this decision solve? What constraints or pressures
     forced it? Include relevant business context, technical constraints,
     and any existing system behavior the decision must work around.

     Aim: 3–6 sentences. Be specific. A future maintainer should understand
     WHY without having to read the surrounding source. -->

## Decision

<!-- The actual choice made, in clear active voice. Include any specifics
     that constrain implementation:
     - Which library / approach / pattern is chosen
     - What scope it applies to
     - What it explicitly does NOT cover

     Example: "We use AWS Amplify for authentication, scoped to the mobile
     login flow only. Backend services continue to use the existing JWT
     infrastructure for inter-service auth — Amplify does not extend there." -->

## Consequences

<!-- What follows from this decision, both positive and negative.
     Format with sub-bullets:

     ### Positive
     - <consequence>
     - <consequence>

     ### Negative
     - <consequence>
     - <consequence>

     ### Neutral / accepted trade-offs
     - <consequence> -->

## Alternatives considered

<!-- What other options were evaluated and why they were rejected.
     For each: name + 1–2 sentence rationale for rejection.

     Example:
     - Firebase Auth — rejected because we already use AWS for everything else;
       adding Firebase increased operational surface for marginal feature gain.
     - Roll our own — rejected on security/maintenance grounds. -->

## Related

<!-- Bulleted list of related [[decisions/...]] (predecessors, related-area
     decisions) and [[components/...]] affected by this decision. The
     components: frontmatter field should match the components listed here. -->

## Open questions

<!-- Anything unresolved or to-be-revisited. "None at this time." if clean. -->
