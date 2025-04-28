#!/usr/bin/env bash

export VSCODE_QUALITY="stable"

while getopts ":i" opt; do
  case "$opt" in
    i)
      export VSCODE_QUALITY="insider"
      ;;
    *)
      ;;
  esac
done

check_file() {
  while [ $# -gt 1 ]; do
    git apply --reject "${1}"

    shift
  done

  if [[ -f "${1}.bak" ]]; then
    mv -f $1{.bak,}
  fi

  if [[ -f "${1}" ]]; then
    echo applying patch: "${1}"
    if ! git apply --ignore-whitespace "${1}"; then
      echo failed to apply patch "${1}"

      git apply --reject "${1}"
      git apply --reject "../patches/helper/settings.patch"

      read -rp "Press any key when the conflict have been resolved..." -n1 -s

      git restore .vscode/settings.json
      git add .
      git diff --staged -U1 > "${1}"
    fi
    git add .
    git reset -q --hard HEAD
  fi
}

cd vscode || { echo "'vscode' dir not found"; exit 1; }

git add .
git reset -q --hard HEAD

for FILE in ../patches/*.patch; do
  check_file "${FILE}"
done

if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
  for FILE in ../patches/insider/*.patch; do
    check_file "${FILE}"
  done
fi

for ARCH in alpine linux osx windows; do
  for FILE in "../patches/${ARCH}/"*.patch; do
    if [[ "${ARCH}" == "linux" && "${FILE}" == *"/arch-"* ]] || [[ "${ARCH}" == "windows" && "${FILE}" == *"/cli"* ]]; then
      echo "skip ${FILE}"
    else
      check_file "${FILE}"
    fi
  done

  if [[ "${ARCH}" == "linux" ]]; then
    check_file "../patches/cli.patch" "../patches/linux/arch-0-support.patch"
    check_file "../patches/cli.patch" "../patches/linux/arch-0-support.patch" "../patches/linux/arch-1-ppc64le.patch"
    check_file "../patches/cli.patch" "../patches/linux/arch-0-support.patch" "../patches/linux/arch-1-ppc64le.patch" "../patches/linux/arch-2-riscv64.patch"
    check_file "../patches/cli.patch" "../patches/linux/arch-0-support.patch" "../patches/linux/arch-1-ppc64le.patch" "../patches/linux/arch-2-riscv64.patch" "../patches/linux/arch-3-loong64.patch"
    check_file "../patches/cli.patch" "../patches/linux/arch-0-support.patch" "../patches/linux/arch-1-ppc64le.patch" "../patches/linux/arch-2-riscv64.patch" "../patches/linux/arch-3-loong64.patch" "../patches/linux/arch-4-s390x.patch"
  elif [[ "${ARCH}" == "windows" ]]; then
    check_file "../patches/cli.patch" "../patches/windows/cli.patch"
  fi

  for TARGET in client reh; do
    for FILE in "../patches/${ARCH}/${TARGET}/"*.patch; do
      check_file "${FILE}"
    done

    for FILE in "../patches/${ARCH}/${TARGET}/"*/*.patch; do
      check_file "${FILE}"
    done
  done
done
