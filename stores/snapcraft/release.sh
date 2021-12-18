#!/bin/bash

set -e

CALLER_DIR=$( pwd )

cd "$( dirname "${BASH_SOURCE[0]}" )"

echo "$SNAP_STORE_LOGIN" | snapcraft login --with -

snapcraft upload --release=stable *.snap

snapcraft logout

cd "${CALLER_DIR}"
