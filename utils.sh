#!/usr/bin/env bash

# All common functions can be added to this file

exists() { type -t "$1" &> /dev/null; }

is_gnu_sed () {
  sed --version &> /dev/null
}

replace () {
  echo "${1}"
  if is_gnu_sed; then
    sed -i -E "${1}" "${2}"
  else
    sed -i '' -E "${1}" "${2}"
  fi
}

if ! exists gsed; then
  if is_gnu_sed; then
    function gsed() {
      sed -i -E "$@"
    }
  else
    function gsed() {
      sed -i '' -E "$@"
    }
  fi
fi
