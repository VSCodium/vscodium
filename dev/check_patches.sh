#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$( dirname -- "${SCRIPT_DIR}" )"
OUTPUT_DIR="${PATCH_CHECK_DIR:-${REPO_ROOT}/.patch-check}"
SCOPE="${1:-compile}"

mkdir -p "${OUTPUT_DIR}"

LOG_FILE="${OUTPUT_DIR}/${SCOPE}.log"
exec > >(tee "${LOG_FILE}") 2>&1

if [[ -z "${RELEASE_VERSION:-}" ]]; then
  export RELEASE_VERSION='0.0.0'
fi

shopt -s nullglob

TMP_DIR="$( mktemp -d "${TMPDIR:-/tmp}/vscodium-patch-check.XXXXXX" )"

cleanup() {
  rm -rf "${TMP_DIR}"
}

trap cleanup EXIT

# include common functions
. "${REPO_ROOT}/utils.sh"

apply_patch_group() {
  local file

  for file in "$@"; do
    if [[ -f "${file}" ]]; then
      apply_patch "${file}"
    fi
  done
}

prepare_compile_tree() {
  local source_dir="${REPO_ROOT}/vscode"
  local quality_dir="${REPO_ROOT}/src/${VSCODE_QUALITY}"

  if [[ ! -d "${source_dir}" ]]; then
    echo "${source_dir} not found"
    exit 1
  fi

  git clone --quiet --shared "${source_dir}" "${TMP_DIR}/vscode"

  if [[ -d "${quality_dir}" ]]; then
    cp -rp "${quality_dir}"/* "${TMP_DIR}/vscode/"
  fi

  cp -f "${REPO_ROOT}/LICENSE" "${TMP_DIR}/vscode/LICENSE.txt"
}

prepare_archive_tree() {
  local archive_path="${REPO_ROOT}/vscode.tar.gz"

  if [[ ! -f "${archive_path}" ]]; then
    echo "${archive_path} not found"
    exit 1
  fi

  tar -xzf "${archive_path}" -C "${TMP_DIR}"
}

apply_compile_patches() {
  local file

  cd "${TMP_DIR}/vscode" || exit 1

  if [[ "${DISABLE_UPDATE:-}" == "yes" ]] && [[ -f "${REPO_ROOT}/patches/00-update-disable.patch.yet" ]]; then
    apply_patch "${REPO_ROOT}/patches/00-update-disable.patch.yet"
  fi

  for file in "${REPO_ROOT}/patches/"*.json; do
    if [[ -f "${file}" ]]; then
      apply_actions "${file}"
    fi
  done

  apply_patch_group "${REPO_ROOT}/patches/"*.patch

  if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
    apply_patch_group "${REPO_ROOT}/patches/insider/"*.patch
  fi

  apply_patch_group "${REPO_ROOT}/patches/${OS_NAME}/"*.patch
  apply_patch_group "${REPO_ROOT}/patches/user/"*.patch
}

apply_linux_client_patches() {
  cd "${TMP_DIR}/vscode" || exit 1
  apply_patch_group "${REPO_ROOT}/patches/linux/client/"*.patch
}

apply_linux_reh_patches() {
  cd "${TMP_DIR}/vscode" || exit 1
  apply_patch_group "${REPO_ROOT}/patches/linux/reh/"*.patch
  apply_patch_group "${REPO_ROOT}/patches/linux/reh/${VSCODE_ARCH:-}/"*.patch
}

apply_alpine_reh_patches() {
  cd "${TMP_DIR}/vscode" || exit 1
  apply_patch_group "${REPO_ROOT}/patches/alpine/reh/"*.patch
}

case "${SCOPE}" in
  compile)
    if [[ -z "${OS_NAME:-}" ]]; then
      echo "OS_NAME is required for compile"
      exit 1
    fi

    if [[ -z "${VSCODE_QUALITY:-}" ]]; then
      echo "VSCODE_QUALITY is required for compile"
      exit 1
    fi

    prepare_compile_tree
    apply_compile_patches
    ;;
  linux-client)
    export OS_NAME="${OS_NAME:-linux}"
    prepare_archive_tree
    apply_linux_client_patches
    ;;
  linux-reh)
    export OS_NAME="${OS_NAME:-linux}"
    prepare_archive_tree
    apply_linux_reh_patches
    ;;
  alpine-reh)
    export OS_NAME="${OS_NAME:-alpine}"
    prepare_archive_tree
    apply_alpine_reh_patches
    ;;
  *)
    echo "Unknown scope: ${SCOPE}"
    exit 1
    ;;
esac

echo "Patch validation succeeded for scope: ${SCOPE}"
