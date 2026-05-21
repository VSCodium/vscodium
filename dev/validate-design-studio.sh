#!/bin/bash
# Cursor ING - Design Studio Exhaustive Validation Script
# Verifies the presence and structure of Design Studio components.

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

PASS_COUNT=0
FAIL_COUNT=0

echo -e "${BLUE}Validating Cursor ING Design Studio Integration...${NC}"

check_file() {
  if [ -f "$1" ]; then
    echo -e "  [${GREEN}PASS${NC}] $1 exists"
    PASS_COUNT=$((PASS_COUNT+1))
  else
    echo -e "  [${RED}FAIL${NC}] $1 missing"
    FAIL_COUNT=$((FAIL_COUNT+1))
  fi
}

check_dir() {
  if [ -d "$1" ]; then
    echo -e "  [${GREEN}PASS${NC}] $1 directory exists"
    PASS_COUNT=$((PASS_COUNT+1))
  else
    echo -e "  [${RED}FAIL${NC}] $1 directory missing"
    FAIL_COUNT=$((FAIL_COUNT+1))
  fi
}

check_grep() {
  local pattern=$1
  local file=$2
  local desc=$3
  if [ ! -f "$file" ]; then
    echo -e "  [${RED}FAIL${NC}] $desc (file $file missing)"
    FAIL_COUNT=$((FAIL_COUNT+1))
    return
  fi
  if grep -q "$pattern" "$file"; then
    echo -e "  [${GREEN}PASS${NC}] $desc"
    PASS_COUNT=$((PASS_COUNT+1))
  else
    echo -e "  [${RED}FAIL${NC}] $desc (pattern not found in $file)"
    FAIL_COUNT=$((FAIL_COUNT+1))
  fi
}

echo "--- Extensions ---"
check_dir "extensions/cursor-ing-design-studio"
check_file "extensions/cursor-ing-design-studio/package.json"
check_file "extensions/cursor-ing-design-studio/tsconfig.json"
check_file "extensions/cursor-ing-design-studio/src/extension.ts"
check_file "extensions/cursor-ing-design-studio/src/sidecar-adapter.ts"

check_dir "extensions/cursor-ing-artifacts"
check_file "extensions/cursor-ing-artifacts/package.json"
check_file "extensions/cursor-ing-artifacts/tsconfig.json"
check_file "extensions/cursor-ing-artifacts/src/extension.ts"

echo "--- Workspace ---"
check_dir ".cursor-ing/design-projects"
check_file ".cursor-ing/design-projects/README.md"
check_dir "cursor-ing/sidecars/open-design"
check_file "cursor-ing/sidecars/open-design/README.md"

echo "--- Agent Harness ---"
check_dir ".agents/skills/design"
check_file ".agents/skills/design/landing-page.json"
check_file ".agents/skills/design/dashboard.json"
check_dir ".agents/vendor/open-design"
check_file ".agents/vendor/open-design/README.md"

echo "--- Documentation & IDs ---"
check_grep "cursorIng.openDesignStudio" "extensions/cursor-ing-design-studio/package.json" "command ID: openDesignStudio"
check_grep "cursorIng.newDesignProject" "extensions/cursor-ing-design-studio/package.json" "command ID: newDesignProject"
check_grep "cursorIng.previewArtifact" "extensions/cursor-ing-design-studio/package.json" "command ID: previewArtifact"
check_grep "cursorIng.openArtifactPreview" "extensions/cursor-ing-artifacts/package.json" "command ID: openArtifactPreview"

check_grep "Design Studio" "AGENTS.md" "AGENTS.md updated"
check_grep "Design Studio" "CURSOR-ING.md" "CURSOR-ING.md updated"

echo -e "\nSummary: ${GREEN}$PASS_COUNT passed${NC}, ${RED}$FAIL_COUNT failed${NC}"

if [ $FAIL_COUNT -eq 0 ]; then
  echo -e "${GREEN}Design Studio Phase 1 validation successful!${NC}"
  RET=0
else
  echo -e "${RED}Design Studio validation FAILED!${NC}"
  RET=1
fi
exit $RET
