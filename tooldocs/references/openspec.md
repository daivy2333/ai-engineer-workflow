---
name: openspec
description: OpenSpec 是一个 **AI 协作规范工具**，让人类和 AI 编码助手在写代码之前先就"要建什么"达成一致。核心理念：fluid not rigid、iterative not waterfall、easy not complex、brownfield-first。
---
# OpenSpec 精简使用手册

## 一、什么是 OpenSpec


| 原则 | 含义 |
|------|------|
| **fluid not rigid** | 没有阶段门控，随时可以做任何操作 |
| **iterative not waterfall** | 边建边学，逐步改进 |
| **easy not complex** | 轻量设置，最少仪式 |
| **brownfield-first** | 优先适配已有代码库的增量修改 |

这些原则描述 OpenSpec 工具本身。本仓库的 `openspec-plan` 和 `openspec-act` 在其上增加 BDD、TDD 和 Gate，不改变 OpenSpec 的文件格式。

---

## 二、核心结构

```
openspec/
├── specs/              ← 行为真相源（系统当前行为的描述）
│   └── <domain>/
│       └── spec.md
├── changes/            ← 提议修改（每个修改一个文件夹）
│   └── <change-name>/
│       ├── README.md       ← 修改说明
│       ├── .openspec.yaml  ← 元数据：schema、创建日期、skip_specs
│       ├── proposal.md     ← 为什么做、做什么
│       ├── specs/          ← 增量规格（ADDED/MODIFIED/REMOVED）
│       ├── design.md       ← 技术方案
│       └── tasks.md        ← 实施清单
└── config.yaml             ← 项目配置
```

**两个关键目录：**
- `specs/` — 系统当前行为的真相源
- `changes/` — 提议的修改，完成后归档合并回 `specs/`

`openspec new change` 只创建目录、`README.md` 和 `.openspec.yaml`；各产物由 AI 按 `openspec instructions` 的指引生成。

本仓库的 Plan/Act 工作流允许在 change 内按需增加：

```text
changes/<change>/
├── iterations/             ← 逻辑 Iteration 目录与执行 Cycle
│   └── <III-title>/
│       ├── 000-initial.md
│       ├── 001-rework.md
│       └── 002-replan.md
└── evidence/               ← 仅在需要留存证据时创建
    └── <III-title>/
        └── <CCC-title>/
            ├── README.md
            └── <最多四个实际证据文件>
```

Plan 将 Persisted Evidence 设为 `none` 或 `required`。`none` 时由 Act Response 保存每项不超过 20 行的决定性输出；`required` 只用于用户要求、无法低成本复现、一次性环境、Issue/Blocker 现场或不可摘要的决定性结构。若 `required` 在执行时不再合法或可采集，Act 以 `blocked` 返回 Plan，不强行收集。每个 Cycle 最多 5 个文件（含 README），整个 change 最多 20 个，单个文本文件最多 500 行且不超过 256 KiB；禁止完整日志目录、源码副本和完整测试输出。Evidence 属于 change，不登记 R，随 change 归档。

本仓库只用目标状态、输出、错误结果、协议结果和退出码证明行为。禁止为了验证、Qualification、Evidence 或运行归属新增 Hash/指纹、revision pin、run-id、peer/host pin、source/worktree freeze、artifact manifest、日志 Hash 链、时间顺序证明及其审计工具；这些材料身份信息不能替代行为验证。产品 requirement 明确要求的认证、完整性校验或多会话协议仍按目标行为规划和测试。

本仓库把 Iteration 定义为 change Map 中的逻辑工作单元，把 Cycle 定义为该 Iteration 内的一次 Plan、Act、Review 执行闭环。Plan Context 从 `draft` 开始，Gate 2 通过或明确豁免且计划获批后变为 `ready`。有限修复由 Plan 保持 Review Result 为 `pending` 并反馈给 Act，在当前 Cycle 覆盖各自最新状态；需要新执行契约时才进入 `rework-required` 并增加同目录 Cycle，计划边界变化则进入 `replan-required`。

上下文按职责传递：Assistant 恢复 OpenSpec 体系文档，Explorer 调查实际代码，Plan 复用探索结果并只补查缺失或失效事实，再把 Act 所需内容直接写入自包含 Plan Context。Act 不回读 Explorer 或重新建立计划基线，只读取当前 Cycle、目标代码和测试。局部实现差异和不影响 Acceptance 的 Minor finding 记录后继续；需要改变行为、接口或错误语义、状态所有权、架构、范围、测试策略或 Acceptance 时才阻塞。

---

## 三、快速开始

```bash
# 1. 安装（需要 Node.js ≥ 20.19.0）
npm install -g @fission-ai/openspec@latest

# 2. 在项目中初始化
cd your-project
openspec init --tools claude --force
# 注意：使用 --tools 指定 AI 工具（不是 --ai）
# 使用 --force 跳过交互式选择

# 3. 验证安装
openspec --version
```

初始化时使用 `--tools` 参数指定 AI 工具（claude、codex、opencode、zcode、cursor 等 40 种，支持 `all` 或 `none`），生成 skills/commands 配置文件。`--language` 预设产物语言，`--profile` 覆盖工作流 profile。

---

## 四、工作流与平台适配

OpenSpec 生命周期使用通用动作：

```text
explore → propose → apply → validate/sync → archive
```

不同 AI 工具可以为这些动作提供 slash command、skill 或其他入口。流程不能依赖某一种命令拼写。

| 语义 | 作用 |
|------|------|
| explore | 调查需求，不修改产品代码 |
| propose | 创建 proposal、specs、design 和 tasks |
| apply | 按 tasks 实施 |
| validate | 检查规格或变更 |
| sync | 将增量规格同步到主规格 |
| archive | 完成并归档变更 |

Claude Code、OpenCode 和 Codex 共用本仓库的 `SKILL.md`。安装目录和平台工具映射见项目 README。

### OpenSpec profile

默认 `core` profile 生成六个命令：

```
/opsx:explore  /opsx:propose  /opsx:apply  /opsx:update  /opsx:sync  /opsx:archive
```

可选工作流（如逐产物审阅）通过交互式 `openspec config profile` 添加，再用 `openspec update` 重新生成入口文件。profile 预设只有 `core`，`openspec config profile custom` 会报错。

未安装命令文件时，CLI 的 `new change`、`status` 和 `instructions` 覆盖同一流程。

可用命令取决于 OpenSpec 版本和当前工具适配。

---

## 五、命令速查

### 核心命令（默认可用）

| 命令 | 用途 | 何时用 |
|------|------|--------|
| `/opsx:propose` | 一步创建修改+所有规划产物 | 快速默认路径 |
| `/opsx:explore` | 探索想法，不创建任何产物 | 需求不明确时 |
| `/opsx:apply` | 按任务清单实施 | 准备写代码 |
| `/opsx:update` | 修订已有规划产物并保持一致 | 计划中途调整（实验性） |
| `/opsx:sync` | 将增量规格合并到主规格 | 长期修改中途同步（可选，archive 会自动提示） |
| `/opsx:archive` | 归档完成的修改 | 全部工作完成 |

### CLI 逐产物推进

不依赖命令文件时，用 CLI 逐产物推进：

```bash
openspec status --change <name>                    # 查看产物进度和下一产物
openspec instructions <artifact> --change <name>   # 获取该产物的写作指引
openspec templates [--schema <name>]               # 查看各产物模板路径
```

### 平台命令不是流程约束

文档中的 `/opsx:*` 是 OpenSpec 集成示例。若当前平台暴露不同入口，使用等价能力，并保持 proposal、specs、design、tasks、validate 和 archive 的行为不变。

---

## 六、增量规格（Delta Specs）— 关键概念

增量规格描述**变化**而非重写全文，三个段：

```markdown
## ADDED Requirements         → 归档时追加到主规格
### Requirement: 2FA
...

## MODIFIED Requirements      → 归档时替换已有需求
### Requirement: Session Timeout
(Previously: 60 minutes) → 现改为30分钟

## REMOVED Requirements       → 归档时删除
### Requirement: Remember Me
(已弃用)
```

**为什么用增量而非全文：**
- 一目了然看到变化
- 多个修改可并行不冲突
- 审阅效率高

**没有行为变化的修改**：`openspec validate` 拒绝没有 delta 的 change。纯重构、工具或文档类修改在该 change 的 `.openspec.yaml` 中写 `skip_specs: true` 显式豁免，不为通过验证编造需求；归档这类修改时也可用 `openspec archive --skip-specs` 跳过规格合并。

---

## 七、完整生命周期示例

```
/opsx:propose add-dark-mode
  → 创建 changes/add-dark-mode/ + 所有产物

/opsx:apply
  → 按任务清单逐步实施，勾选完成项

/opsx:archive
  → 增量规格合并到 specs/ui/spec.md
  → 修改文件夹移至 archive/2025-01-24-add-dark-mode/
```

---

## 八、项目配置 (`openspec/config.yaml`)

```yaml
schema: spec-driven

context: |                           # 注入到所有产物的指令
  Tech stack: TypeScript, React, Node.js
  Testing: Vitest + Playwright
  我们维护所有公开 API 的向后兼容

rules:                               # 只注入到对应产物
  proposal:
    - 包含回滚方案
  specs:
    - 使用 Given/When/Then 格式
  design:
    - 复杂流程需包含序列图

operations:                          # apply 与 archive 的建议性指导
  apply:
    guidance:
      - 保持测试摘要简短
  archive:
    guidance:
      - 收尾前总结归档结果
```

- **context** → 出现在所有产物生成请求中
- **rules** → 仅出现在对应 artifact 的请求中
- **operations** → apply 和 archive 的建议性指导，与产物 rules 分开
- context 上限 50KB，保持精炼

---

## 九、自定义 Schema（工作流）

```bash
# 查看可用 schema 和解析来源
openspec schemas
openspec schema which spec-driven

# 从现有 schema fork
openspec schema fork spec-driven my-workflow

# 从零创建
openspec schema init rapid --artifacts "proposal,tasks" --default

# 验证
openspec schema validate my-workflow
```

当前包内置 schema 为 `spec-driven`（proposal → specs → design → tasks）。

Schema 结构：
```yaml
name: rapid
artifacts:
  - id: proposal
    generates: proposal.md
    requires: []
  - id: tasks
    generates: tasks.md
    requires: [proposal]
apply:
  requires: [tasks]
  tracks: tasks.md
```

Schema 优先级：CLI flag → 修改元数据 → 项目 config → 默认 `spec-driven`

---

## 十、CLI 常用命令

```bash
# 初始化与更新
openspec init --tools claude --force    # 初始化项目（--tools 指定 AI 工具，--force 跳过交互）
openspec update [--force]               # 刷新 AI 工具配置文件

# 查看状态
openspec list                           # 列出活跃修改
openspec list --specs                   # 列出规格
openspec list --sort name --json        # 按名称排序，JSON 输出
openspec view                           # specs 和 changes 的交互式仪表盘
openspec status --change <name>         # 查看修改的产物完成进度
openspec status --all                   # 所有活跃修改的进度
openspec show <item> --type change      # 查看修改或规格详情
openspec show <item> --diff             # 按 requirement 显示增量差异
openspec spec list | spec show <id> | spec validate <id>
openspec change show <name> | change validate <name>   # change list 已废弃，用 openspec list

# 创建
openspec new change <name> [--schema <name>] [--goal <text>] [--description <text>]

# 验证
openspec validate <item> --type change|spec   # 验证单个修改或规格
openspec validate --specs               # 验证所有规格
openspec validate --changes             # 验证所有修改
openspec validate --all                 # 验证全部
openspec validate --archived --strict   # 检查归档修改的任务全部完成（适合 pre-commit）

# 归档
openspec archive <name>                 # 归档修改并合并增量规格
openspec archive <name> -y              # 跳过确认
openspec archive <name> --skip-specs    # 跳过规格合并（infra、工具或文档类修改）

# AI 与 agent 接口
openspec instructions <artifact> --change <name>   # 输出产物写作指引
openspec templates                      # 显示 schema 各产物的模板路径
openspec schemas                        # 列出可用 schema
openspec context [--json]               # 输出当前 root 的工作上下文
openspec doctor                         # 报告 OpenSpec root 的结构健康

# 配置
openspec config profile [preset]        # 配置工作流 profile（预设只有 core）
openspec config list | get <key> | set <key> <value> | path
```

**⚠️ 常见错误**：
- `openspec init --ai claude` → 错误，应该用 `--tools claude`
- `openspec validate`（无参数无 item）→ 错误，需要 `--specs`、`--changes`、`--all` 或指定 item 名
- `openspec validate spec/architecture` → 错误，应该用 `openspec validate architecture`；change 与 spec 同名歧义时加 `--type`
- `openspec validate --verbose` → 错误，没有 `--verbose` 选项
- `openspec config profile custom` → 错误，profile 预设只有 `core`，自定义组合走交互式 `openspec config profile`
- `openspec instructions proposal` → 错误，必须带 `--change <name>`

---

## 十一、多语言配置

在 `config.yaml` 的 `context` 中加入语言指示：

```yaml
context: |
  语言：中文（简体）
  所有产出物必须用简体中文撰写。
  技术术语如 API、REST 保持英文原样。
```

初始化时也可以用 `openspec init --language "简体中文"` 预设新产物的语言。

---

## 十二、跨仓库工作（store 与 workset）

store 是注册到本机的独立 OpenSpec 仓库：

```bash
openspec store setup <id> --path ~/openspec/<id>   # 创建并注册本地 store
openspec store register <path>                     # 注册已有 OpenSpec 仓库
openspec store list                                # 列出已注册 store
openspec store doctor [<id>]                       # 检查注册和元数据
openspec store unregister <id>                     # 只取消注册，不删文件
openspec store remove <id>                         # 取消注册并删除本地目录
```

注册后，读写 changes 和 specs 的命令用 `--store <id>` 指定根目录：`list`、`view`、`show`、`validate`、`archive`、`status`、`instructions`、`doctor`、`context`、`schemas` 和 `new change`。

workset 保存个人工作视图，纯本地，不触碰成员目录：

```bash
openspec workset create <name> --member <path> [--member <name>=<path>] [--tool <id>]
openspec workset list
openspec workset open <name>    # 在编辑器或 agent 会话中打开
openspec workset remove <name>
```

旧版的 `openspec workspace` 命令已由 `store` 和 `workset` 取代。store 和 workset 都是本地协调视图，不是实施产物的存放地。

---

## 十三、何时更新 vs 新建修改

| 场景 | 操作 |
|------|------|
| 同意图，微调执行 | **更新**现有修改（`/opsx:update`） |
| 范围缩小（先做 MVP） | **更新**然后归档，再新建下一阶段 |
| 意图根本变了 | **新建**修改 |
| 范围膨胀超50% | **新建**修改 |
| 原修改可独立完成 | 归档原修改 → **新建**后续 |

---

## 十四、常见问题速查

| 问题 | 解决 |
|------|------|
| 命令不被识别 | `openspec init` + `openspec update`，重启 IDE |
| 产物生成不理想 | 在 `config.yaml` 加更多 context/rules，或改用 CLI 逐产物推进（`status` + `instructions`） |
| Schema 未找到 | `openspec schemas` 查看可用列表 |
| 配置不生效 | 确认是 `config.yaml`（非 `.yml`），检查 YAML 语法 |
| 修改找不到 | 用 `openspec list` 确认存在，或显式指定 `/opsx:apply <name>` |
| 结构关系可疑 | `openspec doctor` 报告 OpenSpec root 的健康状态 |

---

## 十五、从旧版迁移

```bash
openspec init    # 或 openspec update
# 自动检测并清理旧文件，保留用户内容
# 旧 project.md → 手动迁移到 config.yaml，然后删除
```

旧命令映射：`/openspec:proposal` → `/opsx:propose`；`openspec workspace` → `store` 与 `workset`。
