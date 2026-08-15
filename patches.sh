#!/usr/bin/env bash
# shellcheck disable=SC2154

PATCHES_DIR="${PATCHES_DIR:-../patches}"

VSCODIUM_REF_BASE="refs/vscodium/base"
VSCODIUM_REF_HEAD="refs/vscodium/head"

# Build agents set no git identity; pin one for reproducible mailboxes.
VSCODIUM_COMMITTER_NAME="${VSCODIUM_COMMITTER_NAME:-VSCodium}"
VSCODIUM_COMMITTER_EMAIL="${VSCODIUM_COMMITTER_EMAIL:-scripts@vscodium.com}"
VSCODIUM_COMMIT_DATE="${VSCODIUM_COMMIT_DATE:-2000-01-01T00:00:00Z}"

vscodium_git() {
  GIT_AUTHOR_DATE="${VSCODIUM_COMMIT_DATE}" \
  GIT_COMMITTER_DATE="${VSCODIUM_COMMIT_DATE}" \
  git \
    -c "user.name=${VSCODIUM_COMMITTER_NAME}" \
    -c "user.email=${VSCODIUM_COMMITTER_EMAIL}" \
    -c "commit.gpgsign=false" \
    -c "core.hooksPath=/dev/null" \
    "$@"
}

record_base_ref() {
  vscodium_git update-ref "${VSCODIUM_REF_BASE}" HEAD
  echo "Recorded ${VSCODIUM_REF_BASE} = $( git rev-parse --short HEAD )"
}

set_base_ref() {
  vscodium_git update-ref "${VSCODIUM_REF_BASE}" "$1"
}

has_head_ref() {
  git rev-parse --verify --quiet "${VSCODIUM_REF_HEAD}" > /dev/null
}

materialized_record() {
  echo "$( git rev-parse --git-dir )/vscodium-materialized"
}

materialized_state() {
  local ENTRY FILE
  git status --porcelain -z | while IFS= read -r -d '' ENTRY; do
    FILE="${ENTRY:3}"
    if [[ -f "${FILE}" ]]; then
      echo "$( git hash-object -- "${FILE}" ) ${FILE}"
    else
      echo "- ${FILE}"
    fi
  done | LC_ALL=C sort -u
}

record_materialized() {
  materialized_state > "$( materialized_record )"
}

# Overlay assets absent upstream stay untracked; excluding them keeps `git add -A`
# from baking them into a patch.
exclude_overlay() {
  local EXCLUDE SRC FILE
  SRC="../src/${VSCODE_QUALITY:-stable}"
  [[ -d "${SRC}" ]] || return 0
  EXCLUDE="$( git rev-parse --git-dir )/info/exclude"
  mkdir -p "$( dirname "${EXCLUDE}" )"
  # The build's own backups, which an interrupted run leaves behind.
  for FILE in product.json.bak package.json.bak resources/server/manifest.json.bak .npmrc.bak; do
    grep -qxF "/${FILE}" "${EXCLUDE}" 2> /dev/null || echo "/${FILE}" >> "${EXCLUDE}"
  done
  while IFS= read -r FILE; do
    git ls-files --error-unmatch -- "${FILE}" > /dev/null 2>&1 && continue
    grep -qxF "/${FILE}" "${EXCLUDE}" 2> /dev/null || echo "/${FILE}" >> "${EXCLUDE}"
  done < <( cd "${SRC}" && find . -type f | sed 's|^\./||' )
}

clear_materialized() {
  rm -f "$( materialized_record )"
}

unexpected_changes() {
  local RECORDED
  RECORDED="$( materialized_record )"

  if [[ -f "${RECORDED}" ]]; then
    comm -23 <( materialized_state ) <( LC_ALL=C sort -u "${RECORDED}" ) | sed 's/^[^ ]* //'
  else
    git status --porcelain -z | tr '\0' '\n' | sed 's/^...//'
  fi
}

guard_uncommitted() {
  local UNEXPECTED
  [[ "${VSCODIUM_FORCE_RESET:-}" == "1" ]] && return 0
  UNEXPECTED="$( unexpected_changes )"
  [[ -n "${UNEXPECTED}" ]] || return 0

  echo "Refusing to discard changes in vscode/ that this build did not record:" >&2
  echo "${UNEXPECTED}" | sed 's/^/  /' >&2
  echo "If these are your edits, commit them and run ./dev/export.sh to save them." >&2
  echo "If a build failed part-way, they are its leftovers: discard with dev/build.sh -f" >&2
  echo "(VSCODIUM_FORCE_RESET=1). Never commit resolved branding into a patch." >&2
  exit 1
}

patches_fingerprint() {
  {
    echo "${VSCODE_QUALITY:-stable}:${OS_NAME:-}:${DISABLE_UPDATE:-}"
    find "${PATCHES_DIR}" -type f \
      \( -name '*.patch' -o -name '*.patch.yet' -o -name '*.json' -o -name '.patches' \) \
      | LC_ALL=C sort | xargs cat 2> /dev/null
  } | git hash-object --stdin
}

record_patches_hash() {
  patches_fingerprint > "$( git rev-parse --git-dir )/vscodium-patches-hash"
}

# The tip must be reachable from HEAD, or a truncated clone would be reused.
stack_matches_patches() {
  local F
  F="$( git rev-parse --git-dir )/vscodium-patches-hash"
  [[ -f "${F}" ]] || return 1
  [[ "$( cat "${F}" )" == "$( patches_fingerprint )" ]] || return 1
  git merge-base --is-ancestor "${VSCODIUM_REF_HEAD}" HEAD
}

ensure_stack() {
  guard_uncommitted

  if has_head_ref && stack_matches_patches; then
    echo "patch stack unchanged; reusing commits ($( git rev-list --count "${VSCODIUM_REF_BASE}..HEAD" ) on top of base)"
    if [[ "$( git rev-parse HEAD )" != "$( git rev-parse "${VSCODIUM_REF_HEAD}" )" ]]; then
      echo "note: building $( git rev-list --count "${VSCODIUM_REF_HEAD}..HEAD" ) commit(s) not yet in patches/; ./dev/export.sh saves them"
    fi
    vscodium_git reset -q --hard HEAD
  else
    if has_head_ref; then
      echo "patch set or config changed; re-importing the stack"
    fi
    guard_unexported
    ( cd .. && python3 dev/lib/stack.py import )
    clear_materialized
    record_patches_hash
  fi
}

# Only import and export move the tip; commits past it are in no patch file yet.
guard_unexported() {
  local UNSAVED
  [[ "${VSCODIUM_FORCE_RESET:-}" == "1" ]] && return 0

  has_head_ref || return 0
  UNSAVED="$( git rev-list --count "${VSCODIUM_REF_HEAD}..HEAD" )"
  [[ "${UNSAVED}" == "0" ]] && return 0

  echo "Refusing to discard ${UNSAVED} commit(s) in vscode/ that are not in patches/:" >&2
  git log --oneline "${VSCODIUM_REF_HEAD}..HEAD" | sed 's/^/  /' >&2
  echo "Run ./dev/export.sh to save them, or re-run with VSCODIUM_FORCE_RESET=1 (dev/build.sh -f)." >&2
  exit 1
}

# Commits keep !!TOKEN!! raw; reverse-substitution on export would be lossy.
materialize_tokens() {
  local FILE
  while IFS= read -r FILE; do
    [[ -f "${FILE}" ]] || continue
    replace_tokens_in_file "${FILE}"
  done < <( git grep -lE '!![A-Z_]+!!' 2> /dev/null )
}

# Working-tree overlay: default update mode to 'none' when DISABLE_UPDATE=yes.
materialize_disabled_update() {
  [[ "${DISABLE_UPDATE:-}" == "yes" ]] || return 0
  local FILE="${PATCHES_DIR}/00-update-disable.patch.yet"
  [[ -f "${FILE}" ]] || return 0
  apply_patch "${FILE}"
}

