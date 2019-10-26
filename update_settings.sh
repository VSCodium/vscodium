DEFAULT_TRUE="'default': true"
DEFAULT_FALSE="'default': false"
TELEMETRY_ENABLE="'telemetry.enableTelemetry':"
TELEMETRY_CRASH_REPORTER="'telemetry.enableCrashReporter':"

replace () {
  echo $1
  if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
    sed -i '' -E "$1" $2
  else
    sed -i -E "$1" $2
  fi
}

update_setting () {
  local FILENAME="$2"
  # check that the file exists
  if [ ! -f $FILENAME ]; then
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
    if [[ $line == *"$DEFAULT_TRUE"* && "$IN_SETTING" == "1" ]]; then
      local FOUND=1
      break
    fi
  done < $FILENAME

  if [[ "$FOUND" != "1" ]]; then
    echo "$DEFAULT_TRUE not found for setting $SETTING in file $FILENAME"
    return
  fi

  # construct line-aware replacement string
  local DEFAULT_TRUE_TO_FALSE="${LINE_NUM}s/${DEFAULT_TRUE}/${DEFAULT_FALSE}/"

  replace "$DEFAULT_TRUE_TO_FALSE" $FILENAME
}

update_setting "$TELEMETRY_ENABLE" src/vs/platform/telemetry/common/telemetryService.ts
update_setting "$TELEMETRY_CRASH_REPORTER" src/vs/workbench/electron-browser/desktop.contribution.ts
