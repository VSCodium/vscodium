"""
Cursor ING - Phase 1 Preview Dashboard Backend
FastAPI server that serves mock data from the extension models.
No telemetry, no secrets, no external network calls.
"""

import os
import time
from datetime import datetime, timezone
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="Cursor ING Preview Dashboard", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

AGENTS = [
    {
        "id": "planner",
        "role": "planner",
        "name": "Planner",
        "description": "Analyzes tasks, creates structured plans, coordinates agents",
        "status": "idle",
        "permissions": ["read", "plan"],
        "tools": ["file_read", "search", "plan_create"],
        "icon": "TreeStructure",
        "color": "#05A0F0",
        "lastAction": "Ready",
        "lastActionTime": datetime.now(timezone.utc).isoformat(),
    },
    {
        "id": "coder",
        "role": "coder",
        "name": "Coder",
        "description": "Implements code changes according to approved plans",
        "status": "coding",
        "permissions": ["read", "write_pending_approval"],
        "tools": ["file_read", "file_write", "terminal", "search"],
        "icon": "Code",
        "color": "#10B981",
        "lastAction": "Writing src/auth/jwt.ts",
        "lastActionTime": datetime.now(timezone.utc).isoformat(),
    },
    {
        "id": "reviewer",
        "role": "reviewer",
        "name": "Reviewer",
        "description": "Reviews code changes for correctness and quality",
        "status": "reviewing",
        "permissions": ["read", "approve", "reject"],
        "tools": ["file_read", "diff_view", "comment"],
        "icon": "MagnifyingGlass",
        "color": "#F59E0B",
        "lastAction": "Reviewing diff-001",
        "lastActionTime": datetime.now(timezone.utc).isoformat(),
    },
    {
        "id": "security",
        "role": "security",
        "name": "Security Auditor",
        "description": "Scans for vulnerabilities, secrets, and unsafe patterns",
        "status": "clear",
        "permissions": ["read", "flag"],
        "tools": ["file_read", "search", "vuln_scan"],
        "icon": "Shield",
        "color": "#EF4444",
        "lastAction": "Scan complete: 0 issues",
        "lastActionTime": datetime.now(timezone.utc).isoformat(),
    },
    {
        "id": "browser",
        "role": "browser",
        "name": "Browser Agent",
        "description": "Performs web browsing with explicit user approval",
        "status": "idle",
        "permissions": ["read", "browse_pending_approval"],
        "tools": ["browser_navigate", "screenshot", "accessibility_tree"],
        "icon": "Globe",
        "color": "#05A0F0",
        "lastAction": "Ready [PLACEHOLDER]",
        "lastActionTime": datetime.now(timezone.utc).isoformat(),
    },
]

MOCK_PLAN = {
    "id": "plan-1706000000000",
    "title": "Implement user authentication module",
    "description": "Add JWT-based authentication with login, register, and token refresh endpoints.",
    "status": "approved",
    "createdAt": "2026-01-15T10:00:00.000Z",
    "updatedAt": "2026-01-15T10:30:00.000Z",
    "createdBy": "planner",
    "approvedBy": "user",
    "approvedAt": "2026-01-15T10:15:00.000Z",
    "steps": [
        {
            "id": 1,
            "description": "Read existing auth-related files and understand current patterns",
            "status": "completed",
            "files": ["src/auth/", "src/config/"],
            "risk": "low",
            "notes": "Found existing session middleware to extend",
            "agentId": "planner",
        },
        {
            "id": 2,
            "description": "Create JWT utility with sign/verify functions",
            "status": "completed",
            "files": ["src/auth/jwt.ts"],
            "risk": "medium",
            "notes": "Using jsonwebtoken library, RS256 algorithm",
            "agentId": "coder",
        },
        {
            "id": 3,
            "description": "Implement login and register endpoints",
            "status": "in_progress",
            "files": ["src/routes/auth.ts", "src/models/user.ts"],
            "risk": "medium",
            "notes": "",
            "agentId": "coder",
        },
        {
            "id": 4,
            "description": "Security audit of authentication implementation",
            "status": "pending",
            "files": ["src/auth/", "src/routes/auth.ts"],
            "risk": "high",
            "notes": "",
            "agentId": "security",
        },
        {
            "id": 5,
            "description": "Write integration tests for auth endpoints",
            "status": "pending",
            "files": ["tests/auth.test.ts"],
            "risk": "low",
            "notes": "",
            "agentId": "coder",
        },
    ],
}

MOCK_ACTIVITY = [
    {"id": "log-001", "timestamp": "2026-01-15T10:00:01.000Z", "actor": "system", "category": "extension", "message": "Cursor ING activated", "severity": "info"},
    {"id": "log-002", "timestamp": "2026-01-15T10:00:02.000Z", "actor": "system", "category": "provider", "message": "MockProvider registered", "severity": "info"},
    {"id": "log-003", "timestamp": "2026-01-15T10:01:00.000Z", "actor": "user", "category": "command", "message": "Open Composer", "severity": "info"},
    {"id": "log-004", "timestamp": "2026-01-15T10:02:00.000Z", "actor": "user", "category": "composer", "message": "Sent: 'Create a plan for user authentication'", "severity": "info"},
    {"id": "log-005", "timestamp": "2026-01-15T10:02:01.000Z", "actor": "planner", "category": "plan", "message": "Analyzing task: user authentication module", "severity": "info"},
    {"id": "log-006", "timestamp": "2026-01-15T10:02:05.000Z", "actor": "planner", "category": "file_read", "message": "Reading src/auth/ (4 files)", "severity": "info"},
    {"id": "log-007", "timestamp": "2026-01-15T10:02:10.000Z", "actor": "planner", "category": "file_read", "message": "Reading src/config/database.ts", "severity": "info"},
    {"id": "log-008", "timestamp": "2026-01-15T10:02:15.000Z", "actor": "planner", "category": "plan", "message": "Plan created: 5 steps, 2 medium risk", "severity": "info"},
    {"id": "log-009", "timestamp": "2026-01-15T10:15:00.000Z", "actor": "user", "category": "plan", "message": "Plan approved", "severity": "info"},
    {"id": "log-010", "timestamp": "2026-01-15T10:16:00.000Z", "actor": "planner", "category": "file_read", "message": "Step 1: Reading auth files", "severity": "info"},
    {"id": "log-011", "timestamp": "2026-01-15T10:17:00.000Z", "actor": "planner", "category": "plan", "message": "Step 1 completed", "severity": "info"},
    {"id": "log-012", "timestamp": "2026-01-15T10:18:00.000Z", "actor": "coder", "category": "file_write", "message": "Step 2: Creating src/auth/jwt.ts", "severity": "info"},
    {"id": "log-013", "timestamp": "2026-01-15T10:20:00.000Z", "actor": "security", "category": "scan", "message": "Scanning src/auth/jwt.ts", "severity": "info"},
    {"id": "log-014", "timestamp": "2026-01-15T10:20:05.000Z", "actor": "security", "category": "scan", "message": "No secrets detected. No unsafe patterns.", "severity": "info"},
    {"id": "log-015", "timestamp": "2026-01-15T10:22:00.000Z", "actor": "coder", "category": "plan", "message": "Step 2 completed", "severity": "info"},
    {"id": "log-016", "timestamp": "2026-01-15T10:23:00.000Z", "actor": "coder", "category": "file_write", "message": "Step 3: Writing src/routes/auth.ts", "severity": "info"},
    {"id": "log-017", "timestamp": "2026-01-15T10:25:00.000Z", "actor": "reviewer", "category": "review", "message": "Reviewing diff for src/routes/auth.ts", "severity": "info"},
    {"id": "log-018", "timestamp": "2026-01-15T10:25:30.000Z", "actor": "reviewer", "category": "review", "message": "Info: Consider adding rate limiting to login endpoint", "severity": "warning"},
]

MOCK_DIFF = {
    "id": "diff-001",
    "title": "Add input validation to processRequest",
    "description": "Adds null check and type validation to the processRequest function",
    "agentId": "coder",
    "timestamp": "2026-01-15T10:22:00.000Z",
    "status": "pending",
    "hunks": [
        {
            "filePath": "src/utils/processor.ts",
            "oldContent": 'export function processRequest(input: string): string {\n  const result = input.trim().toLowerCase();\n  return result;\n}',
            "newContent": 'export function processRequest(input: string): string {\n  if (!input || typeof input !== \'string\') {\n    throw new Error(\'Input must be a non-empty string\');\n  }\n  const sanitized = input.replace(/[<>]/g, \'\');\n  const result = sanitized.trim().toLowerCase();\n  return result;\n}',
            "startLine": 1,
            "endLine": 8,
        }
    ],
}

PROVIDERS = [
    {"id": "mock", "name": "Mock Provider (Local)", "type": "mock", "status": "active", "requiresKey": False, "model": "cursor-ing-mock-v1"},
    {"id": "openai", "name": "OpenAI Compatible", "type": "openai-compatible", "status": "planned", "requiresKey": True, "model": "gpt-4o"},
    {"id": "anthropic", "name": "Anthropic Compatible", "type": "anthropic-compatible", "status": "planned", "requiresKey": True, "model": "claude-sonnet-4"},
    {"id": "ollama", "name": "Ollama (Local)", "type": "ollama-local", "status": "planned", "requiresKey": False, "model": "codellama"},
    {"id": "openrouter", "name": "OpenRouter", "type": "openrouter-compatible", "status": "planned", "requiresKey": True, "model": "auto"},
]

MOCK_RESPONSES = {
    "default": "I am the Cursor ING mock provider. I produce deterministic responses for testing. No API key required.",
    "plan": "Here is a structured plan:\n\n1. **Analyze** - Read relevant files\n2. **Design** - Propose approach\n3. **Implement** - Write code changes as diffs\n4. **Review** - Check correctness and security\n5. **Test** - Verify changes\n\nEach step requires explicit approval.",
    "code": "```typescript\nexport function processRequest(input: string): string {\n  if (!input || input.trim().length === 0) {\n    throw new Error('Input must not be empty');\n  }\n  return input.trim().toLowerCase();\n}\n```",
    "review": "## Code Review\n\n**Verdict**: Approved with minor suggestions\n\n1. Line 5 - Consider type validation\n2. Line 12 - Handle unicode\n3. Line 18 - Error handling present",
    "security": "## Security Scan: Clear\n\n- No hardcoded secrets\n- No telemetry code\n- No unsafe eval/exec\n- Input validation present",
}

SCAFFOLD_STATS = {
    "totalFiles": 53,
    "extensionFiles": 12,
    "agentDefinitions": 5,
    "skills": 3,
    "modelAdapters": 5,
    "brainDocs": 6,
    "providers": 5,
    "planSteps": 5,
    "activityEntries": 18,
}


@app.get("/api/health")
async def health():
    return {
        "status": "ok",
        "product": "Cursor ING",
        "phase": 1,
        "version": "0.1.0",
        "telemetry": False,
    }


@app.get("/api/stats")
async def get_stats():
    return SCAFFOLD_STATS


@app.get("/api/agents")
async def get_agents():
    return AGENTS


@app.get("/api/agents/{agent_id}")
async def get_agent(agent_id: str):
    agent = next((a for a in AGENTS if a["id"] == agent_id), None)
    if not agent:
        return {"error": "Agent not found"}
    return agent


@app.get("/api/plans")
async def get_plans():
    return [MOCK_PLAN]


@app.get("/api/plans/{plan_id}")
async def get_plan(plan_id: str):
    if plan_id == MOCK_PLAN["id"]:
        return MOCK_PLAN
    return {"error": "Plan not found"}


@app.get("/api/activity")
async def get_activity():
    return MOCK_ACTIVITY


@app.get("/api/diff")
async def get_diffs():
    return [MOCK_DIFF]


@app.get("/api/diff/{diff_id}")
async def get_diff(diff_id: str):
    if diff_id == MOCK_DIFF["id"]:
        return MOCK_DIFF
    return {"error": "Diff not found"}


@app.get("/api/providers")
async def get_providers():
    return PROVIDERS


@app.post("/api/composer/chat")
async def composer_chat(body: dict):
    message = body.get("message", "").lower()
    if "plan" in message or "task" in message:
        response = MOCK_RESPONSES["plan"]
    elif "code" in message or "implement" in message or "write" in message:
        response = MOCK_RESPONSES["code"]
    elif "review" in message or "check" in message:
        response = MOCK_RESPONSES["review"]
    elif "security" in message or "scan" in message:
        response = MOCK_RESPONSES["security"]
    else:
        response = MOCK_RESPONSES["default"]

    return {
        "response": response,
        "model": "cursor-ing-mock-v1",
        "provider": "mock",
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }


@app.get("/api/scaffold/validate")
async def validate_scaffold():
    import subprocess
    result = subprocess.run(
        ["bash", "/app/.agents/validate.sh"],
        capture_output=True,
        text=True,
        timeout=10,
    )
    return {
        "exitCode": result.returncode,
        "passed": result.returncode == 0,
        "output": result.stdout,
    }
