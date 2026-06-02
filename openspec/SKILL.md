---
name: openspec
description: OpenSpec 是一个 **AI 协作规范工具**，让人类和 AI 编码助手在写代码之前先就"要建什么"达成一致。核心理念：
---
# OpenSpec 精简使用手册

## 一、什么是 OpenSpec


| 原则 | 含义 |
|------|------|
| **fluid not rigid** | 没有阶段门控，随时可以做任何操作 |
| **iterative not waterfall** | 边建边学，逐步改进 |
| **easy not complex** | 轻量设置，最少仪式 |
| **brownfield-first** | 优先适配已有代码库的增量修改 |

---

## 二、核心结构

```
openspec/
├── specs/              ← 行为真相源（系统当前行为的描述）
│   └── <domain>/
│       └── spec.md
├── changes/            ← 提议修改（每个修改一个文件夹）
│   └── <change-name>/
│       ├── proposal.md     ← 为什么做、做什么
│       ├── specs/          ← 增量规格（ADDED/MODIFIED/REMOVED）
│       ├── design.md       ← 技术方案
│       ├── tasks.md        ← 实施清单
│       └── .openspec.yaml  ← 元数据
└── config.yaml             ← 项目配置
```

**两个关键目录：**
- `specs/` — 系统当前行为的真相源
- `changes/` — 提议的修改，完成后归档合并回 `specs/`

---

## 三、快速开始

```bash
# 1. 安装（需要 Node.js ≥ 20.19.0）
npm install -g @fission-ai/openspec@latest

# 2. 在项目中初始化
cd your-project
openspec init

# 3. 验证安装
openspec --version
```

初始化时选择你的 AI 工具（Claude Code、Cursor、Windsurf 等 30+ 种），生成 skills/commands 配置文件。

---

## 四、工作流（两种模式）

### 🏃 默认快速路径（`core` profile）

```
/opsx:propose → /opsx:apply → /opsx:sync → /opsx:archive
```

**最适合大多数场景，一键到完成。**

### 🧭 扩展路径（需手动开启）

```bash
openspec config profile    # 选择 custom
openspec update            # 应用变更
```

新增命令：`/opsx:new`、`/opsx:continue`、`/opsx:ff`、`/opsx:verify`、`/opsx:bulk-archive`、`/opsx:onboard`

---

## 五、命令速查

### 核心命令（默认可用）

| 命令 | 用途 | 何时用 |
|------|------|--------|
| `/opsx:propose` | 一步创建修改+所有规划产物 | 快速默认路径 |
| `/opsx:explore` | 探索想法，不创建任何产物 | 需求不明确时 |
| `/opsx:apply` | 按任务清单实施 | 准备写代码 |
| `/opsx:sync` | 将增量规格合并到主规格 | 长期修改中途同步（可选，archive 会自动提示） |
| `/opsx:archive` | 归档完成的修改 | 全部工作完成 |

### 扩展命令（需开启）

| 命令 | 用途 | 何时用 |
|------|------|--------|
| `/opsx:new` | 创建修改骨架 | 想逐步控制产物生成 |
| `/opsx:continue` | 逐一创建下一个产物 | 复杂修改，想审阅每步 |
| `/opsx:ff` | 快进：一次创建所有规划产物 | 范围明确，想快速推进 |
| `/opsx:verify` | 验证实施是否匹配规格 | 归档前的质量检查 |
| `/opsx:bulk-archive` | 批量归档多个完成修改 | 并行工作流完成后 |
| `/opsx:onboard` | 引导式教程 | 新用户首次使用 |

### 不同工具的语法

| 工具 | 语法 |
|------|------|
| Claude Code | `/opsx:propose` |
| Cursor/Windsurf | `/opsx-propose` |
| Copilot IDE | `/opsx-propose` |
| Kimi/Trae | `/skill:openspec-propose` |

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
```

- **context** → 出现在所有产物生成请求中
- **rules** → 仅出现在对应 artifact 的请求中
- context 上限 50KB，保持精炼

---

## 九、自定义 Schema（工作流）

```bash
# 从现有 schema fork
openspec schema fork spec-driven my-workflow

# 从零创建
openspec schema init rapid --artifacts "proposal,tasks" --default

# 验证
openspec schema validate my-workflow
```

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
openspec list                    # 列出活跃修改
openspec list --specs            # 列出规格
openspec show add-dark-mode      # 查看修改详情
openspec validate --changes      # 验证所有修改
openspec status --change <name>  # 查看产物进度
openspec schemas                 # 列出可用 schema
openspec archive <name>          # 归档修改
openspec config profile          # 配置工作流 profile
openspec update                  # 刷新 AI 工具配置文件
```

---

## 十一、多语言配置

在 `config.yaml` 的 `context` 中加入语言指示：

```yaml
context: |
  语言：中文（简体）
  所有产出物必须用简体中文撰写。
  技术术语如 API、REST 保持英文原样。
```

---

## 十二、Workspace 协调（Beta）

跨多个 repo/文件夹工作时使用：

```bash
openspec workspace setup                                 # 交互式创建
openspec workspace setup --name platform --link /repos/api  # 非交互
openspec workspace list                                  # 列出 workspace
openspec workspace doctor                                # 检查健康状态
openspec workspace open                                  # 打开工作集
```

Workspace 是本地协调视图，不是实施产物的存放地。

---

## 十三、何时更新 vs 新建修改

| 场景 | 操作 |
|------|------|
| 同意图，微调执行 | **更新**现有修改 |
| 范围缩小（先做 MVP） | **更新**然后归档，再新建下一阶段 |
| 意图根本变了 | **新建**修改 |
| 范围膨胀超50% | **新建**修改 |
| 原修改可独立完成 | 归档原修改 → **新建**后续 |

---

## 十四、常见问题速查

| 问题 | 解决 |
|------|------|
| 命令不被识别 | `openspec init` + `openspec update`，重启 IDE |
| 产物生成不理想 | 在 `config.yaml` 加更多 context/rules，或用 `/opsx:continue` 替代 `/opsx:ff` |
| Schema 未找到 | `openspec schemas` 查看可用列表 |
| 配置不生效 | 确认是 `config.yaml`（非 `.yml`），检查 YAML 语法 |
| 修改找不到 | 用 `openspec list` 确认存在，或显式指定 `/opsx:apply <name>` |

---

## 十五、从旧版迁移

```bash
openspec init    # 或 openspec update
# 自动检测并清理旧文件，保留用户内容
# 旧 project.md → 手动迁移到 config.yaml，然后删除
```

旧命令映射：`/openspec:proposal` → `/opsx:propose`
