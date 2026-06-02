---
name: openspec-init
description: 项目初始化器 - 整合 Karpathy Guidelines、务实编码原则、Workflow Designer 三大规则体系，初始化 OpenSpec 项目结构（specs/ + changes/），生成 CLAUDE.md 索引和 .claude/docs/ 状态文档。TRIGGER when: 用户说"初始化项目"、"设置规则"、"创建 CLAUDE.md"、"初始化 OpenSpec"、"给项目设置规范"等。
---

# OpenSpec Init — 项目初始化器

**三大规则体系整合 + OpenSpec 初始化 + CLAUDE.md 生成**

禁止把 claude 在 git 提交的时候列为 coworker，不准设置共同创作者

在 plan 阶段进行计划 write plan 写入的时候请分步计划和写入，避免一次性思考和输出太长导致被截断

---

## 功能概述

```
调用此 skill 时：
  1. 检测是否已安装 OpenSpec，未安装则提示安装
  2. 初始化 OpenSpec 项目结构（openspec/ 目录）
  3. 生成 openspec/config.yaml（项目配置）
  4. 初始化 specs/ 目录结构（5 个 domain）
  5. 生成 CLAUDE.md（索引 OpenSpec + .claude/docs/）
  6. 初始化 .claude/docs/ 状态文档（SNAPSHOT.md + tasks.md）
  7. 可选：根据项目类型定制规则强度
  8. 若已存在则提示用户是否确认更新
```

---

## 执行流程

### Phase 0: 环境检查

```
Step 1 — 检查 OpenSpec:
  运行: openspec --version
  → 已安装: 记录版本，继续
  → 未安装: 提示用户安装:
    npm install -g @fission-ai/openspec@latest
    等待用户确认安装完成

Step 2 — 检查项目状态:
  检测 openspec/ 目录是否已存在
  检测 .claude/docs/ 目录是否已存在
  检测 CLAUDE.md 是否已存在
  → 已存在: 提示用户是否覆盖/合并
```

### Phase 1: 项目分析

```
扫描项目：
  1. 检测项目类型（Python/JS/Go/Rust/Mixed）
  2. 检测项目规模（小型/中型/大型）
  3. 检测技术栈（语言、框架、测试工具、格式化工具）
  4. 检测 git 状态（分支、最近提交、未提交更改）
  5. 检测现有文档（README.md、docs/、.claude/docs/）
  6. 分析源码目录结构
```

### Phase 2: 生成 OpenSpec 配置

```
Step 1 — 初始化 OpenSpec:
  运行: openspec init
  选择 AI 工具: Claude Code

Step 2 — 生成 config.yaml:
  根据项目分析结果生成配置：
  - schema: spec-driven
  - context: 技术栈 + 语言偏好 + 项目约束
  - rules: 各产物的生成规则

Step 3 — 验证配置:
  运行: openspec validate
```

### Phase 3: 初始化 specs/ 目录

```
创建 openspec/specs/ 目录结构，生成 5 个 domain 的 spec.md：

  1. architecture/spec.md — 架构决策记录
     - 从项目分析中提取现有架构决策
     - ADR 格式: ### {DATE} - {决策标题}
     - 每条含：决策、原因、影响、替代方案

  2. rules/spec.md — 编码规范
     - 整合三大规则体系（Karpathy、务实编码、Workflow Designer）
     - 根据项目类型定制规范强度
     - 包含项目特定约束（命名、测试、提交规范）

  3. learned/spec.md — 学习记忆
     - 初始化为空模板
     - 包含分类：API路径、文件速查、踩坑档案、技巧模式、依赖关系图、待探索
     - 条目格式: <!-- L{编号} -->

  4. references/spec.md — 外部参考
     - 从 package.json/Cargo.toml 等提取依赖信息
     - 初始化依赖文档表格
     - 包含领域知识笔记区

  5. optimization/spec.md — 优化记录
     - 初始化为空模板
     - 条目格式: <!-- O{编号} --> - {描述}
```

### Phase 4: 生成状态文档

```
创建 .claude/docs/ 目录，生成 2 个状态文档：

  1. SNAPSHOT.md — 项目状态快照
     - 项目结构树
     - 技术栈表格
     - Git 状态
     - 关键文件表格
     - 当前工作（从现有 tasks.md 迁移，如有）

  2. tasks.md — 全局任务追踪
     - 进行中区域
     - 待办区域
     - 阻塞项区域
     - 与 changes/ 同步说明
```

### Phase 5: 生成 CLAUDE.md

```
生成 CLAUDE.md 作为项目入口索引：

  内容包含：
  1. 项目概览（从 README.md 提取或生成）
  2. 文档体系表格（OpenSpec specs/ + .claude/docs/）
  3. 读取顺序表格（按场景）
  4. 检查清单（提交前确认）
  5. Red Flags（违规检查）

  关键原则：
  - CLAUDE.md 只做索引，不重复规则全文
  - 规则全文只在 openspec/specs/rules/spec.md
  - 指向 OpenSpec 和 .claude/docs/ 的具体路径
```

---

## config.yaml 生成模板

```yaml
schema: spec-driven

context: |
  Tech stack: {检测到的技术栈}
  Language: {主要语言} {版本}
  Testing: {测试框架}
  Formatting: {格式化工具}
  所有产出物必须用简体中文撰写。
  技术术语如 API、REST 保持英文原样。

rules:
  proposal:
    - 包含回滚方案
    - 说明为什么做、做什么、不做什么
    - 标注影响范围
  specs:
    - 使用 Given/When/Then 格式描述行为
    - 每个 spec.md 包含版本号和最后更新日期
    - 变更时使用 Delta Specs（ADDED/MODIFIED/REMOVED）
  design:
    - 复杂流程需包含序列图
    - 标注关键依赖关系
    - 包含备选方案对比
  tasks:
    - 每个任务可独立验证
    - 标注依赖关系
    - 包含验收标准
```

---

## specs/ 初始化模板

### architecture/spec.md

```markdown
# Architecture — 架构决策记录

> 由 openspec-init 初始化，由 openspec-assistant 日常维护。
> 条目格式: <!-- A{编号} --> ### {DATE} - {决策标题}
> 每条含：决策、原因、影响、替代方案。

---

## 决策列表

<!-- 添加时格式: <!-- A{编号} --> ### {DATE} - {决策标题} -->

{从项目分析中提取的初始 ADR，如技术栈选型等}

---

## 架构原则

{从 rules/spec.md 中提取的架构相关原则}
```

### rules/spec.md

```markdown
# Rules — 编码规范

> 由 openspec-init 初始化，由 openspec-assistant 日常维护。
> 这是三大规则的唯一事实来源。CLAUDE.md 只做索引。

---

## Karpathy Guidelines

{Karpathy 四原则完整内容}

---

## 务实编码原则

{十大铁律完整内容}

---

## Workflow Designer

{Phase/Gate/Task/Loop 核心概念}

---

## 项目特定规范

### 命名规范

{根据项目语言生成}

### 代码结构

{根据项目框架生成}

### 测试规范

{根据项目测试框架生成}

### 提交规范

{根据项目 git 配置生成}

---

## Red Flags

{违规检查清单}
```

### learned/spec.md

```markdown
# Learned — 学习记忆

> 由 openspec-init 初始化，由 openspec-assistant 日常维护。
> 条目格式: <!-- L{编号} --> 标记开头，支持 grep 精确定位。

---

## API 路径

<!-- 添加时格式: <!-- L{编号} --> | 名称 | 路径 | 用途 | 时间 | -->

## 文件速查

<!-- 添加时格式: <!-- L{编号} --> | 名称 | 路径 | 用途 | 时间 | -->

## 踩坑档案

<!-- 添加时格式: <!-- L{编号} --> ### [{问题标题}] 后跟症状→根因→解决 -->

## 技巧模式

<!-- 添加时格式: <!-- L{编号} --> ### [{技巧标题}] 后跟描述 -->

## 依赖关系图

<!-- 添加时格式: <!-- L{编号} --> 关键依赖间的调用/依赖关系 -->

## 待探索

<!-- 添加时格式: <!-- L{编号} --> - {待探索项} -->
```

### references/spec.md

```markdown
# References — 外部参考与依赖

> 由 openspec-init 初始化，由 openspec-assistant 日常维护。
> 条目格式: <!-- R{编号} --> 标记开头，支持 grep 精确定位。

---

## 依赖文档

<!-- 添加时格式: <!-- R{编号} --> | 依赖 | 版本 | 链接 | 用途 | -->

{从 package.json/Cargo.toml 等提取的依赖列表}

---

## 领域知识笔记

<!-- 添加时格式: <!-- R{编号} --> 笔记内容 -->

---

## 项目分析文档

<!-- 由 openspec-explorer 写入，由 openspec-assistant 日常维护，由 openspec-archivist 周期清理。 -->
<!-- 添加时格式: <!-- R{编号} --> | 主题 | 路径 | 内容概要 | -->
```

### optimization/spec.md

```markdown
# Optimization — 优化记录

> 由 openspec-init 初始化，由 openspec-assistant 日常维护。
> 条目格式: <!-- O{编号} --> - {问题描述}
> 每条含当前影响、建议方案。

---

## 待优化

<!-- 添加时格式: <!-- O{编号} --> - {问题描述} -->

## 已完成

<!-- 完成后移到此处，标注完成日期 -->
```

---

## CLAUDE.md 生成模板

```markdown
# CLAUDE.md - 项目文档索引

> Generated by openspec-init at {TIMESTAMP}
> Project: {PROJECT_NAME}
> Type: {PROJECT_TYPE}

---

## 项目概览

{从 README.md 提取或生成的简要描述}

---

## 文档体系

### OpenSpec（需求规范管理）

| 目录 | 用途 | 查询方式 |
|------|------|----------|
| `openspec/specs/architecture/` | 架构决策记录 | `grep "关键词" openspec/specs/architecture/spec.md` |
| `openspec/specs/rules/` | 编码规范 | `grep "关键词" openspec/specs/rules/spec.md` |
| `openspec/specs/learned/` | 学习记忆 | `grep "关键词" openspec/specs/learned/spec.md` |
| `openspec/specs/references/` | 外部参考 | `grep "关键词" openspec/specs/references/spec.md` |
| `openspec/specs/optimization/` | 优化点 | `grep "关键词" openspec/specs/optimization/spec.md` |
| `openspec/changes/` | 变更提案 | `openspec list` |

### 项目状态（日常维护）

| 文档 | 用途 | 查询方式 |
|------|------|----------|
| `.claude/docs/SNAPSHOT.md` | 项目状态快照 | `grep "关键词" .claude/docs/SNAPSHOT.md` |
| `.claude/docs/tasks.md` | 任务追踪 | `grep "关键词" .claude/docs/tasks.md` |
| `.claude/analysis/` | 深度分析文档 | `ls .claude/analysis/` |

---

## 读取顺序

| 场景 | 读取 | 写入 |
|------|------|------|
| 开始新会话 | CLAUDE.md → SNAPSHOT.md → tasks.md | — |
| 写新功能 | specs/rules/ + specs/architecture/ + specs/learned/ | tasks.md, specs/learned/ |
| 修复 Bug | specs/rules/ + SNAPSHOT.md + specs/learned/ | tasks.md, specs/learned/ |
| 重构 | specs/architecture/ + specs/optimization/ | specs/architecture/ |
| 记录决策 | specs/architecture/ | specs/architecture/ |
| 创建变更 | /opsx:explore 或 /opsx:propose | openspec/changes/ |

---

## OpenSpec 命令

| 命令 | 用途 | 何时用 |
|------|------|--------|
| `/opsx:propose` | 一步创建修改+所有规划产物 | 快速默认路径 |
| `/opsx:explore` | 探索想法，不创建产物 | 需求不明确时 |
| `/opsx:apply` | 按任务清单实施 | 准备写代码 |
| `/opsx:archive` | 归档完成的修改 | 全部工作完成 |

---

## 检查清单

每次提交前确认:

- [ ] 命名清晰，揭示意图
- [ ] 函数 < 20行，单一职责
- [ ] 无重复代码
- [ ] 无魔法数字/字符串
- [ ] 依赖显式注入
- [ ] 核心逻辑有测试覆盖
- [ ] 注释解释"为什么"
- [ ] 已运行格式化和静态分析
- [ ] 代码比来时更干净
- [ ] 只改必须改的代码
- [ ] 不添加未要求的功能

---

## Red Flags

```
❌ 假设不明确 → STOP，问
❌ 过度复杂 → 简化
❌ 改动超出请求 → 回滚
❌ 无测试变更代码 → Iron Law 违规
❌ 顺手添加功能 → Karpathy 违规
❌ Gate BLOCK 不记录 → Workflow 违规
```
```

---

## 三大规则体系

### 一、Karpathy Guidelines（行为约束）

```markdown
## Karpathy Guidelines

行为准则，减少 LLM 编码常见错误。

### 1. Think Before Coding

**不假设。不隐藏困惑。暴露权衡。**

实现前：
- 明确陈述假设，不确定就问
- 多种解读存在时，全部呈现 - 不 silently 选择
- 更简单的方法存在时，说出来。必要时 push back
- 不清楚时，STOP。命名困惑点。问。

### 2. Simplicity First

**最小代码解决问题。无投机性功能。**

- 不添加未被要求的功能
- 单次使用代码不抽象
- 未要求的"灵活性"或"可配置性"不加
- 不可能场景的错误处理不加
- 200 行能减到 50 行，重写

问自己："资深工程师会说这过度复杂吗？" 是 → 简化

### 3. Surgical Changes

**只改必须改。只清理自己的烂摊子。**

编辑现有代码：
- 不"改进"相邻代码、注释、格式
- 不重构没坏的东西
- 匹配现有风格，即使你做法不同
- 注意到无关死代码，提及 - 不删除

改动创建孤儿时：
- 删除 YOUR 改动导致未用的 import/变量/函数
- 不删除先前存在的死代码（除非被要求）

测试：每行改动应直接追溯到用户请求

### 4. Goal-Driven Execution

**定义成功标准。循环直到验证。**

将任务转化为可验证目标：
- "添加验证" → "写无效输入测试，然后让它们通过"
- "修复 bug" → "写复现它的测试，然后让它通过"
- "重构 X" → "确保前后测试都通过"

多步任务，简述计划：
```
1. [步骤] → verify: [检查]
2. [步骤] → verify: [检查]
3. [步骤] → verify: [检查]
```

强成功标准 → 可独立循环。弱标准需要不断澄清。
```

---

### 二、务实编码原则（代码质量）

```markdown
## 务实编码原则

整洁代码与务实原则的软件工匠准则。

### 十大铁律

#### 1. 命名即文档

使用精准、可读、可搜索的名称。

- 名称揭示意图，非实现细节
- 避免缩写、单字母变量（循环计数器除外）
- 使用领域语言，与业务术语一致
- 布尔值用 `is`、`has`、`can`、`should` 开头
- 集合用复数形式

#### 2. 函数单一职责

短小、只做一件事、无副作用。

- 函数长度：理想 < 20行，最多不超过一屏
- 只做一件事，做好它
- 无副作用：不修改输入参数
- 抽象层级一致

#### 3. DRY & 正交性

消除重复，保持模块独立。

- 三次法则：复制两次后，第三次必须抽象
- 正交性：一个模块的改变不应影响其他模块
- 业务逻辑与基础设施分离

#### 4. 显式胜于隐式

依赖注入优于隐藏依赖。

- 依赖通过参数或构造函数显式传入
- 常量命名：用 `MAX_RETRY_COUNT` 而非 `5`
- 避免全局状态和隐式上下文

#### 5. 健壮边界

通过接口与抽象隔离业务核心。

- 高层模块不依赖低层模块，都依赖抽象
- 外部依赖通过接口封装
- 核心业务逻辑与框架解耦

#### 6. 可测试设计

每个单元必须可独立测试。

- 纯函数优于有状态函数
- 依赖可注入，便于 mock
- TDD：先写失败测试，再写实现

#### 7. 尽早重构

持续小步重构消除技术债务。

- 看到坏味道立即重构
- 小步重构：每次改动可独立测试
- 每次提交让代码比之前更好

#### 8. 务实破窗

不容忍劣化代码，及时修复。

- 看到问题立即修复，不留给"以后"
- 曳光弹：先实现端到端最小可用功能，再完善
- 避免过度设计，解决当前问题

#### 9. 自动化检查

始终运行格式化、静态分析与测试。

- 提交前运行格式化工具
- 静态分析检测潜在问题
- 测试覆盖核心逻辑

#### 10. 注释解释意图

只注释"为什么"，不注释"做什么"。

- 好代码是自文档的
- 注释解释非显而易见的决策
- 过时注释比无注释更糟
```

---

### 三、Workflow Designer（流程框架）

```markdown
## Workflow Designer

工作流概念框架，定义执行流程。

### 四个核心概念

#### Phase（阶段）

逻辑分组的工作容器。

- 有明确的进入条件和退出条件
- 内部包含多个 task、gate、loop
- 状态：pending → in_progress → blocked → completed

#### Gate（门控）

检查点，决定是否可以进入下一阶段。

- 有明确的检查条件（checklist）
- 结果：PASS 或 BLOCK
- BLOCK 时必须记录原因
- 类型：auto_check / user_approval / evidence_required

#### Task（任务）

最小执行单元。

- 有明确的输入和输出
- 可独立验证完成状态
- 受 Gate 控制
- 完成必须展示证据

#### Loop（循环）

重复处理机制。

- 有明确的循环条件和退出条件
- 类型：clarification / review-fix / iteration / retry

### 执行铁律

```
1. Phase 进入前必须 Gate PASS
2. Task 开始前必须 Gate PASS
3. Task 完成必须展示证据
4. Loop 退出必须条件 PASS
5. Gate BLOCK 必须记录原因
6. 声明完成必须验证证据
```

### 工具映射

| 概念 | 工具 | 实现方式 |
|------|------|----------|
| Phase 状态 | TodoWrite | 标记 phase 名称和状态 |
| Gate 检查 | AskUserQuestion + 检查 | 定义检查项，逐项验证 |
| Task 标记 | TodoWrite | 标记 task 描述和状态 |
| Loop 控制 | 条件判断 | 在规则中定义循环条件 |
| 并行执行 | Agent (subagent) | spawn 多个 subagent |
| 验证证据 | Bash + 输出展示 | 执行命令，展示片段 |
```

---

## 与旧体系的迁移

### 从 .claude/docs/ 迁移到 OpenSpec

如果项目已有 `.claude/docs/` 文档体系：

```
迁移映射：
  .claude/docs/architecture.md → openspec/specs/architecture/spec.md
  .claude/docs/rules.md → openspec/specs/rules/spec.md
  .claude/docs/learned.md → openspec/specs/learned/spec.md
  .claude/docs/references.md → openspec/specs/references/spec.md
  .claude/docs/optimization.md → openspec/specs/optimization/spec.md
  .claude/docs/SNAPSHOT.md → 保留（不迁移）
  .claude/docs/tasks.md → 保留（不迁移）
  .claude/docs/archive.md → 废弃（用 openspec archive 替代）

迁移步骤：
  1. 读取现有 .claude/docs/ 文档
  2. 提取内容，按 OpenSpec 格式写入 specs/
  3. 保留 .claude/docs/SNAPSHOT.md 和 tasks.md
  4. 删除已迁移的文档（可选，或保留为备份）
  5. 更新 CLAUDE.md 索引
```

---

## 项目分析检查项

```
扫描项目时检查：

文件结构：
  - [ ] 项目根目录
  - [ ] 源码目录
  - [ ] 测试目录
  - [ ] 配置文件
  - [ ] 文档目录

技术栈检测：
  - [ ] package.json / requirements.txt / Cargo.toml / go.mod
  - [ ] 语言版本
  - [ ] 框架/库
  - [ ] 测试框架
  - [ ] 格式化/lint 工具

Git 状态：
  - [ ] 是否 git repo
  - [ ] 当前分支
  - [ ] 最近提交
  - [ ] 未提交更改

现有规则与文档：
  - [ ] 是否有 CLAUDE.md
  - [ ] 是否有 openspec/ 目录
  - [ ] 是否有 .claude/docs/ 目录
  - [ ] 是否有 README.md
  - [ ] 是否有其他规则文件
```

---

## Key Principles

```
三大规则整合到 openspec/specs/rules/spec.md（唯一事实来源）
CLAUDE.md 只做索引，不重复规则内容
初始化 OpenSpec 项目结构（specs/ + changes/）
项目类型适配
规则强度可调
generator 只负责初始化，日常维护交给 assistant
与 OpenSpec CLI 命令无缝集成
```

---

## Red Flags

```
❌ 项目无 CLAUDE.md → 规则缺失
❌ openspec/ 目录不存在 → OpenSpec 未初始化
❌ specs/ 中缺少 domain → 初始化不完整
❌ rules/spec.md 内容与 CLAUDE.md 重复 → CLAUDE.md 应只做索引
❌ SNAPSHOT.md 过时 → 状态不同步（日常由 assistant 维护）
❌ 规则与项目类型不匹配 → 约束无效
❌ 技术决策未记录 → 决策丢失
❌ 阻塞点未记录 → 问题丢失
❌ OpenSpec 未安装 → 环境缺失
❌ config.yaml 缺失 → OpenSpec 配置不完整
```
