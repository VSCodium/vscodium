TELEMETRY_CRASH_REPORTER="{\"telemetry.enableCrashReporter\":{type:\"boolean\",description:n.localize\(1,null\),default:\!0"
TELEMETRY_ENABLE="{\"telemetry.enableTelemetry\":{type:\"boolean\",description:n.localize\(1,null\),default:\!0"

TELEMETRY_CRASH_REPORTER_REPLACEMENT="s/$TELEMETRY_CRASH_REPORTER/{\"telemetry.enableCrashReporter\":{type:\"boolean\",description:n.localize\(1,null\),default:0/g"
TELEMETRY_ENABLE_REPLACEMENT="s/$TELEMETRY_ENABLE/{\"telemetry.enableTelemetry\":{type:\"boolean\",description:n.localize\(1,null\),default:0/g"

if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
  grep -rl --exclude-dir=.git -E $TELEMETRY_CRASH_REPORTER . | xargs sed -i '' -E $TELEMETRY_CRASH_REPORTER_REPLACEMENT
  grep -rl --exclude-dir=.git -E $TELEMETRY_ENABLE . | xargs sed -i '' -E $TELEMETRY_ENABLE_REPLACEMENT
else
  grep -rl --exclude-dir=.git -E $TELEMETRY_CRASH_REPORTER . | xargs sed -i -E $TELEMETRY_CRASH_REPORTER_REPLACEMENT
  grep -rl --exclude-dir=.git -E $TELEMETRY_ENABLE . | xargs sed -i -E $TELEMETRY_ENABLE_REPLACEMENT
fi
