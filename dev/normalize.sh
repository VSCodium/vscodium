#!/usr/bin/env bash

# Usage:
#   ./dev/normalize.sh            normalize the current quality (all OSes)
#   VSCODE_QUALITY=insider ./dev/normalize.sh

set -e

cd "$( dirname "$0" )/.." || exit 1

[[ -d vscode ]] || { echo "'vscode' dir not found; run ./dev/build.sh first"; exit 1; }

# shellcheck disable=SC1091
( cd vscode && . ../utils.sh && . ../patches.sh && guard_preflight ) || exit 1

QUALITY="${VSCODE_QUALITY:-stable}"

for os in linux osx windows; do
  echo "== ${QUALITY}/${os} =="
  VSCODE_QUALITY="${QUALITY}" OS_NAME="${os}" python3 dev/lib/stack.py import
  python3 dev/lib/stack.py export --no-verify
done

# The loop leaves the last OS's stack checked out; force the next build to re-import.
( cd vscode && rm -f "$( git rev-parse --git-dir )/vscodium-patches-hash" )

echo
echo "Normalized ${QUALITY} patches. Review 'git diff patches/'."
echo "For insider-only patches, re-run on an insider checkout with VSCODE_QUALITY=insider."
