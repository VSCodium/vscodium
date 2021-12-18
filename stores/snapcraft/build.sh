#!/bin/bash

set -e

CALLER_DIR=$( pwd )

cd "$( dirname "${BASH_SOURCE[0]}" )"

sg lxd -c 'snapcraft --use-lxd'

ls -la

cd "${CALLER_DIR}"
