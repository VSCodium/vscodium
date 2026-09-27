# 调查问题清单

写代码库说明（[codebase-map.md](codebase-map.md)）第 2 步用。每份文档先在扫描结果里找答案，找不到再读源文件。

---

## 1. STACK.md：技术栈

- 主要语言和确切版本？（看 `.nvmrc`、`go.mod`、`pyproject.toml`、Dockerfile 的 `FROM`）
- 用的什么包管理器？（`npm`、`yarn`、`pnpm`、`bun`、`go mod`、`pip`、`uv`）
- 核心运行时框架有哪些？（Web 服务器、ORM、依赖注入容器）
- `dependencies`（生产）和 `devDependencies`（开发工具）里分别有什么？
- 有没有 Docker 镜像，基础镜像是什么？
- `package.json` / `Makefile` / `pyproject.toml` 里的关键脚本有哪些？

## 2. STRUCTURE.md：目录结构

- 源码放在哪？（通常是 `src/`、`lib/`，Go 项目常在根目录）
- 入口是哪些？（`package.json` 的 `main`、`scripts.start`、`cmd/main.go`、`app.py`）
- 每个顶层目录的用途是什么？
- 有没有不直观的目录（`eng/`、`platform/`、`infra/`）？
- 有哪些隐藏的配置目录（`.github/`、`.vscode/`、`.husky/`）？
- 目录命名遵循什么规律？（camelCase、kebab-case，按领域分还是按层分）

## 3. ARCHITECTURE.md：架构模式

- 代码按层组织（controller → service → repository）还是按功能组织？
- 主要数据流是什么？从入口到数据存储完整追踪一个请求或命令。
- 有没有单例、依赖注入、必须按顺序初始化的东西？
- 有没有后台 worker、队列、事件驱动的组件？
- 反复出现的设计模式有哪些？（Factory、Repository、Decorator、Strategy）

## 4. FEATURES.md：功能

- 用户或调用方能用到哪些功能？从路由、页面、CLI 命令、菜单配置、权限定义里列全。
- 每个功能的入口在哪（路由、页面组件、命令），核心逻辑在哪，读写哪些表或外部服务？
- 哪三到五个功能最重要（最常用、改动最频繁、最复杂）？把它们在代码里的执行路径走一遍。
- 有哪些特性开关、租户级配置、套餐限制会改变功能行为？
- 有没有写了但没接上入口的功能，或者入口在但实现是空的？

## 5. CONVENTIONS.md：编码约定

- 文件命名规则？（至少看 10 个文件：camelCase、kebab-case、PascalCase）
- 函数和变量的命名规则？
- 私有方法和字段有没有前缀（`_methodName`、`#field`）？
- 配了哪些 linter 和 formatter？（看 `.eslintrc`、`.prettierrc`、`biome.json`、`golangci.yml`）
- TypeScript 严格程度怎么设的？（`strict`、`noImplicitAny` 等）
- 每一层怎么处理错误？（抛异常还是返回结构化错误）
- 用什么日志库，日志格式是什么？
- 导入怎么组织？（barrel 导出、路径别名、分组规则）

## 6. INTEGRATIONS.md：外部集成

- 调用了哪些外部 API？（搜 `axios.`、`fetch(`、`http.Get(`、常量里的 base URL）
- 凭据怎么存、怎么取？（`.env`、密钥管理服务、环境变量）
- 连了哪些数据库？（在 manifest 里找 `pg`、`mongoose`、`prisma`、`typeorm`、`drizzle-orm`、`sqlalchemy`）
- 应用和外部服务之间有没有 API 网关、服务网格或代理？
- 用了哪些监控或可观测性工具？（APM、Prometheus、日志管道）
- 有没有消息队列或事件总线？（Kafka、RabbitMQ、SQS、Pub/Sub、Redis Streams）

## 7. TESTING.md：测试

- 配的什么测试运行器？（看 `package.json` 的 `scripts.test`、`pytest.ini`、`go test`、`bun test`）
- 测试文件放在哪？（和源码放一起、`tests/`、`__tests__/`）
- 用什么断言库？（Jest expect、Chai、pytest assert）
- 外部依赖怎么 mock？（`jest.mock`、依赖注入、fixture）
- 有没有连真实服务的集成测试，还是只有 mock 的单元测试？
- 有没有强制的覆盖率门槛？（看 `jest.config.js`、`.nycrc`、`pyproject.toml`、`bunfig.toml`）

## 8. CONCERNS.md：风险与问题

- 生产代码里有多少 TODO / FIXME / HACK？（看扫描结果）
- 近 90 天改动最频繁的是哪些文件？（看扫描结果）
- 有没有超过 500 行、混了多种职责的文件？
- 有没有可以并行却串行调用的服务？
- 有没有该放进配置却写死的值（URL、ID、魔法数字）？
- 有哪些安全风险？（缺输入校验、把原始错误信息返回给客户端、缺鉴权检查）
- 有没有扩展不了的性能写法？（N+1 查询、多实例部署下的进程内缓存）
