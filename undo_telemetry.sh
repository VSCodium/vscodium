#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2016

set -ex

# list of urls to match:
# - mobile.events.data.microsoft.com
# - vortex.data.microsoft.com

SEARCH="\.data\.microsoft\.com"
REPLACEMENT="s|//[^/]+\.data\.microsoft\.com|//0\.0\.0\.0|g"

# include common functions
. ../utils.sh

if is_gnu_sed; then
  replace_with_debug () {
    echo "found: ${2}"
    sed -i -E "${1}" "${2}"
  }
else
  replace_with_debug () {
    echo "found: ${2}"
    sed -i '' -E "${1}" "${2}"
  }
fi
export -f replace_with_debug

d1=$( date +%s )

if [[ "${OS_NAME}" == "linux" ]]; then
  if [[ ${VSCODE_ARCH} == "x64" ]]; then
    ./node_modules/@vscode/ripgrep/bin/rg --no-ignore -l "${SEARCH}" . | xargs -I {} bash -c 'replace_with_debug "${1}" "{}"' _ "${REPLACEMENT}"
  else
    grep -rl --exclude-dir=.git -E "${SEARCH}" . | xargs -I {} bash -c 'replace_with_debug "${1}" "{}"' _ "${REPLACEMENT}"
  fi
elif [[ "${OS_NAME}" == "osx" ]]; then
  ./node_modules/@vscode/ripgrep/bin/rg --no-ignore -l "${SEARCH}" . | xargs -I {} bash -c 'replace_with_debug "${1}" "{}"' _ "${REPLACEMENT}"
else
  ./node_modules/@vscode/ripgrep/bin/rg --no-ignore --path-separator=// -l "${SEARCH}" . | xargs -I {} bash -c 'replace_with_debug "${1}" "{}"' _ "${REPLACEMENT}"
fi

d2=$( date +%s )

echo "undo_telemetry: $((d2 - d1))s"
