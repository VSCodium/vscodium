#!/usr/bin/env bash
#
# dev/clean_codex.sh — Remove all Codex application data from macOS user directories.
#
# Use this to reset Codex to a clean state: wipes preferences, caches, saved
# window state, and recent-document entries. Useful after upgrades or when
# diagnosing misbehaviour caused by stale data.
#
# Usage:
#   ./dev/clean_codex.sh
#
# The script lists every matched path with its size, then prompts for
# confirmation before deleting anything. Press Enter to proceed or Ctrl-C
# to abort. No changes are made until you confirm.
#
# Requirements: bash 4+ (macOS ships 3.2 — install via: brew install bash)
# Platform:     macOS only

set -euo pipefail

# Requires bash 4+ (for globstar and associative arrays)
if [[ "${BASH_VERSINFO[0]}" -lt 4 ]]; then
    echo "Error: This script requires bash 4+."
    echo "macOS ships bash 3.2 — install a newer version via Homebrew: brew install bash"
    echo "Then ensure /opt/homebrew/bin is first in your \$PATH."
    exit 1
fi

user=$USER

# List of paths to delete (supports ** recursive matching via globstar)
read -r -d '' PATHS_LIST << EOF || true
/Users/$user/.codex*
/Users/$user/Library/Application Support/Codex
/Users/$user/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/com.codex*
/Users/$user/Library/Autosave Information/com.codex.plist
/Users/$user/Library/Saved Application State/com.codex*
/Users/$user/Library/Saved Application State/com.codex.savedState
/private/var/folders/**/*com.codex*
EOF

# Enable globstar for ** recursive matching, nullglob so unmatched globs expand to nothing
shopt -s globstar nullglob

# Collect all glob pattern lines
glob_lines=()
while IFS= read -r pattern; do
    [[ -z "$pattern" ]] && continue
    glob_lines+=("$pattern")
done <<< "$PATHS_LIST"

# Resolve globs to actual files and collect unique matches
declare -A seen
matched_files=()

for pattern in "${glob_lines[@]}"; do
    # Disable word splitting so spaces in paths don't cause breakage,
    # while still allowing glob expansion
    old_ifs="$IFS"
    IFS=''
    matches=($pattern)
    IFS="$old_ifs"

    for match in "${matches[@]}"; do
        if [[ -e "$match" ]] && [[ -z "${seen["$match"]:-}" ]]; then
            seen["$match"]=1
            matched_files+=("$match")
        fi
    done
done

# Format file size to human-readable
human_size() {
    local bytes=$1
    if (( bytes >= 1073741824 )); then
        awk "BEGIN { printf \"%.1fG\", $bytes / 1073741824 }"
    elif (( bytes >= 1048576 )); then
        awk "BEGIN { printf \"%.1fM\", $bytes / 1048576 }"
    elif (( bytes >= 1024 )); then
        awk "BEGIN { printf \"%.1fK\", $bytes / 1024 }"
    else
        printf "%dB" "$bytes"
    fi
}

# Get size of a path (recursive for directories)
get_size() {
    local path="$1"
    if [[ -d "$path" ]]; then
        du -sk "$path" 2>/dev/null | awk '{print $1 * 1024}' || echo 0
    elif [[ -f "$path" ]]; then
        stat -f%z "$path" 2>/dev/null || echo 0
    else
        echo 0
    fi
}

# Print output
echo ""
echo "From the following globs:"
for g in "${glob_lines[@]}"; do
    echo "  $g"
done

echo ""
if [[ ${#matched_files[@]} -eq 0 ]]; then
    echo "No files matched."
    exit 0
fi

echo "These files will be deleted:"
total_bytes=0
for f in "${matched_files[@]}"; do
    size_bytes=$(get_size "$f")
    size_human=$(human_size "$size_bytes")
    total_bytes=$((total_bytes + size_bytes))
    echo "  $f  ($size_human)"
done

echo ""
echo "Total: $(human_size $total_bytes)"
echo ""
read -r -p "Enter to continue, ctrl-c to cancel "

# Actually delete
failed=0
for f in "${matched_files[@]}"; do
    if ! rm -rf "$f"; then
        echo "  ⚠ Failed to delete: $f" >&2
        failed=$((failed + 1))
    fi
done

echo ""
if [[ $failed -gt 0 ]]; then
    echo "Done with $failed error(s). Some files may require elevated privileges."
else
    echo "Done. All files deleted successfully."
fi
