#!/usr/bin/env bash

jsonfile=$(curl https://raw.githubusercontent.com/andrewhertog/extension-sideloader/refs/heads/main/extensions.json)
extensions_dir=./vscode/extensions
base_dir=$(pwd)

count=$(jq -r '.builtin | length' ${jsonfile})
for i in $(seq $count); do
  url=$(jq -r ".builtin[$i-1].url" ${jsonfile})
  name=$(jq -r ".builtin[$i-1].name" ${jsonfile})
  echo $name $url
  if [[ -d ${extensions_dir}/"$name" ]]; then
    rm -rf ${extensions_dir}/"$name"
  fi
  mkdir -p ${extensions_dir}/"$name"
  curl -Lso "$name".zip "$url"
  unzip -q "$name".zip -d ${extensions_dir}/"$name"
  mv ${extensions_dir}/"$name"/extension/* ${extensions_dir}/"$name"/
  rm "$name".zip
done

# name="test"
# cp -r /Users/andrew.denhertog/Documents/Projects/andrewhertog/test-extension/test-extension-0.0.1.vsix ./ext.zip
# unzip -q ext.zip -d ${extensions_dir}/"$name"
# mv ${extensions_dir}/"$name"/extension/* ${extensions_dir}/"$name"/
# rm ext.zip
