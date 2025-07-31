#!/usr/bin/env bash
# shellcheck disable=SC1091

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
  *) ;;
  esac
done

check_programs() { # {{{
  for arg in "$@"; do
    if ! command -v "${arg}" &>/dev/null; then
      echo "${arg} could not be found"
      exit 0
    fi
  done
} # }}}

check_programs "icns2png" "composite" "convert" "png2icns" "icotool" "rsvg-convert" "sed"

. ./utils.sh

SRC_PREFIX=""
VSCODE_PREFIX=""

build_letterpress() { # {{{
  # Create Codex-branded letterpress files for watermarks
  local LETTERPRESS_DIR="${SRC_PREFIX}src/${QUALITY}/src/vs/workbench/browser/parts/editor/media"

  if [[ -d "${LETTERPRESS_DIR}" ]]; then
    echo "Updating letterpress watermark files with Codex branding..."

    # Convert main Codex logo to letterpress format
    rsvg-convert -w 40 -h 40 "icons/${QUALITY}/codex_clt.svg" -o "codex_letterpress_temp.png"

    # Create letterpress SVG files with different opacity levels for different themes
    cat >"${LETTERPRESS_DIR}/letterpress-dark.svg" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0" y="0" width="40" height="40" viewBox="0, 0, 40, 40">
  <g id="codex_grey_dark_letterpress">
    <path d="M19.582,8.546 C18.897,8.985 18.7,9.896 19.141,10.578 C21.567,14.335 22.14,17.169 21.892,19.653 C20.888,24.409 18.705,25.373 16.797,25.373 C14.935,25.373 15.434,22.308 16.833,21.411 C17.669,20.889 18.74,20.55 19.561,20.55 C20.375,20.55 21.035,19.892 21.035,19.081 C21.035,18.269 20.375,17.611 19.561,17.611 C18.602,17.611 17.66,17.813 16.782,18.156 C16.961,17.309 17.027,16.394 16.795,15.421 C16.443,13.943 15.429,12.532 13.668,11.164 C13.359,10.924 12.968,10.816 12.58,10.864 C12.192,10.912 11.839,11.112 11.599,11.42 C11.099,12.06 11.215,12.984 11.857,13.482 C13.292,14.597 13.766,15.422 13.928,16.1 C14.09,16.779 13.959,17.508 13.634,18.509 C13.218,19.857 12.735,21.062 12.524,22.216 C12.419,22.784 12.41,23.403 12.384,23.897 C11.35,22.89 10.946,21.56 10.946,19.618 C10.946,18.806 10.286,18.148 9.472,18.148 C8.659,18.149 8,18.806 7.999,19.618 C7.999,22.271 8.775,24.796 10.855,26.48 C12.737,28.274 17.525,27.611 17.525,30.49 C17.525,31.303 18.714,31.698 19.528,31.698 C20.363,31.698 21.413,31.14 21.413,30.49 C21.413,27.223 24.856,25.238 30.524,25.246 C31.338,25.248 31.998,24.59 31.999,23.779 C32.001,22.967 31.342,22.307 30.528,22.306 C30.14,22.305 29.763,22.319 29.39,22.341 C30.024,20.851 30.305,19.21 30.247,17.438 C30.22,16.626 29.539,15.99 28.725,16.017 C27.911,16.043 27.273,16.723 27.3,17.535 C27.377,19.855 27.29,21.927 25.561,23.019 C25.07,23.33 24.498,23.599 23.956,23.599 C24.377,22.455 24.695,21.247 24.825,19.945 C24.908,19.114 24.917,18.127 24.822,17.36 C24.675,16.172 24.497,14.825 24.948,13.81 C25.353,12.936 26.261,12.57 27.594,12.57 C28.407,12.569 29.066,11.911 29.066,11.1 C29.067,10.288 28.407,9.63 27.594,9.629 C25.613,9.629 24.112,10.671 23.261,11.93 C22.816,10.98 22.274,10.001 21.619,8.987 C21.408,8.659 21.075,8.429 20.693,8.346 C20.504,8.305 20.308,8.302 20.118,8.336 C19.927,8.37 19.745,8.441 19.582,8.546 z" fill="#B2B2B2" fill-opacity="0.3" id="path6008"/>
  </g>
</svg>
EOF

    cat >"${LETTERPRESS_DIR}/letterpress-light.svg" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0" y="0" width="40" height="40" viewBox="0, 0, 40, 40">
  <g id="codex_grey_light_letterpress">
    <path d="M19.583,7.847 C18.898,8.287 18.701,9.197 19.142,9.88 C21.568,13.637 22.141,16.471 21.892,18.954 C20.888,23.71 18.705,24.675 16.798,24.675 C14.936,24.675 15.434,21.61 16.834,20.713 C17.67,20.191 18.74,19.852 19.562,19.852 C20.376,19.852 21.036,19.194 21.036,18.382 C21.036,17.571 20.376,16.913 19.562,16.913 C18.602,16.913 17.661,17.114 16.782,17.458 C16.962,16.611 17.028,15.695 16.796,14.722 C16.444,13.245 15.429,11.834 13.668,10.466 C13.36,10.226 12.969,10.118 12.581,10.166 C12.193,10.214 11.84,10.414 11.599,10.721 C11.1,11.362 11.215,12.286 11.858,12.784 C13.293,13.898 13.766,14.723 13.928,15.402 C14.09,16.081 13.96,16.81 13.635,17.81 C13.219,19.159 12.736,20.363 12.524,21.518 C12.42,22.086 12.411,22.705 12.384,23.199 C11.351,22.192 10.947,20.862 10.947,18.919 C10.946,18.108 10.286,17.45 9.473,17.45 C8.659,17.451 8,18.108 8,18.919 C8,21.573 8.776,24.098 10.856,25.782 C12.738,27.575 17.525,26.913 17.525,29.792 C17.525,30.604 18.715,31 19.529,31 C20.363,31 21.414,30.442 21.414,29.792 C21.414,26.525 24.857,24.539 30.524,24.548 C31.338,24.549 31.999,23.892 32,23.08 C32.001,22.268 31.343,21.609 30.529,21.608 C30.141,21.607 29.763,21.62 29.391,21.642 C30.025,20.152 30.306,18.512 30.248,16.739 C30.221,15.928 29.54,15.292 28.726,15.318 C27.912,15.345 27.274,16.025 27.301,16.837 C27.377,19.157 27.29,21.229 25.562,22.321 C25.07,22.631 24.499,22.901 23.957,22.901 C24.378,21.756 24.695,20.548 24.825,19.246 C24.908,18.416 24.917,17.428 24.823,16.662 C24.675,15.474 24.498,14.126 24.949,13.111 C25.354,12.237 26.262,11.871 27.594,11.871 C28.408,11.871 29.067,11.213 29.067,10.402 C29.067,9.59 28.408,8.931 27.594,8.931 C25.614,8.931 24.113,10.973 23.262,11.232 C22.817,10.282 22.275,9.302 21.62,8.289 C21.409,7.961 21.075,7.731 20.694,7.648 C20.504,7.607 20.309,7.603 20.119,7.637 C19.928,7.672 19.746,7.743 19.583,7.847 z" fill="#B2B2B2" fill-opacity="0.1" id="path6008"/>
  </g>
</svg>
EOF

    # Copy for high contrast themes
    cp "${LETTERPRESS_DIR}/letterpress-dark.svg" "${LETTERPRESS_DIR}/letterpress-hcDark.svg"
    cp "${LETTERPRESS_DIR}/letterpress-light.svg" "${LETTERPRESS_DIR}/letterpress-hcLight.svg"

    # Clean up temp file
    rm -f "codex_letterpress_temp.png"

    echo "Letterpress watermark files updated with Codex branding"
  fi
} # }}}

build_darwin_main() { # {{{
  if [[ ! -f "${SRC_PREFIX}src/${QUALITY}/resources/darwin/code.icns" ]]; then
    rsvg-convert -w 655 -h 655 "icons/${QUALITY}/codex_cnl.svg" -o "code_logo.png"
    composite "code_logo.png" -gravity center "icons/template_macos.png" "code_1024.png"
    convert "code_1024.png" -resize 512x512 code_512.png
    convert "code_1024.png" -resize 256x256 code_256.png
    convert "code_1024.png" -resize 128x128 code_128.png

    png2icns "${SRC_PREFIX}src/${QUALITY}/resources/darwin/code.icns" code_512.png code_256.png code_128.png

    rm code_1024.png code_512.png code_256.png code_128.png code_logo.png
  fi
} # }}}

build_darwin_types() { # {{{
  rsvg-convert -w 128 -h 128 "icons/${QUALITY}/codex_cnl_w80_b8.svg" -o "code_logo.png"

  for file in "${VSCODE_PREFIX}"vscode/resources/darwin/*; do
    if [[ -f "${file}" ]]; then
      name=$(basename "${file}" '.icns')

      if [[ "${name}" != 'code' ]] && [[ ! -f "${SRC_PREFIX}src/${QUALITY}/resources/darwin/${name}.icns" ]]; then
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
  if [[ ! -f "${SRC_PREFIX}src/${QUALITY}/resources/linux/code.png" ]]; then
    wget "https://raw.githubusercontent.com/Codex/icons/main/icons/linux/circle1/${COLOR}/paulo22s.png" -O "${SRC_PREFIX}src/${QUALITY}/resources/linux/code.png"
  fi

  mkdir -p "${SRC_PREFIX}src/${QUALITY}/resources/linux/rpm"

  if [[ ! -f "${SRC_PREFIX}src/${QUALITY}/resources/linux/rpm/code.xpm" ]]; then
    convert "${SRC_PREFIX}src/${QUALITY}/resources/linux/code.png" "${SRC_PREFIX}src/${QUALITY}/resources/linux/rpm/code.xpm"
  fi
} # }}}

build_media() { # {{{
  if [[ ! -f "${SRC_PREFIX}src/${QUALITY}/src/vs/workbench/browser/media/code-icon.svg" ]]; then
    cp "icons/${QUALITY}/codex_clt.svg" "${SRC_PREFIX}src/${QUALITY}/src/vs/workbench/browser/media/code-icon.svg"
    gsed -i 's|width="100" height="100"|width="1024" height="1024"|' "${SRC_PREFIX}src/${QUALITY}/src/vs/workbench/browser/media/code-icon.svg"
  fi
} # }}}

build_server() { # {{{
  if [[ ! -f "${SRC_PREFIX}src/${QUALITY}/resources/server/favicon.ico" ]]; then
    wget "https://raw.githubusercontent.com/Codex/icons/main/icons/win32/nobg/${COLOR}/paulo22s.ico" -O "${SRC_PREFIX}src/${QUALITY}/resources/server/favicon.ico"
  fi

  if [[ ! -f "${SRC_PREFIX}src/${QUALITY}/resources/server/code-192.png" ]]; then
    convert -size "192x192" "${SRC_PREFIX}src/${QUALITY}/resources/linux/code.png" "${SRC_PREFIX}src/${QUALITY}/resources/server/code-192.png"
  fi

  if [[ ! -f "${SRC_PREFIX}src/${QUALITY}/resources/server/code-512.png" ]]; then
    convert -size "512x512" "${SRC_PREFIX}src/${QUALITY}/resources/linux/code.png" "${SRC_PREFIX}src/${QUALITY}/resources/server/code-512.png"
  fi
} # }}}

build_windows_main() { # {{{
  if [[ ! -f "${SRC_PREFIX}src/${QUALITY}/resources/win32/code.ico" ]]; then
    wget "https://raw.githubusercontent.com/Codex/icons/main/icons/win32/nobg/${COLOR}/paulo22s.ico" -O "${SRC_PREFIX}src/${QUALITY}/resources/win32/code.ico"
  fi
} # }}}

build_windows_type() { # {{{
  local FILE_PATH IMG_SIZE IMG_BG_COLOR LOGO_SIZE GRAVITY

  FILE_PATH="$1"
  IMG_SIZE="$2"
  IMG_BG_COLOR="$3"
  LOGO_SIZE="$4"
  GRAVITY="$5"

  if [[ ! -f "${FILE_PATH}" ]]; then
    if [[ "${FILE_PATH##*.}" == "png" ]]; then
      convert -size "${IMG_SIZE}" "${IMG_BG_COLOR}" PNG32:"${FILE_PATH}"
    else
      convert -size "${IMG_SIZE}" "${IMG_BG_COLOR}" "${FILE_PATH}"
    fi

    rsvg-convert -w "${LOGO_SIZE}" -h "${LOGO_SIZE}" "icons/${QUALITY}/codex_cnl.svg" -o "code_logo.png"

    composite -gravity "${GRAVITY}" "code_logo.png" "${FILE_PATH}" "${FILE_PATH}"
  fi
} # }}}

build_windows_types() { # {{{
  mkdir -p "${SRC_PREFIX}src/${QUALITY}/resources/win32"

  rsvg-convert -b "#F5F6F7" -w 64 -h 64 "icons/${QUALITY}/codex_cnl.svg" -o "code_logo.png"

  for file in "${VSCODE_PREFIX}"vscode/resources/win32/*.ico; do
    if [[ -f "${file}" ]]; then
      name=$(basename "${file}" '.ico')

      if [[ "${name}" != 'code' ]] && [[ ! -f "${SRC_PREFIX}src/${QUALITY}/resources/win32/${name}.ico" ]]; then
        icotool -x -w 256 "${file}"

        composite -geometry +150+185 "code_logo.png" "${name}_1_256x256x32.png" "${name}.png"

        convert "${name}.png" -define icon:auto-resize=256,128,96,64,48,32,24,20,16 "${SRC_PREFIX}src/${QUALITY}/resources/win32/${name}.ico"

        rm "${name}_1_256x256x32.png" "${name}.png"
      fi
    fi
  done

  build_windows_type "${SRC_PREFIX}src/${QUALITY}/resources/win32/code_70x70.png" "70x70" "canvas:transparent" "45" "center"
  build_windows_type "${SRC_PREFIX}src/${QUALITY}/resources/win32/code_150x150.png" "150x150" "canvas:transparent" "64" "+44+25"
  build_windows_type "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-big-100.bmp" "164x314" "xc:white" "126" "center"
  build_windows_type "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-big-125.bmp" "192x386" "xc:white" "147" "center"
  build_windows_type "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-big-150.bmp" "246x459" "xc:white" "190" "center"
  build_windows_type "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-big-175.bmp" "273x556" "xc:white" "211" "center"
  build_windows_type "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-big-200.bmp" "328x604" "xc:white" "255" "center"
  build_windows_type "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-big-225.bmp" "355x700" "xc:white" "273" "center"
  build_windows_type "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-big-250.bmp" "410x797" "xc:white" "317" "center"
  build_windows_type "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-small-100.bmp" "55x55" "xc:white" "44" "center"
  build_windows_type "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-small-125.bmp" "64x68" "xc:white" "52" "center"
  build_windows_type "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-small-150.bmp" "83x80" "xc:white" "63" "center"
  build_windows_type "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-small-175.bmp" "92x97" "xc:white" "76" "center"
  build_windows_type "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-small-200.bmp" "110x106" "xc:white" "86" "center"
  build_windows_type "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-small-225.bmp" "119x123" "xc:white" "103" "center"
  build_windows_type "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-small-250.bmp" "138x140" "xc:white" "116" "center"
  build_windows_type "${SRC_PREFIX}build/windows/msi/resources/${QUALITY}/wix-banner.bmp" "493x58" "xc:white" "50" "+438+6"
  build_windows_type "${SRC_PREFIX}build/windows/msi/resources/${QUALITY}/wix-dialog.bmp" "493x312" "xc:white" "120" "+22+152"

  rm code_logo.png
} # }}}

if [[ "${0}" == "${BASH_SOURCE[0]}" ]]; then
  build_darwin_main
  build_linux_main
  build_windows_main

  build_darwin_types
  build_windows_types

  build_media
  build_server
  build_letterpress
fi
