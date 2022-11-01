#!/bin/bash

FILE="../patches/${1}.patch"

cd vscode || { echo "'vscode' dir not found"; exit 1; }

git add .
git reset -q --hard HEAD

if [[ -f "${FILE}" ]]; then
  git apply --reject "${FILE}"
fi

read -p "Press any key when the conflict have been resolved..." -n1 -s

git add .
git diff --staged -U1 > "${FILE}"

cd ..

echo "The patch has been generated."
