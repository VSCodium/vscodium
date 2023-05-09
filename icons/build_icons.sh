#!/usr/bin/env bash

set -e

# DEBUG
# set -o xtrace

QUALITY="stable"
COLOR="blue1"

while getopts ":i" opt; do
  case "$opt" in
    i)
      export QUALITY="insider"
      export COLOR="orange1"
      ;;
  esac
done

check_programs() { # {{{
  for arg in "$@"
  do
    if ! command -v "${arg}" >/dev/null 2>&1
    then
      echo "${arg} could not be found"
      exit
    fi
  done
} # }}}

check_programs "icns2png" "composite" "convert" "png2icns" "icotool" "rsvg-convert" "sed"

. ./utils.sh

SRC_PREFIX=""
VSCODE_PREFIX=""

build_darwin_main() { # {{{
  if [ ! -f "${SRC_PREFIX}src/${QUALITY}/resources/darwin/code.icns" ]; then
    rsvg-convert -w 655 -h 655 "icons/${QUALITY}/codium_cnl.svg" -o "code_logo.png"
    composite "code_logo.png" -gravity center "icons/template_macos.png" "code_1024.png"
    convert "code_1024.png" -resize 512x512 code_512.png
    convert "code_1024.png" -resize 256x256 code_256.png
    convert "code_1024.png" -resize 128x128 code_128.png

    png2icns "${SRC_PREFIX}src/${QUALITY}/resources/darwin/code.icns" code_512.png code_256.png code_128.png

    rm code_1024.png code_512.png code_256.png code_128.png code_logo.png
  fi
} # }}}

build_darwin_types() { # {{{
  rsvg-convert -w 128 -h 128 "icons/${QUALITY}/codium_cnl_w80_b8.svg" -o "code_logo.png"

  for file in "${VSCODE_PREFIX}"vscode/resources/darwin/*
  do
    if [ -f "${file}" ]; then
      name=$(basename "${file}" '.icns')

      if [[ ${name} != 'code' ]] && [ ! -f "${SRC_PREFIX}src/${QUALITY}/resources/darwin/${name}.icns" ]; then
        icns2png -x -s 512x512 "${file}" -o .

        composite -blend 100% -geometry +323+365 "icons/corner_512.png" "${name}_512x512x32.png" "${name}.png"
        composite -geometry +359+374 "code_logo.png" "${name}.png" "${name}.png"

        convert "${name}.png" -resize 256x256 "${name}_256.png"

        png2icns "${SRC_PREFIX}src/${QUALITY}/resources/darwin/${name}.icns" "${name}.png" "${name}_256.png"

        rm "${name}_512x512x32.png" "${name}.png" "${name}_256.png"
      fi
    fi
  done

  rm "code_logo.png"
} # }}}

build_linux_main() { # {{{
  if [ ! -f "${SRC_PREFIX}src/${QUALITY}/resources/linux/code.png" ]; then
    wget "https://raw.githubusercontent.com/VSCodium/icons/main/icons/linux/circle1/${COLOR}/paulo22s.png" -O "${SRC_PREFIX}src/${QUALITY}/resources/linux/code.png"
  fi

  mkdir -p "${SRC_PREFIX}src/${QUALITY}/resources/linux/rpm"

  if [ ! -f "${SRC_PREFIX}src/${QUALITY}/resources/linux/rpm/code.xpm" ]; then
    convert "${SRC_PREFIX}src/${QUALITY}/resources/linux/code.png" "${SRC_PREFIX}src/${QUALITY}/resources/linux/rpm/code.xpm"
  fi
} # }}}

build_media() { # {{{
  if [ ! -f "${SRC_PREFIX}src/${QUALITY}/src/vs/workbench/browser/media/code-icon.svg" ]; then
    cp "icons/${QUALITY}/codium_clt.svg" "${SRC_PREFIX}src/${QUALITY}/src/vs/workbench/browser/media/code-icon.svg"
    gsed -i 's|width="100" height="100"|width="1024" height="1024"|' "${SRC_PREFIX}src/${QUALITY}/src/vs/workbench/browser/media/code-icon.svg"
  fi
} # }}}

build_windows_main() { # {{{
  if [ ! -f "${SRC_PREFIX}src/${QUALITY}/resources/win32/code.ico" ]; then
    wget "https://raw.githubusercontent.com/VSCodium/icons/main/icons/win32/nobg/${COLOR}/paulo22s.ico" -O "${SRC_PREFIX}src/${QUALITY}/resources/win32/code.ico"
  fi
} # }}}

build_windows_types() { # {{{
  mkdir -p "${SRC_PREFIX}src/${QUALITY}/resources/win32"

  rsvg-convert -b "#F5F6F7" -w 64 -h 64 "icons/${QUALITY}/codium_cnl.svg" -o "code_logo.png"

  for file in "${VSCODE_PREFIX}"vscode/resources/win32/*.ico
  do
    if [ -f "${file}" ]; then
      name=$(basename "${file}" '.ico')

      if [[ ${name} != 'code' ]] && [ ! -f "${SRC_PREFIX}src/${QUALITY}/resources/win32/${name}.ico" ]; then
        icotool -x -w 256 "${file}"

        composite -geometry +150+185 "code_logo.png" "${name}_9_256x256x32.png" "${name}.png"

        convert "${name}.png" -define icon:auto-resize=256,128,96,64,48,32,24,20,16 "${SRC_PREFIX}src/${QUALITY}/resources/win32/${name}.ico"

        rm "${name}_9_256x256x32.png" "${name}.png"
      fi
    fi
  done

  if [ ! -f "${SRC_PREFIX}src/${QUALITY}/resources/win32/code_70x70.png" ]; then
    convert -size 70x70 canvas:transparent PNG32:"${SRC_PREFIX}src/${QUALITY}/resources/win32/code_70x70.png"
    rsvg-convert -w 45 -h 45 "icons/${QUALITY}/codium_cnl.svg" -o "code_logo.png"
    composite -gravity center "code_logo.png" "${SRC_PREFIX}src/${QUALITY}/resources/win32/code_70x70.png" "${SRC_PREFIX}src/${QUALITY}/resources/win32/code_70x70.png"
  fi

   if [ ! -f "${SRC_PREFIX}src/${QUALITY}/resources/win32/code_150x150.png" ]; then
    convert -size 150x150 canvas:transparent PNG32:"${SRC_PREFIX}src/${QUALITY}/resources/win32/code_150x150.png"
    rsvg-convert -w 64 -h 64 "icons/${QUALITY}/codium_cnl.svg" -o "code_logo.png"
    composite -geometry +44+25 "code_logo.png" "${SRC_PREFIX}src/${QUALITY}/resources/win32/code_150x150.png" "${SRC_PREFIX}src/${QUALITY}/resources/win32/code_150x150.png"
  fi

  if [ ! -f "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-big-100.bmp" ]; then
    convert -size 164x314 xc:white "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-big-100.bmp"
    rsvg-convert -w 126 -h 126 "icons/${QUALITY}/codium_cnl.svg" -o "code_logo.png"
    composite -gravity center "code_logo.png" "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-big-100.bmp" "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-big-100.bmp"
  fi
  if [ ! -f "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-big-125.bmp" ]; then
    convert -size 192x386 xc:white "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-big-125.bmp"
    rsvg-convert -w 147 -h 147 "icons/${QUALITY}/codium_cnl.svg" -o "code_logo.png"
    composite -gravity center "code_logo.png" "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-big-125.bmp" "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-big-125.bmp"
  fi
  if [ ! -f "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-big-150.bmp" ]; then
    convert -size 246x459 xc:white "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-big-150.bmp"
    rsvg-convert -w 190 -h 190 "icons/${QUALITY}/codium_cnl.svg" -o "code_logo.png"
    composite -gravity center "code_logo.png" "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-big-150.bmp" "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-big-150.bmp"
  fi
  if [ ! -f "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-big-175.bmp" ]; then
    convert -size 273x556 xc:white "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-big-175.bmp"
    rsvg-convert -w 211 -h 211 "icons/${QUALITY}/codium_cnl.svg" -o "code_logo.png"
    composite -gravity center "code_logo.png" "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-big-175.bmp" "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-big-175.bmp"
  fi
  if [ ! -f "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-big-200.bmp" ]; then
    convert -size 328x604 xc:white "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-big-200.bmp"
    rsvg-convert -w 255 -h 255 "icons/${QUALITY}/codium_cnl.svg" -o "code_logo.png"
    composite -gravity center "code_logo.png" "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-big-200.bmp" "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-big-200.bmp"
  fi
  if [ ! -f "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-big-225.bmp" ]; then
    convert -size 355x700 xc:white "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-big-225.bmp"
    rsvg-convert -w 273 -h 273 "icons/${QUALITY}/codium_cnl.svg" -o "code_logo.png"
    composite -gravity center "code_logo.png" "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-big-225.bmp" "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-big-225.bmp"
  fi
  if [ ! -f "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-big-250.bmp" ]; then
    convert -size 410x797 xc:white "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-big-250.bmp"
    rsvg-convert -w 317 -h 317 "icons/${QUALITY}/codium_cnl.svg" -o "code_logo.png"
    composite -gravity center "code_logo.png" "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-big-250.bmp" "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-big-250.bmp"
  fi

  if [ ! -f "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-small-100.bmp" ]; then
    convert -size 55x55 xc:white "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-small-100.bmp"
    rsvg-convert -w 44 -h 44 "icons/${QUALITY}/codium_cnl.svg" -o "code_logo.png"
    composite -gravity center "code_logo.png" "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-small-100.bmp" "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-small-100.bmp"
  fi
  if [ ! -f "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-small-125.bmp" ]; then
    convert -size 64x68 xc:white "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-small-125.bmp"
    rsvg-convert -w 52 -h 52 "icons/${QUALITY}/codium_cnl.svg" -o "code_logo.png"
    composite -gravity center "code_logo.png" "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-small-125.bmp" "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-small-125.bmp"
  fi
  if [ ! -f "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-small-150.bmp" ]; then
    convert -size 83x80 xc:white "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-small-150.bmp"
    rsvg-convert -w 63 -h 63 "icons/${QUALITY}/codium_cnl.svg" -o "code_logo.png"
    composite -gravity center "code_logo.png" "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-small-150.bmp" "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-small-150.bmp"
  fi
  if [ ! -f "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-small-175.bmp" ]; then
    convert -size 92x97 xc:white "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-small-175.bmp"
    rsvg-convert -w 76 -h 76 "icons/${QUALITY}/codium_cnl.svg" -o "code_logo.png"
    composite -gravity center "code_logo.png" "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-small-175.bmp" "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-small-175.bmp"
  fi
  if [ ! -f "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-small-200.bmp" ]; then
    convert -size 110x106 xc:white "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-small-200.bmp"
    rsvg-convert -w 86 -h 86 "icons/${QUALITY}/codium_cnl.svg" -o "code_logo.png"
    composite -gravity center "code_logo.png" "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-small-200.bmp" "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-small-200.bmp"
  fi
  if [ ! -f "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-small-225.bmp" ]; then
    convert -size 119x123 xc:white "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-small-225.bmp"
    rsvg-convert -w 103 -h 103 "icons/${QUALITY}/codium_cnl.svg" -o "code_logo.png"
    composite -gravity center "code_logo.png" "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-small-225.bmp" "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-small-225.bmp"
  fi
  if [ ! -f "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-small-250.bmp" ]; then
    convert -size 138x140 xc:white "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-small-250.bmp"
    rsvg-convert -w 116 -h 116 "icons/${QUALITY}/codium_cnl.svg" -o "code_logo.png"
    composite -gravity center "code_logo.png" "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-small-250.bmp" "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-small-250.bmp"
  fi
  if [ ! -f "${SRC_PREFIX}build/windows/msi/resources/${QUALITY}/wix-banner.bmp" ]; then
    convert -size 493x58 xc:white "${SRC_PREFIX}build/windows/msi/resources/${QUALITY}/wix-banner.bmp"
    rsvg-convert -w 50 -h 50 "icons/${QUALITY}/codium_cnl.svg" -o "code_logo.png"
    composite -geometry +438+6 "code_logo.png" "${SRC_PREFIX}build/windows/msi/resources/${QUALITY}/wix-banner.bmp" "${SRC_PREFIX}build/windows/msi/resources/${QUALITY}/wix-banner.bmp"
  fi
  if [ ! -f "${SRC_PREFIX}build/windows/msi/resources/${QUALITY}/wix-dialog.bmp" ]; then
    convert -size 493x312 xc:white "${SRC_PREFIX}build/windows/msi/resources/${QUALITY}/wix-dialog.bmp"
    rsvg-convert -w 120 -h 120 "icons/${QUALITY}/codium_cnl.svg" -o "code_logo.png"
    composite -geometry +22+152 "code_logo.png" "${SRC_PREFIX}build/windows/msi/resources/${QUALITY}/wix-dialog.bmp" "${SRC_PREFIX}build/windows/msi/resources/${QUALITY}/wix-dialog.bmp"
  fi

  rm code_logo.png
} # }}}

if [ "${0}" == "${BASH_SOURCE}" ];
then
  build_darwin_main
  build_linux_main
  build_windows_main

  build_darwin_types
  build_windows_types

  build_media
fi
