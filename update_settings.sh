# shellcheck disable=SC1091,2148

DEFAULT_TRUE="'default': true"
DEFAULT_FALSE="'default': false"
DEFAULT_ON="'default': TelemetryConfiguration.ON"
DEFAULT_OFF="'default': TelemetryConfiguration.OFF"
TELEMETRY_CRASH_REPORTER="'telemetry.enableCrashReporter':"
TELEMETRY_CONFIGURATION=" TelemetryConfiguration.ON"
NLS=workbench.settings.enableNaturalLanguageSearch

# include common functions
. ../utils.sh

update_setting () {
  local FILENAME SETTING LINE_NUM IN_SETTING FOUND DEFAULT_TRUE_TO_FALSE

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

# Move activity bar views to panel to hide them from activity bar
# Keep the original working patterns for search, debug, explorer, and SCM. Extensions was brought back for proper updates until the extensions are baked in (unless we will keep it so users can install other extensions).
replace "s/}, ViewContainerLocation\.Sidebar, \\{ doNotRegisterOpenCommand: true \\}\\);/}, ViewContainerLocation.Panel, { doNotRegisterOpenCommand: true });/g" src/vs/workbench/contrib/search/browser/search.contribution.ts
replace "s/}, ViewContainerLocation\.Sidebar\\);/}, ViewContainerLocation.Panel);/g" src/vs/workbench/contrib/debug/browser/debug.contribution.ts
#replace "s/}, ViewContainerLocation\.Sidebar\\);/}, ViewContainerLocation.Panel);/g" src/vs/workbench/contrib/extensions/browser/extensions.contribution.ts
replace "s/}, ViewContainerLocation\.Sidebar, \\{ isDefault: true \\}\\);/}, ViewContainerLocation.Panel, { isDefault: true });/g" src/vs/workbench/contrib/files/browser/explorerViewlet.ts
replace "s/}, ViewContainerLocation\.Sidebar, \\{ doNotRegisterOpenCommand: true \\}\\);/}, ViewContainerLocation.Panel, { doNotRegisterOpenCommand: true });/g" src/vs/workbench/contrib/scm/browser/scm.contribution.ts
