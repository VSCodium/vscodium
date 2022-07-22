# mobile.events.data.microsoft.com
# vortex.data.microsoft.com
TELEMETRY_URLS="[^/]+\.data\.microsoft\.com"
REPLACEMENT="s/${TELEMETRY_URLS}/0\.0\.0\.0/g"

#include common functions
. ../utils.sh

d1=`date +%s`

if [[ "${OS_NAME}" == "linux" ]]; then
  rg --no-ignore -l "${TELEMETRY_URLS}" . | xargs -I {} bash -c 'echo "found: $@ (`date`)"; sed -i -E "$@"' _ {}
elif [[ "${OS_NAME}" == "osx" ]]; then
  if is_gnu_sed; then
    ./node_modules/@vscode/ripgrep/bin/rg --no-ignore -l "${TELEMETRY_URLS}" . | xargs -I {} bash -c 'echo "found: $@ (`date`)"; sed -i -E "$@"' _ {}
  else
    ./node_modules/@vscode/ripgrep/bin/rg --no-ignore -l "${TELEMETRY_URLS}" . | xargs -I {} bash -c 'echo "found: $@ (`date`)"; sed -i \''\'' -E "$@"' _ {}
  fi
else
  ./node_modules/@vscode/ripgrep/bin/rg --no-ignore --path-separator=// -l "${TELEMETRY_URLS}" . | xargs -I {} bash -c 'echo "found: $@ (`date`)"; sed -i -E "$@"' _ {}
fi

d2=`date +%s`

echo "undo_telemetry: $( echo "${d2} - ${d1}" )s"
