#!/usr/bin/env bash
# track-change.sh — PostToolUse hook for Claude Code
#
# Called after Edit, Write, or MultiEdit tool use.
# Reads the tool call JSON from stdin, extracts modified file paths,
# filters out wiki/ and .claude/ files, and appends them to
# .claude/pending-ingest.txt — concurrency-safe via _pending-lib.sh.
#
# Claude Code passes hook data as JSON on stdin:
#   { "tool_name": "Edit", "tool_input": { "file_path": "..." }, ... }
#   { "tool_name": "MultiEdit", "tool_input": { "edits": [{"file_path": "..."}, ...] } }
#
# Dependency chain for JSON parsing (T7 — no hard python3 requirement):
#   1. jq      (preferred; purpose-built, available on every modern dev env)
#   2. node    (Replit and most JS-flavored envs ship node)
#   3. python3 (macOS default and most Linux distros)
#   4. exits 1 with a clear install hint
#
# Concurrency safety (T5): all writes to pending-ingest.txt go through
# pending_append_unique() which holds an exclusive flock during the
# dedup-check + append window. flock unavailable → best-effort fallback.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PENDING_FILE="$PROJECT_ROOT/.claude/pending-ingest.txt"

# Source the locking library (defines pending_append_unique).
# shellcheck source=_pending-lib.sh
source "$SCRIPT_DIR/_pending-lib.sh"

# Read stdin JSON
INPUT="$(cat)"

# Parse: extract file paths from the tool_input shape
# Handles both Claude Code (Edit, Write, MultiEdit) and Gemini CLI (write_file, replace, etc.)
extract_paths() {
    if command -v jq >/dev/null 2>&1; then
        jq -r '
            if .tool_name == "Edit" or .tool_name == "Write" or .tool_name == "write_file" or .tool_name == "replace" or .tool_name == "replace_file" or .tool_name == "edit_file" or .tool_name == "StrReplace" then
                (.tool_input.file_path // .tool_input.path // empty)
            elif .tool_name == "MultiEdit" then
                (.tool_input.edits // []) | .[] | (.file_path // .path // empty)
            else
                empty
            end
        '
    elif command -v node >/dev/null 2>&1; then
        node -e '
            let raw = "";
            process.stdin.on("data", c => raw += c);
            process.stdin.on("end", () => {
                try {
                    const d = JSON.parse(raw);
                    const t = d.tool_name || "";
                    const i = d.tool_input || {};
                    const out = [];
                    const editTools = ["Edit", "Write", "write_file", "replace", "replace_file", "edit_file", "StrReplace"];
                    if (editTools.includes(t)) {
                        const path = i.file_path || i.path;
                        if (path) out.push(path);
                    } else if (t === "MultiEdit") {
                        for (const e of (i.edits || [])) {
                            if (e) {
                                const path = e.file_path || e.path;
                                if (path) out.push(path);
                            }
                        }
                    }
                    process.stdout.write(out.join("\n") + (out.length ? "\n" : ""));
                } catch (_) { /* silent: malformed input → no paths */ }
            });
        '
    elif command -v python3 >/dev/null 2>&1; then
        python3 - <<'PYEOF'
import json, sys
try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)
tool_name = data.get("tool_name", "")
tool_input = data.get("tool_input", {}) or {}
edit_tools = ("Edit", "Write", "write_file", "replace", "replace_file", "edit_file", "StrReplace")
if tool_name in edit_tools:
    fp = tool_input.get("file_path") or tool_input.get("path")
    if fp:
        print(fp)
elif tool_name == "MultiEdit":
    for edit in (tool_input.get("edits", []) or []):
        fp = (edit or {}).get("file_path") or (edit or {}).get("path")
        if fp:
            print(fp)
PYEOF
    else
        echo "[track-change.sh] ERROR: no JSON parser available (jq, node, or python3 required)." >&2
        echo "[track-change.sh] Install one: 'brew install jq' or 'apt install jq'." >&2
        return 1
    fi
}

FILE_PATHS="$(printf '%s' "$INPUT" | extract_paths || true)"

if [ -z "$FILE_PATHS" ]; then
    exit 0
fi

# Ensure .claude/ directory exists
mkdir -p "$PROJECT_ROOT/.claude"

# Filter and append paths, skipping wiki/ and .claude/ files
while IFS= read -r path; do
    [ -z "$path" ] && continue

    # Resolve to absolute path if relative
    if [[ "$path" != /* ]]; then
        path="$PROJECT_ROOT/$path"
    fi

    # Skip wiki/ files (we don't ingest wiki changes).
    # Match literal "$PROJECT_ROOT/wiki/..." rather than "*/wiki/*" — the latter
    # would also match a wiki/ subdirectory under any other folder name.
    [[ "$path" == "$PROJECT_ROOT/wiki/"* ]] && continue

    # Skip the project's .claude/ directory.
    # Match literal "$PROJECT_ROOT/.claude/..." rather than "*/.claude/*" — the
    # latter incorrectly matches every file when the project itself sits under
    # a parent .claude/ directory (e.g. inside a Claude Code worktree at
    # <parent>/.claude/worktrees/<name>/).
    [[ "$path" == "$PROJECT_ROOT/.claude/"* ]] && continue

    # Skip paths outside the project entirely. The hook is project-scoped —
    # files outside PROJECT_ROOT can't meaningfully participate in /ingest.
    # Catches: ~/.claude/plans/<file>.md (plan-mode files), cross-repo edits
    # (e.g. when you write a wiki snapshot from a worktree of another repo),
    # absolute paths under /Users/x/other-project/. The kbmap workflow is
    # per-project; cross-project ingest belongs in Stage 2 vault import, not
    # in this PostToolUse hook.
    [[ "$path" != "$PROJECT_ROOT/"* ]] && continue

    # Skip /dev/* always, and skip /tmp/* only when it is outside the project.
    # CI/bootstrap smoke tests may intentionally create the entire project under
    # /tmp, so project-owned /tmp paths must remain ingest candidates.
    case "$path" in /dev/*) continue ;; esac

    pending_append_unique "$path"
done <<< "$FILE_PATHS"

exit 0
