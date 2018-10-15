# set defaults for telemetry reporting to false
if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
  sed -i '' "s/\'default\': true,/\'default\': false,/g" ./src/vs/platform/telemetry/common/telemetryService.ts
  sed -i '' "s/\'default\': true,/\'default\': false,/g" ./src/vs/workbench/services/crashReporter/electron-browser/crashReporterService.ts
else
  sed -i "s/\'default\': true,/\'default\': false,/g" ./src/vs/platform/telemetry/common/telemetryService.ts
  sed -i "s/\'default\': true,/\'default\': false,/g" ./src/vs/workbench/services/crashReporter/electron-browser/crashReporterService.ts
fi
