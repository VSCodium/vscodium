# dc.services.visualstudio.com
# vortex.data.microsoft.com
TELEMETRY_URLS="(dc\.services\.visualstudio\.com)|(vortex\.data\.microsoft\.com)"
REPLACEMENT="s/$TELEMETRY_URLS/0\.0\.0\.0/g"

#include common functions
. ../utils.sh

if [[ "$OS_NAME" == "osx" ]]; then
  if is_gnu_sed; then
    grep -rl --exclude-dir=.git -E $TELEMETRY_URLS . | xargs sed -i -E $REPLACEMENT
  else
    grep -rl --exclude-dir=.git -E $TELEMETRY_URLS . | xargs sed -i '' -E $REPLACEMENT
  fi
else
  grep -rl --exclude-dir=.git -E $TELEMETRY_URLS . | xargs sed -i -E $REPLACEMENT
fi
