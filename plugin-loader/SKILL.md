---
name: plugin-loader
description: 管理 Claude Code 插件生态。支持三个 marketplace：claude-plugins-official（官方 34 internal + 15 external）、claude-code-workflows（77 个专业领域插件）、claude-hud（状态栏）。提供全局/项目/文件夹三种部署方式。
---

# Plugin Loader Skill

管理 Claude Code 插件生态，按需安装专业插件。

## 快速开始

**收到此 skill 后，执行以下命令配置 marketplace：**

```bash
# 1. 查看当前 marketplace 状态
claude plugin marketplace list

# 2. 添加缺失的 marketplace（按需添加）
claude plugin marketplace add anthropics/claude-plugins-official   # 官方插件（必须）
claude plugin marketplace add wshobson/agents                      # 社区专业插件（推荐）
claude plugin marketplace add jarrod-watts/claude-hud              # 状态栏插件（可选）

# 3. 验证 marketplace 已添加
claude plugin marketplace list
```

**Marketplace 来源说明：**

| Marketplace | GitHub 仓库 | 类型 | 添加命令 |
|-------------|-------------|------|----------|
| `claude-plugins-official` | [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) | Anthropic 官方 | `claude plugin marketplace add anthropics/claude-plugins-official` |
| `claude-code-workflows` | [wshobson/agents](https://github.com/wshobson/agents) | 社区维护 | `claude plugin marketplace add wshobson/agents` |
| `claude-hud` | [jarrodwatts/claude-hud](https://github.com/jarrodwatts/claude-hud) | 社区维护 | `claude plugin marketplace add jarrodwatts/claude-hud` |

> **注意**：`claude-code-workflows` marketplace 名字与仓库名不同，添加时使用仓库名 `wshobson/agents`，安装插件时使用 marketplace 名 `claude-code-workflows`。

---

## 插件作用域（Scope）层级

```
┌─────────────────────────────────────────────────────────┐
│ 全局 (user scope)                                       │
│ ~/.claude/settings.json                                 │
│ 所有项目共享，跨 session 持久                            │
└─────────────────────────────────────────────────────────┘
      │
      ├─ 项目 A (.claude/settings.json) ← project scope
      │
      ├─ 项目 B (.claude/settings.local.json) ← local scope
      │
      └─ 项目 C (.claude/settings.local.json) ← local scope
```

| Scope | 配置位置 | 生效范围 | 查看命令 |
|-------|----------|----------|----------|
| `user` | `~/.claude/settings.json` | 所有项目 | `claude plugin list` |
| `project` | 项目 `/.claude/settings.json` | 仅该 git 仓库 | `claude plugin list` |
| `local` | 项目 `/.claude/settings.local.json` | 仅该文件夹 | `claude plugin list` |

> **重要**：`project` 和 `local` scope 的插件配置在各项目目录的 `.claude/settings.*.json` 中，不是全局配置。不同项目可以有不同的 local/project 插件，互不影响。

---

## Marketplace 概览

当前配置的三个 marketplace：

| Marketplace | 来源 | 插件数量 | 类型 |
|-------------|------|----------|------|
| `claude-plugins-official` | anthropics/claude-plugins-official | 49 | 官方插件（34 internal + 15 external） |
| `claude-code-workflows` | wshobson/agents | 77 | 专业领域插件 |
| `claude-hud` | jarrodwatts/claude-hud | 1 | 实时状态栏 |

---

## 命令参考

### Plugin 命令

| 命令 | 别名 | 说明 |
|------|------|------|
| `claude plugin install <plugin>@<marketplace>` | `i` | 安装插件 |
| `claude plugin list` | — | 列出已安装插件 |
| `claude plugin update <plugin>` | — | 更新指定插件 |
| `claude plugin update --all` | — | 更新所有插件 |
| `claude plugin disable <plugin>` | — | 禁用插件（临时） |
| `claude plugin enable <plugin>` | — | 启用插件 |
| `claude plugin uninstall <plugin>` | `remove` | 卸载插件 |
| `claude plugin prune` | `autoremove` | 清理不需要的依赖 |
| `claude plugin validate <path>` | — | 验证插件或 manifest |

### Marketplace 命令

| 命令 | 别名 | 说明 |
|------|------|------|
| `claude plugin marketplace list` | — | 列出已配置的 marketplace |
| `claude plugin marketplace add <source>` | — | 添加 marketplace |
| `claude plugin marketplace remove <name>` | `rm` | 移除 marketplace |
| `claude plugin marketplace update [name]` | — | 更新 marketplace（无参数则更新全部） |

> **注意**：以下命令**不存在**，请勿使用：
> - `claude plugin search` ❌
> - `claude plugin marketplace show` ❌

---

## 部署方式

### 1. 全局部署（user scope）

所有项目都能使用该插件：

```bash
claude plugin install <插件名>@<marketplace> --scope user
# 或使用简写
claude i <插件名>@<marketplace> --scope user
```

**示例**：
```bash
claude plugin install python-development@claude-code-workflows --scope user
claude plugin install rust-analyzer-lsp@claude-plugins-official --scope user
```

### 2. 项目部署（project scope）

仅当前 git 仓库可用：

```bash
claude plugin install <插件名>@<marketplace> --scope project
```

**配置位置**：项目的 `.claude/settings.json`

**示例**：
```bash
claude plugin install llm-application-dev@claude-code-workflows --scope project
```

### 3. 本地部署（local scope）

仅当前文件夹可用（无需 git 仓库）：

```bash
claude plugin install <插件名>@<marketplace> --scope local
```

**配置位置**：当前目录的 `.claude/settings.local.json`

### 4. 禁用/启用插件

临时禁用或重新启用已安装的插件：

```bash
claude plugin disable <插件名>
claude plugin enable <插件名>
```

### 5. 卸载插件

完全移除已安装的插件：

```bash
claude plugin uninstall <插件名>
# 或使用别名
claude plugin remove <插件名>
```

**注意**：卸载会从配置文件中删除该插件，需要重新安装才能再次使用。

### 6. 更新插件

更新已安装的插件到最新版本：

```bash
claude plugin update <插件名>
```

更新所有插件：

```bash
claude plugin update --all
```

### 7. 清理依赖

移除不再需要的自动安装依赖：

```bash
claude plugin prune
# 或使用别名
claude plugin autoremove
```

### 8. 管理 Marketplace

**查看已配置的 marketplace**：
```bash
claude plugin marketplace list
```

**添加 marketplace**：
```bash
claude plugin marketplace add <GitHub仓库或URL>
```

**移除 marketplace**：
```bash
claude plugin marketplace remove <marketplace名>
# 或使用别名
claude plugin marketplace rm <marketplace名>
```

**更新 marketplace**：
```bash
claude plugin marketplace update          # 更新全部
claude plugin marketplace update <name>   # 更新指定 marketplace
```

---

## 安装流程

### 1. 查看 marketplace 状态

```bash
claude plugin marketplace list
```

### 2. 添加 marketplace（如缺失）

```bash
claude plugin marketplace add wshobson/agents    # claude-code-workflows
claude plugin marketplace add anthropics/claude-plugins-official
claude plugin marketplace add jarrod-watts/claude-hud
```

### 3. 更新 marketplace（可选）

```bash
claude plugin marketplace update  # 更新全部 marketplace
```

### 4. 查看已安装插件

```bash
claude plugin list
```

### 5. 安装插件

```bash
claude plugin install <插件名>@<marketplace>
# 或使用简写
claude i <插件名>@<marketplace>
```

### 6. 验证安装

```bash
claude plugin list
```

### 7. 清理依赖（可选）

```bash
claude plugin prune  # 清理不需要的自动安装依赖
```

---

## 执行规则

1. **先确认再安装** — 向用户说明插件功能，获得确认
2. **一次一个** — 避免批量安装，按需逐个添加
3. **选择 scope** — 根据使用范围选择 user/project/local
4. **安装后验证** — 使用 `plugin list` 确认
5. **持久保留** — 插件安装后保留，无需重复安装
6. **谨慎卸载** — 卸载前确认用户意图，说明卸载后果
7. **定期更新** — 建议用户定期 `plugin update --all` 获取最新功能

---

<resources>

## claude-plugins-official（49 个：34 internal + 15 external）

### LSP 语言服务器

| 插件名 | 描述 |
|--------|------|
| `rust-analyzer-lsp` | Rust 语言服务器 |
| `pyright-lsp` | Python 语言服务器 |
| `typescript-lsp` | TypeScript 语言服务器 |
| `gopls-lsp` | Go 语言服务器 |
| `clangd-lsp` | C/C++ 语言服务器 |
| `jdtls-lsp` | Java 语言服务器 |
| `kotlin-lsp` | Kotlin 语言服务器 |
| `csharp-lsp` | C# 语言服务器 |
| `swift-lsp` | Swift 语言服务器 |
| `ruby-lsp` | Ruby 语言服务器 |
| `php-lsp` | PHP 语言服务器 |
| `lua-lsp` | Lua 语言服务器 |

### 开发工具

| 插件名 | 描述 |
|--------|------|
| `skill-creator` | 技能创建工具 |
| `plugin-dev` | 插件开发工具 |
| `mcp-server-dev` | MCP 服务器开发 |
| `agent-sdk-dev` | Agent SDK 开发 |
| `feature-dev` | 功能开发流程 |
| `code-review` | 代码审查 |
| `pr-review-toolkit` | PR 审查工具 |
| `code-modernization` | 代码现代化升级 |
| `code-simplifier` | 代码简化 |
| `frontend-design` | 前端设计 |
| `security-guidance` | 安全指导 |
| `session-report` | 会话报告生成 |
| `commit-commands` | Git commit 命令 |
| `hookify` | Hook 工具 |
| `conductor` | 项目管理编排 |
| `claude-code-setup` | Claude Code 配置 |
| `example-plugin` | 插件示例模板 |
| `playground` | 实验沙盒 |
| `ralph-loop` | 循环工作流 |
| `plugin-eval` | 插件评估 |
| `math-olympiad` | 数学竞赛解题 |
| `explanatory-output-style` | 详细输出风格 |
| `learning-output-style` | 教学输出风格 |

### 外部插件（15 个）

> 注：这 15 个外部插件为集成工具，不是 LSP 语言服务器

| 插件名 | 描述 |
|--------|------|
| `asana` | Asana 项目管理集成 |
| `context7` | Context7 知识库集成 |
| `discord` | Discord 机器人开发 |
| `fakechat` | 模拟聊天测试工具 |
| `firebase` | Firebase 集成 |
| `github` | GitHub API 集成 |
| `gitlab` | GitLab API 集成 |
| `greptile` | Greptile 搜索集成 |
| `imessage` | iMessage 集成 |
| `laravel-boost` | Laravel 开发加速 |
| `linear` | Linear 项目管理集成 |
| `playwright` | Playwright 测试框架 |
| `serena` | Serena 项目管理集成 |
| `telegram` | Telegram 机器人开发 |
| `terraform` | Terraform IaC 工具 |

---

## claude-code-workflows（77 个）

> 注：`llm-application-dev`、`agent-orchestration`、`agent-teams` 属于此 marketplace，不是官方外部插件

### 开发语言

| 插件名 | 描述 |
|--------|------|
| `python-development` | Python 3.12+ 开发（16 skills） |
| `javascript-typescript` | JS/TS ES6+ 开发 |
| `systems-programming` | Rust 系统编程 |
| `jvm-languages` | Java/Kotlin/Scala 开发 |
| `dotnet-contribution` | .NET/C# 后端开发 |
| `functional-programming` | Elixir 函数式编程 |
| `shell-scripting` | Bash 脚本编程 |
| `julia-development` | Julia 科学计算 |
| `web-scripting` | PHP/Ruby Web 脚本 |

### 前端/移动

| 插件名 | 描述 |
|--------|------|
| `frontend-mobile-development` | 前端/移动开发 |
| `frontend-mobile-security` | XSS 防护 |
| `ui-design` | UI/UX 设计（iOS/Android） |
| `multi-platform-apps` | 跨平台应用开发 |
| `brand-landingpage` | 品牌 landing page 设计 |
| `accessibility-compliance` | WCAG 无障碍审计 |

### 后端/API

| 插件名 | 描述 |
|--------|------|
| `backend-development` | 后端 API 设计（10 skills） |
| `backend-api-security` | API 安全加固 |
| `api-scaffolding` | REST/GraphQL API 脚手架 |
| `api-testing-observability` | API 测试自动化 |

### AI/ML

| 插件名 | 描述 |
|--------|------|
| `machine-learning-ops` | ML 模型训练流水线 |
| `context-management` | 上下文持久化 |
| `meigen-ai-design` | AI 图像生成创意流程 |

### 数据库

| 插件名 | 描述 |
|--------|------|
| `database-design` | 数据库架构设计 |
| `database-migrations` | 数据库迁移自动化 |
| `database-cloud-optimization` | 云数据库查询优化 |

### 云/基础设施

| 插件名 | 描述 |
|--------|------|
| `kubernetes-operations` | K8s manifest 生成 |
| `cloud-infrastructure` | AWS/Azure/GCP/OCI 架构设计 |
| `cicd-automation` | CI/CD 流水线配置 |
| `deployment-strategies` | 部署模式策略 |
| `deployment-validation` | 部署前检查验证 |
| `infrastructure-validation` | 基础设施验证 |

### 安全

| 插件名 | 描述 |
|--------|------|
| `security-scanning` | SAST 安全扫描 |
| `security-compliance` | SOC2 合规检查 |
| `protect-mcp` | Cedar 策略执行 + Ed25519 签名审计 |
| `block-no-verify` | 阻止 --no-verify Git 操作 |
| `signed-audit-trails` | 签名审计 trail 教程 |
| `review-agent-governance` | PR 审查前人工审批信号 |

### 测试/质量

| 插件名 | 描述 |
|--------|------|
| `comprehensive-review` | 多角度代码分析（架构/安全/性能） |
| `unit-testing` | 单元/集成测试自动化 |
| `tdd-workflows` | TDD 红绿重构方法论 |
| `performance-testing-review` | 性能分析审查 |
| `code-refactoring` | 代码重构清理 |
| `codebase-cleanup` | 技术债务清理 |
| `dependency-management` | 依赖审计管理 |

### 文档

| 插件名 | 描述 |
|--------|------|
| `documentation-generation` | OpenAPI 文档生成 |
| `documentation-standards` | HADS 文档标准（AI/人类双优化） |
| `code-documentation` | 代码文档生成 |
| `c4-architecture` | C4 架构文档（自下而上分析） |

### 调试/运维

| 插件名 | 描述 |
|--------|------|
| `debugging-toolkit` | 交互式调试工具 |
| `error-debugging` | 错误分析 |
| `error-diagnostics` | 错误追踪诊断 |
| `distributed-debugging` | 分布式系统追踪 |
| `incident-response` | 生产故障管理 |
| `observability-monitoring` | 指标收集监控 |
| `application-performance` | 应用性能分析 |
| `diagnostics` | 系统诊断工具 |

### 工作流/协作

| 插件名 | 描述 |
|--------|------|
| `git-pr-workflows` | Git workflow 自动化 |
| `full-stack-orchestration` | 全栈功能编排（含测试） |
| `team-collaboration` | 团队协作流程 |
| `developer-essentials` | 开发者必备技能（Git 等） |

### 数据

| 插件名 | 描述 |
|--------|------|
| `data-engineering` | ETL 流水线构建 |
| `data-validation-suite` | Schema 验证 |

### 其他专业领域

| 插件名 | 描述 |
|--------|------|
| `game-development` | Unity 游戏开发（C# 脚本） |
| `blockchain-web3` | Solidity 智能合约开发 |
| `quantitative-trading` | 量化分析交易 |
| `payment-processing` | Stripe 支付集成 |
| `arm-cortex-microcontrollers` | ARM Cortex-M 嵌入式（Teensy） |
| `reverse-engineering` | 二进制逆向工程 |
| `startup-business-analyst` | 创业商业分析（TAM/SAM/SOM） |
| `business-analytics` | 商业指标分析 |
| `content-marketing` | 内容营销策略 |
| `customer-sales-automation` | 客户支持自动化 |
| `hr-legal-compliance` | HR 政策文档 |
| `seo-analysis-monitoring` | SEO 内容新鲜度分析 |
| `seo-content-creation` | SEO 内容写作 |
| `seo-technical-optimization` | SEO 技术优化（meta tags） |
| `framework-migration` | 框架版本升级迁移 |

---

## claude-hud（1 个）

| 插件名 | 描述 |
|--------|------|
| `claude-hud` | 实时多行状态栏：上下文健康、工具活动、Agent 状态、Todo 进度 |

**提供命令**：
- `/setup` — 配置状态栏
- `/configure` — 自定义显示选项

---

## 推荐插件组合

### Python 后端开发
```bash
claude plugin install python-development@claude-code-workflows --scope user
claude plugin install backend-development@claude-code-workflows --scope user
claude plugin install pyright-lsp@claude-plugins-official --scope user
```

### 前端开发
```bash
claude plugin install frontend-mobile-development@claude-code-workflows --scope user
claude plugin install typescript-lsp@claude-plugins-official --scope user
claude plugin install ui-design@claude-code-workflows --scope user
```

### 安全审计
```bash
claude plugin install security-scanning@claude-code-workflows --scope user
claude plugin install comprehensive-review@claude-code-workflows --scope user
```

### Kubernetes/云运维
```bash
claude plugin install kubernetes-operations@claude-code-workflows --scope user
claude plugin install cloud-infrastructure@claude-code-workflows --scope user
claude plugin install incident-response@claude-code-workflows --scope user
```

### LLM/AI 应用
```bash
claude plugin install llm-application-dev@claude-code-workflows --scope user
claude plugin install agent-orchestration@claude-code-workflows --scope user
```

</resources>