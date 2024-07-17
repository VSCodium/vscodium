#!/usr/bin/env bash
echo $(pwd)

jsonfile=../extensions.json
extensions_dir=./extensions
base_dir=$(pwd)

count=$(jq -r '. | length' ${jsonfile})
for i in $(seq $count); do
  url=$(jq -r ".[$i-1].url" ${jsonfile})
  name=$(jq -r ".[$i-1].name" ${jsonfile})
  echo $name $url
  mkdir -p ${extensions_dir}/"$name"
  curl -L -o "$name".zip "$url"
  unzip "$name".zip -d ${extensions_dir}/"$name"
  mv ${extensions_dir}/"$name"/extension/* ${extensions_dir}/"$name"/
  cd ${extensions_dir}/"$name"
  cd ${base_dir}
  rm "$name".zip
done
