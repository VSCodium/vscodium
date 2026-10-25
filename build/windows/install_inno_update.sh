#!/usr/bin/env bash


INNO_PATH="./build/win32/inno_updater.exe"
INNO_VERSION="0.26.1"

echo "Replacing inno_updater binary"

if [ -f "${INNO_PATH}" ]; then
  rm "${INNO_PATH}"
fi

curl --silent --fail -L https://github.com/VSCodium/inno-updater/releases/download/v${INNO_VERSION}/inno_updater.exe -o "${INNO_PATH}"
chmod +x "${INNO_PATH}"
