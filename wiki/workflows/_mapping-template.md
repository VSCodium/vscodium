---
slug: shadow-ide/workflow/WORKFLOW_NAME
project_slug: shadow-ide
kind: workflow
audience: [user, agent, dev]
version: 1
last_updated:
mapped_date:
status: stub
features: []
components: []
actions: []
tags: []
---

<!--
STRUCTURAL CONTRACT — READ BEFORE EDITING

A workflow page describes an END-TO-END USER JOURNEY — a sequence of steps
the user takes to accomplish something. Workflows compose multiple features.
The agentic assistant uses workflows to walk users through multi-step tasks
("first do X, then Y, then Z").

When creating a new workflow page:

1. Read frontmatter-schema.md for the universal frontmatter conventions.
2. Copy this entire file to OUTPUT_PATH/workflows/[name].md.
3. Replace shadow-ide and WORKFLOW_NAME (kebab-case).
4. Audience: default [user, agent, dev] — workflows are inherently cross-cutting.
5. Required cross-references in frontmatter:
   - features: every feature this workflow includes (at least one)
   - components: every component touched in any step (at least one)
   - actions: every action that gets dispatched in any step (may be empty if
     the workflow is purely UI-driven and doesn't trigger explicit actions)
6. Steps must be NUMBERED in order. If branches exist, list decision points
   in their own section.

Lint validates: required frontmatter, every cross-reference target exists,
slug grammar, at least one feature in `features:`, at least one component in
`components:`.

Section order: Trigger → Steps → Decision points → Failure modes → Components touched → Related features → Open questions
-->

# Workflow Name

> One-line summary of the journey, in user-facing language.

## Trigger

<!-- What starts this workflow? A user action ("user opens the app for the
     first time"), a system event ("scheduled check-in time arrives"), an
     external trigger ("user taps a notification")? Be specific. -->

## Steps

<!-- Numbered list. Each step is one user-perceived action or screen.
     Format:

     1. **Step name** — what the user sees and does. (Component: [[components/foo]])
     2. **Next step** — ...

     Keep step language end-user-readable. Technical detail goes in components/.
     If a step is conditional, note the condition in italics:
     *Conditional on `isFirstLogin == true`.* -->

## Decision points

<!-- Where the workflow branches. Format:

     - After step N: if X, go to [[workflows/branch-A]]; otherwise continue to step N+1.
     - At step M: if user denies permission, return to step M-1.

     If the workflow has no branches, write "Linear — no branches." -->

## Failure modes

<!-- What can go wrong, and what the user experiences. Bulleted:
     - Network failure at step N → retry prompt, blocks progression.
     - Permission denied at step M → workflow aborts, user sees error.

     This section is read by the agentic assistant when troubleshooting. -->

## Components touched

<!-- Bulleted list of [[components/component-name]] involved at any step.
     The components: frontmatter field should match. -->

## Related features

<!-- Bulleted list of [[features/feature-name]] that compose this workflow.
     The features: frontmatter field should match. -->

## Open questions

<!-- TODO: clarify markers for anything ambiguous. "None at this time." if clean. -->
