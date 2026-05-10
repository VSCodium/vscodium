#!/usr/bin/env bash
# run-ingest.sh — Manual ingest trigger (NOT installed as a Stop hook anymore)
#
# Spawns a sub-agent (claude --print or codex -q) to run the ingest workflow
# against .claude/pending-ingest.txt. Runs SYNCHRONOUSLY — caller blocks.
#
# Use cases:
#   - Codex/Replit users who want a sub-process to do the work
#   - CI runners that need ingest after a batched commit
#   - Manual one-off invocation when SessionStart/UserPromptSubmit reminders
#     have been ignored
#
# Authentication (T10):
#   When using `claude` as the sub-agent, one of the following must be true,
#   or the agent will fail to authenticate:
#     - $ANTHROPIC_API_KEY is set in the environment, OR
#     - You are logged in via `claude login` (credentials stored in
#       ~/.claude/config or platform-equivalent)
#   This script warns loudly if neither appears configured but does not exit —
#   we let `claude` itself produce the canonical auth error if it fails.
#   Codex auth is governed by Codex's own configuration; we do not check it here.
#
# On success: clears pending-ingest.txt
# On failure: leaves pending-ingest.txt intact so the next session retries

set -euo pipefail

# Resolve project root (directory containing wiki/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PENDING_FILE="$PROJECT_ROOT/.claude/pending-ingest.txt"
PROMPT_FILE="$PROJECT_ROOT/wiki/prompts/ingest.md"

# ---- Recursion guards (T3) -------------------------------------------------
# When invoked as a Claude Code Stop hook, Claude pipes a JSON payload on stdin.
# The child `claude --print` we spawn below inherits this project's
# .claude/settings.json, so its own Stop hook will fire and re-enter this script
# unless we break the loop.
#
# Three layered guards:
#   1. Read stdin (if any) and bail if `stop_hook_active: true` — Claude Code's
#      official mechanism for breaking Stop-hook recursion.
#   2. Bail if the KBMAP_INGEST_RUNNING sentinel env var is set — set by us
#      before spawning the child agent, inherited by the child process tree.
#   3. Bail if $CLAUDE_PROJECT_DIR is set and disagrees with PROJECT_ROOT —
#      defense-in-depth for nested invocations across projects.
#
# Manual invocations (e.g. from Codex or by hand) have an empty/absent stdin
# and no env vars, so they pass through cleanly.
HOOK_INPUT=""
if [ ! -t 0 ]; then
    # stdin is a pipe/file — drain it (non-blocking via cat is fine; Claude
    # closes the pipe immediately after writing the JSON payload).
    HOOK_INPUT="$(cat || true)"
fi

if [ -n "$HOOK_INPUT" ]; then
    STOP_ACTIVE=""
    if command -v jq >/dev/null 2>&1; then
        STOP_ACTIVE="$(printf '%s' "$HOOK_INPUT" | jq -r '.stop_hook_active // false' 2>/dev/null || echo false)"
    else
        # Pure-bash fallback — robust enough for the tiny JSON shape Claude sends.
        if printf '%s' "$HOOK_INPUT" | grep -Eq '"stop_hook_active"[[:space:]]*:[[:space:]]*true'; then
            STOP_ACTIVE="true"
        else
            STOP_ACTIVE="false"
        fi
    fi
    if [ "$STOP_ACTIVE" = "true" ]; then
        echo "[run-ingest.sh] stop_hook_active=true — skipping to prevent recursion." >&2
        exit 0
    fi
fi

if [ -n "${KBMAP_INGEST_RUNNING:-}" ]; then
    echo "[run-ingest.sh] KBMAP_INGEST_RUNNING already set — skipping nested invocation." >&2
    exit 0
fi

if [ -n "${CLAUDE_PROJECT_DIR:-}" ] && [ "$CLAUDE_PROJECT_DIR" != "$PROJECT_ROOT" ]; then
    echo "[run-ingest.sh] CLAUDE_PROJECT_DIR ($CLAUDE_PROJECT_DIR) != PROJECT_ROOT ($PROJECT_ROOT) — skipping cross-project invocation." >&2
    exit 0
fi
# ---- /Recursion guards -----------------------------------------------------

# No pending changes — nothing to do
if [ ! -f "$PENDING_FILE" ] || [ ! -s "$PENDING_FILE" ]; then
    exit 0
fi

# Verify prompt file exists
if [ ! -f "$PROMPT_FILE" ]; then
    echo "[run-ingest.sh] ERROR: $PROMPT_FILE not found. Ingest skipped." >&2
    exit 1
fi

# Build the prompt — the new wiki/prompts/ingest.md (T8) instructs the agent to
# read .claude/pending-ingest.txt itself, so no placeholder substitution is needed.
# We still log the file list for human visibility.
CHANGED_FILES="$(cat "$PENDING_FILE")"
FULL_PROMPT="$(cat "$PROMPT_FILE")"

echo "[run-ingest.sh] Pending changes detected. Starting wiki ingest agent..." >&2
echo "[run-ingest.sh] Changed files:" >&2
echo "$CHANGED_FILES" | sed 's/^/  /' >&2

# Run the ingest agent — prefer claude, fall back to codex.
# NOTE: Claude CLI has no --cwd flag (silently ignored). The correct way to set
# the working directory is to cd first and use --add-dir. --dangerously-skip-permissions
# is required so the child agent can Edit/Write wiki/ files without interactive prompts.
# Capture exit code with `|| rc=$?` so `set -e` doesn't abort before capture.
EXIT_CODE=0
# Export the sentinel so any nested run-ingest.sh invocation (via the child
# agent's inherited Stop hook) sees it and bails — see "Recursion guards" above.
export KBMAP_INGEST_RUNNING=1
if command -v claude &>/dev/null; then
    # T10: Loud warning if claude has no obvious auth source. Don't exit —
    # claude itself prints the canonical error if creds are missing.
    if [ -z "${ANTHROPIC_API_KEY:-}" ] \
       && [ ! -d "$HOME/.claude" ] \
       && [ ! -f "$HOME/.config/claude/config.json" ]; then
        echo "[run-ingest.sh] WARNING: ANTHROPIC_API_KEY is not set and no claude" >&2
        echo "[run-ingest.sh]   credentials directory was found at ~/.claude or" >&2
        echo "[run-ingest.sh]   ~/.config/claude. The sub-agent will likely fail" >&2
        echo "[run-ingest.sh]   to authenticate. Run 'claude login' or export" >&2
        echo "[run-ingest.sh]   ANTHROPIC_API_KEY before retrying." >&2
    fi
    # Pipe the prompt via stdin instead of a positional arg — the prompt starts
    # with YAML frontmatter (`---`) and claude's argparser would otherwise
    # interpret it as an unknown option. `--print` reads stdin when no
    # positional prompt is given.
    (
        cd "$PROJECT_ROOT" && \
        printf '%s' "$FULL_PROMPT" | claude --print \
            --add-dir "$PROJECT_ROOT" \
            --dangerously-skip-permissions
    ) || EXIT_CODE=$?
elif command -v codex &>/dev/null; then
    # Codex non-interactive mode — same stdin pattern for the same reason.
    ( cd "$PROJECT_ROOT" && printf '%s' "$FULL_PROMPT" | codex -q ) || EXIT_CODE=$?
elif command -v gemini &>/dev/null; then
    # Gemini non-interactive mode — use --approval-mode=yolo for auto-edit.
    # Note: gemini --prompt <arg> is the non-interactive entry point.
    ( cd "$PROJECT_ROOT" && gemini --approval-mode=yolo --prompt "$FULL_PROMPT" ) || EXIT_CODE=$?
else
    echo "[run-ingest.sh] ERROR: Neither 'claude', 'codex', nor 'gemini' CLI found. Ingest skipped." >&2
    echo "[run-ingest.sh] Run manually: gemini --prompt \"\$(cat wiki/prompts/ingest.md)\"" >&2
    exit 1
fi

if [ "$EXIT_CODE" -eq 0 ]; then
    rm -f "$PENDING_FILE"
    echo "[run-ingest.sh] Ingest complete. Wiki updated." >&2
else
    echo "[run-ingest.sh] WARNING: Ingest agent exited with code $EXIT_CODE." >&2
    echo "[run-ingest.sh] pending-ingest.txt preserved — will retry next session." >&2
    exit "$EXIT_CODE"
fi
