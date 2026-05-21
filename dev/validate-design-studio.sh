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

echo "--- Documentation ---"
grep -q "cursorIng.openDesignStudio" extensions/cursor-ing-design-studio/package.json && echo -e "  [${GREEN}PASS${NC}] command ID consistent: openDesignStudio" || (echo -e "  [${RED}FAIL${NC}] command ID inconsistent: openDesignStudio"; FAIL_COUNT=$((FAIL_COUNT+1)))
grep -q "cursorIng.newDesignProject" extensions/cursor-ing-design-studio/package.json && echo -e "  [${GREEN}PASS${NC}] command ID consistent: newDesignProject" || (echo -e "  [${RED}FAIL${NC}] command ID inconsistent: newDesignProject"; FAIL_COUNT=$((FAIL_COUNT+1)))
grep -q "cursorIng.previewArtifact" extensions/cursor-ing-design-studio/package.json && echo -e "  [${GREEN}PASS${NC}] command ID consistent: previewArtifact" || (echo -e "  [${RED}FAIL${NC}] command ID inconsistent: previewArtifact"; FAIL_COUNT=$((FAIL_COUNT+1)))
grep -q "cursorIng.openArtifactPreview" extensions/cursor-ing-artifacts/package.json && echo -e "  [${GREEN}PASS${NC}] command ID consistent: openArtifactPreview" || (echo -e "  [${RED}FAIL${NC}] command ID inconsistent: openArtifactPreview"; FAIL_COUNT=$((FAIL_COUNT+1)))

grep -q "Design Studio" AGENTS.md && echo -e "  [${GREEN}PASS${NC}] AGENTS.md updated" || (echo -e "  [${RED}FAIL${NC}] AGENTS.md missing Design Studio"; FAIL_COUNT=$((FAIL_COUNT+1)))
grep -q "Design Studio" CURSOR-ING.md && echo -e "  [${GREEN}PASS${NC}] CURSOR-ING.md updated" || (echo -e "  [${RED}FAIL${NC}] CURSOR-ING.md missing Design Studio"; FAIL_COUNT=$((FAIL_COUNT+1)))

echo -e "\nSummary: ${GREEN}$PASS_COUNT passed${NC}, ${RED}$FAIL_COUNT failed${NC}"

if [ $FAIL_COUNT -eq 0 ]; then
  echo -e "${GREEN}Design Studio Phase 1 validation successful!${NC}"
  RET=0
else
  echo -e "${RED}Design Studio validation FAILED!${NC}"
  RET=1
fi
exit $RET
