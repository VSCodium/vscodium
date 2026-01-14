#!/usr/bin/env bash

set -e

normalize_file() {
  if [[ "${1}" == *patch ]]; then
    FILE="${1}"
  else
    FILE="${1}.patch"
  fi

  if [[ "${FILE}" == patches/* ]]; then
    FILE="../${FILE}"
  else
    FILE="../patches/${FILE}"
  fi
}

cd vscode || { echo "'vscode' dir not found"; exit 1; }

git add .
git reset -q --hard HEAD

while [[ -n "$( git log -1 | grep "VSCODIUM HELPER" )" ]]; do
  git reset -q --hard HEAD~
done

normalize_file "${1}"

if [[ "${FILE}" != "../patches/helper/settings.patch" ]]; then
  git apply --reject "../patches/helper/settings.patch"

  while [ $# -gt 1 ]; do
    echo "Parameter: $1"
    normalize_file "${1}"

    git apply --reject "${FILE}"

    shift
  done

  git add .
  git commit --no-verify -q -m "VSCODIUM HELPER"

  normalize_file "${1}"
fi

echo "FILE: ${FILE}"

if [[ -f "${FILE}" ]]; then
  if [[ -f "${FILE}.bak" ]]; then
    mv -f $FILE{.bak,}
  fi

  git apply --reject "${FILE}" || true
fi

read -rp "Press any key when the conflict have been resolved..." -n1 -s

while [[ -n "$( find . -name '*.rej' -print )" ]]; do
  echo
  read -rp "Press any key when the conflict have been resolved..." -n1 -s
done

git add .
git diff --staged -U1 > "${FILE}"

if [[ "${FILE}" != "../patches/helper/settings.patch" ]]; then
  git reset -q --hard HEAD
else
  git reset -q --hard HEAD~
fi

echo "The patch has been generated."
