DEFAULT_TRUE="'default': true"
DEFAULT_FALSE="'default': false"
DEFAULT_ON="'default': TelemetryConfiguration.ON"
DEFAULT_OFF="'default': TelemetryConfiguration.OFF"
TELEMETRY_CRASH_REPORTER="'telemetry.enableCrashReporter':"
TELEMETRY_CONFIGURATION=" TelemetryConfiguration.ON"

#include common functions
. ../utils.sh

update_setting () {
  local FILENAME="$2"
  # check that the file exists
  if [ ! -f "$FILENAME" ]; then
    echo "File to update setting in does not exist ${FILENAME}"
    return
  fi

  # go through lines of file, looking for block that contains setting
  local SETTING="$1"
  local LINE_NUM=0
  while read -r line; do
    local LINE_NUM=$(( $LINE_NUM + 1 ))
    if [[ $line == *"$SETTING"* ]]; then
      local IN_SETTING=1
    fi
    if [[ ($line == *"$DEFAULT_TRUE"* || $line == *"$DEFAULT_ON"*) && "$IN_SETTING" == "1" ]]; then
      local FOUND=1
      break
    fi
  done < "$FILENAME"

  if [[ "$FOUND" != "1" ]]; then
    echo "$DEFAULT_TRUE not found for setting $SETTING in file $FILENAME"
    return
  fi

  # construct line-aware replacement string
  if [[ $line == *"$DEFAULT_TRUE"* ]]; then
    local DEFAULT_TRUE_TO_FALSE="${LINE_NUM}s/${DEFAULT_TRUE}/${DEFAULT_FALSE}/"
  else
    local DEFAULT_TRUE_TO_FALSE="${LINE_NUM}s/${DEFAULT_ON}/${DEFAULT_OFF}/"
  fi

  replace "$DEFAULT_TRUE_TO_FALSE" "$FILENAME"
}

update_setting "$TELEMETRY_CRASH_REPORTER" src/vs/workbench/electron-sandbox/desktop.contribution.ts
update_setting "$TELEMETRY_CONFIGURATION" src/vs/platform/telemetry/common/telemetryService.ts
