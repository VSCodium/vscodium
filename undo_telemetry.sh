# dc.services.visualstudio.com
# vortex.data.microsoft.com
TELEMETRY_URLS="(dc\.services\.visualstudio\.com)|(vortex\.data\.microsoft\.com)"
REPLACEMENT="s/$TELEMETRY_URLS/0\.0\.0\.0/g"

if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
  grep -rl --exclude-dir=.git -E $TELEMETRY_URLS . | xargs sed -i '' -E $REPLACEMENT
else
  grep -rl --exclude-dir=.git -E $TELEMETRY_URLS . | xargs sed -i -E $REPLACEMENT
fi

# set defaults for telemetry reporting to false
sed -i "s/\'default\': true,/\'default\': false,/g" ./src/vs/platform/telemetry/common/telemetryService.ts
sed -i "s/\'default\': true,/\'default\': false,/g" ./src/vs/workbench/services/crashReporter/electron-browser/crashReporterService.ts
