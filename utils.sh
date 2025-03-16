#!/usr/bin/env bash

APP_NAME="${APP_NAME:-VSCodium}"
APP_NAME_LC="$( echo "${APP_NAME}" | awk '{print tolower($0)}' )"
BINARY_NAME="${BINARY_NAME:-codium}"
GH_REPO_PATH="${GH_REPO_PATH:-VSCodium/vscodium}"
ORG_NAME="${ORG_NAME:-VSCodium}"

# All common functions can be added to this file

apply_patch() {
  echo applying patch: "$1";
  # grep '^+++' "$1"  | sed -e 's#+++ [ab]/#./vscode/#' | while read line; do shasum -a 256 "${line}"; done
  
  replace "s|!!APP_NAME!!|${APP_NAME}|" "$1"
  replace "s|!!APP_NAME_LC!!|${APP_NAME_LC}|" "$1"
  replace "s|!!BINARY_NAME!!|${BINARY_NAME}|" "$1"
  replace "s|!!GH_REPO_PATH!!|${GH_REPO_PATH}|" "$1"
  replace "s|!!ORG_NAME!!|${ORG_NAME}|" "$1"
  
  if ! git apply --ignore-whitespace "$1"; then
    echo failed to apply patch "$1" >&2
    exit 1
  fi
}

exists() { type -t "$1" &> /dev/null; }

is_gnu_sed () {
  sed --version &> /dev/null
}

replace () {
  # echo "${1}"
  if is_gnu_sed; then
    sed -i -E "${1}" "${2}"
  else
    sed -i '' -E "${1}" "${2}"
  fi
}

if ! exists gsed; then
  if is_gnu_sed; then
    function gsed() {
      sed -i -E "$@"
    }
  else
    function gsed() {
      sed -i '' -E "$@"
    }
  fi
fi
