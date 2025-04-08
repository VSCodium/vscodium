#!/usr/bin/env bash

set -ex

cd cli

export CARGO_NET_GIT_FETCH_WITH_CLI="true"
export VSCODE_CLI_APP_NAME="$( echo "${APP_NAME}" | awk '{print tolower($0)}' )"
export VSCODE_CLI_BINARY_NAME="$( node -p "require(\"../product.json\").serverApplicationName" )"

TUNNEL_APPLICATION_NAME="$( node -p "require(\"../product.json\").tunnelApplicationName" )"
NAME_SHORT="$( node -p "require(\"../product.json\").nameShort" )"

npm pack @vscode/openssl-prebuilt@0.0.11
mkdir openssl
tar -xvzf vscode-openssl-prebuilt-0.0.11.tgz --strip-components=1 --directory=openssl

if [[ "${OS_NAME}" == "osx" ]]; then
  if [[ "${VSCODE_ARCH}" == "arm64" ]]; then
    VSCODE_CLI_TARGET="aarch64-apple-darwin"
  else
    VSCODE_CLI_TARGET="x86_64-apple-darwin"
  fi

  export OPENSSL_LIB_DIR="$( pwd )/openssl/out/${VSCODE_ARCH}-osx/lib"
  export OPENSSL_INCLUDE_DIR="$( pwd )/openssl/out/${VSCODE_ARCH}-osx/include"

  cargo build --release --target "${VSCODE_CLI_TARGET}" --bin=code

  cp "target/${VSCODE_CLI_TARGET}/release/code" "../../VSCode-darwin-${VSCODE_ARCH}/${NAME_SHORT}.app/Contents/Resources/app/bin/${TUNNEL_APPLICATION_NAME}"
elif [[ "${OS_NAME}" == "windows" ]]; then
  if [[ "${VSCODE_ARCH}" == "arm64" ]]; then
    VSCODE_CLI_TARGET="aarch64-pc-windows-msvc"
    export VSCODE_CLI_RUST="-C target-feature=+crt-static -Clink-args=/guard:cf -Clink-args=/CETCOMPAT:NO"
  else
    VSCODE_CLI_TARGET="x86_64-pc-windows-msvc"
    export VSCODE_CLI_RUSTFLAGS="-Ctarget-feature=+crt-static -Clink-args=/guard:cf -Clink-args=/CETCOMPAT"
  fi

  export VSCODE_CLI_CFLAGS="/guard:cf /Qspectre"
  export OPENSSL_LIB_DIR="$( pwd )/openssl/out/${VSCODE_ARCH}-windows-static/lib"
  export OPENSSL_INCLUDE_DIR="$( pwd )/openssl/out/${VSCODE_ARCH}-windows-static/include"

  rustup target add "${VSCODE_CLI_TARGET}"

  cargo build --release --target "${VSCODE_CLI_TARGET}" --bin=code

  cp "target/${VSCODE_CLI_TARGET}/release/code.exe" "../../VSCode-win32-${VSCODE_ARCH}/bin/${TUNNEL_APPLICATION_NAME}.exe"
else
  export OPENSSL_LIB_DIR="$( pwd )/openssl/out/${VSCODE_ARCH}-linux/lib"
  export OPENSSL_INCLUDE_DIR="$( pwd )/openssl/out/${VSCODE_ARCH}-linux/include"

  if [[ "${VSCODE_ARCH}" == "arm64" ]]; then
    VSCODE_CLI_TARGET="aarch64-unknown-linux-gnu"
  elif [[ "${VSCODE_ARCH}" == "armhf" ]]; then
    VSCODE_CLI_TARGET="armv7-unknown-linux-gnueabihf"
    export OPENSSL_LIB_DIR="$( pwd )/openssl/out/arm-linux/lib"
    export OPENSSL_INCLUDE_DIR="$( pwd )/openssl/out/arm-linux/include"
  elif [[ "${VSCODE_ARCH}" == "x64" ]]; then
    VSCODE_CLI_TARGET="x86_64-unknown-linux-gnu"
  # elif [[ "${VSCODE_ARCH}" == "ppc64le" ]]; then
  #   VSCODE_CLI_TARGET="powerpc64-unknown-linux-gnu"
  # elif [[ "${VSCODE_ARCH}" == "riscv64" ]]; then
  #   VSCODE_CLI_TARGET="riscv64-unknown-linux-gnu"
  # elif [[ "${VSCODE_ARCH}" == "loong64" ]]; then
  #   VSCODE_CLI_TARGET="loongarch64-unknown-linux-gnu"
  fi

  if [[ -n "${VSCODE_CLI_TARGET}" ]]; then
    rustup target add "${VSCODE_CLI_TARGET}"

    cargo build --release --target "${VSCODE_CLI_TARGET}" --bin=code

    cp "target/${VSCODE_CLI_TARGET}/release/code" "../../VSCode-linux-${VSCODE_ARCH}/bin/${TUNNEL_APPLICATION_NAME}"
  fi
fi

cd ..
