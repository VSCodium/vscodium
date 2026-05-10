---
description: Run a wiki maintenance pass — broken-link repair, staleness flagging, cross-reference cleanup
argument-hint: [full|targeted: <scope>]
---

Read `wiki/prompts/lint.md` and execute the workflow it describes in full.

If $ARGUMENTS contains a scope (e.g. "targeted: components/auth"), pass that into Phase L-0 as the scope for this lint session. If empty, ask the user whether to run a full lint or a targeted lint before proceeding.
