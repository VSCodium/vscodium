# mobile.events.data.microsoft.com
# vortex.data.microsoft.com
TELEMETRY_URLS="[^/]+\.data\.microsoft\.com"
REPLACEMENT="s/${TELEMETRY_URLS}/0\.0\.0\.0/g"

#include common functions
. ../utils.sh

debug() {
  d1=`perl -MTime::HiRes=time -e 'printf "%.5f\n", time'`

  sed -i -E "${REPLACEMENT}" "${1}"

  d2=`perl -MTime::HiRes=time -e 'printf "%.5f\n", time'`

  echo "found: ${1} ($( du -h ${1} | cut -f1 )) $( echo "(${d2} - ${d1}) * 1000" | bc )ms"
}

export -f debug

d1=`perl -MTime::HiRes=time -e 'printf "%.5f\n", time'`

if [[ "${OS_NAME}" == "osx" ]]; then
  if is_gnu_sed; then
    ./node_modules/@vscode/ripgrep/bin/rg --no-ignore -l "${TELEMETRY_URLS}" . | xargs sed -i -E "${REPLACEMENT}"
  else
    ./node_modules/@vscode/ripgrep/bin/rg --no-ignore -l "${TELEMETRY_URLS}" . | xargs sed -i '' -E "${REPLACEMENT}"
  fi
else
  ./node_modules/@vscode/ripgrep/bin/rg --no-ignore -l "${TELEMETRY_URLS}" . | xargs -I {} bash -c 'debug "$@"' _ {}
fi

d2=`perl -MTime::HiRes=time -e 'printf "%.5f\n", time'`

echo "undo_telemetry: $( echo "${d2} - ${d1}" | bc )s"
