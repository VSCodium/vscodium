#!/usr/bin/env bash
# 探测本机是否装有可用的 archify skill。
#   可用：stdout 打印 archify 目录，退出码 0
#   不可用：stderr 打印原因，退出码 1
# 用法：bash find-archify.sh [项目根目录]   （默认取当前 git 仓库根或当前目录）
set -u

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
skill_dir="$(dirname "$here")"
project_root="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"

candidates=(
  "$(dirname "$skill_dir")/archify"   # 和本 skill 装在同一个 skills 目录下
  "$project_root/.claude/skills/archify"
  "$project_root/.agents/skills/archify"
  "$project_root/.codex/skills/archify"
  "$project_root/.cursor/skills/archify"
  "$HOME/.claude/skills/archify"
  "$HOME/.agents/skills/archify"
  "${CODEX_HOME:-$HOME/.codex}/skills/archify"
  "$HOME/.cursor/skills/archify"
)

# Claude Code 插件缓存里的 archify
if [ -d "$HOME/.claude/plugins" ]; then
  while IFS= read -r f; do
    candidates+=("$(dirname "$f")")
  done < <(find "$HOME/.claude/plugins" -maxdepth 7 -type f -path '*/archify/SKILL.md' 2>/dev/null)
fi

found=""
for d in "${candidates[@]}"; do
  if [ -f "$d/SKILL.md" ] && [ -f "$d/bin/archify.mjs" ]; then
    found="$(cd "$d" && pwd -P)"
    break
  fi
done

if [ -z "$found" ]; then
  echo "archify: 未找到已安装的 archify skill" >&2
  exit 1
fi

if ! command -v node >/dev/null 2>&1; then
  echo "archify: 找到 $found，但本机没有 node，无法运行" >&2
  exit 1
fi

node_major="$(node -p 'process.versions.node.split(".")[0]' 2>/dev/null || echo 0)"
if [ "$node_major" -lt 18 ]; then
  echo "archify: 找到 $found，但 node 版本 $(node --version) 低于要求的 18" >&2
  exit 1
fi

echo "$found"
