---
slug: shadow-ide/workflow/patch-refresh-after-upstream-change
project_slug: shadow-ide
kind: workflow
audience: [agent, dev]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
features: [shadow-ide/feature/developer-local-build-flow, shadow-ide/feature/telemetry-and-service-hardening, shadow-ide/feature/extension-marketplace-control]
components: [shadow-ide/component/patch-set, shadow-ide/component/root-build-orchestration, shadow-ide/component/documentation-site, shadow-ide/component/font-size-generator]
actions: [shadow-ide/action/run-dev-build]
tags: [patches, maintenance, upstream]
---

# Patch Refresh After Upstream Change

> Maintainer repairs patch files after VS Code source changes cause patch application failures.

## Trigger

`prepare_vscode.sh` fails while applying a patch, usually after changing the upstream VS Code tag/commit.

## Steps

1. **Run a build until failure** - Use `./dev/build.sh` or CI logs to identify the failed patch. (Component: [[components/root-build-orchestration]])
2. **Choose repair mode** - Use `./dev/update_patches.sh` for semi-automated repair or `./dev/patch.sh <name>.patch` for one patch. (Component: [[components/patch-set]])
3. **Open prepared `vscode/`** - Resolve `.rej` files against upstream changes. (Component: [[components/patch-set]])
4. **Validate upstream app** - Run upstream watch/code commands as documented in `docs/howto-build.md`. (Component: [[components/documentation-site]])
5. **Regenerate patch** - Let the helper update the patch file after conflicts are resolved. (Component: [[components/patch-set]])
6. **Rerun build** - Confirm the patch set applies cleanly and the build reaches the next phase. (Workflow: [[workflows/local-development-build]])
7. **Update wiki if behavior changed** - Touch relevant component/feature pages. (Workflow: [[workflows/knowledge-base-maintenance]])

## Decision points

- If the upstream code removed the feature entirely, decide whether to drop, replace, or redesign the patch.
- If the patch is platform-specific, verify only the relevant platform path first, then run broader CI.

## Failure modes

- Patch applies but behavior is wrong -> build passes but runtime tests/review catch mismatch.
- Generated patch includes unrelated source churn -> review patch carefully before commit.
- Branding placeholders lost -> patch may hard-code the wrong product identity.

## Components touched

- [[components/patch-set]]
- [[components/root-build-orchestration]]
- [[components/documentation-site]]
- [[components/font-size-generator]]

## Related features

- [[features/developer-local-build-flow]]
- [[features/telemetry-and-service-hardening]]
- [[features/extension-marketplace-control]]

## Open questions

None at this time.
