---
slug: shadow-ide/overview/project-discovery
project_slug: shadow-ide
kind: overview
audience: [user, agent, dev]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
tags: [discovery, overview, shadow-ide]
---

# Project Discovery

> Shadow-IDE is represented here as a VS Code/VSCodium-derived build distribution repository: it fetches upstream VS Code, overlays product resources, applies patches, builds platform artifacts, publishes releases, and maintains update metadata.

## What this repository is

This repository is not a conventional app source tree where most product code lives under `src/`. It is a build and distribution orchestration repo. The main source editor is fetched from `https://github.com/Microsoft/vscode.git` by [[components/root-build-orchestration]], then altered by [[components/vscode-overlay-and-product-metadata]] and [[components/patch-set]] before platform-specific packaging.

The Git remote points at `arimacmini1/Shadow-IDE`, so this is the Shadow-IDE project home. The tracked product defaults currently remain largely VSCodium-flavored in files such as `utils.sh`, `prepare_vscode.sh`, GitHub workflow env blocks, docs, icons, and generated resources. Future Shadow-IDE branding work should be coordinated through [[features/product-branding-and-assets]] instead of one-off string edits.

## Primary responsibilities

- Track the upstream VS Code stable and insider revisions in [[components/upstream-version-metadata]].
- Clone the selected upstream revision with [[actions/run-upstream-fetch]].
- Copy `src/stable` or `src/insider` overlays into the upstream checkout.
- Merge repository `product.json` values into upstream `vscode/product.json`.
- Apply the ordered [[glossary/patch-set]] across shared, quality-specific, platform-specific, and user patch directories.
- Build minified desktop, CLI, and [[glossary/reh]] artifacts.
- Generate Linux, macOS, and Windows package assets through [[components/platform-build-packaging]] and [[components/stores-and-package-managers]].
- Publish artifacts to GitHub releases and update version metadata for update checks.
- Maintain local docs, governance files, and this knowledge base.

## Current upstream snapshot

Both `upstream/stable.json` and `upstream/insider.json` point to:

| Track | VS Code tag | Commit |
|-------|-------------|--------|
| stable | `1.116.0` | `560a9dba96f961efea7b1612916f89e5d5d4d679` |
| insider | `1.116.0` | `560a9dba96f961efea7b1612916f89e5d5d4d679` |

The generated [[glossary/release-version]] adds a day/hour patch counter to the upstream tag unless an explicit `RELEASE_VERSION` is provided.

## Important source signals

- `README.md` explains the upstream VSCodium model and distribution rationale.
- `docs/howto-build.md` documents dependencies, local build flow, CI/downstream build flow, and patch update process.
- `prepare_vscode.sh` is the main mutation step where overlays, product settings, patch application, dependency install, telemetry undo, and platform metadata changes happen.
- `.github/workflows/publish-*.yml` are the durable CI entry points for release production.
- `.claude/worktrees/stoic-davinci-b0cc8e/` is an untracked local worktree containing ShadowIDE-oriented changes; this knowledge base does not treat it as canonical tracked source.

## User-visible product model

The product being built is a VS Code-family editor distribution. Users receive familiar VS Code workbench behavior with project-specific product metadata, assets, extension-gallery defaults, telemetry/service policy changes, packaging, and update routes controlled by this repo. See [[features/extension-marketplace-control]], [[features/telemetry-and-service-hardening]], and [[features/cross-platform-build-and-packaging]].

## Developer model

Developers work mostly in Bash, YAML, JSON, TypeScript helper code, and patch files. Most changes are either:

- build orchestration changes;
- product metadata/branding changes;
- patch changes against upstream VS Code paths;
- packaging/signing/release automation changes;
- documentation or knowledge-base maintenance.

Source edits that change upstream VS Code behavior are usually made as `.patch` files, then validated by applying them during `prepare_vscode.sh` or through the patch refresh workflow.

## Risks and constraints

- Upstream VS Code changes can break patches without any local TypeScript compile error until the patch applies.
- Product identity is split across `utils.sh`, `prepare_vscode.sh`, `product.json`, assets, workflows, docs, and platform package metadata.
- CI workflows rely on external systems such as GitHub releases, SignPath, macOS certificates, Electron downloads, npm packages, Docker images, and optional update metadata repositories.
- Live release actions are side-effecting and require credentials. Action pages in this wiki are contracts, not permission grants.
- The repository includes an untracked `.claude/worktrees/` directory from earlier local work; do not treat it as committed Shadow-IDE source without deliberate review.

## Related pages

- [[architecture/overview]]
- [[architecture/tech-stack]]
- [[code-structure]]
- [[features/cross-platform-build-and-packaging]]
- [[workflows/upstream-release-publish]]
- [[index]]
