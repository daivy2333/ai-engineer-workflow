---
name: openspec-explorer
description: OpenSpec 项目探究者 - 深度阅读项目生成 .claude/analysis/ 分析文档，并反哺：references/spec.md（索引 R）、learned/spec.md（知识 L）、architecture/spec.md（架构 A）。支持宏观/微观两种模式。TRIGGER when: 用户说"探究"、"分析项目"、"理解架构"、"梳理流程"、"总结项目"、"探索代码"、"深入阅读"、"生成分析文档"、"理解这个模块"、"梳理这个子系统"、或在开发前需要深度理解项目/子系统时。
---

# OpenSpec Explorer — 项目探究者

**根据任务目标深度阅读项目，理解架构与细节，总结成分析文档并记录索引。**

此技能负责探究性阅读和文档生成，与 openspec-assistant 是协作关系，assistant 维护日常状态，explorer 补充深度分析。

superpowers 的 plan 和 spec 文件应当也生成到 .claude 文件夹下（如果要求冲突，生成位置以这个为准，路径是 .claude/docs/superpowers/，在这里生成 plan 和 spec 文件夹）

在 plan 阶段进行计划 write plan 写入的时候如果计划太长请分步写入，避免一次性思考和输出太长导致被截断

---

## 功能概述

此 Skill 用于：
1. **宏观探究**：笼统地根据目的总结项目所有可能需要的信息，生成多个主题分析文档
2. **微观探究**：根据特定任务目标，聚焦探索解决实际问题所需的信息，生成 1-2 个精炼文档
3. **架构理解**：通过 grep/Read 理解模块间关系、调用链、数据流，输出架构分析文档
4. **细节梳理**：深入某个子系统/模块，梳理接口、状态机、关键路径
5. **文档落盘**：将分析成果写入 `.claude/analysis/`（或用户指定位置）
6. **索引注册**：在 `openspec/specs/references/spec.md` 中注册生成文档的路径和概要
7. **知识反哺**：将探索中发现的 API 路径、关键文件等实用知识写入 `openspec/specs/learned/spec.md`
8. **架构发现**：将发现的架构模式、设计决策写入 `openspec/specs/architecture/spec.md`

---

## 文档体系映射

### 写入目标

| 内容类型 | 目标文件 | 编号格式 |
|----------|----------|----------|
| 分析文档 | `.claude/analysis/{主题}.md` | 无编号（文件名即标识） |
| 文档索引 | `openspec/specs/references/spec.md` | <!-- R{编号} --> |
| 学习知识 | `openspec/specs/learned/spec.md` | <!-- L{编号} --> |
| 架构发现 | `openspec/specs/architecture/spec.md` | <!-- A{编号} --> |

### 读取来源

| 内容 | 来源文件 |
|------|----------|
| 项目状态 | `.claude/docs/SNAPSHOT.md` |
| 已有分析 | `openspec/specs/references/spec.md`（项目分析文档区域） |
| 已有知识 | `openspec/specs/learned/spec.md` |
| 架构决策 | `openspec/specs/architecture/spec.md` |
| OpenSpec 变更 | `openspec list` + `openspec/changes/` |

---

## 核心约束

```
1. 探究产出 ≠ 开发状态 — 分析文档写入 .claude/analysis/（或用户指定位置），不写入 openspec/specs/
2. 索引必注册 — 每份分析文档完成后，必须在 openspec/specs/references/spec.md 中追加索引条目
3. 知识必反哺 — 探索中发现的关键 API 路径、文件速查等，同步写入 openspec/specs/learned/spec.md
4. 架构必记录 — 探索中发现的架构模式、设计决策，同步写入 openspec/specs/architecture/spec.md
5. 不重复探究 — 探究前先检查 references/spec.md 和 learned/spec.md，避免对已分析过的内容重复工作
6. 探究不修改代码 — explorer 只阅读和生成文档，不修改项目源码
7. 目标驱动 — 每次探究必须有明确的目标（用户指定或从任务上下文推断）
8. 深度优先 — 优先深入理解核心路径，而非广度覆盖所有细节
9. 交叉引用 — 生成的文档之间如有关联，在文档头部标注 See also 交叉引用
10. 来源标注 — 每份分析文档头部标注来源（项目名、分支、分析日期）
11. 禁止全量覆盖 — 见 `CLAUDE.md → 五.7、文件编辑铁律`
12. 归档感知 — 探究时遇到 Lxx/Rxx/Axx 标记，先 `grep "<!-- arc:" <源文件>` 检查是否已归档；已归档条目跳到 `openspec/archive/<日期>-arc-XXX/specs/<源域>/spec.md`。
```

**与 openspec-assistant 边界**：
- assistant 维护 **开发状态**（tasks/SNAPSHOT/learned/references 日常增改）
- explorer 生成 **深度分析**（架构理解、流程梳理、接口分析 → .claude/analysis/）
- explorer 只写入 references/spec.md（追加分析文档索引条目）、learned/spec.md（追加关键知识）和 architecture/spec.md（追加架构发现）
- assistant 日常维护时不会删除 explorer 注册的索引条目（知识只增不减原则）

**与 openspec-archivist 边界**：
- archivist 清理 references/spec.md 时，对 explorer 注册的条目需检查目标文档是否仍存在
- 目标文档已删除/移动 → Archive 条目（附带 `[MOVED]` 或 `[DELETED]` 标记）
- 目标文档仍存在 → Keep
- archivist 不负责清理 .claude/analysis/ 目录下的文档

**与 openspec-init 边界**：
- generator 初始化时，references/spec.md 模板应包含"项目分析文档"区域，为 explorer 预留位置
- generator 不生成 .claude/analysis/ 目录，那是 explorer 的工作

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
  1. `ls` / `glob` → 获取目录结构
  2. `grep -rn "{主类/入口}"` → 查找核心符号
  3. 检查 .claude/docs/SNAPSHOT.md → 了解当前状态
  4. 检查 openspec/specs/references/spec.md → 查看已有分析文档
  5. 检查 .claude/analysis/ 目录是否已存在
  6. 检查 `openspec list` → 了解活跃变更

Step 2 — 去重检查:
  对 references/spec.md 中已有条目 grep "docs/analysis" 或 grep "项目分析文档":
    → 已有分析文档的，列出现有主题
    → 确认用户是否需要更新/补充，而非重新分析

Step 3 — 主题拆分:
  根据项目扫描结果，提出分析主题拆分方案:
    - 必选: project-overview.md（项目概览，总是第一个生成）
    - 根据项目类型选择: boot/启动、核心模型、I/O框架、设备模型、等
    - 根据用户目标调整: 如果用户说"我要做异步 I/O"，则 async-io-framework.md 优先级提高
    - 根据 OpenSpec 变更调整: 如果有活跃变更，相关模块优先级提高
  使用 AskUserQuestion 请用户确认或调整主题列表和生成顺序

Step 4 — 制定探究计划:
  对每个主题，确定:
    - 用 grep/Read 探查的范围（文件名/符号名）
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

  Step 1 — 深度探究（grep/Read）:
    1. `grep -rn "{主题相关的关键词}"` → 找到相关文件和位置
    2. `Read {找到的关键文件}` → 阅读核心实现
    3. `grep -rn "{函数名}"` → 追踪调用链（callers/callees）
    4. `grep -rn "{符号名}"` → 评估改动影响范围

  Step 2 — 知识反哺:
    将探索中发现的关键知识同步写入 openspec/specs/learned/spec.md:
    - API 路径 → API 路径表格
    - 关键文件位置 → 文件速查表格
    - 架构模式 → 技巧模式区
    - 踩坑发现 → 踩坑档案区
    遵循 assistant 的 L 编号体系（读取最大编号后递增）

  Step 3 — 架构发现:
    将探索中发现的架构模式、设计决策同步写入 openspec/specs/architecture/spec.md:
    - 模块间通信方式 → ADR 条目
    - 状态管理模式 → ADR 条目
    - 关键设计决策 → ADR 条目
    遵循 assistant 的 A 编号体系（读取最大编号后递增）

  Step 4 — 生成文档:
    按照文档模板（见下方）生成分析文档:
    - 头部: 来源标注 + See also 交叉引用
    - 主体: 编号章节、表格、代码片段、架构图
    - 尾部: 关键文件索引表

  Step 5 — 写入文件:
    写入 .claude/analysis/{主题文件名}.md
    如果 .claude/analysis/ 不存在，先创建目录

  Step 6 — 索引注册:
    在 openspec/specs/references/spec.md 的"项目分析文档"区域追加:
    <!-- R{编号} --> | {主题} | .claude/analysis/{文件名}.md | {内容概要} |
    遵循 assistant 的 R 编号体系（读取最大编号后递增）

  Step 7 — 交叉引用更新:
    如该主题与其他已生成主题有关联:
    - 在当前文档头部 See also 添加引用
    - 在关联文档头部 See also 添加反向引用

Exit: 所有主题的文档已生成 + 索引已注册 + 知识已反哺 + 架构已记录
Next: Gate 2
```

### Gate 2: 探究质量检查

```
检查项:
  ✅ 每份文档覆盖了对应主题的核心内容
  ✅ 文档间交叉引用正确
  ✅ references/spec.md 中索引条目完整
  ✅ learned/spec.md 中关键知识已记录
  ✅ architecture/spec.md 中架构发现已记录
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
    - 与 OpenSpec 变更的关联（如有）

Step 2 — 更新 references/spec.md 总索引:
  如果生成了 3 份以上文档，在 references/spec.md 的"项目分析文档"区域
  追加一个总览条目:
  <!-- R{编号} --> | 项目分析文档体系 | .claude/analysis/ | {项目名} 完整分析，共 N 份文档 |

Exit: 探究完成，摘要已展示
```

---

## 微观模式执行流程

### Phase 1: FOCUS（聚焦阶段）

```
Entry: 用户触发微观探究 + 提供目标描述

Step 1 — 目标分析:
  1. 解析用户目标: 需要理解什么？解决什么问题？
  2. 检查 openspec/specs/references/spec.md → 是否已有相关分析
  3. 检查 openspec/specs/learned/spec.md → 是否已有相关知识
  4. 检查 openspec/specs/architecture/spec.md → 是否已有相关决策
  5. 检查 .claude/analysis/ → 是否有可复用的现有分析
  6. 检查 openspec list → 是否有相关变更

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

Step 1 — 定向探究（grep/Read）:
  1. `grep -rn "{任务目标相关关键词}"` → 找到相关文件和位置
  2. `grep -rn "{入口函数名}"` → 找上游调用者
  3. `Read {入口文件}` → 阅读函数体，追踪下游调用
  4. `grep -rn "{要改动的符号}"` → 评估影响范围
  5. `Read {找到的具体文件}` → 阅读完整源码

Step 2 — 知识反哺:
  与宏观模式相同，将关键知识写入 openspec/specs/learned/spec.md

Step 3 — 架构发现:
  与宏观模式相同，将架构发现写入 openspec/specs/architecture/spec.md

Step 4 — 生成文档:
  按照文档模板生成 1-2 份聚焦文档:
    - 围绕核心问题组织内容
    - 包含关键代码路径和调用链
    - 标注与任务直接相关的关键发现
    - 如有依赖的已有分析文档，在 See also 中引用

Step 5 — 写入文件:
  写入 .claude/analysis/{聚焦主题}.md

Step 6 — 索引注册:
  在 references/spec.md 追加索引条目

Exit: 文档已生成 + 索引已注册 + 知识已反哺 + 架构已记录
Next: Gate 2
```

### Gate 2: 完整性检查

```
检查项:
  ✅ 核心问题列表中的每个问题都有回答
  ✅ 关键调用链/依赖链已追踪完整
  ✅ 文档内容与用户目标直接相关
  ✅ references/spec.md 索引已注册
  ✅ learned/spec.md 关键知识已反哺
  ✅ architecture/spec.md 架构发现已记录

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
    - 与 OpenSpec 变更的关联（如有）
    - 建议的下一步行动（如需要进一步探究的方向）

Exit: 探究完成，报告已展示
```

---

## references/spec.md 更新机制

### 分析文档条目格式

在 references/spec.md 的"项目分析文档"区域，追加条目：

```markdown
<!-- R{编号} --> | {主题} | .claude/analysis/{文件名}.md | {内容概要} |
```

示例：
```markdown
<!-- R20 --> | 项目概览 | .claude/analysis/project-overview.md | 仓库结构、构建系统、依赖图 |
<!-- R21 --> | 启动流程 | .claude/analysis/boot-init.md | axruntime → mount → spawn init |
<!-- R22 --> | 设备注册 | .claude/analysis/device-registration.md | DeviceOps trait、Device struct、devfs |
<!-- R23 --> | TTY/Console 栈 | .claude/analysis/tty-console-stack.md | N_TTY、ldisc、termios |
```

### 分析文档总览条目

当生成 3 份以上文档时，追加总览条目：

```markdown
<!-- R{编号} --> | 项目分析文档体系 | .claude/analysis/ | {项目名} 完整分析，共 N 份文档 |
```

### 条目编号规则

```
1. 读取 references/spec.md 中已有最大 R 编号
2. 新条目编号递增
3. 分析文档总览条目占用一个 R 编号
```

### references/spec.md 区域布局

```
references/spec.md 应包含以下区域（按顺序）:

1. 依赖文档（generator 初始化，assistant 维护）
2. 项目分析文档（explorer 写入，assistant/archivist 维护）
3. 领域知识笔记（generator 初始化，assistant 维护）

如 references/spec.md 中缺少"项目分析文档"区域:
  → explorer 首次写入时自动创建该区域 H2 标题和注释头
```

---

## learned/spec.md 更新机制

### 反哺规则

```
探究过程中发现以下知识时，必须同步写入 openspec/specs/learned/spec.md:

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
与 openspec-assistant 的 L 编号体系一致:

API 路径: <!-- L{编号} --> | {名称} | {路径} | {用途} | {时间} |
文件速查: <!-- L{编号} --> | {名称} | {路径} | {用途} | {时间} |
踩坑档案: <!-- L{编号} --> ### [{问题标题}] 后跟症状→根因→解决
技巧模式: <!-- L{编号} --> ### [{技巧标题}] 后跟描述
```

---

## architecture/spec.md 更新机制

### 记录规则

```
探究过程中发现以下架构信息时，必须同步写入 openspec/specs/architecture/spec.md:

✅ 模块间通信方式 → ADR 条目（如事件驱动、RPC、共享状态）
✅ 状态管理模式 → ADR 条目（如状态机、Actor、Redux）
✅ 关键设计决策 → ADR 条目（如为什么选这个算法、为什么用这个数据结构）
✅ 架构约束 → ADR 条目（如性能约束、兼容性约束）

不记录的内容:
❌ 分析文档中已有的详细架构描述（文档本身已记录）
❌ 过于具体的实现细节（只与特定分析相关）
❌ 显而易见的设计选择（无需记录）
```

### 记录格式

```
与 openspec-assistant 的 A 编号体系一致:

ADR 条目: <!-- A{编号} --> ### {DATE} - {决策标题}
每条含：决策、原因、影响、替代方案
```

---

## 分析文档生成模板

### 标准文档格式

```markdown
# {主题标题}

> Part of {项目名} codebase analysis (branch: {分支名})
> Generated by openspec-explorer at {日期}
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
```

---

## 探究策略（阅读顺序与方法）

### 自顶向下策略

```
适用于: 宏观模式、需要理解全局架构

grep/Read 默认动作:
  1. `ls` / `glob` → 项目结构
  2. `grep -rn "{项目名/主类}"` → 找入口文件
  3. `Read {入口文件}` → 阅读核心源码
  4. `grep -rn "{入口函数名}"` → 找上游调用者
  5. `grep -rn "{入口函数名}"` + `Read` → 找下游调用
```

### 自底向上策略

```
适用于: 微观模式、需要理解特定实现

grep/Read 默认动作:
  1. `Read {目标文件}` → 阅读完整源码
  2. `grep -rn "{目标函数名}"` → 找下游依赖
  3. `grep -rn "{目标函数名}"` → 找上游消费者
  4. `grep -rn "{目标符号}"` → 评估改动影响范围
  5. `grep -rn "{相关类型名}"` → 找关联符号
```

### 调用链追踪策略

```
适用于: 理解执行流程、数据流

grep/Read 默认动作:
  1. `grep -rn "{X}"` → 找到 X 的定义位置，`Read` 函数体追踪到 Y
  2. `grep -rn "{X 中调用的函数}"` → 深度遍历下游（逐层）
  3. `grep -rn "{Y}"` → 反向遍历上游调用者（逐层）
  4. 标注合成边（callback、EventEmitter、React re-render）

输出格式:
  调用链文档（嵌套缩进或流程图语法）
```

### 去重检查策略

```
探究前必做:
  1. grep ".claude/analysis" openspec/specs/references/spec.md → 已有分析文档列表
  2. ls .claude/analysis/ → 已有文件
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
ls .claude/analysis/ | grep "关键词"

# 搜索分析文档内容
grep -rn "关键词" .claude/analysis/

# 搜索特定文档的关键接口表
grep "|.*|.*|" .claude/analysis/{文件名}.md

# 搜索关键文件索引
grep "^|" .claude/analysis/{文件名}.md | tail -N
```

### references/spec.md 中搜索分析文档索引

```bash
# 列出所有分析文档条目
grep "| .claude/analysis/" openspec/specs/references/spec.md

# 搜索特定主题
grep "关键词" openspec/specs/references/spec.md | grep ".claude/analysis"

# 搜索总览条目
grep "文档体系" openspec/specs/references/spec.md | grep ".claude/analysis/"
```

### learned/spec.md 中搜索探究反哺

```bash
# 搜索 explorer 反哺的 API 路径
grep "| .*| .*|" openspec/specs/learned/spec.md | grep "关键词"

# 搜索踩坑档案
grep "^###" openspec/specs/learned/spec.md | grep -i "关键词"
```

### architecture/spec.md 中搜索架构发现

```bash
# 搜索 explorer 记录的架构决策
grep "^###" openspec/specs/architecture/spec.md | grep "关键词"

# 搜索决策日期
grep -E "^\d{4}-\d{2}-\d{2}" openspec/specs/architecture/spec.md
```

---

## references/spec.md 区域初始化

### 首次写入时自动补全

当 explorer 需要写入 references/spec.md 但发现缺少"项目分析文档"区域时，自动在"依赖文档"区域之后插入：

```markdown
## 项目分析文档

<!-- 由 openspec-explorer 写入，由 openspec-assistant 日常维护，由 openspec-archivist 周期清理。 -->
<!-- 添加时格式: <!-- R{编号} --> | 主题 | 路径 | 内容概要 | -->

<!-- R{编号} --> | {主题} | .claude/analysis/{文件名}.md | {内容概要} |
```

---

## 与其他 Skill 的协作规则

### 与 openspec-assistant

```
协作场景:

1. explorer 写入 references/spec.md:
   - explorer 直接追加条目（Pattern 9 风格）
   - assistant 日常维护时不会删除 explorer 的条目
   - assistant 可更新条目的概要描述（如文档内容变更）

2. explorer 写入 learned/spec.md:
   - explorer 直接追加条目（Pattern 8 风格）
   - assistant 日常维护时正常管理这些条目
   - archivist 可按标准判断归档

3. explorer 写入 architecture/spec.md:
   - explorer 直接追加条目（Pattern 7 风格）
   - assistant 日常维护时正常管理这些条目

4. explorer 读取 assistant 维护的文档:
   - 探究前读取 SNAPSHOT.md 了解项目状态
   - 探究前读取 learned/spec.md 避免重复发现
   - 探究前读取 references/spec.md 检查已有分析
   - 探究前读取 architecture/spec.md 了解已有决策

5. 助手与探究者的知识流向:
   SNAPSHOT.md ← assistant 维护，explorer 读取
   learned/spec.md  ← 双向（assistant 日常，explorer 探究发现）
   references/spec.md ← 双向（assistant 依赖/领域知识，explorer 分析文档索引）
   architecture/spec.md ← 双向（assistant 日常，explorer 架构发现）
   .claude/analysis/ ← explorer 专属写入，assistant 可读取引用
```

### 与 openspec-archivist

```
协作场景:

1. archivist 清理 references/spec.md 中的分析文档条目:
   - 检查目标文档是否存在: test -f .claude/analysis/{文件名}.md
   - 文档存在 → Keep
   - 文档已删除 → Archive（标记 [DELETED]）
   - 文档已移动 → Archive（标记 [MOVED]，如能定位新路径则更新）
   - 总览条目中的文档数与实际不符 → Stale-Warn

2. archivist 清理 learned/spec.md 中 explorer 反哺的条目:
   - 与普通条目相同标准（按 learned/spec.md 判断框架）
   - 无特殊处理

3. archivist 清理 architecture/spec.md 中 explorer 记录的条目:
   - 与普通条目相同标准（按 architecture/spec.md 判断框架）
   - 无特殊处理

4. archivist 不负责清理 .claude/analysis/ 目录:
   - 该目录下的文档由用户决定保留/删除
   - 如用户删除了文档，archivist 清理 references/spec.md 中的索引
```

### 与 OpenSpec CLI

```
协作场景:

1. 探究前检查 OpenSpec 变更:
   - 运行 openspec list 获取活跃变更
   - 如有相关变更，优先分析相关模块

2. 探究结果可指导变更:
   - 分析文档可作为 /opsx:propose 的输入
   - 架构发现可作为 design.md 的参考
   - 关键文件索引可帮助 /opsx:apply 定位代码
```

## 探究输出物清单

每次探究完成后，应产出：

```
必须产出:
  ✅ .claude/analysis/{主题}.md — 1-N 份分析文档
  ✅ references/spec.md 索引条目 — 每份文档对应一条 R 编号条目
  ✅ learned/spec.md 知识反哺 — 探究中发现的关键知识
  ✅ architecture/spec.md 架构发现 — 探究中发现的架构模式和决策

条件产出:
  📎 references/spec.md 总览条目 — 生成 3 份以上文档时
  📎 文档间交叉引用更新 — 宏观模式下
  📎 references/spec.md 区域初始化 — 首次写入时缺少"项目分析文档"区域
```

---

## 关键原则

```
目标驱动，每次探究有明确目的
深度优先，优先理解核心路径而非广度覆盖
不重复探究，先检查已有文档和知识
探究不修改代码，只阅读和生成文档
索引必注册，每份分析文档必须在 references/spec.md 有索引
知识必反哺，关键发现同步到 learned/spec.md
架构必记录，架构发现同步到 architecture/spec.md
来源标注，分析文档头部标注项目和分支
交叉引用，关联文档互相引用
外科手术式更新，写入 references/learned/architecture 时只追加必要内容
禁止全量覆盖 — 见 `CLAUDE.md → 五.7、文件编辑铁律`
grep 友好，所有条目有编号标记，支持精确搜索
与 assistant/archivist 各司其职，互不冲突
与 OpenSpec CLI 无缝集成
禁止只进行 web search 而不实际阅读项目代码就生成文档
```

---

## Red Flags

```
探究前:
❌ 不检查 references/spec.md/learned/spec.md 就开始探究 → 重复工作
❌ 不确认探究目标和范围就深入阅读 → 方向偏离
❌ 目标过大不拆分主题 → 产出质量差

探究中:
❌ 修改项目源码 → 探究者不修改代码
❌ 只阅读不记录关键发现 → 知识丢失
❌ 追踪调用链过深陷入细节 → 偏离目标
❌ 生成的文档没有关键文件索引表 → 不实用

探究后:
❌ 不在 references/spec.md 注册索引 → 文档难以发现
❌ 不反哺 learned/spec.md → 知识碎片化
❌ 不记录 architecture/spec.md → 架构发现丢失
❌ 不标注来源（项目/分支）→ 文档无法追溯
❌ 宏观模式下不建立文档间交叉引用 → 文档孤立

与其他 Skill:
❌ explorer 写入 references/spec.md 时覆盖 assistant 的条目 → 数据丢失
❌ explorer 写入 learned/spec.md 时不遵循 L 编号体系 → 编号冲突
❌ explorer 写入 architecture/spec.md 时不遵循 A 编号体系 → 编号冲突
❌ references/spec.md 中缺少"项目分析文档"区域就直接追加 → 区域混乱
❌ 生成文档到 openspec/specs/ 下 → 位置错误（应在 .claude/analysis/）
❌ 使用 Write 全量覆盖已有文档 → 内容丢失 violation（必须用 Edit 精准替换）
```
