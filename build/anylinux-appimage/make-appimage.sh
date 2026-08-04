#!/bin/sh

set -eu

ARCH=$(uname -m)
QUALITY="${VSCODE_QUALITY:-stable}"
export ARCH
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON="icons/$QUALITY/codium_cnl.svg"
export DEPLOY_GTK=1
export DEPLOY_OPENGL=1
export DEPLOY_VULKAN=1

# Deploy dependencies
# Protect the CLI script (bin/bin/codium) from being overwritten by an Electron hardlink.
# quick-sharun skips non-executable files, so we make it non-executable temporarily.
chmod -x ./AppDir/bin/bin/codium
quick-sharun ./AppDir/bin/*
chmod +x ./AppDir/bin/bin/codium

# Route all launches through the CLI script (bin/bin/codium).
# This keeps CLI commands working and doesn't affect normal launch.
cat > ./AppDir/bin/cli-router.hook <<'EOF'
exec "$APPDIR/bin/bin/codium" "$@"
EOF

# Additional changes can be done in between here

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the AppImage (simple test: check for missing symbols)
quick-sharun --simple-test ./dist/*.AppImage
