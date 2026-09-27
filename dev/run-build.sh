#!/usr/bin/env bash
# Local build wrapper:
#  - use the node version from .nvmrc
#  - use homebrew python3.12 (docs require python 3.11+)
#  - strip homebrew util-linux env flags: its uuid/uuid.h shadows the macOS SDK
#    header and breaks native module builds (@vscodium/policy-watcher)
export NVM_DIR="$HOME/.nvm"
. "$NVM_DIR/nvm.sh"
nvm use 24.18.0

unset LDFLAGS CPPFLAGS PKG_CONFIG_PATH
export PATH="$( echo "$PATH" | tr ':' '\n' | grep -v 'util-linux' | paste -sd: - )"
export PATH="$HOME/build-bin:$PATH"
export PYTHON="/opt/homebrew/bin/python3.12"

cd "$(dirname "$0")/.."
exec ./dev/build.sh "$@"
