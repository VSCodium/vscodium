# 技术栈识别

技术栈不明确时读这份：多种 manifest 并存、文件扩展名陌生、找不到明显的 `package.json` / `go.mod`。

---

## Manifest 文件 → 生态

| 文件 | 生态 | 重点看的字段 |
|------|-----------|--------------------|
| `package.json` | Node.js / JavaScript / TypeScript | `dependencies`, `devDependencies`, `scripts`, `main`, `type`, `engines` |
| `go.mod` | Go | Module path, Go version, `require` block |
| `requirements.txt` | Python (pip) | Package list with pinned versions |
| `Pipfile` | Python (pipenv) | `[packages]`, `[dev-packages]`, `[requires]` python version |
| `pyproject.toml` | Python (poetry / uv / hatch) | `[tool.poetry.dependencies]`, `[project]`, `[build-system]` |
| `setup.py` / `setup.cfg` | Python (setuptools, legacy) | `install_requires`, `python_requires` |
| `Cargo.toml` | Rust | `[dependencies]`, `[[bin]]`, `[lib]` |
| `pom.xml` | Java / Kotlin (Maven) | `<dependencies>`, `<artifactId>`, `<groupId>`, `<java.version>` |
| `build.gradle` / `build.gradle.kts` | Java / Kotlin (Gradle) | `dependencies {}`, `sourceCompatibility` |
| `composer.json` | PHP | `require`, `require-dev` |
| `Gemfile` | Ruby | `gem` declarations, `ruby` version constraint |
| `mix.exs` | Elixir | `deps/0`, `elixir: "~> X.Y"` |
| `pubspec.yaml` | Dart / Flutter | `dependencies`, `dev_dependencies`, `environment.sdk` |
| `*.csproj` | .NET / C# | `<PackageReference>`, `<TargetFramework>` |
| `*.sln` | .NET solution | References multiple `.csproj` projects |
| `deno.json` / `deno.jsonc` | Deno (TypeScript runtime) | `imports`, `tasks` |
| `bun.lockb` | Bun (JavaScript runtime) | Binary lockfile — check `package.json` for deps |
| `bun.lock` | Bun (JavaScript runtime) | Text lockfile (Bun 1.2+) — check `package.json` for deps |

---

## 运行时版本在哪里

| 语言 | 版本写在哪 |
|----------|--------------------------|
| Node.js | `.nvmrc`, `.node-version`, `engines.node` in `package.json`, Docker `FROM node:X` |
| Python | `.python-version`, `pyproject.toml [requires-python]`, Docker `FROM python:X` |
| Go | First line of `go.mod` (`go 1.21`) |
| Java | `<java.version>` in `pom.xml`, `sourceCompatibility` in `build.gradle`, Docker `FROM eclipse-temurin:X` |
| Ruby | `.ruby-version`, `Gemfile` `ruby 'X.Y.Z'` |
| Rust | `rust-toolchain.toml`, `rust-toolchain` file |
| .NET | `<TargetFramework>` in `.csproj` (e.g., `net8.0`) |

---

## 框架识别（Node.js / TypeScript）

| `package.json` 里的依赖 | 框架 |
|-----------------------------|-----------|
| `express` | Express.js (minimal HTTP server) |
| `fastify` | Fastify (high-performance HTTP server) |
| `next` | Next.js (SSR/SSG React — check for `pages/` or `app/` directory) |
| `nuxt` | Nuxt.js (SSR/SSG Vue) |
| `@nestjs/core` | NestJS (opinionated Node.js framework with DI) |
| `koa` | Koa (middleware-focused, no built-in router) |
| `@hapi/hapi` | Hapi |
| `hono` | Hono (lightweight, multi-runtime HTTP framework) |
| `elysia` | Elysia (Bun-first HTTP framework, TypeBox schemas via `t`) |
| `@trpc/server` | tRPC (type-safe API without REST/GraphQL schemas) |
| `routing-controllers` | routing-controllers (decorator-based Express wrapper) |
| `typeorm` | TypeORM (SQL ORM with decorators) |
| `prisma` | Prisma (type-safe ORM, check `prisma/schema.prisma`) |
| `mongoose` | Mongoose (MongoDB ODM) |
| `sequelize` | Sequelize (SQL ORM) |
| `drizzle-orm` | Drizzle (lightweight SQL ORM) |
| `react` without `next` | Vanilla React SPA (check for `react-router-dom`) |
| `vue` without `nuxt` | Vanilla Vue SPA |

---

## 框架识别（Python）

| 包 | 框架 |
|---------|-----------|
| `fastapi` | FastAPI (async REST, auto OpenAPI docs) |
| `flask` | Flask (minimal WSGI web framework) |
| `django` | Django (batteries-included, check `settings.py`) |
| `starlette` | Starlette (ASGI, often used as FastAPI base) |
| `aiohttp` | aiohttp (async HTTP client and server) |
| `sqlalchemy` | SQLAlchemy (SQL ORM; check for `alembic` migrations) |
| `alembic` | Alembic (SQLAlchemy migration tool) |
| `pydantic` | Pydantic (data validation; core to FastAPI) |
| `celery` | Celery (distributed task queue) |

---

## Monorepo 识别

按顺序检查这些信号：

1. `pnpm-workspace.yaml` — pnpm workspaces
2. `lerna.json` — Lerna monorepo
3. `nx.json` — Nx monorepo (also check `workspace.json`)
4. `turbo.json` — Turborepo
5. `rush.json` — Rush (Microsoft monorepo manager)
6. `moon.yml` — Moon
7. `package.json` with `"workspaces": [...]` — npm/yarn workspaces
8. Presence of `packages/`, `apps/`, `libs/`, or `services/` directories with their own `package.json`

确认是 monorepo 后：每个 workspace 的依赖和约定可能**各自独立**。在 `STACK.md` 里分别写每个子包，在 `STRUCTURE.md` 里说明 monorepo 结构。

---

## TypeScript 路径别名

`tsconfig.json` 里有 `paths` 时，非相对路径前缀的导入是别名。写结构前先映射成真实路径。

```json
// tsconfig.json 示例
"paths": {
  "@/*": ["./src/*"],
  "@components/*": ["./src/components/*"],
  "@utils/*": ["./src/utils/*"]
}
```

`import { foo } from '@/utils/bar'` 实际指向 `src/utils/bar`。文档里写 `src/utils/bar`，不写 `@/utils/bar`。

---

## Docker 基础镜像 → 运行时

没有 manifest 但有 `Dockerfile` 时，`FROM` 行能看出运行时：

| FROM 行 | 运行时 |
|------------------|---------|
| `FROM node:X` | Node.js X |
| `FROM python:X` | Python X |
| `FROM golang:X` | Go X |
| `FROM eclipse-temurin:X` | Java X (Eclipse Temurin JDK) |
| `FROM mcr.microsoft.com/dotnet/aspnet:X` | .NET X |
| `FROM ruby:X` | Ruby X |
| `FROM rust:X` | Rust X |
| 只有 `FROM alpine` | 看 `RUN apk add` 装了什么 |
