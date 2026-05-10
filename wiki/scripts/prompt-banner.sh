#!/usr/bin/env bash
# prompt-banner.sh — UserPromptSubmit hook for Claude Code
#
# Fires before Claude processes each user prompt. If wiki ingest is pending
# from earlier code changes in this session, inject a one-line reminder so
# the model is forced to acknowledge the debt every turn until /ingest runs.
#
# This is a stronger guarantee than SessionStart alone (which only fires once
# at session start). UserPromptSubmit fires on every prompt — the reminder
# stays visible until pending-ingest.txt is cleared.
#
# Outputs Claude Code hookSpecificOutput JSON on stdout per:
#   https://code.claude.com/docs/en/hooks-guide.md

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PENDING_FILE="$PROJECT_ROOT/.claude/pending-ingest.txt"

# Nothing pending — exit silently.
if [ ! -f "$PENDING_FILE" ] || [ ! -s "$PENDING_FILE" ]; then
    exit 0
fi

COUNT="$(awk 'NF' "$PENDING_FILE" | wc -l | tr -d ' ')"

# Keep the per-prompt banner compact — just a count and the action.
CONTEXT="[kbmap] Wiki ingest pending for ${COUNT} file(s). Run /ingest before ending the session, or read wiki/prompts/ingest.md and execute the workflow."

if command -v jq >/dev/null 2>&1; then
    jq -n --arg ctx "$CONTEXT" '{
        hookSpecificOutput: {
            hookEventName: "UserPromptSubmit",
            additionalContext: $ctx
        }
    }'
else
    ESC="$(printf '%s' "$CONTEXT" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g')"
    printf '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"%s"}}\n' "$ESC"
fi

exit 0
