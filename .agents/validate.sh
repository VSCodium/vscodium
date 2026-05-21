#!/usr/bin/env bash
# Cursor ING Phase 1 Validation Script
# Checks that all required scaffold files exist and are well-formed.

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0
WARN=0

check_file() {
  if [[ -f "$1" ]]; then
    echo -e "${GREEN}[PASS]${NC} $1 exists"
    PASS=$((PASS + 1))
  else
    echo -e "${RED}[FAIL]${NC} $1 missing"
    FAIL=$((FAIL + 1))
  fi
}

check_dir() {
  if [[ -d "$1" ]]; then
    echo -e "${GREEN}[PASS]${NC} $1/ exists"
    PASS=$((PASS + 1))
  else
    echo -e "${RED}[FAIL]${NC} $1/ missing"
    FAIL=$((FAIL + 1))
  fi
}

check_json() {
  if [[ -f "$1" ]]; then
    if jq empty "$1" 2>/dev/null; then
      echo -e "${GREEN}[PASS]${NC} $1 is valid JSON"
      PASS=$((PASS + 1))
    else
      echo -e "${RED}[FAIL]${NC} $1 is invalid JSON"
      FAIL=$((FAIL + 1))
    fi
  else
    echo -e "${RED}[FAIL]${NC} $1 missing"
    FAIL=$((FAIL + 1))
  fi
}

check_no_plans_in_brain() {
  local found
  found=$(find .agents/brain -name "*.plan.json" 2>/dev/null)
  if [[ -n "$found" ]]; then
    echo -e "${RED}[FAIL]${NC} Plans found in .agents/brain/ -- plans must only be in .cursor-ing/plans/"
    FAIL=$((FAIL + 1))
  else
    echo -e "${GREEN}[PASS]${NC} No plan files in .agents/brain/ (correct: plans in .cursor-ing/plans/)"
    PASS=$((PASS + 1))
  fi
}

echo "============================================"
echo "  Cursor ING Phase 1 Validation"
echo "============================================"
echo ""

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

echo "Repo root: $REPO_ROOT"
echo ""

echo "--- Core Files ---"
check_file "AGENTS.md"
check_file "CURSOR-ING.md"
check_file "LICENSE"

echo ""
echo "--- .cursor-ing/ Workspace State ---"
check_dir ".cursor-ing"
check_file ".cursor-ing/README.md"
check_dir ".cursor-ing/plans"
check_json ".cursor-ing/plans/auth-module.plan.json"

echo ""
echo "--- .agents/ Harness ---"
check_dir ".agents"
check_json ".agents/registry.json"
check_dir ".agents/model-adapters"
check_file ".agents/model-adapters/claude.md"
check_file ".agents/model-adapters/codex.md"
check_file ".agents/model-adapters/kimi.md"
check_file ".agents/model-adapters/qwen-code.md"
check_file ".agents/model-adapters/gemini-code.md"
check_dir ".agents/vendor"
check_file ".agents/vendor/README.md"
check_dir ".agents/skills"
check_file ".agents/skills/code-review.md"
check_file ".agents/skills/plan-and-execute.md"
check_file ".agents/skills/diff-apply.md"
check_dir ".agents/agents"
check_file ".agents/agents/planner.md"
check_file ".agents/agents/coder.md"
check_file ".agents/agents/reviewer.md"
check_file ".agents/agents/security.md"
check_file ".agents/agents/browser.md"
check_dir ".agents/brain"
check_file ".agents/brain/memory.md"
check_file ".agents/brain/glossary.md"
check_file ".agents/brain/assumptions.md"
check_dir ".agents/brain/adr"
check_file ".agents/brain/adr/001-extension-first.md"
check_file ".agents/brain/adr/002-plan-storage-location.md"
check_dir ".agents/brain/maps"
check_file ".agents/brain/maps/architecture.md"
check_dir ".agents/brain/runbooks"
check_file ".agents/brain/runbooks/phase1-setup.md"

echo ""
echo "--- Plan Storage Rule ---"
check_no_plans_in_brain

echo ""
echo "--- Extension Skeleton ---"
check_dir "extensions/cursor-ing-ai"
check_json "extensions/cursor-ing-ai/package.json"
check_json "extensions/cursor-ing-ai/tsconfig.json"
check_file "extensions/cursor-ing-ai/src/extension.ts"
check_dir "extensions/cursor-ing-ai/src/providers"
check_file "extensions/cursor-ing-ai/src/providers/types.ts"
check_file "extensions/cursor-ing-ai/src/providers/registry.ts"
check_file "extensions/cursor-ing-ai/src/providers/mock-provider.ts"
check_dir "extensions/cursor-ing-ai/src/agents"
check_file "extensions/cursor-ing-ai/src/agents/types.ts"
check_file "extensions/cursor-ing-ai/src/agents/roster.ts"
check_dir "extensions/cursor-ing-ai/src/plans"
check_file "extensions/cursor-ing-ai/src/plans/types.ts"
check_file "extensions/cursor-ing-ai/src/plans/plan-viewer.ts"
check_dir "extensions/cursor-ing-ai/src/activity"
check_file "extensions/cursor-ing-ai/src/activity/activity-log.ts"
check_dir "extensions/cursor-ing-ai/src/diff"
check_file "extensions/cursor-ing-ai/src/diff/diff-preview.ts"
check_dir "extensions/cursor-ing-ai/src/composer"
check_file "extensions/cursor-ing-ai/src/composer/composer-panel.ts"

echo ""
echo "============================================"
echo "  Results: ${GREEN}${PASS} passed${NC}, ${RED}${FAIL} failed${NC}, ${YELLOW}${WARN} warnings${NC}"
echo "============================================"

if [[ $FAIL -gt 0 ]]; then
  echo -e "${RED}Phase 1 validation FAILED${NC}"
  exit 1
else
  echo -e "${GREEN}Phase 1 validation PASSED${NC}"
  exit 0
fi
