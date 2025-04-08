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
  export VSCODE_SYSROOT_DIR="../.build/sysroots"

  if [[ "${VSCODE_ARCH}" == "arm64" ]]; then
    VSCODE_CLI_TARGET="aarch64-unknown-linux-gnu"

    # export CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER="${VSCODE_SYSROOT_DIR}/aarch64-linux-gnu/bin/aarch64-linux-gnu-gcc"
    # export CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_RUSTFLAGS="-C link-arg=--sysroot=${VSCODE_SYSROOT_DIR}/aarch64-linux-gnu/aarch64-linux-gnu/sysroot"
    # export CC_aarch64_unknown_linux_gnu="${VSCODE_SYSROOT_DIR}/aarch64-linux-gnu/bin/aarch64-linux-gnu-gcc --sysroot=${VSCODE_SYSROOT_DIR}/aarch64-linux-gnu/aarch64-linux-gnu/sysroot"
    # export PKG_CONFIG_LIBDIR_aarch64_unknown_linux_gnu="${VSCODE_SYSROOT_DIR}/aarch64-linux-gnu/aarch64-linux-gnu/sysroot/usr/lib/aarch64-linux-gnu/pkgconfig:${VSCODE_SYSROOT_DIR}/aarch64-linux-gnu/aarch64-linux-gnu/sysroot/usr/share/pkgconfig"
    # export PKG_CONFIG_SYSROOT_DIR_aarch64_unknown_linux_gnu="${VSCODE_SYSROOT_DIR}/aarch64-linux-gnu/aarch64-linux-gnu/sysroot"
    # export OBJDUMP="${VSCODE_SYSROOT_DIR}/aarch64-linux-gnu/aarch64-linux-gnu/bin/objdump"

    export CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER=aarch64-linux-gnu-gcc
    export CC_aarch64_unknown_linux_gnu=aarch64-linux-gnu-gcc
    export CXX_aarch64_unknown_linux_gnu=aarch64-linux-gnu-g++
    export PKG_CONFIG_ALLOW_CROSS=1

    sudo apt-get install -y gcc-aarch64-linux-gnu g++-aarch64-linux-gnu
    sudo apt-get install -y crossbuild-essential-arm64
  elif [[ "${VSCODE_ARCH}" == "armhf" ]]; then
    VSCODE_CLI_TARGET="armv7-unknown-linux-gnueabihf"

    export OPENSSL_LIB_DIR="$( pwd )/openssl/out/arm-linux/lib"
    export OPENSSL_INCLUDE_DIR="$( pwd )/openssl/out/arm-linux/include"

    # export CARGO_TARGET_ARMV7_UNKNOWN_LINUX_GNUEABIHF_LINKER="${VSCODE_SYSROOT_DIR}/arm-rpi-linux-gnueabihf/bin/arm-rpi-linux-gnueabihf-gcc"
    # export CARGO_TARGET_ARMV7_UNKNOWN_LINUX_GNUEABIHF_RUSTFLAGS="-C link-arg=--sysroot=${VSCODE_SYSROOT_DIR}/arm-rpi-linux-gnueabihf/arm-rpi-linux-gnueabihf/sysroot"
    # export CC_armv7_unknown_linux_gnueabihf="${VSCODE_SYSROOT_DIR}/arm-rpi-linux-gnueabihf/bin/arm-rpi-linux-gnueabihf-gcc --sysroot=${VSCODE_SYSROOT_DIR}/arm-rpi-linux-gnueabihf/arm-rpi-linux-gnueabihf/sysroot"
    # export PKG_CONFIG_LIBDIR_armv7_unknown_linux_gnueabihf="${VSCODE_SYSROOT_DIR}/arm-rpi-linux-gnueabihf/arm-rpi-linux-gnueabihf/sysroot/usr/lib/arm-rpi-linux-gnueabihf/pkgconfig:${VSCODE_SYSROOT_DIR}/arm-rpi-linux-gnueabihf/arm-rpi-linux-gnueabihf/sysroot/usr/share/pkgconfig"
    # export PKG_CONFIG_SYSROOT_DIR_armv7_unknown_linux_gnueabihf="${VSCODE_SYSROOT_DIR}/arm-rpi-linux-gnueabihf/arm-rpi-linux-gnueabihf/sysroot"
    # export OBJDUMP="${VSCODE_SYSROOT_DIR}/arm-rpi-linux-gnueabihf/arm-rpi-linux-gnueabihf/bin/objdump"

    export CARGO_TARGET_ARMV7_UNKNOWN_LINUX_GNUEABIHF_LINKER=arm-linux-gnueabihf-gcc
    export CC_armv7_unknown_linux_gnueabihf=arm-linux-gnueabihf-gcc
    export CXX_armv7_unknown_linux_gnueabihf=arm-linux-gnueabihf-g++
    export PKG_CONFIG_ALLOW_CROSS=1

    sudo apt-get install -y gcc-arm-linux-gnu g++-arm-linux-gnu
    sudo apt-get install -y crossbuild-essential-arm
  elif [[ "${VSCODE_ARCH}" == "x64" ]]; then
    VSCODE_CLI_TARGET="x86_64-unknown-linux-gnu"

    # export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER="${VSCODE_SYSROOT_DIR}/x86_64-linux-gnu/bin/x86_64-linux-gnu-gcc"
    # export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_RUSTFLAGS="-C link-arg=--sysroot=${VSCODE_SYSROOT_DIR}/x86_64-linux-gnu/x86_64-linux-gnu/sysroot -C link-arg=-L${VSCODE_SYSROOT_DIR}/x86_64-linux-gnu/x86_64-linux-gnu/sysroot/usr/lib/x86_64-linux-gnu"
    # export CC_x86_64_unknown_linux_gnu="${VSCODE_SYSROOT_DIR}/x86_64-linux-gnu/bin/x86_64-linux-gnu-gcc --sysroot=${VSCODE_SYSROOT_DIR}/x86_64-linux-gnu/x86_64-linux-gnu/sysroot"
    # export PKG_CONFIG_LIBDIR_x86_64_unknown_linux_gnu="${VSCODE_SYSROOT_DIR}/x86_64-linux-gnu/x86_64-linux-gnu/sysroot/usr/lib/x86_64-linux-gnu/pkgconfig:${VSCODE_SYSROOT_DIR}/x86_64-linux-gnu/x86_64-linux-gnu/sysroot/usr/share/pkgconfig"
    # export PKG_CONFIG_SYSROOT_DIR_x86_64_unknown_linux_gnu="${VSCODE_SYSROOT_DIR}/x86_64-linux-gnu/x86_64-linux-gnu/sysroot"
    # export OBJDUMP="${VSCODE_SYSROOT_DIR}/x86_64-linux-gnu/x86_64-linux-gnu/bin/objdump"
  fi

  if [[ -n "${VSCODE_CLI_TARGET}" ]]; then
    # node -e '(async () => { const { getVSCodeSysroot } = require("../build/linux/debian/install-sysroot.js"); await getVSCodeSysroot(process.env["VSCODE_ARCH"]); })()'

    rustup target add "${VSCODE_CLI_TARGET}"

    cargo build --release --target "${VSCODE_CLI_TARGET}" --bin=code

    cp "target/${VSCODE_CLI_TARGET}/release/code" "../../VSCode-linux-${VSCODE_ARCH}/bin/${TUNNEL_APPLICATION_NAME}"
  fi
fi

cd ..
