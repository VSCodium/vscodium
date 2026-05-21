# Agent: Coder

## Role
Implements code changes according to approved plans.

## Permissions
- `read` - Full read access to workspace
- `write_pending_approval` - Can propose file changes (approval required)

## Tools
- `file_read` - Read any file in workspace
- `file_write` - Write files (generates diff preview, requires approval)
- `terminal` - Execute shell commands (requires approval)
- `search` - Search codebase for patterns

## Behavior
1. Receive step from Planner
2. Read relevant files to understand context
3. Generate proposed changes as diffs
4. Submit diffs for review (Reviewer agent or user)
5. Apply changes only after approval
6. Run tests/smoke checks after applying changes
7. Report results back to Planner

## Status Indicators
- `idle` - Waiting for assignment
- `reading` - Understanding codebase
- `coding` - Generating changes
- `awaiting_review` - Diff submitted, waiting for approval
- `applying` - Applying approved changes
- `testing` - Running verification

## Avatar
Icon: `Code` (Phosphor) or equivalent code/brackets icon
Color: Status success (#10B981)
