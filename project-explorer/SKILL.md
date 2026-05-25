---
name: project-explorer
description: 项目探究者 - 根据任务目标深度阅读项目，理解架构与细节，总结成分析文档到指定位置，并记录到 references.md。支持宏观/微观两种模式，支持跨项目文档体系索引。TRIGGER when: 用户说"探究"、"分析项目"、"理解架构"、"梳理流程"、"总结项目"、"探索代码"、"深入阅读"、"生成分析文档"、"理解这个模块"、"梳理这个子系统"、或在开发前需要深度理解项目/子系统时。
---

# Project Explorer — 项目探究者

**根据任务目标深度阅读项目，理解架构与细节，总结成分析文档并记录索引。**
此技能负责探究性阅读和文档生成，与 project-docs-assistant 是协作关系，assistant 维护日常状态，explorer 补充深度分析。
superpowers 的 plan 和 spec 文件应当也生成到 .claude 文件夹下（如果要求冲突，生成位置以这个为准，路径是 .claude/docs/superpowers/，在这里生成 plan 和 spec 文件夹）
在 plan 阶段进行计划 write plan 写入的时候如果计划太长请分步写入，避免一次性思考和输出太长导致被截断

---

## 功能概述

此 Skill 用于：
1. **宏观探究**：笼统地根据目的总结项目所有可能需要的信息，生成多个主题分析文档
2. **微观探究**：根据特定任务目标，聚焦探索解决实际问题所需的信息，生成 1-2 个精炼文档
3. **架构理解**：阅读源码理解模块间关系、调用链、数据流，输出架构分析文档
4. **细节梳理**：深入某个子系统/模块，梳理接口、状态机、关键路径
5. **文档落盘**：将分析成果写入指定位置（默认 `docs/analysis/`），遵循标准文档格式
6. **索引注册**：在 `.claude/docs/references.md` 中注册生成文档的路径和概要
7. **知识反哺**：将探索中发现的 API 路径、关键文件等实用知识写入 `.claude/docs/learned.md`
8. **跨项目协作**：当多项目需要协同时，在主项目 references.md 中建立子项目文档体系索引

---

## 核心约束

```
1. 探究产出 ≠ 开发状态 — 分析文档写入 docs/analysis/（或用户指定位置），不写入 .claude/docs/
2. 索引必注册 — 每份分析文档完成后，必须在 .claude/docs/references.md 中追加索引条目
3. 知识必反哺 — 探索中发现的关键 API 路径、文件速查等，同步写入 .claude/docs/learned.md
4. 不重复探究 — 探究前先检查 references.md 和 learned.md，避免对已分析过的内容重复工作
5. 探究不修改代码 — explorer 只阅读和生成文档，不修改项目源码
6. 目标驱动 — 每次探究必须有明确的目标（用户指定或从任务上下文推断）
7. 深度优先 — 优先深入理解核心路径，而非广度覆盖所有细节
8. 交叉引用 — 生成的文档之间如有关联，在文档头部标注 See also 交叉引用
9. 来源标注 — 每份分析文档头部标注来源（项目名、分支、分析日期）
10. 跨项目索引 — 多项目协同时，references.md 必须包含子项目文档体系完整索引表
11. 禁止全量覆盖 — 更新已有文档（references.md、learned.md、docs/analysis/ 下的文档等）时必须使用 Edit（精准替换）而非 Write（全文覆盖），确保未被涉及的内容不被丢弃。只有创建全新文件时才使用 Write
```

**与 project-docs-assistant 边界**：
- assistant 维护 **开发状态**（tasks/SNAPSHOT/learned/references 日常增改）
- explorer 生成 **深度分析**（架构理解、流程梳理、接口分析 → docs/analysis/）
- explorer 可以直接写入 references.md（追加索引条目）和 learned.md（追加关键知识）
- assistant 日常维护时不会删除 explorer 注册的索引条目（知识只增不减原则）

**与 project-archivist 边界**：
- archivist 清理 references.md 时，对 explorer 注册的条目需检查目标文档是否仍存在
- 目标文档已删除/移动 → Archive 条目（附带 `[MOVED]` 或 `[DELETED]` 标记）
- 目标文档仍存在 → Keep
- archivist 不负责清理 docs/analysis/ 目录下的文档

**与 project-rules-generator 边界**：
- generator 初始化时，references.md 模板应包含"项目分析文档"区域，为 explorer 预留位置
- generator 不生成 docs/analysis/ 目录，那是 explorer 的工作

---

## 两种工作模式

### 宏观模式（Macro）

**触发条件**：
- 用户说"分析整个项目"、"梳理项目架构"、"全面理解项目"
- 开发初期，需要建立项目全局认知
- 项目规模较大，需要拆分主题逐步理解

**特点**：
- 产出多份主题文档（3-8 份）
- 每份文档聚焦一个主题（如启动流程、设备模型、I/O 框架）
- 文档间通过 See also 交叉引用关联
- 探究顺序：先全局（overview）→ 再分层（核心模块）→ 最后细节（特定子系统）

### 微观模式（Micro）

**触发条件**：
- 用户说"理解这个模块"、"梳理这个流程"、"这个子系统的接口是什么"
- 有明确的开发任务，需要深入理解特定部分
- 修复/扩展某个功能，需要先理解现有实现

**特点**：
- 产出 1-2 份聚焦文档
- 文档围绕任务目标，只包含与任务直接相关的信息
- 更深入，包含关键代码路径、状态转换、边界条件
- 探究顺序：从任务入口 → 追踪依赖链 → 理解核心机制

---

## 宏观模式执行流程

### Phase 1: PLAN（规划阶段）

```
Entry: 用户触发宏观探究 + 提供项目路径/当前项目

Step 1 — 项目扫描:
  1. 检查项目根目录结构（ls 第一层 + src 第一层）
  2. 检查是否有 CLAUDE.md → 了解项目类型和文档体系
  3. 检查 .claude/docs/SNAPSHOT.md → 了解当前状态
  4. 检查 .claude/docs/references.md → 查看已有分析文档（避免重复）
  5. 检查 docs/analysis/ 目录是否已存在及其内容
  6. 快速扫描源码目录（find 统计文件数、语言类型）

Step 2 — 去重检查:
  对 references.md 中已有条目 grep "docs/analysis" 或 grep "项目分析文档":
    → 已有分析文档的，列出现有主题
    → 确认用户是否需要更新/补充，而非重新分析

Step 3 — 主题拆分:
  根据项目扫描结果，提出分析主题拆分方案:
    - 必选: project-overview.md（项目概览，总是第一个生成）
    - 根据项目类型选择: boot/启动、核心模型、I/O框架、设备模型、等
    - 根据用户目标调整: 如果用户说"我要做异步 I/O"，则 async-io-framework.md 优先级提高
  使用 AskUserQuestion 请用户确认或调整主题列表和生成顺序

Step 4 — 制定探究计划:
  对每个主题，确定:
    - 需要阅读的核心文件/目录
    - 需要理解的接口/数据结构
    - 输出文档的文件名和概要
    - 与其他主题的交叉引用关系

Exit: 主题列表已确认 + 探究计划已制定
Next: Gate 1
```

### Gate 1: 探究计划确认

```
检查项:
  ✅ 主题列表完整，覆盖用户目标
  ✅ 每个主题有明确的核心文件/目录
  ✅ 去重检查通过（无重复分析）
  ✅ 用户已确认主题列表和生成顺序

BLOCK → 返回 Phase 1 调整
PASS  → 进入 Phase 2
```

### Phase 2: EXPLORE（探究阶段）

```
Entry: Gate 1 PASS

对每个主题（按确认的顺序）:

  Step 1 — 深度阅读:
    1. 读取核心源码文件（使用 Read 工具）
    2. 追踪关键调用链（使用 Grep/Find）
    3. 理解数据结构和接口定义
    4. 识别模块间依赖关系
    5. 记录关键发现（API路径、文件位置、架构模式）

  Step 2 — 知识反哺:
    将探索中发现的关键知识同步写入 .claude/docs/learned.md:
    - API 路径 → API 路径表格
    - 关键文件位置 → 文件速查表格
    - 架构模式 → 技巧模式区
    - 踩坑发现 → 踩坑档案区
    遵循 assistant 的 L 编号体系（读取最大编号后递增）

  Step 3 — 生成文档:
    按照文档模板（见下方）生成分析文档:
    - 头部: 来源标注 + See also 交叉引用
    - 主体: 编号章节、表格、代码片段、架构图
    - 尾部: 关键文件索引表

  Step 4 — 写入文件:
    写入 docs/analysis/{主题文件名}.md
    如果 docs/analysis/ 不存在，先创建目录

  Step 5 — 索引注册:
    在 .claude/docs/references.md 的"项目分析文档"区域追加:
    <!-- R{编号} --> | {主题} | docs/analysis/{文件名}.md | {内容概要} |
    遵循 assistant 的 R 编号体系（读取最大编号后递增）

  Step 6 — 交叉引用更新:
    如该主题与其他已生成主题有关联:
    - 在当前文档头部 See also 添加引用
    - 在关联文档头部 See also 添加反向引用

Exit: 所有主题的文档已生成 + 索引已注册 + 知识已反哺
Next: Gate 2
```

### Gate 2: 探究质量检查

```
检查项:
  ✅ 每份文档覆盖了对应主题的核心内容
  ✅ 文档间交叉引用正确
  ✅ references.md 中索引条目完整
  ✅ learned.md 中关键知识已记录
  ✅ 无遗漏的核心模块/接口

BLOCK → 返回 Phase 2 补充
PASS  → 进入 Phase 3
```

### Phase 3: SUMMARY（总结阶段）

```
Entry: Gate 2 PASS

Step 1 — 生成探究摘要:
  在对话中展示探究成果摘要:
    - 生成了哪些文档（文件名 + 一句话概要）
    - 发现的关键架构模式
    - 关键依赖关系
    - 与用户目标的关联

Step 2 — 更新 references.md 总索引:
  如果生成了 3 份以上文档，在 references.md 的"项目分析文档"区域
  追加一个总览条目:
  <!-- R{编号} --> | 项目分析文档体系 | docs/analysis/ | {项目名} 完整分析，共 N 份文档 |

Step 3 — 交叉项目索引（如适用）:
  如果当前项目有子项目/关联项目且已有文档体系:
  在 references.md 中建立子项目文档体系索引表
  （见"跨项目协作机制"章节）

Exit: 探究完成，摘要已展示
```

---

## 微观模式执行流程

### Phase 1: FOCUS（聚焦阶段）

```
Entry: 用户触发微观探究 + 提供目标描述

Step 1 — 目标分析:
  1. 解析用户目标: 需要理解什么？解决什么问题？
  2. 检查 .claude/docs/references.md → 是否已有相关分析
  3. 检查 .claude/docs/learned.md → 是否已有相关知识
  4. 检查 docs/analysis/ → 是否有可复用的现有分析

Step 2 — 范围确定:
  根据目标确定需要探索的范围:
    - 核心文件列表（初步估计）
    - 关键接口/数据结构
    - 依赖链深度（几层调用）
  如范围不确定，使用 AskUserQuestion 请用户确认

Step 3 — 探究点列表:
  列出需要回答的核心问题（3-8 个）:
    例如: "这个模块的入口在哪？核心状态机是什么？与外部模块的接口有哪些？"

Exit: 目标明确 + 范围确定 + 核心问题列表
Next: Gate 1
```

### Gate 1: 目标确认

```
检查项:
  ✅ 探究目标明确（需要理解什么/解决什么问题）
  ✅ 范围合理（不过大也不过小）
  ✅ 核心问题列表完整
  ✅ 去重检查通过

BLOCK → 返回 Phase 1 调整
PASS  → 进入 Phase 2
```

### Phase 2: DIVE（深入阶段）

```
Entry: Gate 1 PASS

Step 1 — 定向阅读:
  1. 从入口点开始阅读源码（Read 工具）
  2. 追踪关键调用链（Grep/Find）
  3. 理解核心数据结构和接口
  4. 记录关键路径和边界条件
  5. 回答核心问题列表中的每个问题

Step 2 — 知识反哺:
  与宏观模式相同，将关键知识写入 learned.md

Step 3 — 生成文档:
  按照文档模板生成 1-2 份聚焦文档:
    - 围绕核心问题组织内容
    - 包含关键代码路径和调用链
    - 标注与任务直接相关的关键发现
    - 如有依赖的已有分析文档，在 See also 中引用

Step 4 — 写入文件:
  写入 docs/analysis/{聚焦主题}.md

Step 5 — 索引注册:
  在 references.md 追加索引条目

Exit: 文档已生成 + 索引已注册 + 知识已反哺
Next: Gate 2
```

### Gate 2: 完整性检查

```
检查项:
  ✅ 核心问题列表中的每个问题都有回答
  ✅ 关键调用链/依赖链已追踪完整
  ✅ 文档内容与用户目标直接相关
  ✅ references.md 索引已注册
  ✅ learned.md 关键知识已反哺

BLOCK → 返回 Phase 2 补充
PASS  → 进入 Phase 3
```

### Phase 3: REPORT（报告阶段）

```
Entry: Gate 2 PASS

Step 1 — 生成探究报告:
  在对话中展示:
    - 回答了哪些核心问题
    - 关键发现（与用户目标最相关的 3-5 点）
    - 生成的文档路径
    - 建议的下一步行动（如需要进一步探究的方向）

Exit: 探究完成，报告已展示
```

---

## 跨项目协作机制

### 触发条件

```
以下情况需要建立跨项目文档索引:
1. 当前项目依赖子项目（如 StarryOS 依赖 uart_16550 crate）
2. 当前项目是上层框架，子项目是底层驱动/库
3. 用户说"这个项目需要和 XXX 协作"、"关联项目的文档"
4. references.md 中已记录子项目依赖但缺少文档体系索引
```

### 子项目文档体系索引格式

在 `.claude/docs/references.md` 中，为有体系文档的子项目建立索引表：

```markdown
### {子项目名} 文档体系

<!-- R{编号} --> {子项目名} 是 {主项目名} 的{关系描述}，其文档体系路径:

| 文档 | 路径 | 内容概要 |
|------|------|----------|
| 项目入口 | `{相对路径}/CLAUDE.md` | 项目概览、规范 |
| 状态快照 | `{相对路径}/.claude/docs/SNAPSHOT.md` | 状态、核心 API 速查 |
| 学习记忆 | `{相对路径}/.claude/docs/learned.md` | API 路径、踩坑档案 |
| 架构决策 | `{相对路径}/.claude/docs/architecture.md` | ADR、核心设计 |
| 编码规范 | `{相对路径}/.claude/docs/rules.md` | 规则体系 |
| 外部参考 | `{相对路径}/.claude/docs/references.md` | 依赖文档、领域知识 |
| 优化记录 | `{相对路径}/.claude/docs/optimization.md` | 待优化项 |
| 分析文档 | `{相对路径}/docs/analysis/` | 深度分析文档目录 |

关键定位:
- **核心接口**: `{相对路径}/src/{关键文件}` — {说明}
- **主入口**: `{相对路径}/src/lib.rs` — {说明}
- **配置**: `{相对路径}/Cargo.toml` — {说明}
```

### 索引建立流程

```
1. 识别需要索引的子项目（从 references.md 依赖文档区域或用户指定）
2. 检查子项目是否有 .claude/docs/ 文档体系
3. 如果有 → 读取子项目 CLAUDE.md 或 SNAPSHOT.md 了解文档结构
4. 生成索引表，追加到主项目 references.md
5. 使用 R 编号体系标记
6. 在子项目的 references.md 中也添加反向引用（如可写）
```

### 双向索引规则

```
主项目 references.md → 子项目文档体系索引表（概览 + 关键定位）
子项目 references.md → 主项目文档体系索引表（反向引用，如可写）

如子项目不可写（如 crates.io 依赖）:
  → 只在主项目建立单向索引
  → 标注"（上游 crate，不可写）"
```

---

## references.md 更新机制

### 分析文档条目格式

在 references.md 的"项目分析文档"区域，追加条目：

```markdown
<!-- R{编号} --> | {主题} | docs/analysis/{文件名}.md | {内容概要} |
```

示例：
```markdown
<!-- R20 --> | 项目概览 | docs/analysis/project-overview.md | 仓库结构、构建系统、依赖图 |
<!-- R21 --> | 启动流程 | docs/analysis/boot-init.md | axruntime → mount → spawn init |
<!-- R22 --> | 设备注册 | docs/analysis/device-registration.md | DeviceOps trait、Device struct、devfs |
<!-- R23 --> | TTY/Console 栈 | docs/analysis/tty-console-stack.md | N_TTY、ldisc、termios |
```

### 分析文档总览条目

当生成 3 份以上文档时，追加总览条目：

```markdown
<!-- R{编号} --> | 项目分析文档体系 | docs/analysis/ | {项目名} 完整分析，共 N 份文档 |
```

### 条目编号规则

```
1. 读取 references.md 中已有最大 R 编号
2. 新条目编号递增
3. 跨项目索引表占用一个 R 编号（整个表格作为一个条目）
4. 分析文档总览条目占用一个 R 编号
```

### references.md 区域布局

```
references.md 应包含以下区域（按顺序）:

1. 依赖文档（generator 初始化，assistant 维护）
2. 项目分析文档（explorer 写入，assistant/archivist 维护）
3. 子项目文档体系索引（explorer 写入，assistant/archivist 维护）
4. 领域知识笔记（generator 初始化，assistant 维护）

如 references.md 中缺少"项目分析文档"区域:
  → explorer 首次写入时自动创建该区域 H2 标题和注释头
```

---

## learned.md 更新机制

### 反哺规则

```
探究过程中发现以下知识时，必须同步写入 learned.md:

✅ API 路径 → API 路径表格（函数签名 + 所在文件）
✅ 关键文件位置 → 文件速查表格（模块入口、配置文件、核心定义）
✅ 架构模式 → 技巧模式区（模块间通信方式、状态管理模式等）
✅ 踩坑发现 → 踩坑档案区（陷阱、隐含约束、非直觉行为）
✅ 依赖关系 → 依赖关系图区（模块间调用关系）

不反哺的内容:
❌ 分析文档中已有的详细流程描述（文档本身已记录）
❌ 过于具体的实现细节（只与特定分析相关）
❌ 用户已知道的信息（不重复记录）
```

### 反哺格式

```
与 project-docs-assistant 的 L 编号体系一致:

API 路径: <!-- L{编号} --> | {名称} | {路径} | {用途} | {时间} |
文件速查: <!-- L{编号} --> | {名称} | {路径} | {用途} | {时间} |
踩坑档案: <!-- L{编号} --> ### [{问题标题}] 后跟症状→根因→解决
技巧模式: <!-- L{编号} --> ### [{技巧标题}] 后跟描述
```

---

## 分析文档生成模板

### 标准文档格式

```markdown
# {主题标题}

> Part of {项目名} codebase analysis (branch: {分支名})
> Generated by project-explorer at {日期}
> See also: [{关联文档1}](关联文档1.md), [{关联文档2}](关联文档2.md)

---

## 1. {第一个主题章节}

[内容: 架构概述、核心概念、关键实体]

### 1.1 {子章节}

[内容: 具体细节]

### 关键接口

| 接口 | 定义位置 | 用途 |
|------|---------|------|
| {接口名} | `{文件路径}:{行号}` | {用途} |

## 2. {第二个主题章节}

[内容]

### 调用链

```
{调用方} → {中间层} → {被调用方}
  ↓
{数据流向}
```

### 关键数据结构

| 结构体 | 定义位置 | 核心字段 |
|--------|---------|---------|
| {结构体名} | `{文件路径}` | {核心字段列表} |

## 3. {更多章节...}

---

## 关键文件索引

| 文件 | 作用 | 核心内容 |
|------|------|---------|
| `{相对路径}` | {作用} | {核心内容} |
```

### 文档命名规范

```
命名规则: 使用小写 + 连字符，简洁表达主题

推荐命名:
  project-overview.md       — 项目概览
  boot-init.md              — 启动/初始化流程
  device-model.md           — 设备模型
  io-framework.md           — I/O 框架
  async-io-framework.md     — 异步 I/O 框架
  syscall-interface.md      — 系统调用接口
  task-process-model.md     — 任务/进程模型
  tty-console-stack.md      — TTY/Console 栈
  memory-management.md      — 内存管理
  driver-architecture.md    — 驱动架构
  {module-name}-design.md   — 特定模块设计上下文
  {module-name}-internal.md — 特定模块内部实现

不推荐:
  analysis1.md, doc.md, notes.md — 无信息量
```

### See also 交叉引用

```
规则:
1. 宏观模式下，每份文档的 See also 列出同批次生成的关联文档
2. 微观模式下，See also 列出已有的相关分析文档
3. 交叉引用使用相对路径: [{文档名}](文档名.md)
4. 双向引用: A 引用 B 时，也更新 B 的 See also 引用 A
5. 如关联文档属于子项目: [{子项目文档}]({相对路径})
```

---

## 探究策略（阅读顺序与方法）

### 自顶向下策略

```
适用于: 宏观模式、需要理解全局架构

阅读顺序:
  1. CLAUDE.md / README.md → 项目概述
  2. 目录结构 → 模块划分
  3. Cargo.toml / package.json → 依赖关系
  4. src/lib.rs / src/main.rs → 入口和公共 API
  5. 各模块的 mod.rs / index.ts → 模块组织
  6. 核心 trait/接口定义 → 架构骨架
  7. 实现文件 → 细节填充
```

### 自底向上策略

```
适用于: 微观模式、需要理解特定实现

阅读顺序:
  1. 目标文件（用户指定的或从任务推断的）
  2. 该文件 import/use 的依赖 → 上游依赖
  3. 该文件定义的公开接口 → 对外契约
  4. 调用该文件的地方（Grep find-references）→ 下游消费者
  5. 相关的测试文件 → 预期行为
  6. 相关的配置文件 → 运行时行为
```

### 调用链追踪策略

```
适用于: 理解执行流程、数据流

追踪方法:
  1. 从入口函数开始（如 main、handler、init）
  2. 记录每个函数调用 → 形成调用树
  3. 标注数据流向（参数传递、返回值）
  4. 标注状态变更（全局状态修改、锁获取释放）
  5. 识别分支条件（错误处理、配置分支）
  6. 到达系统边界（系统调用、I/O 操作、外部 API）时停止

输出格式:
  调用链文档（嵌套缩进或流程图语法）
```

### 去重检查策略

```
探究前必做:
  1. grep "docs/analysis" .claude/docs/references.md → 已有分析文档列表
  2. ls docs/analysis/ → 已有文件
  3. 对每个计划分析的主题:
     → 已存在且内容覆盖 → 跳过或询问用户是否需要更新
     → 已存在但不完整 → 补充模式（追加缺失内容）
     → 不存在 → 新建

更新 vs 重建:
  - 文档存在但分支已变 → 重建（添加"基于 {旧分支} 版本更新"注释）
  - 文档存在且分支不变但内容可补充 → 追加（在文档末尾添加新章节）
  - 用户明确要求重建 → 重建
```

---

## grep 搜索友好设计

### 分析文档内搜索

```bash
# 搜索某主题的分析文档
ls docs/analysis/ | grep "关键词"

# 搜索分析文档内容
grep -rn "关键词" docs/analysis/

# 搜索特定文档的关键接口表
grep "|.*|.*|" docs/analysis/{文件名}.md

# 搜索关键文件索引
grep "^|" docs/analysis/{文件名}.md | tail -N
```

### references.md 中搜索分析文档索引

```bash
# 列出所有分析文档条目
grep "| docs/analysis/" .claude/docs/references.md

# 搜索特定主题
grep "关键词" .claude/docs/references.md | grep "docs/analysis"

# 搜索子项目索引
grep "文档体系" .claude/docs/references.md

# 搜索总览条目
grep "文档体系" .claude/docs/references.md | grep "docs/analysis/"
```

### learned.md 中搜索探究反哺

```bash
# 搜索 explorer 反哺的 API 路径
grep "| .*| .*|" .claude/docs/learned.md | grep "关键词"

# 搜索踩坑档案
grep "^###" .claude/docs/learned.md | grep -i "关键词"
```

---

## references.md 区域初始化

### 首次写入时自动补全

当 explorer 需要写入 references.md 但发现缺少"项目分析文档"区域时，自动在"依赖文档"区域之后插入：

```markdown
## 项目分析文档

<!-- 由 project-explorer 写入，由 project-docs-assistant 日常维护，由 project-archivist 周期清理。 -->
<!-- 添加时格式: <!-- R{编号} --> | 主题 | 路径 | 内容概要 | -->

<!-- R{编号} --> | {主题} | docs/analysis/{文件名}.md | {内容概要} |
```

### 缺少"子项目文档体系"区域时

当需要写入跨项目索引但缺少区域时，在"项目分析文档"之后插入：

```markdown
## 子项目文档体系索引

<!-- 由 project-explorer 写入，由 project-docs-assistant 日常维护，由 project-archivist 周期清理。 -->
<!-- 记录有体系文档的子/关联项目的文档路径索引。 -->
```

---

## 与其他 Skill 的协作规则

### 与 project-docs-assistant

```
协作场景:

1. explorer 写入 references.md:
   - explorer 直接追加条目（Pattern 9 风格）
   - assistant 日常维护时不会删除 explorer 的条目
   - assistant 可更新条目的概要描述（如文档内容变更）

2. explorer 写入 learned.md:
   - explorer 直接追加条目（Pattern 8 风格）
   - assistant 日常维护时正常管理这些条目
   - archivist 可按标准判断归档

3. explorer 读取 assistant 维护的文档:
   - 探究前读取 SNAPSHOT.md 了解项目状态
   - 探究前读取 learned.md 避免重复发现
   - 探究前读取 references.md 检查已有分析

4. 助手与探究者的知识流向:
   SNAPSHOT.md ← assistant 维护，explorer 读取
   learned.md  ← 双向（assistant 日常，explorer 探究发现）
   references.md ← 双向（assistant 依赖/领域知识，explorer 分析文档索引）
   docs/analysis/ ← explorer 专属写入，assistant 可读取引用
```

### 与 project-archivist

```
协作场景:

1. archivist 清理 references.md 中的分析文档条目:
   - 检查目标文档是否存在: test -f docs/analysis/{文件名}.md
   - 文档存在 → Keep
   - 文档已删除 → Archive（标记 [DELETED]）
   - 文档已移动 → Archive（标记 [MOVED]，如能定位新路径则更新）
   - 总览条目中的文档数与实际不符 → Stale-Warn

2. archivist 清理 learned.md 中 explorer 反哺的条目:
   - 与普通条目相同标准（按 learned.md 判断框架）
   - 无特殊处理

3. archivist 不负责清理 docs/analysis/ 目录:
   - 该目录下的文档由用户决定保留/删除
   - 如用户删除了文档，archivist 清理 references.md 中的索引
```

### 与 project-rules-generator

```
协作场景:

1. generator 初始化 references.md 时:
   - 模板中应包含"项目分析文档"区域（空，待 explorer 填充）
   - 模板中应包含"子项目文档体系索引"区域（空，待 explorer 填充）
   - 当前 generator 模板可能缺少这些区域 → explorer 首次写入时自动补全

2. generator 初始化项目时:
   - 不创建 docs/analysis/ 目录
   - 不预生成分析文档
   - 在 CLAUDE.md 的文档体系表格中添加 docs/analysis/ 的说明
```

---

## 探究输出物清单

每次探究完成后，应产出：

```
必须产出:
  ✅ docs/analysis/{主题}.md — 1-N 份分析文档
  ✅ references.md 索引条目 — 每份文档对应一条 R 编号条目
  ✅ learned.md 知识反哺 — 探究中发现的关键知识

条件产出:
  📎 references.md 总览条目 — 生成 3 份以上文档时
  📎 references.md 子项目索引 — 涉及多项目协同时
  📎 文档间交叉引用更新 — 宏观模式下
  📎 references.md 区域初始化 — 首次写入时缺少"项目分析文档"区域
```

---

## 关键原则

```
目标驱动，每次探究有明确目的
深度优先，优先理解核心路径而非广度覆盖
不重复探究，先检查已有文档和知识
探究不修改代码，只阅读和生成文档
索引必注册，每份分析文档必须在 references.md 有索引
知识必反哺，关键发现同步到 learned.md
来源标注，分析文档头部标注项目和分支
交叉引用，关联文档互相引用
跨项目索引，多项目协同时建立文档体系索引表
外科手术式更新，写入 references.md/learned.md 时只追加必要内容
禁止全量覆盖，更新已有文档必须用 Edit 而非 Write，保护原有内容不被意外丢失
grep 友好，所有条目有编号标记，支持精确搜索
与 assistant/archivist/generator 各司其职，互不冲突
```

---

## Red Flags

```
探究前:
❌ 不检查 references.md/learned.md 就开始探究 → 重复工作
❌ 不确认探究目标和范围就深入阅读 → 方向偏离
❌ 目标过大不拆分主题 → 产出质量差

探究中:
❌ 修改项目源码 → 探究者不修改代码
❌ 只阅读不记录关键发现 → 知识丢失
❌ 追踪调用链过深陷入细节 → 偏离目标
❌ 生成的文档没有关键文件索引表 → 不实用

探究后:
❌ 不在 references.md 注册索引 → 文档难以发现
❌ 不反哺 learned.md → 知识碎片化
❌ 不标注来源（项目/分支）→ 文档无法追溯
❌ 宏观模式下不建立文档间交叉引用 → 文档孤立

跨项目:
❌ 不建立子项目文档体系索引 → 协作信息缺失
❌ 子项目文档体系索引不包含关键定位 → 索引不实用
❌ 双向索引只建单向 → 反向查找困难

与其他 Skill:
❌ explorer 写入 references.md 时覆盖 assistant 的条目 → 数据丢失
❌ explorer 写入 learned.md 时不遵循 L 编号体系 → 编号冲突
❌ references.md 中缺少"项目分析文档"区域就直接追加 → 区域混乱
❌ 生成文档到 .claude/docs/ 下 → 位置错误（应在 docs/analysis/）
❌ 使用 Write 全量覆盖已有文档（references.md/learned.md/分析文档等）→ 内容丢失 violation（必须用 Edit 准替换）
```
