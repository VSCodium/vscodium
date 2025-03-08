#!/usr/bin/env bash

# When installing @vscode/ripgrep, it will try to download prebuilt ripgrep binary from https://github.com/microsoft/ripgrep-prebuilt,
# however, loong64 is not a supported architecture and x86 will be picked as fallback, so we need to replace it with a native one.

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <path_to_node_modules>"
    exit 1
fi

RG_PATH="$1/@vscode/ripgrep/bin/rg"
RG_VERSION="14.1.1"

echo "Replacing ripgrep binary with loong64 one"

rm "${RG_PATH}"
curl --silent --fail -L https://github.com/darkyzhou/ripgrep-loongarch64-musl/releases/download/${RG_VERSION}/rg -o "${RG_PATH}"
chmod +x "${RG_PATH}"
