---
slug: shadow-ide/feature/FEATURE_NAME
project_slug: shadow-ide
kind: feature
audience: [user, agent]
version: 1
last_updated:
mapped_date:
status: stub
components: []
actions: []
workflows: []
tags: []
---

<!--
STRUCTURAL CONTRACT — READ BEFORE EDITING

A feature page describes a USER-VISIBLE capability of the application — what
the user can do or experience, not how the code is structured. The end-user
agentic assistant queries these pages to explain "what can this app do for me?"

When creating a new feature page:

1. Read frontmatter-schema.md for the universal frontmatter conventions.
2. Copy this entire file to OUTPUT_PATH/features/[name].md.
3. Replace shadow-ide with the project's slug; FEATURE_NAME with kebab-case
   feature name (e.g. enrollee-login). Set last_updated and mapped_date to today.
4. Fill every ## section in order — do not skip, reorder, or remove.
5. Cross-reference frontmatter fields:
   - components: every component this feature uses
   - actions: every action page exposing an executable invocation of this feature
     (may be empty for display-only features)
   - workflows: every workflow that includes this feature
6. Audience: default [user, agent]. Add `dev` only if the page is heavily
   technical AND devs would read it as primary content. Do NOT use [all].
7. Status: stub at creation, partial when sections are filled but TODOs remain,
   complete only when every section has real content.

Lint validates: required frontmatter, slug grammar, slug ↔ path consistency,
bidirectional `actions` ↔ action's `feature`, no broken cross-references.

Section order: Purpose → User-visible behavior → Components used → Actions exposed → Related workflows → Open questions → Notes for the assistant
-->

# Feature Name

> One-line summary in user-facing language. What the feature does, not how.

## Purpose

<!-- Why does this feature exist? What user need does it serve?
     Aim: 2–4 sentences. End-user-readable language. No jargon. -->

## User-visible behavior

<!-- Describe what the user sees and does. Pretend you're explaining to a new
     user via the in-app assistant. Use "you" voice ("you tap Continue, then...").
     Include the entry point (which screen / which button), the main flow, and
     the typical end state.

     If the feature has multiple branches, list them under ### sub-headings:
     ### Happy path
     ### When you don't have permission
     ### When the network is offline -->

## Components used

<!-- Bulleted list of [[components/component-name]] that implement this feature.
     The components: frontmatter field should match this list. -->

## Actions exposed

<!-- Bulleted list of [[actions/action-name]] that the agentic assistant can
     dispatch on the user's behalf for this feature. The actions: frontmatter
     field should match. May be empty if this feature is display-only.

     Each entry is a slug — the agentic assistant reads the action page to
     learn the endpoint, auth, side effects, etc. -->

## Related workflows

<!-- Bulleted list of [[workflows/workflow-name]] that include this feature
     as one step. The workflows: frontmatter field should match. -->

## Open questions

<!-- Anything unclear that needs clarification.
     Mark with <!-- TODO: clarify --> for searchability.
     If nothing unclear, write "None at this time." -->

## Notes for the assistant

<!-- Optional but encouraged. Guidance for the agentic in-app assistant on:
     - When to suggest this feature unprompted (or NOT to)
     - What the user might be trying to accomplish when they ask about this
     - Common confusions to address proactively
     - Whether to offer to dispatch any of the linked actions

     Example:
     "If the user asks about logging in but seems frustrated about the live-
      photo step, point them to [[features/enrollee-login#first-time]]. Do NOT
      offer to dispatch [[actions/mobile-login]] directly — login credentials
      must be entered in the official UI for compliance reasons." -->
