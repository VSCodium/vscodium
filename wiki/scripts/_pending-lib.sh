#!/usr/bin/env bash
# _pending-lib.sh — shared helpers for safe concurrent access to pending-ingest.txt
#
# Sourced by track-change.sh, bash-mutation-watch.sh, session-start.sh,
# prompt-banner.sh, and run-ingest.sh. Two parallel Claude sessions writing the
# same project would otherwise race on appends (TOCTOU between dedup check and
# echo >>) and on read+delete (run-ingest.sh deletes after ingest while another
# tool-use is still appending).
#
# Strategy:
#   - Prefer `flock` (Linux always, macOS via homebrew util-linux). 5s timeout
#     on contention so a stuck lock doesn't hang Claude indefinitely.
#   - Fall back to a best-effort O_APPEND-only path when flock is missing.
#     POSIX guarantees atomic writes under PIPE_BUF (~4KB) for O_APPEND, so
#     simple appends are still safe; only the dedup-check race remains.
#
# All callers must source this file with:
#   source "$(dirname "${BASH_SOURCE[0]}")/_pending-lib.sh"

# Set PENDING_LOCK once per script. Default: alongside the pending file.
: "${PENDING_FILE:?PENDING_FILE must be set before sourcing _pending-lib.sh}"
PENDING_LOCK="${PENDING_LOCK:-$PENDING_FILE.lock}"

_kbmap_have_flock() { command -v flock >/dev/null 2>&1; }

# Internal: the actual dedup-check + append. Defined as a function so it runs
# in-process (subshell inherits functions and vars; bash -c does not inherit
# non-exported vars, which is why we avoid it here).
_kbmap_dedup_append() {
    local path="$1"
    if ! grep -qxF -- "$path" "$PENDING_FILE" 2>/dev/null; then
        printf '%s\n' "$path" >> "$PENDING_FILE"
    fi
}

# pending_with_lock <mode> <command...>
#   mode: "shared" (read) or "exclusive" (write)
#   command: any callable (typically a function name) operating on $PENDING_FILE
#
# Example:
#   pending_with_lock exclusive _kbmap_dedup_append "/some/path"
pending_with_lock() {
    local mode="$1"; shift
    local flag
    case "$mode" in
        shared)    flag="-s" ;;
        exclusive) flag="-x" ;;
        *) echo "[_pending-lib] bad mode: $mode" >&2; return 2 ;;
    esac

    # Ensure parent dir exists for the lock file.
    mkdir -p "$(dirname "$PENDING_LOCK")"

    if _kbmap_have_flock; then
        # 5-second wait; on timeout, fall through to running unlocked rather
        # than dropping the operation. flock -w returns 1 on timeout.
        (
            flock -w 5 "$flag" 9 || \
                echo "[_pending-lib] flock timeout on $PENDING_LOCK; running unlocked" >&2
            "$@"
        ) 9>>"$PENDING_LOCK"
    else
        # No flock: best-effort. Document the limitation once per script run.
        if [ -z "${_KBMAP_FLOCK_WARNED:-}" ]; then
            echo "[_pending-lib] flock not found; running without locks (install util-linux or brew install flock)" >&2
            export _KBMAP_FLOCK_WARNED=1
        fi
        "$@"
    fi
}

# pending_append_unique <path>
#   Append <path> to $PENDING_FILE only if not already present.
#   Holds an exclusive lock across the dedup-check + append window.
pending_append_unique() {
    local path="$1"
    [ -z "$path" ] && return 0
    pending_with_lock exclusive _kbmap_dedup_append "$path"
}
