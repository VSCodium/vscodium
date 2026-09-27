#!/usr/bin/env bash
set -euo pipefail

# Update mise documentation
# This script fetches the latest docs from mise.jdx.dev and converts them to markdown

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REFS_DIR="${SCRIPT_DIR}/references"
TEMP_OUTPUT="${SCRIPT_DIR}/.temp-output"

echo "=== Updating mise Documentation ==="

# Clean up previous temp output
rm -rf "${TEMP_OUTPUT}"

# Fetch docs from mise.jdx.dev
# Focus on: dev-tools (tool management), configuration, and CLI reference
echo "Fetching docs from mise.jdx.dev..."

# Dev tools section (primary focus - tool management)
echo "Fetching dev-tools section..."
npx @mdream/crawl \
  "https://mise.jdx.dev/dev-tools/**" \
  --skip-sitemap \
  --output "${TEMP_OUTPUT}" \
  --artifacts "markdown"

# Configuration section
echo "Fetching configuration section..."
npx @mdream/crawl \
  "https://mise.jdx.dev/configuration/**" \
  --skip-sitemap \
  --output "${TEMP_OUTPUT}" \
  --artifacts "markdown"

# Getting started and core guides
echo "Fetching core guides..."
npx @mdream/crawl \
  "https://mise.jdx.dev/getting-started" \
  "https://mise.jdx.dev/installing-mise" \
  "https://mise.jdx.dev/ide-integration" \
  --skip-sitemap \
  --output "${TEMP_OUTPUT}" \
  --artifacts "markdown"

# CLI reference (selective - most useful commands)
echo "Fetching CLI reference..."
npx @mdream/crawl \
  "https://mise.jdx.dev/cli/use" \
  "https://mise.jdx.dev/cli/install" \
  "https://mise.jdx.dev/cli/ls" \
  "https://mise.jdx.dev/cli/doctor" \
  "https://mise.jdx.dev/cli/which" \
  "https://mise.jdx.dev/cli/where" \
  "https://mise.jdx.dev/cli/exec" \
  "https://mise.jdx.dev/cli/activate" \
  "https://mise.jdx.dev/cli/trust" \
  "https://mise.jdx.dev/cli/outdated" \
  "https://mise.jdx.dev/cli/upgrade" \
  --skip-sitemap \
  --output "${TEMP_OUTPUT}" \
  --artifacts "markdown"

# Copy relevant docs to references directory
echo "Copying documentation to references/..."
mkdir -p "${REFS_DIR}/dev-tools"
mkdir -p "${REFS_DIR}/configuration"
mkdir -p "${REFS_DIR}/cli"
mkdir -p "${REFS_DIR}/guides"

# Copy dev-tools docs
if [ -d "${TEMP_OUTPUT}/dev-tools" ]; then
  cp -v "${TEMP_OUTPUT}/dev-tools"/*.md "${REFS_DIR}/dev-tools/" 2>/dev/null || true

  # Copy backends subdirectory if it exists
  if [ -d "${TEMP_OUTPUT}/dev-tools/backends" ]; then
    mkdir -p "${REFS_DIR}/dev-tools/backends"
    cp -v "${TEMP_OUTPUT}/dev-tools/backends"/*.md "${REFS_DIR}/dev-tools/backends/" 2>/dev/null || true
  fi
fi

# Copy configuration docs
if [ -d "${TEMP_OUTPUT}/configuration" ]; then
  cp -v "${TEMP_OUTPUT}/configuration"/*.md "${REFS_DIR}/configuration/" 2>/dev/null || true
fi

# Copy CLI docs
if [ -d "${TEMP_OUTPUT}/cli" ]; then
  cp -v "${TEMP_OUTPUT}/cli"/*.md "${REFS_DIR}/cli/" 2>/dev/null || true
fi

# Copy guide docs (top-level pages)
for guide in getting-started installing-mise ide-integration; do
  if [ -f "${TEMP_OUTPUT}/${guide}.md" ]; then
    cp -v "${TEMP_OUTPUT}/${guide}.md" "${REFS_DIR}/guides/"
  fi
done

# Clean up temp output
rm -rf "${TEMP_OUTPUT}"

echo "=== Update complete ==="
echo "Documentation updated in: ${REFS_DIR}"
echo ""
echo "Key directories:"
for dir in "${REFS_DIR}"/*/; do
  if [ -d "$dir" ]; then
    count=$(find "$dir" -name "*.md" 2>/dev/null | wc -l)
    echo "  $(basename "$dir")/: $count files"
  fi
done
