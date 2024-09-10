#!/usr/bin/env bash

jsonfile=../extensions.json
extensions_dir=./.build/extensions
base_dir=$(pwd)

count=$(jq -r '. | length' ${jsonfile})
for i in $(seq $count); do
  url=$(jq -r ".[$i-1].url" ${jsonfile})
  name=$(jq -r ".[$i-1].name" ${jsonfile})
  echo $name $url
  if [[ -d ${extensions_dir}/"$name" ]]; then
    rm -rf ${extensions_dir}/"$name"
  fi
  mkdir -p ${extensions_dir}/"$name"
  curl -Lso "$name".zip "$url"
  unzip -q "$name".zip -d ${extensions_dir}/"$name"
  mv ${extensions_dir}/"$name"/extension/* ${extensions_dir}/"$name"/
  if [[ "${name}" == "codex-scripture-viewer" ]]; then
    cd ${extensions_dir}/"$name"
    npm prune --omit=dev
    cd ./webviews/codex-webviews
    npm prune --omit=dev
    cd ${base_dir}
  fi
  rm "$name".zip
done
