#!/usr/bin/env bash
# 用法: check_progress.sh <计划.md> [仓库根,默认 .]
# 检查计划顶部「实施进度」的内部一致性 —— 实施期每回写一次跑一次,写计划时也跑一次(应报 0/N)。
# 只检查摘要、状态、ID 与引用文件存在性,不读取独立记录正文,也不证明验收已通过。
# 兼容旧版内联证据表并提示迁移;「压根没回写」仍需结合陈旧提示与实际工作判断。
set -euo pipefail
plan="${1:?用法: check_progress.sh <计划.md> [仓库根]}"; root="${2:-.}"
[ -f "$plan" ] || { echo "ERROR: 计划文件不存在: $plan" >&2; exit 1; }

errs=0; warns=0
err()  { echo "ERROR: $*"; errs=$((errs + 1)); }
warn() { echo "WARN:  $*"; warns=$((warns + 1)); }
trim() { printf '%s' "$1" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'; }
plain() { trim "$(printf '%s' "$1" | tr -d '*`')"; }
field() { trim "$(grep -m1 "^- $1[：:]" <<<"$snap" | sed "s/^- $1[：:]//" || true)"; }
required() {
  local value
  value="$(plain "$2")"
  case "$value" in ""|—|-|待补|TBD|N/A) err "$1 为空或待补" ;; esac
  # 摘要可合法提到 <select> 等标签;只对基线检查被反引号包裹的占位。
  if [[ "$1" = *代码基线 ]] && [[ "$value" =~ \<[^\<\>]+\> ]]; then
    err "$1 残留模板占位"
  fi
  return 0
}

# 取出一节:从标题行的下一行起,到下一个同级或更高级标题为止。
section() {
  awk -v re="$1" '
    /^#+[ \t]/ {
      lvl = length($1)
      if (inseg && lvl <= start) exit
      if (!inseg && $0 ~ re) { inseg = 1; start = lvl; next }
    }
    inseg { print }
  ' "$2"
}
# 表中以 M<数字> 开头的行(「评审整改」这类非里程碑行不计入)
mrows() { grep -E '^\|[[:space:]]*\**M[0-9]+\**[[:space:]]*\|' <<<"$1" || true; }
ids() { mrows "$1" | cut -d '|' -f2 | tr -d '*`[:space:]' | sed 's/M/\nM/g' | sed '/^$/d'; }

prog="$(section '^#+[ \t].*实施进度' "$plan")"
snap="$(section '^#+[ \t].*恢复快照' "$plan")"
recs="$(section '^#+[ \t].*完成记录' "$plan")"
mile="$(section '^#+[ \t].*里程碑' "$plan")"

[ -n "$prog" ] || err "找不到「实施进度」节 —— 跨对话恢复的唯一入口缺失"
[ -n "$snap" ] || err "找不到「恢复快照」"
[ -n "$recs" ] || err "找不到「完成记录」"
[ -n "$mile" ] || err "找不到里程碑表"

# ① 快照七个字段齐全
for f in 最近更新 当前进度 当前状态 最近完成 下一步 当前阻塞 代码基线; do
  required "恢复快照:$f" "$(field "$f")"
done

# ② 快照里的模板占位没填(骨架的 <...> 应当被真实内容替换)。
#    只查快照:完成记录的证据正文里出现 <img> / <select> 这类尖括号是正常的。先剥掉行内代码。
while IFS= read -r l; do
  [ -n "$l" ] && err "恢复快照残留模板占位:$(trim "$l")"
done < <(sed 's/`[^`]*`//g' <<<"$snap" | grep -E '<[^<>]+>' || true)
# 协议里唯一的填空:实施者不加载写计划的 skill,留着占位就等于没有校验命令。
if grep -qF '<进度校验命令>' <<<"$prog"; then
  err "「回写后自查」的 <进度校验命令> 未替换为可运行命令或人工核对说明"
fi

# ③ 识别新摘要索引与旧内联证据表,核对 ID 和记录字段。
mcount="$(mrows "$mile" | grep -c . || true)"
rcount="$(mrows "$recs" | grep -c . || true)"
legacy=0
if grep -qE '^\|[[:space:]]*Milestone[[:space:]]*\|[[:space:]]*状态[[:space:]]*\|' <<<"$recs"; then :
elif grep -qE '^\|[[:space:]]*Milestone[[:space:]]*\|[[:space:]]*完成时间[[:space:]]*\|' <<<"$recs"; then
  legacy=1
  warn "旧版内联证据表:本次续做时将详情迁入独立记录,计划保留状态、摘要与链接"
else
  err "完成记录表头不受支持,请使用 Milestone / 状态 / 更新时间 / 简要记录 / 实现与验收记录"
fi
mids="$(ids "$mile")"
for id in $(printf '%s\n' "$mids" | sort | uniq -d); do err "里程碑表 ID 重复:$id"; done
seen=""; completed=0; latest_completed=""
plan_dir="$(cd "$(dirname "$plan")" && pwd)"
link_re='^\[[^]]+\]\(([^)]+)\)$'
while IFS= read -r row; do
  [ -n "$row" ] || continue
  IFS='|' read -r _ c_m c_2 c_3 c_4 c_5 _rest <<<"$row"
  m="$(plain "$c_m")"
  grep -qxF "$m" <<<"$mids" || err "完成记录出现未知里程碑:$m"
  if grep -qxF "$m" <<<"$seen"; then err "完成记录里程碑重复:$m"; fi
  seen="${seen}"$'\n'"$m"
  if [ "$legacy" -eq 1 ]; then
    state="已完成"
    required "$m 完成时间" "$c_2"
    required "$m 完成摘要" "$c_3"
    required "$m 验证证据" "$c_4"
    required "$m 代码基线" "$c_5"
  else
    state="$(plain "$c_2")"
    case "$state" in 进行中|阻塞|已完成) ;; *) err "$m 状态无效:$state" ;; esac
    required "$m 更新时间" "$c_3"
    required "$m 简要记录" "$c_4"
    link="$(trim "$c_5")"
    if [[ "$link" =~ $link_re ]]; then
      target="${BASH_REMATCH[1]}"
      target="${target#<}"; target="${target%>}"; target="${target%%#*}"
      case "$target" in
        ""|/*|*://*) err "$m 记录须为相对计划文件的本地链接:$target" ;;
        *) [ -f "$plan_dir/$target" ] || err "$m 记录文件不存在:$target"
           [ ! "$plan_dir/$target" -ef "$plan" ] || err "$m 记录必须独立于计划文件" ;;
      esac
    else
      err "$m 缺少实现与验收记录的 Markdown 链接"
    fi
  fi
  if [ "$state" = "已完成" ]; then
    completed=$((completed + 1)); latest_completed="$m"
  fi
done < <(mrows "$recs")
if [ "$rcount" -gt 0 ] && grep -qE '尚未(完成|开始)任何里程碑' <<<"$recs"; then
  err "完成记录已有实施事实,却仍保留初始占位行"
fi

# ④ n/N 只统计已完成状态,进行中/阻塞不计入。
cur="$(field 当前进度)"
done_n=""; total_n=""
if [[ "$cur" =~ ([0-9]+)[[:space:]]*/[[:space:]]*([0-9]+) ]]; then
  done_n="${BASH_REMATCH[1]}"; total_n="${BASH_REMATCH[2]}"
else
  err "「当前进度」不是 n/N 形状,新对话读不出进度:$(trim "$cur")"
fi
if [ -n "$total_n" ]; then
  [ "$mcount" -gt 0 ] || err "里程碑表里没有 M<数字> 行,无法核对 N"
  [ "$mcount" -eq 0 ] || [ "$total_n" -eq "$mcount" ] \
    || err "「当前进度」的 N=$total_n,里程碑表却有 $mcount 行 —— 计划改过里程碑但没同步快照"
  [ "$done_n" -eq "$completed" ] \
    || err "「当前进度」说完成 $done_n 个,完成记录实际完成 $completed 个(共 $rcount 行)"
fi

# ⑤ 最近完成取记录中最后一条已完成行,允许 M3 先于 M2 完成。
lastdone="$(plain "$(field 最近完成)")"
if [ "$completed" -eq 0 ]; then
  [ "$lastdone" = "无" ] || err "0 个里程碑完成,但「最近完成」写着:$lastdone"
else
  latest_re="^${latest_completed}([^0-9]|$)"
  [[ "$lastdone" =~ $latest_re ]] || err "最近完成应为 $latest_completed,实际为:$lastdone"
fi

# ⑥ 陈旧提示:代码改了、计划没动
if command -v git >/dev/null 2>&1 && git -C "$root" rev-parse --git-dir >/dev/null 2>&1; then
  planrel="$(git -C "$root" ls-files --full-name --error-unmatch "$plan" 2>/dev/null || true)"
  dirty="$(git -C "$root" status --porcelain 2>/dev/null | cut -c4- | sed 's/.* -> //' || true)"
  if [ -n "$dirty" ]; then
    n="$(grep -c . <<<"$dirty" || true)"
    if [ -n "$planrel" ] && grep -qxF "$planrel" <<<"$dirty"; then :
    elif [ -n "$done_n" ] && [ -n "$total_n" ] && [ "$done_n" -lt "$total_n" ]; then
      warn "还剩 $((total_n - done_n)) 个里程碑未完成,工作树有 $n 个未提交改动,而本计划文件没被改过 —— 若其中已完成某个里程碑,先回写「实施进度」再继续"
    fi
  fi
fi

echo "---"
echo "进度:${done_n:-?}/${total_n:-?} · 里程碑表 $mcount 行 · 记录 $rcount 行(已完成 $completed) · ERROR $errs · WARN $warns"
[ "$errs" -eq 0 ] || exit 1
