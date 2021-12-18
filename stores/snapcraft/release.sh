#!/bin/bash

set -e

CALLER_DIR=$( pwd )

cd "$( dirname "${BASH_SOURCE[0]}" )"

snapcraft upload --release=stable *.snap

cd "${CALLER_DIR}"
