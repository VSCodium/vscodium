#!/usr/bin/env bash
# session-start.sh — SessionStart hook for Claude Code
#
# Fires when a Claude Code session starts (matchers: startup, resume, clear).
# If .claude/pending-ingest.txt has entries from a previous session, inject a
# context banner so the model sees "wiki ingest pending" at the very start of
# the session and can route to /ingest before doing anything else.
#
# Outputs Claude Code hookSpecificOutput JSON on stdout per:
#   https://code.claude.com/docs/en/hooks-guide.md
#
# This replaces the old Stop-hook-spawns-subagent pattern (T4 in plan):
# - No child `claude` process spawned (no recursion, no API key dependency)
# - No blocking session exit (Stop hooks added latency the user perceived as a hang)
# - Failure mode is graceful: if the script errors, the user just doesn't see
#   the banner — the session still works.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PENDING_FILE="$PROJECT_ROOT/.claude/pending-ingest.txt"

# Nothing pending — exit silently.
if [ ! -f "$PENDING_FILE" ] || [ ! -s "$PENDING_FILE" ]; then
    exit 0
fi

# Count pending files. Use awk so we don't depend on wc -l line-count semantics.
COUNT="$(awk 'NF' "$PENDING_FILE" | wc -l | tr -d ' ')"
FILES="$(awk 'NF' "$PENDING_FILE" | head -20)"
TRUNCATED=""
if [ "$COUNT" -gt 20 ]; then
    TRUNCATED=$'\n  ...and '"$((COUNT - 20))"' more.'
fi

# Build the additionalContext payload. Keep it terse and actionable.
read -r -d '' CONTEXT <<EOF || true
[kbmap] Wiki ingest is pending for ${COUNT} source file(s) modified in a previous session.
Run the /ingest slash command before ending this session, or invoke wiki/prompts/ingest.md directly.

Pending files:
${FILES}${TRUNCATED}
EOF

# Emit Claude Code hookSpecificOutput JSON. Use jq if available, else hand-roll.
if command -v jq >/dev/null 2>&1; then
    jq -n --arg ctx "$CONTEXT" '{
        hookSpecificOutput: {
            hookEventName: "SessionStart",
            additionalContext: $ctx
        }
    }'
else
    # Hand-rolled escape: backslash, double quote, newline. Sufficient for our content.
    ESC="$(printf '%s' "$CONTEXT" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' | awk 'BEGIN{ORS=""} {print (NR==1 ? "" : "\\n") $0}')"
    printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$ESC"
fi

exit 0
