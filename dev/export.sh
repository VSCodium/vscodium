#!/usr/bin/env bash

set -e

cd "$( dirname "$0" )/.." || exit 1

[[ -d vscode ]] || { echo "'vscode' dir not found; run ./dev/build.sh first"; exit 1; }

exec python3 dev/lib/stack.py export "$@"
