#!/bin/bash

set -e

echo "$SNAP_STORE_LOGIN" | snapcraft login --with -

snapcraft upload --release=stable *.snap

snapcraft logout
