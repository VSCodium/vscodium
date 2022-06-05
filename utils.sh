#!/bin/bash

#All common functions can be added to this file

is_gnu_sed () {
  sed --version >/dev/null 2>&1
}

replace () {
  echo "$1"
  if is_gnu_sed; then
    sed -i -E "$1" "$2"
  else
    sed -i '' -E "$1" "$2"
  fi
}
