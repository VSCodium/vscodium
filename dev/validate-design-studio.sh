#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'
PASS_COUNT=0
FAIL_COUNT=0
check_file() {
  if [ -f "$1" ]; then
    echo -e "  [${GREEN}PASS${NC}] $1 exists"
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    echo -e "  [${RED}FAIL${NC}] $1 missing"
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
}
check_dir() {
  if [ -d "$1" ]; then
    echo -e "  [${GREEN}PASS${NC}] $1 directory exists"
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    echo -e "  [${RED}FAIL${NC}] $1 directory missing"
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
}
check_grep() {
  if [ ! -f "$2" ]; then
    echo -e "  [${RED}FAIL${NC}] $3 (file $2 missing)"
    FAIL_COUNT=$((FAIL_COUNT + 1))
    return
  fi
  if grep -q "$1" "$2"; then
    echo -e "  [${GREEN}PASS${NC}] $3"
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    echo -e "  [${RED}FAIL${NC}] $3 (pattern '$1' not found in $2)"
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
}
echo -e "${BLUE}Validating Integration...${NC}"
check_dir "extensions/cursor-ing-design-studio"
check_file "extensions/cursor-ing-design-studio/package.json"
check_file "extensions/cursor-ing-design-studio/tsconfig.json"
check_file "extensions/cursor-ing-design-studio/src/extension.ts"
check_file "extensions/cursor-ing-design-studio/src/sidecar-adapter.ts"
check_dir "extensions/cursor-ing-artifacts"
check_file "extensions/cursor-ing-artifacts/package.json"
check_file "extensions/cursor-ing-artifacts/tsconfig.json"
check_file "extensions/cursor-ing-artifacts/src/extension.ts"
check_dir ".cursor-ing/design-projects"
check_file ".cursor-ing/design-projects/README.md"
check_dir "cursor-ing/sidecars/open-design"
check_file "cursor-ing/sidecars/open-design/README.md"
check_dir ".agents/skills/design"
check_file ".agents/skills/design/landing-page.json"
check_file ".agents/skills/design/dashboard.json"
check_dir ".agents/vendor/open-design"
check_file ".agents/vendor/open-design/README.md"
check_grep "cursorIng.openDesignStudio" "extensions/cursor-ing-design-studio/package.json" "command ID: openDesignStudio"
check_grep "cursorIng.newDesignProject" "extensions/cursor-ing-design-studio/package.json" "command ID: newDesignProject"
check_grep "cursorIng.previewArtifact" "extensions/cursor-ing-design-studio/package.json" "command ID: previewArtifact"
check_grep "cursorIng.openArtifactPreview" "extensions/cursor-ing-artifacts/package.json" "command ID: openArtifactPreview"
check_grep "Design Studio" "AGENTS.md" "AGENTS.md updated"
check_grep "Design Studio" "CURSOR-ING.md" "CURSOR-ING.md updated"
echo -e "\nSummary: ${GREEN}$PASS_COUNT passed${NC}, ${RED}$FAIL_COUNT failed${NC}"
if [ $FAIL_COUNT -eq 0 ]; then
  echo -e "${GREEN}Validation successful!${NC}"
  RET=0
else
  echo -e "${RED}Validation FAILED!${NC}"
  RET=1
fi
exit $RET
