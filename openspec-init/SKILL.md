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
  5. 生成 CLAUDE.md（**包含完整规则**：索引 OpenSpec + 三大规则 + 技能执行规则）
  6. 初始化 .claude/docs/ 状态文档（SNAPSHOT.md + tasks.md）
  7. 可选：根据项目类型定制规则强度
  8. 若已存在则提示用户是否确认更新
```

---

## 执行流程

### Phase 0: 环境检查

```
（**Phase 0 任务化铁律**: 4 个 Step 必须各自 TaskCreate 任务化，每 Step 独立 Task，不允许合并。
  每个 Task 完成必须含: 命令名 + 关键输出摘录。无证据 = 未完成。）

Step 1 — 检查 OpenSpec:
  运行: openspec --version
  → 已安装: 记录版本，继续
  → 未安装: 提示用户安装:
    npm install -g @fission-ai/openspec@latest
    等待用户确认安装完成
  ❌ "openspec 已存在 = Phase 0 完成" → 错误，每 Step 独立检查

Step 2 — 检查 CodeGraph（**对源码项目强制执行**）:
  ⚠️ 源码项目判定（命中任一即视为源码项目）:
    - 目录: src/、lib/、pkg/、kernel/、app/、cmd/、internal/、core/、source/、sources/、packages/
    - 或含: .py/.ts/.tsx/.js/.jsx/.rs/.go/.java/.cpp/.c/.h/.swift/.kt/.cs/.rb/.php/.scala 源码文件

  ⚠️ 本步对源码项目 = "必须"。未执行 = Phase 0 未完成 = **禁止进入 Phase 1**。
  ⚠️ "未安装" 不是豁免理由，必须立即安装。
  ⚠️ "已存在 .codegraph/" 不是跳过理由，必须 init 验证 healthy。

  运行: codegraph --version（或 which codegraph）
  → 已安装: 记录版本号 → 继续 Step 3
  → 未安装: **必须立即执行安装**（不允许仅"提示用户后等"）:
    curl -fsSL https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.sh | sh
  安装完成后必须再次运行 `codegraph --version` 验证安装成功
  验证成功才视为本步完成
  ❌ "建议用户安装" / "未检测" 作为跳过项 → 错误，必须实际安装

Step 3 — 检查项目状态（**每项独立检测**，禁止用"已存在"概括）:
  ⚠️ "目录已存在" ≠ "本项已检查"。每项必须独立运行检查命令。

  3.1 openspec/ 目录: `test -d openspec && echo "存在" || echo "缺失"`
  3.2 .claude/docs/ 目录: `test -d .claude/docs && echo "存在" || echo "缺失"`
  3.3 .codegraph/ 目录（CodeGraph 索引）: `test -d .codegraph && echo "存在" || echo "缺失"`
  3.4 CLAUDE.md: `test -f CLAUDE.md && echo "存在" || echo "缺失"`

  → 任一存在: 记录状态 + 提示用户是否覆盖/合并
  → 任一缺失: 记录为 "待创建"（不豁免后续创建步骤）
  ❌ "用 ls 代替 test -d/f" → 错误，必须独立运行检查命令

Step 4 — 源码项目 + CodeGraph 索引初始化（**强制**，禁用"建议"一词）:
  ⚠️ 本步对源码项目 = "必须"。"建议" 一词在本步视为禁用。
  ⚠️ "已存在 .codegraph/" 不是跳过理由。必须 init 验证健康状态。
  ⚠️ 索引 unhealthy = 重新 init（最多 3 次），禁止"先继续后面修"。

  检测: 复用 Step 2 源码项目判定逻辑
  → 源码项目: **必须执行** `codegraph init -i`
  → 索引建好后: **必须执行** `codegraph status` 验证显示 healthy
  → 状态非 healthy: 重新 init，最多 3 次
  → 非源码项目: 记录"无源码"判定证据，跳过（必须含判定命令输出）
  ❌ "建议运行 codegraph init" → 错误，必须运行并验证
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
  运行: openspec init --tools claude --force
  注意：
    - 使用 --tools（不是 --ai）
    - 使用 --force 跳过交互式选择
    - 不加 --force 会阻塞等待用户输入

Step 2 — 生成 config.yaml:
  根据项目分析结果生成配置：
  - schema: spec-driven
  - context: 技术栈 + 语言偏好 + 项目约束
  - rules: 各产物的生成规则

Step 3 — 验证配置:
  运行: openspec validate --specs
  注意：
    - validate 必须带子参数：--all, --changes, 或 --specs
    - 验证单个 spec: openspec validate architecture（不带 spec/ 前缀）
    - 没有 --verbose 选项
```

### Phase 3: 初始化 specs/ 目录

```
创建 openspec/specs/ 目录结构，生成 5 个 domain 的 spec.md：

  ⚠️ 重要：OpenSpec 验证器要求 spec 必须包含以下结构：
     - ## Purpose — 简要目的描述
     - ## Requirements — 需求列表
     - ### Requirement: {名称} — 每个需求
     - #### Scenario: {场景名} — 每个需求的场景
     - WHEN/THEN 条件 — 场景的具体行为

  1. architecture/spec.md — 架构决策记录
     - 从项目分析中提取现有架构决策
     - 使用 OpenSpec 标准格式（Purpose + Requirements + Scenario）

  2. ~~rules/spec.md~~（已废弃） — 规则已整合到 CLAUDE.md
     - 不再单独生成 rules domain
     - 规则全文在 CLAUDE.md 的"规则"章节

  3. learned/spec.md — 学习记忆
     - 初始化为空模板
     - 包含分类：API路径、文件速查、踩坑档案、技巧模式
     - 使用 OpenSpec 标准格式

  4. references/spec.md — 外部参考
     - 从 package.json/Cargo.toml 等提取依赖信息
     - 初始化依赖文档表格
     - 使用 OpenSpec 标准格式

  5. optimization/spec.md — 优化记录
     - 初始化为空模板
     - 使用 OpenSpec 标准格式
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
  - CLAUDE.md 同时承担 **文档索引** + **规则唯一事实来源** 两个角色
  - 所有规则都内嵌在 CLAUDE.md（不再单独维护 rules domain）
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

⚠️ **OpenSpec 验证器要求格式**：
每个 spec 必须包含 `## Purpose` + `## Requirements` + `### Requirement:` + `#### Scenario:` + `WHEN/THEN` 结构。

### architecture/spec.md

```markdown
## Purpose

定义项目的架构决策和设计原则，指导开发过程中的技术选型和系统设计。

## Requirements

### Requirement: 架构决策记录

所有重要的架构决策 SHALL 以 ADR（Architecture Decision Record）形式记录，包含决策内容、原因、影响和替代方案。

#### Scenario: 记录新决策

- **WHEN** 开发者做出影响系统架构的决策（如选择数据库、设计模块边界、确定通信协议）
- **THEN** 必须创建新的 ADR 条目，包含：决策标题、决策内容、决策原因、影响范围、替代方案

#### Scenario: 查询已有决策

- **WHEN** 开发者需要了解某个架构选择的原因
- **THEN** 可以通过 grep 搜索 decision 标题或关键词快速定位相关 ADR

### Requirement: 架构原则遵循

所有架构设计 SHALL 遵循项目定义的架构原则。

#### Scenario: 评估设计方案

- **WHEN** 开发者提出新的设计方案
- **THEN** 方案必须符合架构原则（如 SOLID、DRY、关注点分离），不符合时需说明理由

### Requirement: 模块边界清晰

系统模块之间 SHALL 有清晰的边界和接口定义。

#### Scenario: 新增模块依赖

- **WHEN** 模块 A 需要依赖模块 B
- **THEN** 必须通过明确定义的接口交互，禁止直接访问内部实现
```

### rules/spec.md

```markdown
## Purpose

定义项目的编码规范和开发流程，确保代码质量和团队协作效率。

## Requirements

### Requirement: 命名规范

所有代码标识符 SHALL 遵循命名规范，确保可读性和一致性。

#### Scenario: 命名变量和函数

- **WHEN** 开发者创建新的变量、函数或类
- **THEN** 名称必须清晰揭示意图，避免缩写，布尔值用 is/has/can/should 开头

### Requirement: 函数单一职责

每个函数 SHALL 只做一件事，保持简短。

#### Scenario: 编写函数

- **WHEN** 开发者编写或重构函数
- **THEN** 函数长度不超过 20 行，无副作用，抽象层级一致

### Requirement: 测试覆盖

核心业务逻辑 SHALL 有测试覆盖。

#### Scenario: 实现新功能

- **WHEN** 开发者实现新的业务逻辑
- **THEN** 必须编写对应的单元测试，测试通过后才能提交

### Requirement: 代码审查

所有代码变更 SHALL 经过审查。

#### Scenario: 提交代码

- **WHEN** 开发者完成代码变更
- **THEN** 必须运行格式化工具和静态分析，确保无警告后才能提交

### ~~rules/spec.md~~（已废弃）

```
⚠️ rules/spec.md 已废弃！规则已整合到 CLAUDE.md。

如需查看或修改项目规则：
  1. 读取 CLAUDE.md 的"# 规则"章节
  2. 不再生成或维护 openspec/specs/rules/ 目录
  3. 历史迁移：原 rules.md → CLAUDE.md 规则章节
```

### learned/spec.md

```markdown
## Purpose

记录项目开发过程中学到的知识，避免重复探索，加速问题解决。

## Requirements

### Requirement: API 路径记录

项目中使用的关键 API 路径 SHALL 记录，包含用途和使用示例。

#### Scenario: 发现新 API

- **WHEN** 开发者发现或使用了新的 API 端点
- **THEN** 必须记录到 learned/spec.md，包含：API 路径、用途、请求/响应格式

### Requirement: 踩坑经验记录

遇到的技术陷阱和解决方案 SHALL 记录，防止重复踩坑。

#### Scenario: 解决棘手问题

- **WHEN** 开发者花费大量时间解决了一个技术问题
- **THEN** 必须记录踩坑档案，包含：症状、根因、解决方案、预防措施

### Requirement: 技巧模式记录

有效的开发技巧和模式 SHALL 记录，促进知识共享。

#### Scenario: 发现高效做法

- **WHEN** 开发者发现了一种高效的开发技巧或模式
- **THEN** 必须记录到技巧模式区，包含：技巧名称、适用场景、使用方法

### Requirement: 文件速查表

关键文件和目录的位置 SHALL 记录，加速代码导航。

#### Scenario: 定位关键文件

- **WHEN** 开发者频繁访问某些文件或目录
- **THEN** 必须记录到文件速查表，包含：文件路径、用途、关键内容
```

### references/spec.md

```markdown
## Purpose

记录项目依赖和外部参考资源，确保依赖可追溯，资源可获取。

## Requirements

### Requirement: 依赖版本锁定

所有项目依赖 SHALL 记录版本信息，确保构建可重现。

#### Scenario: 添加新依赖

- **WHEN** 开发者引入新的外部依赖
- **THEN** 必须记录到 references/spec.md，包含：依赖名称、版本、官方链接、用途说明

#### Scenario: 更新依赖版本

- **WHEN** 开发者升级或降级依赖版本
- **THEN** 必须更新 references/spec.md 中的版本记录，标注更新原因

### Requirement: 外部资源记录

项目使用的外部资源和文档 SHALL 记录，方便查阅。

#### Scenario: 参考外部文档

- **WHEN** 开发者参考了重要的外部文档或资源
- **THEN** 必须记录到 references/spec.md，包含：资源名称、链接、关键内容摘要

### Requirement: 项目分析文档索引

深度分析文档 SHALL 建立索引，方便查找。

#### Scenario: 生成分析文档

- **WHEN** openspec-explorer 生成了项目分析文档
- **THEN** 必须在 references/spec.md 中注册索引条目，包含：主题、路径、内容概要
```

### optimization/spec.md

```markdown
## Purpose

记录项目中发现的优化点和改进方向，持续提升代码质量和性能。

## Requirements

### Requirement: 优化点记录

发现的性能瓶颈、代码异味、技术债务 SHALL 记录，包含当前影响和建议方案。

#### Scenario: 发现优化机会

- **WHEN** 开发者发现代码中存在性能问题、重复代码、过度复杂设计等
- **THEN** 必须记录到 optimization/spec.md，包含：问题描述、当前影响、建议方案、优先级

#### Scenario: 评估优化价值

- **WHEN** 开发者需要决定是否进行某项优化
- **THEN** 可以参考 optimization/spec.md 中的记录，评估影响范围和收益

### Requirement: 优化完成追踪

已完成的优化 SHALL 记录完成状态，保留历史记录。

#### Scenario: 完成优化

- **WHEN** 开发者完成了某项优化工作
- **THEN** 必须更新 optimization/spec.md，标记为已完成，记录完成日期和实际效果

### Requirement: 优化优先级管理

优化点 SHALL 有优先级排序，合理安排优化顺序。

#### Scenario: 规划优化计划

- **WHEN** 开发者制定优化计划时
- **THEN** 可以参考 optimization/spec.md 中的优先级标注，优先处理高优先级优化点
```

---

## CLAUDE.md 生成模板

**重要**：CLAUDE.md 同时承担 **文档索引** + **规则唯一事实来源** 两个角色。所有规则都内嵌在 CLAUDE.md 中，不再单独维护 `openspec/specs/rules/spec.md`。

```markdown
# CLAUDE.md - 项目入口

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

### 代码智能（CodeGraph，强制）

| 工具 | 用途 | 何时用 |
|------|------|--------|
| `codegraph_explore` | 理解模块工作原理 | 探究项目时首选 |
| `codegraph_callers/callees` | 调用链分析 | 重构前评估 |
| `codegraph_impact` | 改动影响范围 | 重构前必做 |
| `codegraph_status` | 索引健康 | 排查问题时 |

---

## 读取顺序

| 场景 | 读取 | 写入 |
|------|------|------|
| 开始新会话 | CLAUDE.md → SNAPSHOT.md → tasks.md | — |
| 写新功能 | 编码规范 + architecture + learned | tasks.md, learned |
| 修复 Bug | 编码规范 + SNAPSHOT.md + learned | tasks.md, learned（踩坑） |
| 重构 | architecture + optimization + 编码规范 | architecture |
| 记录决策 | architecture | architecture |
| 创建变更 | /opsx:explore 或 /opsx:propose | openspec/changes/ |
| 理解代码 | codegraph_explore | — |

---

## OpenSpec 命令

| 命令 | 用途 | 何时用 |
|------|------|--------|
| `/opsx:propose` | 一步创建修改+所有规划产物 | 快速默认路径 |
| `/opsx:explore` | 探索想法，不创建产物 | 需求不明确时 |
| `/opsx:apply` | 按任务清单实施 | 准备写代码 |
| `/opsx:archive` | 归档完成的修改 | 全部工作完成 |

⚠️ CLI 提醒：
- `openspec init --tools claude --force`（不是 `--ai`，需要 `--force` 跳过交互）
- `openspec validate --specs`（必须带子参数）
- 验证单个：`openspec validate architecture`（不带 spec/ 前缀）

---

# 规则（唯一事实来源）

> 本节是项目规则的唯一来源。所有 agent 必须遵守。

## 一、Karpathy Guidelines（行为约束）

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
1. [步骤] → verify: [检查]
2. [步骤] → verify: [检查]
3. [步骤] → verify: [检查]

强成功标准 → 可独立循环。弱标准需要不断澄清。

### 5. Requirements Integrity

**不裁剪用户需求。未经 approval 不得放弃。**

- 用户明确要求的所有功能必须实现
- 简化实现 ≠ 裁剪功能
- 任何裁剪必须先报告，获 approval 后才执行
- 缺依赖、缺时间不是裁剪理由

---

## 二、务实编码原则（代码质量）

### 十大铁律

1. **命名即文档** — 精准、可读、可搜索的名称
2. **函数单一职责** — < 20行，只做一件事，无副作用
3. **DRY & 正交性** — 三次法则，模块独立
4. **显式胜于隐式** — 依赖注入，常量命名
5. **健壮边界** — 依赖抽象，核心与框架解耦
6. **可测试设计** — 纯函数优先，依赖可注入
7. **尽早重构** — 小步重构，每次提交更好
8. **务实破窗** — 看到问题立即修，不留给以后
9. **自动化检查** — 格式化、静态分析、测试覆盖
10. **注释解释意图** — 注释"为什么"，不注释"做什么"

---

## 三、Workflow Designer（流程框架）

### 核心概念

- **Phase** — 逻辑分组的工作容器（进入/退出条件明确）
- **Gate** — 检查点（PASS 或 BLOCK，BLOCK 必须记录原因）
- **Task** — 最小执行单元（可独立验证，完成必须展示证据）
- **Loop** — 重复处理（clarification / review-fix / iteration / retry）

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

| 概念 | 工具 |
|------|------|
| Phase/Task 状态 | TaskCreate / TaskUpdate |
| Gate 检查 | AskUserQuestion + 逐项验证 |
| Loop 控制 | 条件判断 |
| 并行执行 | Agent (subagent) |
| 验证证据 | Bash + 输出展示 |

---

## 四、核心执行约束（8 条）

```
1. 不探索清楚不实现（Gate 1/BDD）
2. 不计划清楚不实现（Gate 2）
3. 不完整覆盖需求不实现（Gate 2/Requirements Integrity）
4. 不测试通过不提交（Gate 5）
5. 不验证成功不声明（Gate 5）
6. 三次失败必须反思（Gate 6）
7. 不见见证不变更（TDD Iron Law / Gate 3）
8. 不见场景缺口不进设计（BDD智能缺口 / Gate 1）
```

---

## 五、技能执行规则（强制）

> **本节规则专门防止"步骤可跳过"和"完成无证据"类失误。**

### 1. 强制任务化（TaskCreate）

调用任何 skill 时，**第一步必须是 TaskCreate 任务化所有 Phase 步骤**：

```
1. 读取 skill 文档所有 Phase/Step 标题
2. 每个 Phase/Step 创建一条 TaskCreate
3. 开始 Phase X 前 → TaskUpdate mark in_progress
4. 完成 Phase X 后 → TaskUpdate mark completed（带证据）
5. 跳过任何步骤 → TaskUpdate 状态 "SKIPPED: {原因}"（不允许静默跳过）
6. 最终报告前 → TaskList 检查所有任务有 completed 或 SKIPPED 状态
```

### 2. 显式记录跳过（无静默跳过）

```
❌ 禁止：跳过步骤不在报告里说明
✅ 必须：跳过任何 step 必须在最终报告里显式列出（含 N/A 原因）
✅ 必须：用户询问"完成了？"时，主动列出未做的步骤
```

### 3. 完成后自审（5 问）

完成所有 Phase 后，**声明完成前必须回答 5 问**：

```
1. 我执行了技能里的每一步吗？
2. 跳过的步骤有显式记录原因吗？
3. 关键 Gate/Loop 都通过了吗？
4. 有输出证据（命令、文件、片段）吗？
5. 报告前我读过 TaskList 确认状态吗？

任一为 NO → 不允许声明完成
```

### 4. 禁止强假设推断

```
❌ 看到部分证据就推断整体完成（如：看到目录存在就推断整个初始化做完）
✅ 必须逐项打勾，每条 step 有输出或显式记录 "N/A（原因）"
✅ 不确定时 STOP 问，不确定时倾向于"漏做"而非"早收尾"
```

### 5. CodeGraph 工具调用规范（重要，避免误用）

**MCP 工具 vs CLI 命令**：

```
⚠️ 关键区分：CodeGraph 有两套调用接口，绝对不能混淆

1. MCP 工具（agent tool-palette，agent 内部调用）：
   - codegraph_explore
   - codegraph_search
   - codegraph_callers
   - codegraph_callees
   - codegraph_impact
   - codegraph_node
   - codegraph_files
   - codegraph_status
   - 等等
   → 在 agent 内部通过 tool-call 接口调用
   → 不是 shell 命令，不能用 bash 执行
   → 错误示范：bash 中运行 codegraph_status → "command not found"

2. CLI 命令（shell 中调用）：
   - codegraph init / codegraph index / codegraph status
   - codegraph search / codegraph files / codegraph callers
   - 等等
   → 用空格分隔子命令
   → 在 Bash 工具中执行
   → 正确示范：Bash 中运行 codegraph status

⚠️ 误用后果：把 MCP 工具当 bash 命令运行 → "command not found"
   这不代表 MCP 工具不可用，只代表"用错调用方式"
```

**CodeGraph 优先**：

```
CodeGraph 可用时（项目已 init，MCP 已连接）：
  ⭐ 优先用 codegraph_explore 替代 Read + Grep
  ⭐ 一次 codegraph_explore 顶一组 search + node
  ⭐ 不要开 Explore 子 agent 读文件（浪费）
  ⭐ 看到 ⚠️ stale banner 时，对那一个文件直接 Read，其它继续信任
  ⭐ 信任 CodeGraph 结果，**不要用 grep 反向验证**（违反项目 house rule）
```

**信任 CodeGraph 结果（重要 house rule）**：

```
CLAUDE.md 明确：
  "CodeGraph is the pre-built index, so a grep/read loop just repeats work it already did."

src/mcp/server-instructions.ts 第一条：
  "Trust codegraph's results — don't re-verify them with grep."

实际应用：
  ❌ 错误：codegraph_callers 返回 [A, B, C] → 用 grep 验证确实有 A, B, C
  ✅ 正确：codegraph_callers 返回 [A, B, C] → 信任结果，直接使用
  ❌ 错误：codegraph_status 返回 unhealthy → fallback 走 Read + Grep
  ✅ 正确：codegraph_status 返回 unhealthy → 修复 MCP 连接/索引，不要降级
```

**CodeGraph 不可用时的处理**：

```
❌ 错误做法：CodeGraph 不可用 → 降级到 Read + Grep
   - 这违反项目 house rule
   - CLAUDE.md 明确：CodeGraph is the pre-built index
   - 重复了 CodeGraph 已经做过的工作，更慢更贵

✅ 正确做法：
  1. 检查 MCP 连接是否正常
  2. 用 codegraph_status 查看索引健康
  3. 用 codegraph init 重建索引（必须）
  4. 在 CodeGraph 恢复前，停止代码探索任务，提示用户修复
  5. 如果是 CLI 命令，区分是不是用错调用方式（如 codegraph_status vs codegraph status）
```

### 6. OpenSpec 集成

```
- 变更必须用 /opsx:propose 创建，不用手动操作 changes/
- 验证用 openspec validate --specs
- 归档用 openspec archive <name>
- 与 openspec-assistant 双向同步：changes/ ↔ tasks.md
```

### 7. 文件编辑铁律

```
- 更新已有文档用 Edit（精准替换），不用 Write（全量覆盖）
- 创建全新文件才用 Write
- 禁止全量覆盖导致内容丢失
```

---

## 六、检查清单

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

## Red Flags (CLAUDE.md 模板内)

```
❌ 假设不明确 → STOP，问
❌ 过度复杂 → 简化
❌ 改动超出请求 → 回滚
❌ 无测试变更代码 → Iron Law 违规
❌ 顺手添加功能 → Karpathy 违规
❌ 静默跳过 skill 步骤 → 技能执行违规
❌ "Should/probably" → 验证违规
❌ Gate BLOCK 不记录 → Workflow 违规
❌ 强假设推断（看到部分就推断完成）→ 自审违规
```
```

---


## 与旧体系的迁移

### 从 .claude/docs/ 迁移到 OpenSpec

如果项目已有 `.claude/docs/` 文档体系：

```
迁移映射：
  .claude/docs/architecture.md → openspec/specs/architecture/spec.md
  .claude/docs/learned.md → openspec/specs/learned/spec.md
  .claude/docs/references.md → openspec/specs/references/spec.md
  .claude/docs/optimization.md → openspec/specs/optimization/spec.md
  .claude/docs/rules.md → 整合到 CLAUDE.md（不再单独维护）
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
三大规则整合到 CLAUDE.md（唯一事实来源）
CLAUDE.md 同时承担文档索引 + 规则全文两个角色（不再单独维护 rules domain）
初始化 OpenSpec 项目结构（specs/ + changes/）
项目类型适配
规则强度可调
generator 只负责初始化，日常维护交给 assistant
与 OpenSpec CLI 命令无缝集成
与 CodeGraph 集成，加速代码探索
```

---

## CodeGraph 集成

### 初始化时检测 CodeGraph

```
环境检查（Phase 0）:
  1. 检查 OpenSpec（必需）
  2. 检查 CodeGraph（**对源码项目强制**）
     - 已安装: **必须**运行 `codegraph init -i` 建索引
     - 未安装: **必须**执行安装（curl 脚本）+ 验证 `codegraph --version` 成功
```

### CLAUDE.md 索引增加 CodeGraph 部分

```
在文档体系表格后增加:
## 代码智能（CodeGraph）

| 工具 | 用途 | 何时用 |
|------|------|--------|
| `codegraph_explore` | 理解模块工作原理 | 探究项目时首选 |
| `codegraph_callers/callees` | 调用链分析 | 重构前评估 |
| `codegraph_impact` | 改动影响范围 | 重构前必做 |
| `codegraph_status` | 索引健康 | 排查问题时 |
```

### 初始化项目后

```
项目有源码时，必须执行（强约束）:
  1. codegraph init -i
  2. codegraph status  # 必须显示 healthy，不允许 unhealthy
  3. 在 CLAUDE.md 中必须添加 CodeGraph 章节
  强约束: 源码项目无 CodeGraph 索引 = 未完成初始化
```

### 与 openspec-assistant/explorer 的关系

```
CodeGraph 是预建索引，提供:
  - 快速符号定位（替代 grep）
  - 调用链追踪（替代 grep find-references）
  - 改动影响评估（替代手算）
  - 目录结构（替代 ls）

openspec-explorer 用 CodeGraph 加速深度阅读
openspec-assistant 用 CodeGraph 验证 API 活性
openspec-archivist 用 CodeGraph 验证引用关系
```

---

## Red Flags

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
❌ 源码项目无 CodeGraph 索引 → 初始化未完成（必须安装）
❌ codegraph_status unhealthy → 索引损坏，需 codegraph init 重建
❌ 生成独立的 openspec/specs/rules/spec.md → 已废弃（规则在 CLAUDE.md）
❌ 跳过 Phase 0 的 CodeGraph 检查 → 技能执行违规
```
