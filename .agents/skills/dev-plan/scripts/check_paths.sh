#!/usr/bin/env bash
# 用法: check_paths.sh <计划.md> [仓库根,默认 .]
# 从计划文档提取反引号内的仓库路径样式 token,检查真实存在性,打印 MISSING 列表。
# 注意:报告仅供人工复核——★新增文件、占位符、示例路径本来就不存在(正常);
#       "复用/已核实"类路径出现在 MISSING 里才是问题(虚构引用)。
set -euo pipefail
plan="$1"; root="${2:-.}"
missing=0; checked=0
exts='ts|tsx|js|jsx|mjs|cjs|json|md|css|scss|html|sh|sql|ya?ml|toml|py|txt|svg|png|conf|env'
while IFS= read -r p; do
  first="${p%%/*}"; last="${p##*/}"
  # 只检查两类 token:① 首段是仓库根下真实目录(仓库根相对路径);② 末段带常见文件扩展名。
  # 其余(如 tools/list、files.read/files.write 这类方法名/scope 名)跳过。
  if [ ! -d "$root/$first" ] && ! [[ "$last" =~ \.($exts)$ ]]; then continue; fi
  checked=$((checked + 1))
  [ -e "$root/$p" ] && continue
  # 计划常写 workspace 相对路径(如 src/lib/gate.ts 或 routes/git.ts),尝试常见 monorepo 布局
  found=0
  for base in "$root"/apps/*/ "$root"/apps/*/src/ "$root"/packages/*/ "$root"/packages/*/src/; do
    [ -e "$base$p" ] && { found=1; break; }
  done
  if [ "$found" -eq 0 ]; then echo "MISSING: $p"; missing=$((missing + 1)); fi
done < <(
  grep -oE '`[^`]+`' "$plan" | tr -d '`' \
    | grep -E '^[A-Za-z0-9_.@-]+(/[A-Za-z0-9_.@-]+)+/?$' \
    | grep -vE '[<>*{}()]' \
    | grep -vE '^(https?:|node_modules/|@)' \
    | sort -u
)
echo "---"
echo "共检查 $checked 个路径样式 token,MISSING $missing 个。"
echo "(存在的不打印;MISSING 需逐条人工判断:新增(★)/占位路径可忽略,复用/已核实类路径缺失必须修)"
