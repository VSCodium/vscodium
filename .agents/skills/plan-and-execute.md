# Skill: Plan and Execute

## Trigger
- `task_assigned` - When a new task is assigned to an agent
- `plan_requested` - When user explicitly requests a plan

## Scope
Create a structured plan, get approval, then execute steps.

## Steps
1. Analyze the task requirements
2. Read relevant files to understand context
3. Create a plan with numbered steps:
   - Each step has: description, files involved, risk level, status
4. Present plan for user approval
5. On approval, execute steps one at a time
6. After each step: log action, update plan status
7. If a step fails: pause, report, await guidance

## Plan File Format
```json
{
  "id": "plan-{timestamp}",
  "title": "Task description",
  "status": "draft|approved|in_progress|completed|failed",
  "steps": [
    {
      "id": 1,
      "description": "...",
      "status": "pending|in_progress|completed|failed|skipped",
      "files": ["path/to/file"],
      "risk": "low|medium|high",
      "notes": ""
    }
  ]
}
```

## Permissions Required
- `read` - to analyze codebase
- `plan` - to create plan files
- `write_pending_approval` - to execute approved steps

## Attribution
Original skill for Cursor ING. Inspired by oh-my-claudecode plan approval flow.
