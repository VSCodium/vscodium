#!/usr/bin/env bash
# bash-mutation-watch.sh — PostToolUse(Bash) hook for Claude Code
#
# track-change.sh only watches Edit / Write / MultiEdit. But agents routinely
# mutate files via Bash: `sed -i`, `mv`, redirections (`> FILE`), `git checkout`,
# `cp`, `tee`, `curl -o`, etc. Without this hook, those mutations slip past
# pending-ingest.txt and the wiki goes stale silently.
#
# Heuristic file-mutation detector. Reads the Bash command from the hook stdin
# and appends candidate paths to pending-ingest.txt. The plan (T6) accepts
# false positives over false negatives — better to ingest a file that didn't
# really change than to skip ingesting one that did.
#
# Patterns covered (single command or `;`/`&&`/`||`-chained):
#   - sed -i [-e ...] FILE          → FILE
#   - mv [flags] SRC DST            → DST (and SRC, since SRC was effectively deleted)
#   - cp [flags] SRC DST            → DST
#   - tee [flags] FILE              → FILE
#   - rm [flags] FILE               → FILE (deletion is still a wiki-relevant signal)
#   - touch [flags] FILE            → FILE
#   - > FILE / >> FILE / N> FILE    → FILE
#   - curl -o FILE / curl --output FILE / wget -O FILE
#   - git checkout [--] FILES       → FILES
#   - git restore [--] FILES        → FILES
#   - git apply / git am            → flagged with no path (forces ingest of all changed files via fallback)
#   - python -c "open('F','w')..."  → NOT detected (out of scope; rare in practice)
#
# Patterns NOT covered (documented limits):
#   - Heredocs writing to files (`cat > F <<EOF`)  — actually covered by `> F` detection
#   - Subshells / process substitutions          — best-effort
#   - Pipe chains where final stage writes a file via tool we don't recognize

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PENDING_FILE="$PROJECT_ROOT/.claude/pending-ingest.txt"

# shellcheck source=_pending-lib.sh
source "$SCRIPT_DIR/_pending-lib.sh"

INPUT="$(cat)"

# Extract the command string. Same parser ladder as track-change.sh.
extract_command() {
    if command -v jq >/dev/null 2>&1; then
        jq -r '.tool_input.command // empty'
    elif command -v node >/dev/null 2>&1; then
        node -e '
            let raw = "";
            process.stdin.on("data", c => raw += c);
            process.stdin.on("end", () => {
                try {
                    const d = JSON.parse(raw);
                    const cmd = (d.tool_input && d.tool_input.command) || "";
                    process.stdout.write(cmd);
                } catch (_) {}
            });
        '
    elif command -v python3 >/dev/null 2>&1; then
        python3 -c '
import json, sys
try:
    d = json.load(sys.stdin)
    print((d.get("tool_input") or {}).get("command", ""), end="")
except Exception:
    pass
'
    else
        echo "[bash-mutation-watch.sh] ERROR: need jq, node, or python3 for JSON parsing." >&2
        return 1
    fi
}

CMD="$(printf '%s' "$INPUT" | extract_command || true)"
[ -z "$CMD" ] && exit 0

mkdir -p "$PROJECT_ROOT/.claude"

# add_candidate <path>
#   Filter wiki/, .claude/, and obviously-non-source paths, then queue.
add_candidate() {
    local p="$1"
    [ -z "$p" ] && return 0
    # Strip surrounding quotes if any.
    p="${p%\'}"; p="${p#\'}"
    p="${p%\"}"; p="${p#\"}"
    # Resolve relative paths against project root.
    [[ "$p" != /* ]] && p="$PROJECT_ROOT/$p"
    # Skip the project's own wiki/ and .claude/ — match literal "$PROJECT_ROOT/..."
    # to avoid false matches when the project itself sits under a parent .claude/
    # (e.g. inside a Claude Code worktree at <parent>/.claude/worktrees/<name>/).
    case "$p" in
        "$PROJECT_ROOT/wiki/"*|"$PROJECT_ROOT/.claude/"*) return 0 ;;
    esac
    # Skip .git/ and common non-source dirs anywhere in the path.
    case "$p" in
        */.git/*|*/node_modules/*|*/__pycache__/*|*/.venv/*|*/venv/*|*/dist/*|*/build/*) return 0 ;;
    esac
    # Skip /dev/* and /tmp/* — never sources.
    case "$p" in /dev/*|/tmp/*) return 0 ;; esac
    # Skip paths still containing an un-expanded shell variable (e.g. a literal
    # "$tmp" or "${FOO}"). bash-mutation-watch parses the raw command string,
    # so any token that referenced a shell variable arrives here un-expanded —
    # the resulting "$PROJECT_ROOT/$tmp" is a phantom path that doesn't exist
    # on disk and pollutes pending-ingest.txt as a false positive. A real
    # source-file path containing `$` is exceedingly rare and would still be
    # caught via the Edit/Write hooks if it changed.
    case "$p" in *\$*) return 0 ;; esac
    # Shape-plausibility filter for non-existent paths. The parser sometimes
    # mistakes shell operators ("|") or command names ("bash") for filenames
    # (e.g. from `cmd | bash script.sh` where the parser lifts "bash" as a
    # token), which after PROJECT_ROOT prefixing become phantom paths like
    # "$PROJECT_ROOT/bash". A real file path either exists on disk OR contains
    # at least one directory separator beyond PROJECT_ROOT OR has a file
    # extension. Anything else is almost certainly a parser false positive.
    # (Trade-off: a deleted top-level extensionless file like `gradlew` would
    # be missed. Acceptable because such files are essentially never edited
    # in a real workflow, and any genuine change would be caught by the
    # Edit/Write hooks.)
    if [ ! -e "$p" ]; then
        suffix="${p#"$PROJECT_ROOT/"}"
        case "$suffix" in
            */*|*.*) ;;                  # subdir or extension — plausible
            *) return 0 ;;               # bare token — drop
        esac
    fi
    # Skip paths outside the project entirely. After all the in-project
    # filters above, anything that survives but isn't under PROJECT_ROOT
    # is a cross-project / cross-repo file — those don't participate in
    # this project's /ingest. (Catches paths the parser captured from
    # shell commands that referenced absolute paths in other directories.)
    [[ "$p" != "$PROJECT_ROOT/"* ]] && return 0
    pending_append_unique "$p"
}

# Split the command on `;`, `&&`, `||`, `|`, newline. Crude but effective.
# Use awk to normalize separators to newlines, then read line-by-line.
NORMALIZED="$(printf '%s' "$CMD" | awk '
    {
        gsub(/&&/, "\n"); gsub(/\|\|/, "\n"); gsub(/;/, "\n");
        # Do NOT split on single | because that would break our redirect detector for `tee`
        # and pipe-fed tools; we accept that some pipelines may slip through.
        print
    }
')"

while IFS= read -r piece; do
    # Trim leading/trailing whitespace.
    piece="$(printf '%s' "$piece" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    [ -z "$piece" ] && continue

    # Detect: redirections `> FILE`, `>> FILE`, `N> FILE` (N is a digit)
    while [[ "$piece" =~ (^|[[:space:]])([0-9]?\>{1,2})[[:space:]]*([^[:space:]\;\&\|]+) ]]; do
        candidate="${BASH_REMATCH[3]}"
        add_candidate "$candidate"
        # Strip the matched portion to find more redirects.
        piece="${piece/${BASH_REMATCH[0]}/ }"
    done

    # Tokenize on whitespace for the command-shape detectors.
    # shellcheck disable=SC2206
    tokens=( $piece )
    [ "${#tokens[@]}" -eq 0 ] && continue

    cmd_name="${tokens[0]}"
    # Strip leading env var assignments like `FOO=bar cmd ...`
    while [[ "$cmd_name" =~ ^[A-Za-z_][A-Za-z0-9_]*= ]]; do
        tokens=( "${tokens[@]:1}" )
        [ "${#tokens[@]}" -eq 0 ] && break
        cmd_name="${tokens[0]}"
    done
    [ "${#tokens[@]}" -eq 0 ] && continue

    case "$cmd_name" in
        sed)
            # Look for -i (in-place) and treat the last non-flag arg as the file.
            inplace=0
            for t in "${tokens[@]:1}"; do
                if [[ "$t" == "-i" || "$t" == -i\.* || "$t" == "--in-place" ]]; then inplace=1; break; fi
            done
            if [ "$inplace" -eq 1 ]; then
                # Last token that doesn't start with `-` and isn't an expression after -e
                last_file=""
                skip_next=0
                for t in "${tokens[@]:1}"; do
                    if [ "$skip_next" -eq 1 ]; then skip_next=0; continue; fi
                    case "$t" in
                        -e|-f|--expression|--file) skip_next=1 ;;
                        -*) ;;
                        *) last_file="$t" ;;
                    esac
                done
                add_candidate "$last_file"
            fi
            ;;
        mv|cp)
            # Last non-flag token is the destination; second-to-last is the source.
            srcs=()
            for t in "${tokens[@]:1}"; do
                case "$t" in -*) ;; *) srcs+=( "$t" ) ;; esac
            done
            n="${#srcs[@]}"
            if [ "$n" -ge 2 ]; then
                # Destination
                add_candidate "${srcs[$((n-1))]}"
                # All sources (could be globs; just record literally)
                for ((i=0; i<n-1; i++)); do add_candidate "${srcs[$i]}"; done
            fi
            ;;
        rm|touch)
            for t in "${tokens[@]:1}"; do
                case "$t" in -*) ;; *) add_candidate "$t" ;; esac
            done
            ;;
        tee)
            # tee writes to one or more files (last positional args).
            for t in "${tokens[@]:1}"; do
                case "$t" in -*) ;; *) add_candidate "$t" ;; esac
            done
            ;;
        curl)
            # -o FILE or --output FILE
            i=1
            while [ "$i" -lt "${#tokens[@]}" ]; do
                t="${tokens[$i]}"
                if [ "$t" = "-o" ] || [ "$t" = "--output" ]; then
                    next="${tokens[$((i+1))]:-}"
                    [ -n "$next" ] && add_candidate "$next"
                fi
                i=$((i+1))
            done
            ;;
        wget)
            # -O FILE
            i=1
            while [ "$i" -lt "${#tokens[@]}" ]; do
                t="${tokens[$i]}"
                if [ "$t" = "-O" ] || [ "$t" = "--output-document" ]; then
                    next="${tokens[$((i+1))]:-}"
                    [ -n "$next" ] && add_candidate "$next"
                fi
                i=$((i+1))
            done
            ;;
        git)
            sub="${tokens[1]:-}"
            case "$sub" in
                checkout|restore)
                    # Detect branch-creation forms: -b / -B / --orphan create a
                    # branch from positional args, which are git refs
                    # (NEW_BRANCH [START_POINT]), NOT file paths. Capturing them
                    # as candidates pollutes pending-ingest with phantom paths
                    # (e.g. "claude/some-feature", "origin/main"). Skip the
                    # entire handler in that case.
                    is_branch_creation=0
                    for t in "${tokens[@]:2}"; do
                        case "$t" in
                            -b|-B|--orphan) is_branch_creation=1 ;;
                        esac
                    done
                    if [ "$is_branch_creation" -eq 0 ]; then
                        # Files come after `--`, or after the subcommand if
                        # no flags/refs. Without `--`, positional args may be
                        # branch refs that get filtered by shape-plausibility
                        # (no subdir + no extension → drop) or by the
                        # outside-PROJECT_ROOT check.
                        saw_sep=0
                        for t in "${tokens[@]:2}"; do
                            if [ "$saw_sep" -eq 1 ]; then add_candidate "$t"; continue; fi
                            if [ "$t" = "--" ]; then saw_sep=1; continue; fi
                            case "$t" in -*) ;; *) add_candidate "$t" ;; esac
                        done
                    fi
                    ;;
                apply|am)
                    # We can't know which files without parsing the patch.
                    # Append a sentinel so the user/agent knows something git-applied
                    # without listed files. The /ingest workflow can `git diff` to reconcile.
                    pending_append_unique "$PROJECT_ROOT/<git-${sub}>"
                    ;;
            esac
            ;;
    esac
done <<< "$NORMALIZED"

exit 0
