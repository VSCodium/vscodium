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

# Additional changes can be done in between here

# Implement the official codium CLI script as a hook so every launch
# goes through cli.js (keeps CLI commands working, GUI unaffected).
# Paths are resolved from $APPDIR/bin since $0 is AppRun here.
cat > ./AppDir/bin/cli-router.hook <<'EOF'
# when run in remote terminal, use the remote cli
if [ -n "$VSCODE_IPC_HOOK_CLI" ]; then
        REMOTE_CLI="$(which -a 'codium' | grep /remote-cli/)"
        if [ -n "$REMOTE_CLI" ]; then
                "$REMOTE_CLI" "$@"
                exit $?
        fi
fi

# test that VSCode wasn't installed inside WSL
if grep -qi Microsoft /proc/version && [ -z "$DONT_PROMPT_WSL_INSTALL" ]; then
        echo "To use VSCodium with the Windows Subsystem for Linux, please install VSCodium in Windows and uninstall the Linux version in WSL. You can then use the \`codium\` command in a WSL terminal just as you would in a normal command prompt." 1>&2
        printf "Do you want to continue anyway? [y/N] " 1>&2
        read -r YN
        YN=$(printf '%s' "$YN" | tr '[:upper:]' '[:lower:]')
        case "$YN" in
                y | yes )
                ;;
                * )
                        exit 1
                ;;
        esac
        echo "To no longer see this prompt, start VSCodium with the environment variable DONT_PROMPT_WSL_INSTALL defined." 1>&2
fi

# If root, ensure that --user-data-dir or --file-write is specified
if [ "$(id -u)" = "0" ]; then
        for i in "$@"
        do
                case "$i" in
                        --user-data-dir | --user-data-dir=* | --file-write | tunnel | serve-web )
                                CAN_LAUNCH_AS_ROOT=1
                        ;;
                esac
        done
        if [ -z "$CAN_LAUNCH_AS_ROOT" ]; then
                echo "You are trying to start VSCodium as a super user which isn't recommended. If this was intended, please add the argument \`--no-sandbox\` and specify an alternate user data directory using the \`--user-data-dir\` argument." 1>&2
                exit 1
        fi
fi

ELECTRON="$APPDIR/bin/codium"
CLI="$APPDIR/bin/resources/app/out/cli.js"
ELECTRON_RUN_AS_NODE=1 "$ELECTRON" "$CLI" "$@"
exit $?
EOF


# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the AppImage (simple test: check for missing symbols)
quick-sharun --simple-test ./dist/*.AppImage
