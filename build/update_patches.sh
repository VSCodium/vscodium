#!/bin/bash

cd vscode || { echo "'vscode' dir not found"; exit 1; }

git add .
git reset -q --hard HEAD

for FILE in ../patches/*.patch; do
  if [ -f "${FILE}" ]; then
    echo applying patch: "${FILE}"
    git apply --ignore-whitespace "${FILE}"
    if [ $? -ne 0 ]; then
      echo failed to apply patch "${FILE}"
      git apply --reject "${FILE}"
      read -p "Press any key when the conflict have been resolved..." -n1 -s
      git add .
      git diff --staged -U1 > "${FILE}"
    fi
    git add .
    git reset -q --hard HEAD
  fi
done
