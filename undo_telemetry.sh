# mobile.events.data.microsoft.com
# vortex.data.microsoft.com
TELEMETRY_URLS="[^/]+\.data\.microsoft\.com"
REPLACEMENT="s/${TELEMETRY_URLS}/0\.0\.0\.0/g"

#include common functions
. ../utils.sh

if [[ "${OS_NAME}" == "osx" ]]; then
  if is_gnu_sed; then
    ./node_modules/@vscode/ripgrep/bin/rg --no-ignore -l "${TELEMETRY_URLS}" . | xargs sed -i -E "${REPLACEMENT}"
  else
    ./node_modules/@vscode/ripgrep/bin/rg --no-ignore -l "${TELEMETRY_URLS}" . | xargs sed -i '' -E "${REPLACEMENT}"
  fi
else
  ./node_modules/@vscode/ripgrep/bin/rg --no-ignore -l "${TELEMETRY_URLS}" . | xargs -I {} bash -c 'debug "$@"' _ {}
fi
