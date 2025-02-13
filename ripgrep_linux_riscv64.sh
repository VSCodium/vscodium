#!/usr/bin/env bash

# microsoft/ripgrep-prebuilt doesn't support riscv64.
# Tracking PR: https://github.com/microsoft/ripgrep-prebuilt/pull/41

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <path_to_node_modules>"
    exit 1
fi

RG_PATH="$1/@vscode/ripgrep/bin/rg"
RG_VERSION="14.1.1-3"

echo "Replacing ripgrep binary with riscv64 one"

rm "${RG_PATH}"
curl --silent --fail -L https://github.com/riscv-forks/ripgrep-riscv64-prebuilt/releases/download/${RG_VERSION}/rg -o "${RG_PATH}"
chmod +x "${RG_PATH}"
