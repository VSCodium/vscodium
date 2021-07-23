#!/usr/bin/env bash

set -e

# DEBUG
# set -o xtrace

check_programs() {
  for arg in "$@"
  do
    if ! command -v $arg >/dev/null 2>&1
    then
      echo "$arg could not be found"
      exit
    fi
  done
}

check_programs "icns2png" "composite" "convert" "png2icns" "icotool"

SRC_PREFIX=""
VSCODE_PREFIX=""

build_darwin_types() {
  for file in ${VSCODE_PREFIX}vscode/resources/darwin/*
  do
    if [ -f "$file" ]; then
      name=$(basename $file '.icns')

      if [[ $name != 'code' ]] && [ ! -f "${SRC_PREFIX}src/resources/darwin/$name.icns" ]; then
        icns2png -x -s 512x512 $file -o .

        composite -blend 100% -geometry +323+365 icons/corner_512.png "${name}_512x512x32.png" "$name.png"
        composite icons/code_darwin.png "$name.png" "$name.png"

        convert "$name.png" -resize 256x256 "${name}_256.png"

        png2icns "${SRC_PREFIX}src/resources/darwin/$name.icns" "$name.png" "${name}_256.png"

        rm "${name}_512x512x32.png" "$name.png" "${name}_256.png"
      fi
    fi
  done
}

build_darwin_main() {
  if [ ! -f "${SRC_PREFIX}src/resources/darwin/code.icns" ]; then
    convert "${SRC_PREFIX}src/resources/linux/code.png" -resize 512x512 code_512.png
    convert "${SRC_PREFIX}src/resources/linux/code.png" -resize 256x256 code_256.png
    convert "${SRC_PREFIX}src/resources/linux/code.png" -resize 128x128 code_128.png

    png2icns "${SRC_PREFIX}src/resources/darwin/code.icns" code_512.png code_256.png code_128.png

    rm code_512.png code_256.png code_128.png
  fi
}

build_win32() {
  for file in ${VSCODE_PREFIX}vscode/resources/win32/*.ico
  do
    if [ -f "$file" ]; then
      name=$(basename $file '.ico')

      if [[ $name != 'code' ]] && [ ! -f "${SRC_PREFIX}src/resources/win32/$name.ico" ]; then
        icotool -x -w 256 $file

        composite -geometry +150+185 icons/code_64.png "${name}_9_256x256x32.png" "${name}.png"

        convert "${name}.png" -define icon:auto-resize=256,128,96,64,48,32,24,20,16 "${SRC_PREFIX}src/resources/win32/$name.ico"

        rm "${name}_9_256x256x32.png" "${name}.png"
      fi
    fi
  done

  if [ ! -f "${SRC_PREFIX}src/resources/win32/code.ico" ]; then
    convert "${SRC_PREFIX}src/resources/linux/code.png" -define icon:auto-resize=256,128,96,64,48,32,24,20,16 "${SRC_PREFIX}src/resources/win32/code.ico"
  fi

  if [ ! -f "${SRC_PREFIX}src/resources/win32/inno-big-100.bmp" ]; then
    convert -size 164x314 xc:white "${SRC_PREFIX}src/resources/win32/inno-big-100.bmp"
    composite -size 126x -gravity center icons/codium_only.svg "${SRC_PREFIX}src/resources/win32/inno-big-100.bmp" "${SRC_PREFIX}src/resources/win32/inno-big-100.bmp"
  fi
  if [ ! -f "${SRC_PREFIX}src/resources/win32/inno-big-125.bmp" ]; then
    convert -size 192x386 xc:white "${SRC_PREFIX}src/resources/win32/inno-big-125.bmp"
    composite -size 147x -gravity center icons/codium_only.svg "${SRC_PREFIX}src/resources/win32/inno-big-125.bmp" "${SRC_PREFIX}src/resources/win32/inno-big-125.bmp"
  fi
  if [ ! -f "${SRC_PREFIX}src/resources/win32/inno-big-150.bmp" ]; then
    convert -size 246x459 xc:white "${SRC_PREFIX}src/resources/win32/inno-big-150.bmp"
    composite -size 190x -gravity center icons/codium_only.svg "${SRC_PREFIX}src/resources/win32/inno-big-150.bmp" "${SRC_PREFIX}src/resources/win32/inno-big-150.bmp"
  fi
  if [ ! -f "${SRC_PREFIX}src/resources/win32/inno-big-175.bmp" ]; then
    convert -size 273x556 xc:white "${SRC_PREFIX}src/resources/win32/inno-big-175.bmp"
    composite -size 211x -gravity center icons/codium_only.svg "${SRC_PREFIX}src/resources/win32/inno-big-175.bmp" "${SRC_PREFIX}src/resources/win32/inno-big-175.bmp"
  fi
  if [ ! -f "${SRC_PREFIX}src/resources/win32/inno-big-200.bmp" ]; then
    convert -size 328x604 xc:white "${SRC_PREFIX}src/resources/win32/inno-big-200.bmp"
    composite -size 255x -gravity center icons/codium_only.svg "${SRC_PREFIX}src/resources/win32/inno-big-200.bmp" "${SRC_PREFIX}src/resources/win32/inno-big-200.bmp"
  fi
  if [ ! -f "${SRC_PREFIX}src/resources/win32/inno-big-225.bmp" ]; then
    convert -size 355x700 xc:white "${SRC_PREFIX}src/resources/win32/inno-big-225.bmp"
    composite -size 273x -gravity center icons/codium_only.svg "${SRC_PREFIX}src/resources/win32/inno-big-225.bmp" "${SRC_PREFIX}src/resources/win32/inno-big-225.bmp"
  fi
  if [ ! -f "${SRC_PREFIX}src/resources/win32/inno-big-250.bmp" ]; then
    convert -size 410x797 xc:white "${SRC_PREFIX}src/resources/win32/inno-big-250.bmp"
    composite -size 317x -gravity center icons/codium_only.svg "${SRC_PREFIX}src/resources/win32/inno-big-250.bmp" "${SRC_PREFIX}src/resources/win32/inno-big-250.bmp"
  fi

  if [ ! -f "${SRC_PREFIX}src/resources/win32/inno-small-100.bmp" ]; then
    convert -size 55x55 xc:white "${SRC_PREFIX}src/resources/win32/inno-small-100.bmp"
    composite -size 44x -gravity center icons/codium_only.svg "${SRC_PREFIX}src/resources/win32/inno-small-100.bmp" "${SRC_PREFIX}src/resources/win32/inno-small-100.bmp"
  fi
  if [ ! -f "${SRC_PREFIX}src/resources/win32/inno-small-125.bmp" ]; then
    convert -size 64x68 xc:white "${SRC_PREFIX}src/resources/win32/inno-small-125.bmp"
    composite -size 52x -gravity center icons/codium_only.svg "${SRC_PREFIX}src/resources/win32/inno-small-125.bmp" "${SRC_PREFIX}src/resources/win32/inno-small-125.bmp"
  fi
  if [ ! -f "${SRC_PREFIX}src/resources/win32/inno-small-150.bmp" ]; then
    convert -size 83x80 xc:white "${SRC_PREFIX}src/resources/win32/inno-small-150.bmp"
    composite -size 63x -gravity center icons/codium_only.svg "${SRC_PREFIX}src/resources/win32/inno-small-150.bmp" "${SRC_PREFIX}src/resources/win32/inno-small-150.bmp"
  fi
  if [ ! -f "${SRC_PREFIX}src/resources/win32/inno-small-175.bmp" ]; then
    convert -size 92x97 xc:white "${SRC_PREFIX}src/resources/win32/inno-small-175.bmp"
    composite -size 76x -gravity center icons/codium_only.svg "${SRC_PREFIX}src/resources/win32/inno-small-175.bmp" "${SRC_PREFIX}src/resources/win32/inno-small-175.bmp"
  fi
  if [ ! -f "${SRC_PREFIX}src/resources/win32/inno-small-200.bmp" ]; then
    convert -size 110x106 xc:white "${SRC_PREFIX}src/resources/win32/inno-small-200.bmp"
    composite -size 86x -gravity center icons/codium_only.svg "${SRC_PREFIX}src/resources/win32/inno-small-200.bmp" "${SRC_PREFIX}src/resources/win32/inno-small-200.bmp"
  fi
  if [ ! -f "${SRC_PREFIX}src/resources/win32/inno-small-225.bmp" ]; then
    convert -size 119x123 xc:white "${SRC_PREFIX}src/resources/win32/inno-small-225.bmp"
    composite -size 103x -gravity center icons/codium_only.svg "${SRC_PREFIX}src/resources/win32/inno-small-225.bmp" "${SRC_PREFIX}src/resources/win32/inno-small-225.bmp"
  fi
  if [ ! -f "${SRC_PREFIX}src/resources/win32/inno-small-250.bmp" ]; then
    convert -size 138x140 xc:white "${SRC_PREFIX}src/resources/win32/inno-small-250.bmp"
    composite -size 116x -gravity center icons/codium_only.svg "${SRC_PREFIX}src/resources/win32/inno-small-250.bmp" "${SRC_PREFIX}src/resources/win32/inno-small-250.bmp"
  fi
}

if [ "$0" == "$BASH_SOURCE" ];
then
  build_darwin_types
  build_win32
fi
