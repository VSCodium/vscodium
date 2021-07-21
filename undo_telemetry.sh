# dc.services.visualstudio.com
# vortex.data.microsoft.com
TELEMETRY_URLS="(dc\.services\.visualstudio\.com)|(vortex\.data\.microsoft\.com)"
REPLACEMENT="s/$TELEMETRY_URLS/0\.0\.0\.0/g"

if [[ "$OS_NAME" == "osx" ]]; then
  if sed --version 2>&1 | grep -q GNU; then
    grep -rl --exclude-dir=.git -E $TELEMETRY_URLS . | xargs sed -i -E $REPLACEMENT
  else
    grep -rl --exclude-dir=.git -E $TELEMETRY_URLS . | xargs sed -i '' -E $REPLACEMENT
  fi
else
  grep -rl --exclude-dir=.git -E $TELEMETRY_URLS . | xargs sed -i -E $REPLACEMENT
fi
