#!/usr/bin/env bash

jsonfile=../extensions.json
extensions_dir=./extensions
base_dir=$(pwd)

count=$(jq -r '. | length' ${jsonfile})
for i in $(seq $count); do
  url=$(jq -r ".[$i-1].url" ${jsonfile})
  name=$(jq -r ".[$i-1].name" ${jsonfile})
  echo $name $url
  mkdir -p ${extensions_dir}/"$name"
  curl -Lso "$name".zip "$url"
  unzip -q "$name".zip -d ${extensions_dir}/"$name"
  mv ${extensions_dir}/"$name"/extension/* ${extensions_dir}/"$name"/
  cd ${extensions_dir}/"$name"
  npm install --omit dev
  cd ${base_dir}
  rm "$name".zip
done

ls ./extensions
