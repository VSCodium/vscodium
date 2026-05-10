---
slug: shadow-ide/decision/track-upstream-vscode-by-scripted-overlay
project_slug: shadow-ide
kind: decision
audience: [dev, agent]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
decision_status: accepted
superseded_by:
components: [shadow-ide/component/root-build-orchestration, shadow-ide/component/patch-set, shadow-ide/component/vscode-overlay-and-product-metadata]
tags: [upstream, overlay, patches]
---

# Track Upstream VS Code By Scripted Overlay

> We build from upstream VS Code and express distribution changes as overlays plus patches instead of maintaining a full source fork.

## Status

**Accepted** - inherited from the VSCodium architecture and active in this repo.

## Context

VS Code changes rapidly. Maintaining a complete forked source tree would make upstream upgrades harder. This repo mostly needs product/distribution changes, not ownership of every upstream source file.

## Decision

Use `get_repo.sh` to fetch upstream, `src/<quality>/` and product metadata to overlay resources, and `patches/**/*.patch` to encode code changes.

## Consequences

### Positive

- Upstream source remains cleanly replaceable.
- Local changes are visible as patches and overlays.
- Release automation can rebuild new upstream versions with minimal committed churn.

### Negative

- Patch drift is a regular maintenance cost.
- Debugging requires understanding both upstream source and local patch order.

### Neutral / accepted trade-offs

- Generated `vscode/` is transient and should not be treated as primary source.

## Alternatives considered

- Full fork of `microsoft/vscode` - rejected due to merge burden.
- Binary-only repackaging - rejected because product behavior and policy changes require source-level patching.

## Related

- [[components/root-build-orchestration]]
- [[components/patch-set]]
- [[components/vscode-overlay-and-product-metadata]]

## Open questions

None at this time.
