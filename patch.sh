#!/usr/bin/env bash

if [[ "${1}" == *patch ]]; then
  FILE="../patches/${1}"
else
  FILE="../patches/${1}.patch"
fi

cd vscode || { echo "'vscode' dir not found"; exit 1; }

git add .
git reset -q --hard HEAD

if [[ -f "${FILE}" ]]; then
  git apply --reject "${FILE}"
fi

git apply --reject "../patches/helper/settings.patch"

read -rp "Press any key when the conflict have been resolved..." -n1 -s

git restore .vscode/settings.json

git add .
git diff --staged -U1 > "${FILE}"

cd ..

echo "The patch has been generated."
