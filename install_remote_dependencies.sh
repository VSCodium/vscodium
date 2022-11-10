#!/bin/bash

set -e

cd vscode || { echo "'vscode' dir not found"; exit 1; }

yarn --cwd remote --frozen-lockfile --check-files

cd ..

tar cf remote-dependencies.tar ./vscode/remote/node_modules
