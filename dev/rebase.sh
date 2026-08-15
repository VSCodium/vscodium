#!/usr/bin/env bash
# Usage:
#   ./dev/rebase.sh <new-ms-commit>    rebase onto an explicit commit
#   ./dev/rebase.sh                    rebase onto upstream/<quality>.json's commit
#   ./dev/rebase.sh --continue         finish after resolving conflicts

set -e

cd "$( dirname "$0" )/.." || exit 1
ROOT="${PWD}"

cd vscode || { echo "'vscode' dir not found; run ./dev/build.sh first"; exit 1; }

# shellcheck disable=SC1091
. ../utils.sh
# shellcheck disable=SC1091
. ../patches.sh

STATE="$( git rev-parse --git-dir )/vscodium-rebase-target"

# The tip stays put: the rebased commits reach patches/ only via export.sh.
finish_rebase() {
  local newbase
  newbase="$( cat "${STATE}" )"
  set_base_ref "${newbase}"
  rm -f "${STATE}"
  echo
  echo "Rebased onto ${newbase:0:8}."
  git for-each-ref refs/vscodium/ --format='  %(refname:short) %(objectname:short)'
  echo
  echo "Next: ./dev/export.sh    (regenerate patch files against the new upstream)"
}

if [[ "${1:-}" == "--continue" ]]; then
  [[ -f "${STATE}" ]] || { echo "No rebase in progress." >&2; exit 1; }
  # Tolerate a rebase the developer already finished with plain git.
  if [[ -d "$( git rev-parse --git-path rebase-merge )" ]] || [[ -d "$( git rev-parse --git-path rebase-apply )" ]]; then
    vscodium_git rebase --continue
  fi
  # An abort looks like a finish; confirm the stack landed before moving the base.
  if ! git merge-base --is-ancestor "$( cat "${STATE}" )" HEAD; then
    rm -f "${STATE}"
    echo "The rebase was aborted; vscode/ is unchanged and the refs were left alone." >&2
    exit 1
  fi
  finish_rebase
  exit 0
fi

QUALITY="${VSCODE_QUALITY:-stable}"
NEW_COMMIT="${1:-}"
if [[ -z "${NEW_COMMIT}" ]]; then
  NEW_COMMIT="$( jq -r '.commit' "${ROOT}/upstream/${QUALITY}.json" )"
fi

guard_uncommitted

OLD_BASE="$( git rev-parse "${VSCODIUM_REF_BASE}" )"
COUNT="$( git rev-list --count "${VSCODIUM_REF_BASE}..HEAD" )"

if [[ "${OLD_BASE}" == "${NEW_COMMIT}" ]]; then
  echo "Already based on ${NEW_COMMIT:0:8}; nothing to rebase."
  exit 0
fi

# The build leaves the tree materialized, which git rebase refuses to start on.
if [[ -n "$( git status --porcelain )" ]]; then
  echo "vscode/ has local changes; rebase needs a clean tree." >&2
  echo "Commit your work and run ./dev/export.sh, then: git -C vscode reset --hard HEAD" >&2
  exit 1
fi

echo "Rebasing ${COUNT} commits: ${OLD_BASE:0:8} -> ${NEW_COMMIT:0:8}"
git fetch --depth 1 origin "${NEW_COMMIT}"

if vscodium_git rebase --onto "${NEW_COMMIT}" "${OLD_BASE}"; then
  echo "${NEW_COMMIT}" > "${STATE}"
  finish_rebase
elif [[ -d "$( git rev-parse --git-path rebase-merge )" ]] || [[ -d "$( git rev-parse --git-path rebase-apply )" ]]; then
  echo "${NEW_COMMIT}" > "${STATE}"
  echo
  echo "Conflicts. Run 'git -C vscode status' and resolve each row by its label:" >&2
  echo "  both modified    edit out the <<<<<<< markers, then 'git add' it" >&2
  echo "  deleted by us    upstream deleted a file this patch edits: 'git rm' it and drop" >&2
  echo "                   that hunk ('git add' would resurrect the deleted file)" >&2
  echo "  deleted by them  this patch deletes a file upstream edited: 'git rm' it to keep" >&2
  echo "                   the deletion" >&2
  echo "Then run:  ./dev/rebase.sh --continue" >&2
  exit 1
else
  echo "Rebase did not start; vscode/ is unchanged." >&2
  exit 1
fi
