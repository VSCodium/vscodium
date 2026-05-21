# Skill: Code Review

## Trigger
- `review_request` - When a diff or changeset needs review
- `pr_opened` - When a pull request is opened

## Scope
Read-only analysis of code changes. No file modifications.

## Steps
1. Read the diff or changed files
2. Identify: bugs, security issues, style violations, performance concerns
3. Produce structured review with:
   - severity (critical/warning/info)
   - file path and line number
   - description
   - suggested fix (as comment, not applied)
4. Log review actions to activity log

## Permissions Required
- `read` - to access files and diffs
- `comment` - to add review comments

## Tests
- Given a diff with an obvious bug, the skill should flag it
- Given clean code, the skill should produce minimal feedback
- All actions should appear in the activity log

## Attribution
Original skill for Cursor ING. No external source.
