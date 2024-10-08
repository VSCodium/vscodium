#!/usr/bin/env bash

set -e

if [[ -n "${PULL_REQUEST_ID}" ]]; then
  BRANCH_NAME=$( git rev-parse --abbrev-ref HEAD )

  git config --global user.email "$( echo "${GITHUB_USERNAME}" | awk '{print tolower($0)}' )-ci@not-real.com"
  git config --global user.name "${GITHUB_USERNAME} CI"
  git fetch --unshallow
  git fetch origin "pull/${PULL_REQUEST_ID}/head"
  git checkout FETCH_HEAD
  git merge --no-edit "origin/${BRANCH_NAME}"
fi
