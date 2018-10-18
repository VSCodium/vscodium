# dc.services.visualstudio.com
# vortex.data.microsoft.com
TELEMETRY_URLS="(dc\.services\.visualstudio\.com)|(vortex\.data\.microsoft\.com)"
REPLACEMENT="s/$TELEMETRY_URLS/0\.0\.0\.0/g"

TELEMETRY_CRASH_REPORTER="\{\"telemetry.enableCrashReporter\":{type:\"boolean\",description:n.localize(1,null),default:!0"
TELEMETRY_ENABLE="{\"telemetry.enableTelemetry\":{type:\"boolean\",description:n.localize(1,null),default:!0"

TELEMETRY_CRASH_REPORTER_REPLACEMENT="\{\"telemetry.enableCrashReporter\":{type:\"boolean\",description:n.localize(1,null),default:false"
TELEMETRY_ENABLE_REPLACEMENT="\{\"telemetry.enableTelemetry\":{type:\"boolean\",description:n.localize(1,null),default:false"

if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
  grep -rl --exclude-dir=.git -E $TELEMETRY_URLS . | xargs sed -i '' -E $REPLACEMENT
  grep -rl --exclude-dir=.git -E $TELEMETRY_CRASH_REPORTER . | xargs sed -i '' -E $TELEMETRY_CRASH_REPORTER_REPLACEMENT
  grep -rl --exclude-dir=.git -E $TELEMETRY_ENABLE . | xargs sed -i '' -E $TELEMETRY_ENABLE_REPLACEMENT
else
  grep -rl --exclude-dir=.git -E $TELEMETRY_URLS . | xargs sed -i -E $REPLACEMENT
  grep -rl --exclude-dir=.git -E $TELEMETRY_CRASH_REPORTER . | xargs sed -i -E $TELEMETRY_CRASH_REPORTER_REPLACEMENT
  grep -rl --exclude-dir=.git -E $TELEMETRY_ENABLE . | xargs sed -i -E $TELEMETRY_ENABLE_REPLACEMENT
fi

