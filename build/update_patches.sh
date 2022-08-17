#!/bin/bash

cd vscode || { echo "'vscode' dir not found"; exit 1; }

git add .
git reset -q --hard HEAD

for file in ../patches/*.patch; do
  if [ -f "${file}" ]; then
    echo applying patch: "${file}"
    git apply --ignore-whitespace "${file}"
    if [ $? -ne 0 ]; then
      echo failed to apply patch "${file}"
      git apply --reject "${file}"
      read -p "Press any key when the conflict have been resolved..." -n1 -s
      git diff -U1 > "${file}"
    fi
    git add .
    git reset -q --hard HEAD
  fi
done
