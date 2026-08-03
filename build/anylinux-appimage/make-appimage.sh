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
quick-sharun ./AppDir/bin/*

# Restore the CLI script and route CLI arguments via hook.
# quick-sharun skipped it because we removed +x in get-dependencies.sh.
chmod +x ./AppDir/bin/bin/codium

cat > ./AppDir/bin/cli-router.hook <<'EOF'
case "$1" in --*) exec "$APPDIR/bin/bin/codium" "$@" ;; esac
EOF

# Additional changes can be done in between here

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the AppImage (simple test: check for missing symbols)
quick-sharun --simple-test ./dist/*.AppImage
