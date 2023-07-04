#!/usr/bin/env bash

export VSCODE_QUALITY="stable"

while getopts ":ilp" opt; do
  case "$opt" in
    i)
      export VSCODE_QUALITY="insider"
      ;;
  esac
done

cd vscode || { echo "'vscode' dir not found"; exit 1; }

git add .
git reset -q --hard HEAD

for FILE in ../patches/*.patch; do
  if [[ -f "${FILE}" ]]; then
    echo applying patch: "${FILE}"
    if ! git apply --ignore-whitespace "${FILE}"; then
      echo failed to apply patch "${FILE}"

      git apply --reject "${FILE}"
      git apply --reject "../patches/helper/settings.patch"

      read -p "Press any key when the conflict have been resolved..." -n1 -s

      git restore .vscode/settings.json
      git add .
      git diff --staged -U1 > "${FILE}"
    fi
    git add .
    git reset -q --hard HEAD
  fi
done

if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
  for FILE in ../patches/insider/*.patch; do
    if [[ -f "${FILE}" ]]; then
      echo applying patch: "${FILE}"
      if ! git apply --ignore-whitespace "${FILE}"; then
        echo failed to apply patch "${FILE}"

        git apply --reject "${FILE}"
        git apply --reject "../patches/helper/settings.patch"

        read -p "Press any key when the conflict have been resolved..." -n1 -s

        git restore .vscode/settings.json
        git add .
        git diff --staged -U1 > "${FILE}"
      fi
      git add .
      git reset -q --hard HEAD
    fi
  done
fi
