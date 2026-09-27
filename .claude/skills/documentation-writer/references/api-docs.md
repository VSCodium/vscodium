# API 文档

API 文档是参考文档，读者是要调用它的开发者。他们带着具体问题来查：这个接口要什么参数、返回什么、出错时怎么办。所以要准、要全、结构要统一，不需要讲故事。

API 文档分两种，先分清：

- **HTTP 接口**（REST、RPC 风格、GraphQL）：从路由、校验 schema、中间件、错误处理里提取。
- **库 / SDK 参考**：从公开导出的函数、类、类型签名和注释里提取。

## 目录

- [HTTP 接口：找全端点](#http-接口找全端点)
- [HTTP 接口：每个端点要查清的事](#http-接口每个端点要查清的事)
- [输出格式：Markdown 还是 OpenAPI](#输出格式markdown-还是-openapi)
- [Markdown 接口文档结构](#markdown-接口文档结构)
- [OpenAPI 规范](#openapi-规范)
- [库 / SDK 参考](#库--sdk-参考)
- [完整性核对](#完整性核对)

## HTTP 接口：找全端点

漏掉端点是接口文档最常见的问题。先找全，再逐个写。

1. **找路由定义**。按框架找注册方式，同时找路由前缀（子路由挂载在哪个路径下），前缀拼错会让整份文档的路径都错：

   | 框架 | 路由写法 | 前缀 / 分组 |
   |---|---|---|
   | Express / Koa Router | `app.get(...)`、`router.post(...)` | `app.use('/api', router)`、`new Router({ prefix })` |
   | Fastify | `fastify.get(...)`、`fastify.route({ method, url })` | `register(plugin, { prefix })` |
   | Hono | `app.get(...)` | `app.route('/api', sub)`、`basePath()` |
   | Elysia | `.get('/path', handler, { body, query, params })` | `new Elysia({ prefix })`、`.group('/x', ...)` |
   | NestJS | `@Get(':id')`、`@Post()` | `@Controller('users')`、全局 `setGlobalPrefix` |
   | FastAPI | `@app.get(...)`、`@router.post(...)` | `APIRouter(prefix=...)`、`include_router(..., prefix=...)` |
   | Flask | `@app.route('/x', methods=[...])` | Blueprint 的 `url_prefix` |
   | Django / DRF | `urls.py` 的 `path()`、`ViewSet` | `include()`、`router.register()` |
   | Spring | `@GetMapping`、`@PostMapping` | 类上的 `@RequestMapping` |
   | Gin / Echo / Chi | `r.GET(...)`、`e.POST(...)`、`r.Get(...)` | `r.Group("/v1")`、`r.Route(...)` |
   | Go net/http 1.22+ | `mux.HandleFunc("GET /users/{id}", ...)` | 外层 mux 的 `Handle` 前缀 |
   | Rails | `config/routes.rb` 的 `resources`、`get` | `namespace`、`scope` |
   | Laravel | `routes/api.php` 的 `Route::get` | `Route::prefix()->group()` |
   | ASP.NET | `[HttpGet]`、minimal API 的 `app.MapGet` | `[Route("api/[controller]")]`、`MapGroup` |

   框架能列出路由的，优先用它的输出核对：`bin/rails routes`、`php artisan route:list`、FastAPI 的 `/openapi.json`、Spring Actuator 的 `/actuator/mappings`。

2. **数清楚**。统计路由注册的数量，写文档前记下这个数，写完核对。路由注册经常跨行（`.post(` 换行后才是路径），逐行 `grep` 会漏掉一大截，要用能跨行匹配的方式数。例如链式注册的框架（Express、Hono、Elysia、Fastify）：

   ```bash
   python3 - <<'EOF'
   import re, pathlib
   pat = re.compile(r"\.(get|post|put|patch|delete)\(\s*['\"`]([^'\"`]+)", re.I)
   routes = sorted((m[1].upper(), m[2], str(p)) for p in pathlib.Path("src").rglob("*.[jt]s")
                   for m in pat.finditer(p.read_text(encoding="utf-8")))
   print(len(routes)); [print(*r) for r in routes]
   EOF
   ```

   装饰器风格（NestJS、FastAPI、Spring）按装饰器改正则。统计结果和你的端点清单对不上时，找出差异再继续。

3. **分组**。按资源（用户、订单）或按路由文件分组，组内按「列表、详情、创建、更新、删除、其他动作」排序。

## HTTP 接口：每个端点要查清的事

| 要查的 | 去哪里找 |
|---|---|
| 方法和完整路径 | 路由定义 + 所有前缀拼起来 |
| 鉴权方式、需要的角色 / 权限 / scope | 路由上的中间件、guard、装饰器，全局鉴权插件；有没有例外（公开接口） |
| 路径参数、查询参数 | 路由声明、校验 schema；默认值和取值范围从 schema 或代码里取 |
| 请求体字段、类型、必填、约束 | 校验库：zod、TypeBox（Elysia 的 `t.Object`）、Joi、yup、class-validator DTO、pydantic 模型、Go struct tag、Bean Validation 注解 |
| 响应结构 | handler 的返回值、序列化器、统一响应包装函数；数据库 schema 只作参考，以实际返回的字段为准 |
| 错误 | handler 里的 `throw` / 返回的错误、全局错误处理（Express 错误中间件、Elysia `onError`、FastAPI `exception_handler`、Spring `@ControllerAdvice`）、错误码常量文件 |
| 分页、排序、过滤 | 分页工具函数、查询参数解析 |
| 副作用 | 发消息、写审计日志、调外部服务、触发异步任务 |
| 幂等、并发、限流 | 幂等键、乐观锁、限流中间件 |

**例子里的数据**从测试用例、seed 脚本、fixture、schema 里取形状：ID 是 UUID 还是自增整数还是带前缀的字符串，金额是整数分还是小数字符串，时间是 ISO 字符串还是时间戳。形状要对，值可以是假的。token、密钥一律用占位符（`<your-token>`）。

**代码里缺注释**的端点，不要替它编一个说明。从 handler 逻辑读出它做什么；实在读不出业务意图的，写行为（「按 `status` 过滤并返回最近 50 条」），并标 `[ASK USER]` 问用途。

## 输出格式：Markdown 还是 OpenAPI

- 默认写 **Markdown**，给人读。
- 用户要 OpenAPI / Swagger，或者仓库已经在用 OpenAPI 工具链（有 `openapi.yaml`、swagger UI、代码生成客户端），写或更新 **OpenAPI**。
- 框架已经从代码自动生成 OpenAPI（FastAPI、NestJS 的 `@nestjs/swagger`、Elysia 的 swagger 插件、springdoc）时，不要再手写一份平行的规范，两份会不一致。告诉用户生成地址，文档只补自动生成覆盖不到的内容：鉴权流程、错误码含义、调用顺序、示例。需要完善生成结果的，建议在代码注解上改，改源码前先问用户。

## Markdown 接口文档结构

```markdown
# <服务名> API

## 概览
- Base URL：各环境地址（从配置里取，不确定的标 [TODO]）
- 鉴权：怎么拿凭证、放在哪个请求头
- 响应格式：统一的成功 / 失败信封结构，给一个例子
- 分页：参数名、默认值、上限
- 错误：错误响应的结构，完整错误码表在文末
- 共 N 个端点（与代码核对过的数字）

## 端点一览
| 方法 | 路径 | 说明 | 权限 |

## <资源名>

### GET /users/{id}  获取单个用户

一句话说明它做什么、什么时候用。

**权限**：`users:read`

**路径参数**
| 参数 | 类型 | 说明 |

**查询参数**
| 参数 | 类型 | 必填 | 默认值 | 说明 |

**请求体**
| 字段 | 类型 | 必填 | 约束 | 说明 |

**响应** `200`
（JSON 示例）

**错误**
| 状态码 | 错误码 | 什么时候出现 |

**注意**：幂等性、副作用、调用顺序等，没有就不写。

代码位置：`src/routes/users.ts:42`

## 错误码
| 错误码 | HTTP 状态 | 含义 | 调用方该怎么处理 |
```

没有请求体的端点不写「请求体」小节，不要留一个写着「无」的空表。每个端点给一个 `curl` 示例还是只在概览里给一个，看文档长度决定：端点少于 15 个可以每个都给，多了只给有代表性的。

## OpenAPI 规范

- 版本：仓库工具链有要求就照做，否则用 `openapi: 3.1.0`。`info.version` 取 manifest 里的版本号。
- `servers` 从配置里取；本地地址和端口要和代码一致。
- 字段结构放进 `components/schemas`，用 `$ref` 复用；鉴权放进 `components/securitySchemes`，在操作或全局上声明 `security`。
- 每个操作都要有：`operationId`（稳定、唯一，客户端代码生成要用）、`tags`、`summary`、参数、`requestBody`（有的话）、成功响应和主要错误响应。
- 枚举值、`minimum` / `maximum`、`maxLength`、`format`（`uuid`、`date-time`、`email`）从校验 schema 里照搬，不要猜。
- 写完校验：本机有 `npx` 且能联网时跑 `npx @redocly/cli lint <文件>`；不行至少确认 YAML 能被解析。校验结果写进交付说明。

一个最小片段示意格式：

```yaml
paths:
  /users/{id}:
    get:
      operationId: getUser
      tags: [users]
      summary: 获取单个用户
      security: [{ bearerAuth: [] }]
      parameters:
        - { name: id, in: path, required: true, schema: { type: string, format: uuid } }
      responses:
        '200':
          description: 用户详情
          content:
            application/json:
              schema: { $ref: '#/components/schemas/User' }
        '404':
          description: 用户不存在
          content:
            application/json:
              schema: { $ref: '#/components/schemas/Error' }
```

## 库 / SDK 参考

1. **找公开面**：`package.json` 的 `exports` / `main` / `types` 和入口 barrel 文件，Python 的 `__init__.py` 与 `__all__`，Go 的大写导出标识符，Rust `lib.rs` 里的 `pub`，Java 的公开 API 包。没导出的不写，写了读者会去用。
2. **每个导出项写**：签名（从代码复制，不要手打）、参数（类型、是否可选、默认值）、返回值、会抛出的错误、一个最小示例；有 `@deprecated` 或版本说明的照实写。
3. **组织**：按使用顺序（初始化、主要操作、辅助工具、类型）组织，比按字母排序好用。开头给一段「最小可用示例」，让读者 30 秒内跑通。
4. **仓库已经在用 TypeDoc、Sphinx、rustdoc、godoc 这类生成器**的，优先建议补源码注释再生成；手写文档只补生成器给不了的内容（概念说明、完整示例、迁移指南）。

## 完整性核对

交付前逐项确认：

- [ ] 文档里的端点数等于代码里统计出的端点数；有意不写的（内部接口、调试接口）在文档或交付说明里列出来
- [ ] 每个路径都拼上了完整前缀，和一个真实请求能对上
- [ ] 每个端点的权限要求都查过中间件，不是猜的
- [ ] 请求字段的必填、约束与校验 schema 一致
- [ ] 错误码表里的每个码在代码里都能找到出处
- [ ] 示例 JSON 的字段名和响应代码一致
- [ ] 代码注释缺失、只能推断用途的端点已标 `[INFERRED]` 或 `[ASK USER]`
