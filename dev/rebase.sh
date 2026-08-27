#!/usr/bin/env bash

set -e

cd "$( dirname "$0" )/.." || exit 1

[[ -d vscode ]] || { echo "'vscode' dir not found; run ./dev/build.sh first"; exit 1; }

case " $* " in
  *" --continue "* | *" --skip "* | *" --skip="* | *" --redo "* | *" --abort "* | *" --status "* | *" --help "* | *" -h "*)
    ;;
  *)
    # shellcheck disable=SC1091
    ( cd vscode && . ../utils.sh && . ../patches.sh && guard_preflight ) || exit 1
    ;;
esac

exec python3 dev/lib/stack.py rebase "$@"
