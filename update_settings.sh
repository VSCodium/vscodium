REPLACEMENT="s/'default': true/'default': false/"

if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
  sed -i '' -E "$REPLACEMENT" src/vs/platform/telemetry/common/telemetryService.ts
  sed -i '' -E "$REPLACEMENT" src/vs/workbench/services/crashReporter/electron-browser/crashReporterService.ts
else
  sed -i -E "$REPLACEMENT" src/vs/platform/telemetry/common/telemetryService.ts
  sed -i -E "$REPLACEMENT" src/vs/workbench/services/crashReporter/electron-browser/crashReporterService.ts
fi