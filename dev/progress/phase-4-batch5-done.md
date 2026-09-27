# Phase 4 批 5（96 policy-watcher）完工记录

- 提交：`96-light-remove-policy-watcher.patch`
- 验收：全量构建 EXIT 0；patch 无失败；无 .rej

## 断言证据

| 断言 | 证据 |
|---|---|
| postinstall 无 ERR | build.log `npm error|ERR!` 计数 = 0 |
| 模块不再安装 | `ls vscode/node_modules/@vscodium/` 仅剩 native-keymap |
| 源码不再引用包 | 两处服务改为变量说明符动态 import + catch 降级（一条 info 日志），本地最小 Watcher 类型替代包类型 |
| 应用可启动 | renderer.log Render performance baseline=1，无新增错误 |
| 装机 JS | 26.3MB 持平（原生模块不占 JS 口径；node_modules 少一个 node-gyp 包） |

## 备注

- `.moduleignore` 中 5 行 policy-watcher 打包排除模式保留（对不存在的包为 no-op，且属 21 号 patch 区域）。
- 托管策略（MDM/注册表读取）功能随之禁用：vslight 无企业策略需求；日志可见降级信息。
