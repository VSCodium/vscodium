#!/bin/bash
# Cursor ING - Design Studio Validation Script
# Verifies the presence and structure of Design Studio components.

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Validating Cursor ING Design Studio Integration...${NC}"

check_file() {
  if [ -f "$1" ]; then
    echo -e "  [${GREEN}OK${NC}] $1 exists"
  else
    echo -e "  [${RED}FAIL${NC}] $1 missing"
  fi
}

check_dir() {
  if [ -d "$1" ]; then
    echo -e "  [${GREEN}OK${NC}] $1 directory exists"
  else
    echo -e "  [${RED}FAIL${NC}] $1 directory missing"
  fi
}

echo "Checking extensions..."
check_dir "extensions/cursor-ing-design-studio"
check_file "extensions/cursor-ing-design-studio/package.json"
check_file "extensions/cursor-ing-design-studio/src/extension.ts"
check_file "extensions/cursor-ing-design-studio/src/sidecar-adapter.ts"

check_dir "extensions/cursor-ing-artifacts"
check_file "extensions/cursor-ing-artifacts/package.json"
check_file "extensions/cursor-ing-artifacts/src/extension.ts"

echo "Checking workspace directories..."
check_dir ".cursor-ing/design-projects"
check_dir "cursor-ing/sidecars/open-design"

echo "Checking agent skills and vendor..."
check_dir ".agents/skills/design"
check_file ".agents/skills/design/landing-page.json"
check_dir ".agents/vendor/open-design"

echo "Checking documentation..."
grep -q "Design Studio" AGENTS.md && echo -e "  [${GREEN}OK${NC}] AGENTS.md updated" || echo -e "  [${RED}FAIL${NC}] AGENTS.md missing Design Studio"
grep -q "Design Studio" CURSOR-ING.md && echo -e "  [${GREEN}OK${NC}] CURSOR-ING.md updated" || echo -e "  [${RED}FAIL${NC}] CURSOR-ING.md missing Design Studio"

echo -e "${GREEN}Design Studio Phase 1 validation complete!${NC}"
