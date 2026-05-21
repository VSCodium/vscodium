# Skill: Diff Apply

## Trigger
- `diff_approved` - When a diff preview is approved by the user
- `edit_requested` - When a file edit is requested

## Scope
Generate, preview, and apply file diffs with explicit approval.

## Steps
1. Generate the proposed change as a unified diff
2. Display diff preview to user (additions in green, removals in red)
3. Await explicit approval (approve/reject/modify)
4. On approval: apply the diff atomically
5. On rejection: discard and log
6. Log all actions to activity log

## Safety Rules
- Never apply changes without preview and approval
- Create a backup before applying (in-memory or temp file)
- If apply fails, roll back and report
- Show exact line numbers and file paths

## Permissions Required
- `read` - to read current file state
- `write_pending_approval` - writes require explicit user approval
- `approve` / `reject` - user-facing actions

## Attribution
Original skill for Cursor ING. No external source.
