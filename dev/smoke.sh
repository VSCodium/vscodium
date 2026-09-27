#!/usr/bin/env bash
# =============================================================================
# dev/smoke.sh —— vslight 验收冒烟脚本（规格 + 实现）
#
# 【驱动方式】
#   L1 静态层：直接断言 .app 包内文件存在/不存在（确定性最强）
#   L2 CLI 层：bin/vslight --version / --list-extensions / --install-extension（open-vsx）
#   L3 UI 层：macOS AppleScript/JXA —— open -na 启动、System Events 快捷键注入
#             （Cmd+Shift+P 命令面板、Cmd+` 终端、Cmd+S 保存）、AX 树读取断言
#
# 【退出码】0=全部通过；1=静态/CLI 硬断言失败；2=UI 层断言失败；3=用法/环境错误
#           （含未授予「辅助功能」权限、app 不存在等）
#
# 【超时】启动 90s；窗口就绪 60s；单步按键注入 15s；扩展安装 120s
#
# 【用法】
#   ./dev/smoke.sh [--app PATH] [--phase N] [--skip-ui] [--keep]
#     --app     .app 路径，默认 VSCode-darwin-arm64/VSLight.app，
#               不存在则回退 VSCodium.app（基线回归用）
#     --phase   启用到第 N 阶段为止的负向断言（默认 7=全部）：
#               >=2 品牌（vslight 二进制/无 tunnel 二进制/无 reh 产物/bundle id）
#               >=3 remote.* 前缀为 0 + 无 Remote Explorer 入口
#               >=4 debug.*/chat.*/notebook.* 前缀为 0 + 无 sessions/agentHost 产物
#     --skip-ui 只跑 L1+L2（无 GUI 环境/CI 用）
#     --keep    保留临时 profile/workspace（排查用）
#
# 【正向清单】打开窗口 → 编辑文件并保存（磁盘内容断言）→ 命令面板可用 →
#   终端可开（AX 检出 Terminal 面板）→ Git（vscode.git 内置 + Source Control 入口）→
#   open-vsx 装/卸扩展
# 【负向清单】无 tunnel 二进制；无 reh 产物；无 sessions.desktop.main/agentHostMain 产物；
#   workbench 产物中 "remote."/"debug."/"chat."/"notebook." 前缀计数为 0；
#   命令面板无 Remote Explorer / Debug: / Chat: 入口；无空白视图容器（AX 检出）
# 【保留面回归】终端 ✓ Git ✓ open-vsx ✓ 主题扩展安装 ✓ zh-CN 语言包（菜单出现「文件」）✓
# =============================================================================
set -u

APP_PATH=""
PHASE=7
SKIP_UI=0
KEEP=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --app) APP_PATH="$2"; shift 2 ;;
    --phase) PHASE="$2"; shift 2 ;;
    --skip-ui) SKIP_UI=1; shift ;;
    --keep) KEEP=1; shift ;;
    *) echo "unknown arg: $1" >&2; exit 3 ;;
  esac
done

cd "$(dirname "$0")/.."

if [[ -z "${APP_PATH}" ]]; then
  if [[ -d "VSCode-darwin-arm64/VSLight.app" ]]; then
    APP_PATH="VSCode-darwin-arm64/VSLight.app"
  elif [[ -d "VSCode-darwin-arm64/VSCodium.app" ]]; then
    APP_PATH="VSCode-darwin-arm64/VSCodium.app"
  else
    echo "ERROR: no .app found under VSCode-darwin-arm64/" >&2; exit 3
  fi
fi
[[ -d "${APP_PATH}" ]] || { echo "ERROR: app not found: ${APP_PATH}" >&2; exit 3; }

APP_NAME="$( basename "${APP_PATH}" .app )"
APP_RES="${APP_PATH}/Contents/Resources/app"
BIN="${APP_RES}/bin/vslight"
[[ -x "${BIN}" ]] || BIN="${APP_RES}/bin/codium"
OUT_DIR="${APP_RES}/out"

FAIL_HARD=0
FAIL_UI=0
declare -a RESULTS=()

note() { printf '  %s\n' "$*"; }
pass() { RESULTS+=( "PASS: $1" ); note "[PASS] $1"; }
fail() { RESULTS+=( "FAIL: $1" ); note "[FAIL] $1"; if [[ "${2:-hard}" == "ui" ]]; then FAIL_UI=1; else FAIL_HARD=1; fi; }
skip() { RESULTS+=( "SKIP: $1" ); note "[SKIP] $1"; }

check() { # check <desc> <expected> <actual>
  if [[ "$2" == "$3" ]]; then pass "$1"; else fail "$1 (expected=$2 actual=$3)"; fi
}

# ---- timeout wrapper: run_to <seconds> <cmd...> ; returns 124 on timeout
run_to() {
  local secs="$1"; shift
  "$@" & local pid=$!
  local waited=0
  while kill -0 "${pid}" 2>/dev/null; do
    sleep 1; waited=$(( waited + 1 ))
    if (( waited >= secs )); then kill -9 "${pid}" 2>/dev/null; wait "${pid}" 2>/dev/null; return 124; fi
  done
  wait "${pid}"
}

# =============================================================================
echo "== L1 静态包断言 (${APP_PATH}) =="

[[ -x "${BIN}" ]] && pass "bin 存在 ($( basename "${BIN}" ))" || fail "bin 不存在"

if (( PHASE >= 2 )); then
  if ls "${APP_RES}/bin/" | grep -q -- '-tunnel'; then fail "tunnel 二进制仍存在" ; else pass "无 tunnel 二进制"; fi
  if [[ "${APP_NAME}" == "VSLight" ]]; then
    BID="$( /usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier' "${APP_PATH}/Contents/Info.plist" 2>/dev/null )"
    check "bundle id == com.vslight" "com.vslight" "${BID}"
    BNAME="$( /usr/libexec/PlistBuddy -c 'Print CFBundleName' "${APP_PATH}/Contents/Info.plist" 2>/dev/null )"
    check "bundle name == VSLight" "VSLight" "${BNAME}"
  else
    skip "基线包（非 VSLight.app），品牌断言跳过"
  fi
  if ls -d vscode-reh-* 1>/dev/null 2>&1; then fail "仓库根仍有 vscode-reh-* 产物"; else pass "无 reh 产物"; fi
fi

if (( PHASE >= 4 )); then
  if find "${OUT_DIR}" -name 'sessions.desktop.main.js' | grep -q .; then fail "sessions.desktop.main.js 仍在产物"; else pass "产物无 sessions.desktop.main.js"; fi
  if find "${OUT_DIR}" -name 'agentHostMain.js' | grep -q .; then fail "agentHostMain.js 仍在产物"; else pass "产物无 agentHostMain.js"; fi
fi

# ---- 配置/命令前缀计数（workbench 产物内，quoted-prefix 口径）
count_prefix() { # count_prefix <prefix> -> stdout count
  grep -roh "\"$1" "${OUT_DIR}/vs/workbench" 2>/dev/null | wc -l | tr -d ' '
}
if (( PHASE >= 3 )); then check '"remote." 前缀为 0' "0" "$( count_prefix 'remote\.' )"; fi
if (( PHASE >= 4 )); then
  check '"debug." 前缀为 0' "0" "$( count_prefix 'debug\.' )"
  check '"chat." 前缀为 0' "0" "$( count_prefix 'chat\.' )"
  check '"notebook." 前缀为 0' "0" "$( count_prefix 'notebook\.' )"
fi

# =============================================================================
echo "== L2 CLI 断言 =="

SMOKE_ROOT="$( mktemp -d /tmp/vslight-smoke.XXXXXX )"
UDIR="${SMOKE_ROOT}/user-data"
EDIR="${SMOKE_ROOT}/extensions"
WS="${SMOKE_ROOT}/ws"
mkdir -p "${WS}"
cleanup() {
  if (( KEEP == 0 )); then
    pkill -f "${APP_NAME}.*${SMOKE_ROOT}" 2>/dev/null
    rm -rf "${SMOKE_ROOT}"
  else
    note "保留现场: ${SMOKE_ROOT}"
  fi
}
trap cleanup EXIT

echo 'hello vslight' > "${WS}/a.txt"
echo 'the quick brown fox' > "${WS}/b.txt"
git -C "${WS}" init -q && git -C "${WS}" add -A && git -C "${WS}" -c user.email=s@moke -c user.name=smoke commit -qm init

VER_OUT="$( run_to 30 "${BIN}" --user-data-dir "${UDIR}" --extensions-dir "${EDIR}" --version 2>/dev/null )"
if [[ -n "${VER_OUT}" ]]; then pass "--version => $( head -1 <<< "${VER_OUT}" )"; else fail "--version 无输出"; fi

if [[ "${APP_NAME}" == "VSLight" ]] && (( PHASE >= 2 )); then
  TUNNEL_OUT="$( "${BIN}" tunnel 2>&1 )"
  if grep -q 'not supported' <<< "${TUNNEL_OUT}"; then
    pass "vslight tunnel 给出可读报错: $( head -1 <<< "${TUNNEL_OUT}" )"
  else
    fail "vslight tunnel 未给出预期报错: $( head -1 <<< "${TUNNEL_OUT}" )"
  fi
fi

if [[ -d "${APP_RES}/extensions/git" && -d "${APP_RES}/extensions/git-base" ]]; then
  pass "内置 Git 扩展在包内 (git, git-base)"
else
  fail "内置 Git 扩展缺失"
fi

EXT_LIST="$( run_to 60 "${BIN}" --user-data-dir "${UDIR}" --extensions-dir "${EDIR}" --list-extensions 2>/dev/null )"

if run_to 120 "${BIN}" --user-data-dir "${UDIR}" --extensions-dir "${EDIR}" --install-extension zhuangtongfa.material-theme >/dev/null 2>&1; then
  EXT_LIST2="$( "${BIN}" --user-data-dir "${UDIR}" --extensions-dir "${EDIR}" --list-extensions 2>/dev/null )"
  if grep -qi 'zhuangtongfa.material-theme' <<< "${EXT_LIST2}"; then pass "open-vsx 主题扩展安装成功"; else fail "主题扩展装了但 list 不见"; fi
else
  fail "open-vsx 扩展安装失败（网络/市场问题?）"
fi

if run_to 180 "${BIN}" --user-data-dir "${UDIR}" --extensions-dir "${EDIR}" --install-extension MS-CEINTL.vscode-language-pack-zh-hans >/dev/null 2>&1; then
  pass "zh-CN 语言包安装成功"
  ZH_PACK=1
else
  fail "zh-CN 语言包安装失败"
  ZH_PACK=0
fi

# =============================================================================
if (( SKIP_UI == 1 )); then
  echo "== L3 UI 断言（--skip-ui，跳过）=="
else
  echo "== L3 UI 断言 (AppleScript/AX) =="

  AX_OK="$( osascript -e 'tell application "System Events" to return UI elements enabled' 2>/dev/null )"
  if [[ "${AX_OK}" != "true" ]]; then
    echo "ERROR: 未授予辅助功能权限（系统设置 → 隐私与安全性 → 辅助功能 → 终端）" >&2
    exit 3
  fi

  launch_app() { # launch_app [extra-args...]
    pkill -f "${APP_NAME}.*${SMOKE_ROOT}" 2>/dev/null; sleep 1
    open -na "${APP_PATH}" --args \
      --user-data-dir "${SMOKE_ROOT}/user-data" \
      --extensions-dir "${SMOKE_ROOT}/extensions" \
      --disable-workspace-trust --skip-welcome --skip-release-notes \
      "$@" "${WS}"
    run_to 90 osascript -e "
      tell application \"System Events\"
        repeat 90 times
          if exists process \"${APP_NAME}\" then
            if (count of windows of process \"${APP_NAME}\") > 0 then return \"ok\"
          end if
          delay 1
        end repeat
        return \"timeout\"
      end tell" | grep -q ok
  }
  quit_app() { osascript -e "tell application \"${APP_NAME}\" to quit" 2>/dev/null; sleep 2; pkill -f "${APP_NAME}.*${SMOKE_ROOT}" 2>/dev/null; }

  ax_find() { # ax_find <needle> -> 0 if any UI element name/description contains needle
    run_to 30 osascript -e "
      tell application \"System Events\" to tell process \"${APP_NAME}\"
        set hits to UI elements of window 1 whose name contains \"$1\" or description contains \"$1\"
        return (count of hits) as text
      end tell" 2>/dev/null | grep -qv '^0$'
  }

  keystroke_cmd() { # keystroke_cmd <key> [shift]
    if [[ "${2:-}" == "shift" ]]; then
      osascript -e "tell application \"System Events\" to keystroke \"$1\" using {command down, shift down}"
    else
      osascript -e "tell application \"System Events\" to keystroke \"$1\" using command down"
    fi
  }

  if launch_app; then pass "窗口启动"; else fail "90s 内无窗口" ui; fi

  # 正向：编辑并保存（磁盘内容断言）
  osascript -e "tell application \"System Events\" to tell process \"${APP_NAME}\" to click menu item \"a.txt\" of menu 1 of menu bar item \"File\" of menu bar 1" >/dev/null 2>&1
  run_to 15 osascript -e "tell application \"System Events\" to keystroke \"vslight-smoke-edit \""
  keystroke_cmd s
  sleep 2
  # 编辑落到哪个文件取决于焦点，断言任一文件被改动即证明编辑链路通
  if grep -rq 'vslight-smoke-edit' "${WS}" 2>/dev/null; then pass "编辑→保存落盘"; else fail "编辑未落盘" ui; fi

  # 正向：终端
  keystroke_cmd '`'
  sleep 3
  if ax_find "Terminal" || ax_find "终端"; then pass "终端面板打开"; else fail "终端面板未检出" ui; fi

  # 正向：Git 视图容器
  keystroke_cmd g shift 2>/dev/null  # cmd+shift+g = Source Control
  sleep 2
  if ax_find "Source Control" || ax_find "源代码管理"; then pass "Source Control 入口存在"; else fail "Source Control 未检出" ui; fi

  # 负向：命令面板无 Remote Explorer / Debug / Chat 入口
  if (( PHASE >= 3 )); then
    keystroke_cmd p shift
    sleep 1
    run_to 15 osascript -e 'tell application "System Events" to keystroke "Remote Explorer"'
    sleep 2
    if ax_find "Remote Explorer"; then fail "命令面板仍有 Remote Explorer" ui; else pass "命令面板无 Remote Explorer"; fi
    osascript -e 'tell application "System Events" to key code 53' # esc
  fi
  if (( PHASE >= 4 )); then
    for Q in "Debug: Start" "Chat:" "Notebook:"; do
      keystroke_cmd p shift
      sleep 1
      run_to 15 osascript -e "tell application \"System Events\" to keystroke \"$Q\""
      sleep 2
      if ax_find "${Q%%:*}"; then fail "命令面板仍命中 ${Q}" ui; else pass "命令面板无 ${Q}"; fi
      osascript -e 'tell application "System Events" to key code 53'
    done
  fi

  quit_app

  # 保留面：zh-CN 界面
  if (( ZH_PACK == 1 )); then
    if launch_app --locale zh-CN; then
      MENUS="$( run_to 30 osascript -e "tell application \"System Events\" to tell process \"${APP_NAME}\" to get name of menu bar items of menu bar 1" 2>/dev/null )"
      if grep -q '文件' <<< "${MENUS}"; then pass "zh-CN 界面生效（菜单含「文件」）"; else fail "zh-CN 未生效: ${MENUS}" ui; fi
    else
      fail "zh-CN 模式启动失败" ui
    fi
    quit_app
  fi
fi

# =============================================================================
echo
echo "== 结果汇总 =="
printf '%s\n' "${RESULTS[@]}"
if (( FAIL_HARD == 1 )); then exit 1; fi
if (( FAIL_UI == 1 )); then exit 2; fi
exit 0
