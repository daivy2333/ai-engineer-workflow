---
name: openspec-plan
description: 需求探索、BDD缺口扫描、计划制定、OpenSpec变更创建 — Phase 1-2 的前置工作流。完成后进入 openspec-act 执行。
---

# OpenSpec Plan — 探索与计划工作流

---

## 核心约束

完整定义见 `CLAUDE.md → 四、核心执行约束（8 条）`

本 workflow 在此约束下执行：

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

## 五系统分工

| 系统 | 角色 | 职责 | 激活时机 |
|------|------|------|----------|
| **本 workflow** | 主执行 | 需求探索 → 计划制定 → 变更创建 | Phase 1-2 |
| **Karpathy** | 监察层 | 原则监察 | 全流程 |
| **BDD** | 缺口发现 | 智能扫描 + 用户选择 + 场景草图 | Phase 1 |
| **TDD** | 测试监察 | Iron Law + Verify RED/GREEN | Phase 3 |
| **OpenSpec** | 变更管理 | 变更提案 + 增量规格 + 归档 | Phase 1-4 |

**协作边界**：
- workflow 负责**执行流程**，Gate/Loop 控制
- Karpathy 负责**原则监察**，违规即报
- BDD 负责**缺口发现 + 用户选择**，Phase 1 强制询问
- TDD — 本 skill 不激活（归 openspec-act）
- OpenSpec 负责**变更管理**，Phase 1 创建变更，Phase 4 归档变更
- 本 skill 覆盖 Phase 1-2，Phase 3-4 由 openspec-act 负责

---

## Karpathy 监察（全流程自动激活）

> 原则定义 + 监控表 + 违规处理流程 → 见 `CLAUDE.md → 一、Karpathy Guidelines`
> 本 skill 重点：**Requirements Integrity**（需求完整性优先于实现简化）

**违规处理流程**：检测到违反任一原则 → 立即报告 → 用户未 approve 前不得进入下一 Phase。

### Requirements Integrity 违规处理

> 见 `CLAUDE.md → 一.5 Requirements Integrity`

发现未经用户确认的需求裁剪 → 立即报告 → 用户未 approve 前不得进入 Phase 3。

---

## BDD 智能缺口（Phase 1 自动激活）

**方法论定义**：见 `CLAUDE.md → 五、BDD 方法论`（原则定义、缺口扫描规则、标准默认假设）

本 workflow 中 BDD 的执行流程：

```
Step 1：需求扫描（自动）
  读取需求 → 自动识别 Happy Path / Sad Path / Edge（扫描规则见 CLAUDE.md）

Step 2：缺口发现 → AskUserQuestion（一次）
  选项: "用默认假设补充" / "手动补充具体场景" / "跳过，需求已足够清晰"

Step 3：用户选择处理
  "用默认假设" → 按 CLAUDE.md 标准默认假设自动生成场景草图 → 继续
  "手动补充" → 询问具体缺口 → 补充 → 继续
  "跳过" → 记录缺口到 OpenSpec proposal.md → 继续

Step 4：生成场景草图（模型生成，用户确认）
  格式见 CLAUDE.md → 五、BDD 方法论，不要求 Given-When-Then 表格
```

---

## OpenSpec 集成

### 变更生命周期

```
Phase 1 (CLARIFY) → /opsx:explore 或 /opsx:propose
  - 探索需求，创建变更提案
  - 生成 proposal.md + specs/ + design.md + tasks.md

Phase 2 (PLAN) → 细化 OpenSpec 变更
  - 完善 tasks.md 任务清单
  - 完善 specs/ 增量规格
  - 完善 design.md 技术方案
```

### 与 openspec-assistant 同步

> 同步规则见 `CLAUDE.md → 五.5b、与 openspec-assistant 同步`

- /opsx:propose 后 → assistant 同步任务
- /opsx:apply 后 → assistant 更新状态
- /opsx:archive 后 → assistant 移除任务

### 归档位置

`openspec archive` 后的归档位于 `openspec/archive/<日期>-<change-name>/`。Gate 5 验证若发现 carrier change（archivist 步骤 4-12 触发），额外确认：`openspec validate --changes` 通过 + 源文档有对应 `<!-- arc:` 指引。

---

## 轻量模式（Light Mode）

**触发条件**（全部满足）：

```
✅ 改动 < 3 文件
✅ 核心代码 < 60 行
✅ 不涉及跨模块影响
✅ 不涉及架构决策
✅ 不涉及安全/数据/性能关键路径
```

**轻量模式行为**：

```
Phase 1 简化：
  - 可跳过 explore/librarian 并行探索
  - 仍需 BDD 缺口扫描 + AskUserQuestion
  - 仍需 Scenario Sketch
  - 仍需 /opsx:propose 创建 OpenSpec 变更

Phase 2 大幅简化：
  - plan agent 可选
  - Requirements Traceability Matrix 可选
  - OpenSpec tasks.md 简化（不需要完整 design.md）

Phase 3-4 完整保留 → 由 openspec-act 按标准模式执行

为什么这样设计：
  - 避免对小任务"过度杀伤"导致流程被整体跳过
  - 保留核心约束（OpenSpec 追溯、Gate 5 验证）
  - 跳过的是"分析规划"层级，不是"执行验证"层级
```

**判定示例**：

```
✅ "修这个 5 行 bug" → 轻量模式
   - 1 文件，5 行改动
   - 跳过 plan agent
   - 仍需 /opsx:propose + Gate 5 验证

✅ "改一个函数签名" → 轻量模式
   - 1-2 文件，< 20 行
   - 跳过 plan agent
   - 仍需 OpenSpec 变更（签名变化是 breaking change）

❌ "重构认证模块" → 标准模式
   - 多文件，架构改动
   - 走完整 Phase 1/2 流程

❌ "修复内存泄漏" → 标准模式
   - 性能关键路径
   - 涉及架构决策（要不要重写）
```

---

## 门控（Phase 1-2）

### Gate 1: Design Approval + BDD Check

**位置**：Phase 1 结束 → Phase 2 前

```
检查项：
  ✅ BDD 智能缺口完成（场景扫描 + 用户选择）
  ✅ AskUserQuestion 已询问（场景缺口）
  ✅ 用户已回答
  ✅ 生成了 Scenario Sketch（模型生成）
  ✅ OpenSpec 变更已创建（/opsx:propose 或 /opsx:explore）

触发：用户说 "approved" / "继续" / "开始计划"
```

**Gate 1 豁免条款**：

```
⚠️ 关键：即使任务"看起来清晰"也必须过 Gate 1
  ❌ 错误："用户给了 4 个具体子任务，够清晰了，跳过 Phase 1"
  ✅ 正确：任务清晰是好事，但仍要 BDD 缺口扫描（可能有未暴露的边角）

豁免机制（仅两种情况允许跳过 Gate 1）：
  1. 用户显式说："跳过 Gate 1" / "直接做" / "不用 clarify"
     → 记录在 OpenSpec 变更的 proposal.md 中："用户显式豁免 Gate 1"
  2. 进入轻量模式（见上文）
     → 仍需 BDD 缺口扫描，但探索可简化

agent 自主判断豁免 → 不允许
  - "我判断任务够清晰" / "用户描述够具体" → 这些不构成豁免
  - 必须用户原话显式 approve 才行
```

---

### Gate 2: Requirements Completeness

**位置**：Phase 2 结束 → Phase 3 前（进入 openspec-act 前）

```
❌ 不开始实现、不执行 task、不调用 executing-plans
✅ Lite Plan Check → Requirements Completeness Check → 用户 approve Completeness
✅ OpenSpec tasks.md 已完善
✅ OpenSpec specs/ 已完善
✅ OpenSpec design.md 已完善
```

**Requirements Traceability Matrix**：

| Requirement | Task(s) | Coverage | Simplification | Status |
|-------------|---------|----------|----------------|--------|
| R1: 功能 X | T1, T2 | 100% | None | ✅ |
| R2: 功能 Y | T3 | 80% | "Z 化为 W" | ⚠️ |
| R3: 功能 Z | - | 0% | None | ❌ |

```
Status：
  ✅ = Covered
  ⚠️ = Simplified（需用户 approval）
  ❌ = Missing（必须修复）

Gate 2 通过：所有 ✅、所有 ⚠️ 已获 approval、无 ❌
```

**Gate 2 豁免条款**：

```
⚠️ 关键：即使有完整任务清单（T1-T4）也必须过 Gate 2
  ❌ 错误："用户给了 T1-T4，够具体了，跳过 plan agent 和 RTM 矩阵"
  ✅ 正确：任务清单是输入，但 plan agent 的"完整性检查"和"简化标注"是 Gate 2 的核心价值

豁免机制（仅两种情况允许跳过 Gate 2）：
  1. 用户显式说："跳过 Gate 2" / "不用 plan" / "直接做"
     → 记录在 OpenSpec 变更的 proposal.md 中："用户显式豁免 Gate 2"
  2. 进入轻量模式 + < 2 文件 + 纯机械改动
     → plan agent 可选，但 RTM 矩阵仍需（哪怕简化版）

agent 自主判断豁免 → 不允许
  - "T1-T4 已经够清晰" / "有 OpenSpec 任务清单了" → 这些不构成豁免
  - Gate 2 的价值是"完整性检查"和"简化标注"，不是"任务细化"
```

---

## 循环（Phase 1-2）

### Loop 1: Clarification（Phase 1）

```
Explore → Decompose → Gap Scan → AskUserQuestion（一次）→ Scenario Sketch → /opsx:propose → [Gate 1]
```

---

### Loop 2: Plan Revision（Phase 2）

```
Plan Agent → Lite Plan Check → Requirements Completeness Check → Task Mapping → Self-review → User review → [Gate 2]
```

---

## Phase 流程

### Phase 1: CLARIFY

```
调用：BDD 智能缺口（缺口发现）+ /opsx:explore 或 /opsx:propose（变更创建）
Announce："Phase 1: 需求探索 + OpenSpec 变更创建"
输出：Approved Requirements List + Scenario Sketch + OpenSpec 变更
```

### Phase 2: PLAN

```
调用：Plan Agent（轻量计划检查）+ /opsx:propose（OpenSpec 变更完善）
Announce："Phase 2: 计划细化 + OpenSpec 完善"
流程：Plan Agent → Lite Plan Check → Requirements Completeness Check → Self-review → User review → [Gate 2] → 进入 openspec-act Phase 3
```

如果计划太长请分步写入

---

## Auto Mode

**行为准则**：见 `CLAUDE.md → 七、Auto Mode 行为准则`

本 workflow 下各场景的行为映射：

| 场景 | Interactive | Auto Mode |
|------|-------------|-----------|
| Gate 6 blocker | STOP → 等待决策 | 记录 → 自动尝试下一方案 |
| Review 发现问题 | STOP → 等待修复 | 自动修复 → 继续 |
| 测试失败 | STOP → 报告 | 自动调试 → 继续 |
| 用户 approval | 等待 | 自动继续 |
| BDD 缺口选择 | STOP → 等待选择 | 用户选择后自动继续 |
| OpenSpec 变更创建 | 等待用户 approve | 自动继续 |

**Auto Mode 触发**：

- 用户说"auto 模式"、"自动模式"、"完全自动"、"auto mode" → 进入 Auto Mode
- 默认 Interactive（最常见）；Auto Mode 用于批处理、无人值守场景
- BDD 缺口、Gate 6 反射等决策点：用户先选一次策略 → Auto Mode 按策略自动继续

> Phase 3-4 Auto Mode 行为见 openspec-act

---

## Red Flags

```
Phase 1:
❌ "Too simple to need design" → Gate 1 violation
❌ Code before design approved → Gate 1 violation
❌ 未询问场景缺口 → BDD violation
❌ 未创建 OpenSpec 变更 → 变更管理 violation

Phase 2:
❌ TBD/TODO in plan → Lite Plan Check violation
❌ Requirements Traceability Matrix 未完成 → Gate 2 violation
❌ Simplification 未经用户 approval → Gate 2 violation
❌ OpenSpec tasks.md 未完善 → 变更管理 violation

General:
> 完整列表见 `CLAUDE.md → Red Flags`

❌ "Should/probably" → Verification violation
❌ Gate BLOCK 不记录 → Workflow 违规
❌ 自我审计三项（逐项检查/贴输出/5问覆盖）→ Self-audit violation
```

---

## Key Principles

> 通用原则详见 `CLAUDE.md → 规则`。以下为 Phase 1-2 侧重。

```
五系统协作：
  workflow（执行）→ Karpathy（监察）→ BDD（缺口发现）→ TDD（测试）→ OpenSpec（变更管理）
  权责清晰，违规即报

Requirements Integrity 优先于 Simplicity（定义见 CLAUDE.md）
Iron Law 优先于 所有借口
Gap Scan 优先于 手动填写表格

Gate 控制 Phase 进入
Loop 控制 Phase 内完成

验证铁律：必须展示输出片段
TDD 铁律：变更必须有测试见证
遇阻即停不猜测
三次失败必须反思：禁止继续第4次修复
Task Complete 条件：Gate 5 通过后才能 Mark completed

OpenSpec 集成：变更生命周期管理
Auto Mode 适配

本 skill 完成后 → 进入 openspec-act 执行 Phase 3-4
```

---

## 与其他 Skill 的关系

| Skill | 关系 | 说明 |
|-------|------|------|
| openspec-act | 下游 | 本 skill 完成后进入 openspec-act 执行 Phase 3-4 |
| openspec-assistant | 协作 | 日常文档维护，变更同步 |
| openspec-archivist | 后续 | 文档膨胀时触发归档 |
