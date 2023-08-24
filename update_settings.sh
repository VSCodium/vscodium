# shellcheck disable=SC1091,2148

# include common functions
. ../utils.sh

update_setting () {
  local FILENAME SETTING LINE_NUM IN_SETTING FOUND DEFAULT_TRUE_TO_FALSE DEFAULT_TRUE DEFAULT_FALSE
  local DEFAULT_ON DEFAULT_OFF TELEMETRY_CRASH_REPORTER TELEMETRY_CONFIGURATION NLS line

  DEFAULT_TRUE="'default': true"
  DEFAULT_FALSE="'default': false"
  DEFAULT_ON="'default': TelemetryConfiguration.ON"
  DEFAULT_OFF="'default': TelemetryConfiguration.OFF"
  TELEMETRY_CRASH_REPORTER="'telemetry.enableCrashReporter':"
  TELEMETRY_CONFIGURATION=" TelemetryConfiguration.ON"
  NLS=workbench.settings.enableNaturalLanguageSearch

  FILENAME="${2}"
  # check that the file exists
  if [[ ! -f "${FILENAME}" ]]; then
    echo "File to update setting in does not exist ${FILENAME}"
    return
  fi

  # go through lines of file, looking for block that contains setting
  SETTING="${1}"
  LINE_NUM=0
  while read -r line; do
    LINE_NUM=$(( LINE_NUM + 1 ))
    if [[ "${line}" == *"${SETTING}"* ]]; then
      IN_SETTING=1
    fi
    if [[ ("${line}" == *"${DEFAULT_TRUE}"* || "${line}" == *"${DEFAULT_ON}"*) && "${IN_SETTING}" == "1" ]]; then
      FOUND=1
      break
    fi
  done < "${FILENAME}"

  if [[ "${FOUND}" != "1" ]]; then
    echo "${DEFAULT_TRUE} not found for setting ${SETTING} in file ${FILENAME}"
    return
  fi

  # construct line-aware replacement string
  if [[ "${line}" == *"${DEFAULT_TRUE}"* ]]; then
    DEFAULT_TRUE_TO_FALSE="${LINE_NUM}s/${DEFAULT_TRUE}/${DEFAULT_FALSE}/"
  else
    DEFAULT_TRUE_TO_FALSE="${LINE_NUM}s/${DEFAULT_ON}/${DEFAULT_OFF}/"
  fi

  replace "${DEFAULT_TRUE_TO_FALSE}" "${FILENAME}"
}

update_setting "${TELEMETRY_CRASH_REPORTER}" src/vs/workbench/electron-sandbox/desktop.contribution.ts
update_setting "${TELEMETRY_CONFIGURATION}" src/vs/platform/telemetry/common/telemetryService.ts
update_setting "${NLS}" src/vs/workbench/contrib/preferences/common/preferencesContribution.ts
