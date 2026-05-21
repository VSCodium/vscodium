# .agents/vendor/ - Raw Open-Source Inspiration References

This directory holds raw open-source references used as inspiration for Cursor ING.

## Rules
1. **Read-only.** Never modify files in this directory directly.
2. **Updated by git pull** from upstream repositories.
3. **Never copied blindly** into production code.
4. **Inspiration only** until license review is complete.

## Planned References

| Source | License | Status | Inspiration For |
|--------|---------|--------|-----------------|
| Clicky | TBD | Pending review | Agent visualization in files |
| agent-browser | TBD | Pending review | Browser-use panel |
| Plannotator | TBD | Pending review | Plan review/annotation |
| OpenSwarm | TBD | Pending review | Orchestrator/helper agents |
| oh-my-claudecode | TBD | Pending review | Interview/plan/execute loop |
| oh-my-codex | TBD | Pending review | Interview/plan/execute loop |
| oh-my-openagent | TBD | Pending review | Model-agnostic orchestration |
| claude-for-legal | TBD | Pending review | Legal/document workflow |

## Adding a Reference
1. Create a subdirectory: `.agents/vendor/{project-name}/`
2. Add the upstream README and LICENSE
3. Document in this file with license status
4. Do NOT import code until license is verified as compatible (MIT, Apache 2.0, BSD)
