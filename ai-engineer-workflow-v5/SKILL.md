---
name: ai-engineer-workflow-v5
description: V5 + OpenSpec 集成。强化验证、防止蔓延、架构反思、需求完整性、TDD铁律、BDD智能缺口、OpenSpec 变更管理。
---

# AI Engineer Workflow V5 — OpenSpec 集成版

**强化验证、防止蔓延、架构反思、需求完整性、TDD铁律、BDD智能缺口、OpenSpec 变更管理**

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
| **本 workflow** | 主执行 | brainstorm → plan → execute → review → complete | 全流程 |
| **Karpathy** | 监察层 | 原则监察 | 全流程 |
| **BDD** | 缺口发现 | 智能扫描 + 用户选择 + 场景草图 | Phase 1 |
| **TDD** | 测试监察 | Iron Law + Verify RED/GREEN | Phase 3 |
| **OpenSpec** | 变更管理 | 变更提案 + 增量规格 + 归档 | Phase 1-4 |

**协作边界**：
- workflow 负责**执行流程**，Gate/Loop 控制
- Karpathy 负责**原则监察**，违规即报
- BDD 负责**缺口发现 + 用户选择**，Phase 1 强制询问
- TDD 负责**测试铁律**，Phase 3 强制执行
- OpenSpec 负责**变更管理**，Phase 1 创建变更，Phase 4 归档变更

---

## Karpathy 监察（全流程自动激活）

**原则定义**：见 `CLAUDE.md → 一、Karpathy Guidelines`

本 workflow 全程监控以下 4 项原则的遵守情况：

| 原则 | 在 workflow 中的约束对象 | 特殊决策权 |
|------|--------------------------|-----------|
| **Think Before Coding** | 所有 Phase | — |
| **Implementation Simplicity** | 实现方式、代码结构、技术选型 | — |
| **Requirements Integrity** | 需求范围、功能约束 | **必须用户 approval** |
| **Surgical Changes** | Phase 3 | — |

**与 code-refactoring plugin 协调**：
- 用户明确说"重构" → 调用 plugin，Surgical Changes 暂停
- 用户说"修复"/"添加功能" → Surgical Changes 生效，不调用 plugin
- 发现需重构 → 先报告获 approval → 再调用

**违规处理流程**：检测到违反任一原则 → 立即报告 → 用户未 approve 前不得进入下一 Phase。

### Requirements Integrity 违规处理

**原则定义**：见 `CLAUDE.md → 一.5 Requirements Integrity`

本 workflow 的违规处理流程：

```
发现未经用户确认的需求裁剪
  → 立即报告
  → 用户未 approve 前不得进入 Phase 3
```

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

## TDD 监察（Phase 3 自动激活）

**方法论定义**：见 `CLAUDE.md → 六、TDD 方法论`（Iron Law、Red-Green-Refactor、Verify RED/GREEN、测试质量标准、常见借口）

本 workflow 中 TDD 的执行绑定：

```
Phase 3 遵循 TDD Iron Law（定义见 CLAUDE.md）

本 workflow 执行铁律：
  1. 确定变更范围
  2. 建立测试覆盖变更范围
  3. Verify Current State → 展示输出
  4. Make Change
  5. Verify New State → 展示输出
  6. Done
```

循环引用：`RED → Verify RED → GREEN → Verify GREEN → REFACTOR`（完整定义见 CLAUDE.md）

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

Phase 3 (EXECUTE) → /opsx:apply
  - 按 tasks.md 任务清单实施
  - 每个任务完成后勾选

Phase 4 (COMPLETE) → /opsx:archive
  - 归档完成的变更
  - 增量规格合并到 specs/
```

### 与 openspec-assistant 同步

```
同步时机：
  - /opsx:propose 后 → assistant 同步任务到 .claude/docs/tasks.md
  - /opsx:apply 后 → assistant 更新 tasks.md 状态
  - /opsx:archive 后 → assistant 从 tasks.md 移除已完成任务

同步方式：
  - assistant 读取 openspec/changes/<name>/tasks.md
  - 同步到 .claude/docs/tasks.md（标记来源 change）
  - 保持双向一致性
```

### 归档位置

`openspec archive` 后的归档位于 `openspec/archive/<日期>-<change-name>/`。Gate 5 验证若发现 carrier change（archivist 步骤 4-12 触发），额外确认：`openspec validate --changes` 通过 + 源文档有对应 `<!-- arc:` 指引。

---

## 六个门控（GATES）

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

---

### Gate 2: Requirements Completeness

**位置**：Phase 2 结束 → Phase 3 前

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

---

### Gate 3: Test Witness

**位置**：每个 task 开始前

```
遵循 TDD Iron Law（见 TDD 监察）

✅ 确定变更范围
✅ 存在测试覆盖变更范围
✅ Verify Current State 已展示输出
✅ 当前状态符合预期（RED/GREEN）

不符合 → 必须先建立测试
```

---

### Gate 4: Two-Stage Review

**位置**：每个 task 完成后

```
严格顺序：
  1. Spec compliance review（先）
  2. Code quality review（后）

❌ spec compliance ✅ 前开始 code quality
❌ 有 open Critical/Important issues 时继续下一 task

Issue 级别：
  Critical：立即修复
  Important：下一 task 前修复
  Minor：记录，稍后处理
```

---

### Gate 5: Evidence-Based Verification

**位置**：任何声明工作状态时

```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE

步骤：
  1. IDENTIFY：什么命令证明？
  2. RUN：执行完整命令
  3. READ：完整输出 + exit code
  4. EXTRACT：展示关键输出片段 ← 强制展示证据
  5. VERIFY：输出确认声明？
  6. ONLY THEN：做出声明
```

**验证格式（强制）**：

| 验证项 | 命令 | 输出片段 | 结论 |
|--------|------|----------|------|
| 测试 | cargo test | "32 passed, 0 failed" | ✅ |
| Clippy | cargo clippy | "0 warnings" | ✅ |

**禁止**：只说 "tests pass" 无输出证据、使用 "应该/大概/似乎"

---

### Gate 6: Stop-On-Blocker + 3-Failure Reflection

**位置**：Phase 3 全程监测

| 障碍 | 检测点 | 行为 |
|------|--------|------|
| 缺失依赖 | GREEN 编译失败 | STOP → 报告 → 提供安装命令 |
| 测试 errors | Verify Current/New | STOP → 报告 → 分析原因 |
| 跳过 Verify | 任何变更 | STOP → 补充验证 |
| "太简单不用测" | 任何阶段 | STOP → 违反 Iron Law |
| 无测试变更代码 | Phase 3 | STOP → 建立测试 |
| 指令不清晰 | 任何阶段 | STOP → 问用户澄清 |
| 计划缺口 | task 无法完成 | STOP → 回 Phase 2 补充 |
| 验证失败 3次 | 同一验证点 | STOP → 问用户决策 |
| 同一 bug 修复 3次 | 仍未解决 | 架构反思模式 |

**三次失败架构反思**：

```
同一问题修复尝试 ≥ 3 次仍未解决：

→ 强制切换到架构分析模式：
   1. STOP 当前修复
   2. 记录：每次修复的尝试方法和失败症状
   3. 架构检查：
      - 每次修复暴露新的 shared state/coupling？
      - 需要"大规模重构"才能实现？
      - 每次修复在其他地方产生新症状？
   4. 决策：
      - 任一为 YES → 架构问题，讨论重构
      - 全为 NO → 回 Phase 1（需求理解错误）

禁止：
❌ 继续第 4、5 次相同类型的修复尝试
❌ 不记录失败历史就盲目 retry
```

---

## 五个循环（LOOPS）

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

### Loop 3: Red-Green-Refactor（每个 task）

```
[变更范围确认] → [Gate 3] → TDD 循环（见 TDD 监察）→ [Gate 5] → [Gate 4]
```

---

### Loop 4: Review-Fix

```
Stage 1: Spec compliance → Issues? → Fix → Re-check
                              ↓ ✅
Stage 2: Code quality → Issues? → Fix → Re-check
                              ↓ ✅
                   [Gate 5] → Fresh verification evidence
                              ↓ ✅
                   Task complete → Mark completed
```

**分歧 > 2 轮** → 提交用户裁决

---

### Loop 5: Complete Decision

```
Run test → [Gate 5] → 0 failures → 声明 → /opsx:archive → 4 options → Execute
                    → N failures → Fix → Loop

4 Options：Merge locally / Create Pull Request / Keep branch / Discard（需 typed confirmation）
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
流程：Plan Agent → Lite Plan Check → Requirements Completeness Check → Self-review → User review → [Gate 2] → Phase 3
```

如果计划太长请分步写入

### Phase 3: EXECUTE

```
模式：Inline（简单任务） / Subagent（复杂任务、并行）

调用：
  Inline：TaskCreate/TaskUpdate 工具 + TDD Iron Law
  Subagent：Agent 工具委托
  OpenSpec：/opsx:apply

流程骨架：
  Load plan → Create TodoWrite
  **TaskCreate 铁律**: 每 Phase/Step 独立 Task，不合并；跳过必标 "SKIPPED: {原因}"; 报告前 TaskList 确认
  For each task:
    1. [变更范围确认]
       - grep -rn {目标符号} → 评估改动影响，找到所有引用
    2. Mark in_progress
    3. [Gate 3] 建立测试 + Verify Current State
       - Read + grep -rn {相关符号} → 理解当前实现
       - Read 相关源文件 → 拉源码参考
    4. [Loop 3] TDD 循环（Iron Law + 状态见证）
    5. [Gate 5] Verify New State（展示输出片段）
       - grep -rn {改动符号} → 验证所有调用已更新
    6. [Gate 4 + Loop 4] Review
       - Read + grep -rn {模块/符号} → 整体复查
    7. Mark completed（仅 Gate 5 通过后）

  All tasks → Phase 4
```

### Phase 4: COMPLETE

```
调用：Loop 5（4 选项决策）+ /opsx:archive
Announce："Phase 4: 归档变更 + 完成分支"
流程：[Loop 5] → **5 问对账式自审（PASS 才 END）** → /opsx:archive → END

5 问对账式（必答，禁用 "基本/大致/应该/差不多"）:
  1. 我执行了技能里的每一步吗？→ 按 Step 列证据（命令 + 输出摘录），❌ 禁止 "Phase 0~5 全部覆盖"
  2. 跳过的步骤有显式记录原因吗？→ 区分 "主动跳过"（含检测证据） vs "被动遗漏"（违规）
  3. 关键 Gate/Loop 都通过了吗？→ 按 Gate 列证据
  4. 有输出证据吗？→ 粘贴关键命令的输出片段（不只是说 "运行了"）
  5. 报告前读过 TaskList 吗？→ 列出 TaskList 当前状态
  任一为 NO → 不允许声明完成
```

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

Phase 3:
❌ 无测试变更代码 → Iron Law violation
❌ 跳过 Verify Current State → Iron Law violation
❌ 跳过 Verify New State → Iron Law violation
❌ "Tests pass" without running → Gate 5 violation
❌ "Tests pass" without 输出片段 → Gate 5 violation
❌ "太简单不用测" → Iron Law violation
❌ 变更超出 PLAN 范围 → Surgical Changes violation
❌ 继续第 4 次相同修复 → 3-Failure violation

Phase 4:
❌ 未归档 OpenSpec 变更 → 变更管理 violation
❌ 5 问自审未通过就 END → 自审 violation

General:
❌ "Should/probably" → Verification violation
❌ Gate BLOCK 不记录 → Workflow 违规（见 CLAUDE.md）
❌ 看到一处已存在就推断全部已检查（必须逐项独立运行检查命令）→ Self-audit violation
❌ 用 "基本/大致/应该" 代替实际输出（必须贴输出摘录）→ Self-audit violation
❌ 5 问自审用 "Phase 0~5 全部覆盖" 泛化掩盖空洞 → Self-audit violation

```

---

## Key Principles

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
```
