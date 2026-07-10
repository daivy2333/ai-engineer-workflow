---
name: ai-engineer-workflow-v5-ulw
description: UltraWork V5 + OpenSpec 集成 + TDD监察 + BDD智能缺口。强制探索、Plan Agent、深度委托、Manual QA、零妥协、Auto-mode aware。
---

# AI Engineer Workflow V5 — UltraWork Mode + OpenSpec + CodeGraph

**完整版：Requirements Completeness Gate 内嵌，TDD铁律，BDD智能缺口，零妥协，OpenSpec 变更管理，CodeGraph 智能索引**

---

## CodeGraph 铁律（默认机制，非可选工具）

> 本节为全局铁律。所有 Phase/Pattern 默认遵循，不再重复声明。

### 工具映射（意图 → 工具）

| 意图 | 工具 | 说明 |
|------|------|------|
| 找符号位置 | `codegraph_search` | 只定位，不带源码 |
| 拉单个完整源码 | `codegraph_node` | 同名重载时返回所有定义 |
| 理解模块 / 追踪流程 | `codegraph_explore` ⭐ | 一次返回按文件分组的源码（首选） |
| 找上游调用 | `codegraph_callers` | 重构影响分析、debug 入口 |
| 找下游调用 | `codegraph_callees` | 依赖链追踪 |
| 评估改动影响 | `codegraph_impact` | 跨文件影响范围 |
| 看目录结构 | `codegraph_files` | 比 `ls` 快 |
| 检查索引健康 | `codegraph_status` | 用前必检 |

### 守则（必须遵守）

- 找代码 → 优先 `codegraph_explore`，**禁止**先 `grep` / `ls` / `Read`
- **禁止**用 `Read + Grep` 兜底（CodeGraph 是预建索引，重复更慢更贵）
- **禁止**把 MCP 工具当 bash 命令调用（`codegraph_explore` ≠ `codegraph explore`）
- **禁止**用 `grep` 反向验证 CodeGraph 结果（信任 AST 解析）
- **禁止** CodeGraph 不可用时静默降级 → 必先 `codegraph_status` 排查，提示用户修复
- 看到 ⚠️ stale banner → 仅对 banner 列出的文件 `Read`，其他继续信任 CodeGraph
- 看到 `command not found` → 先确认是 MCP 工具调用方式错误（不是 MCP 不可用）

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

## 六系统分工

| 系统 | 角色 | 职责 | 激活时机 |
|------|------|------|----------|
| **本 workflow** | 主执行 | brainstorm → plan → execute → review → complete | 全流程 |
| **Karpathy** | 监察层 | 原则监察 | 全流程 |
| **BDD** | 缺口发现 | 智能扫描 + 用户选择 + 场景草图 | Phase 1 |
| **TDD** | 测试监察 | Iron Law + Verify RED/GREEN | Phase 3 |
| **OpenSpec** | 变更管理 | 变更提案 + 增量规格 + 归档 | Phase 1-4 |
| **CodeGraph** | 代码智能 | 预建代码索引 | Phase 2-3 |

**协作边界**：
- workflow 负责**执行流程**，Gate/Loop 控制
- Karpathy 负责**原则监察**，违规即报
- BDD 负责**缺口发现 + 用户选择**，Phase 1 强制询问
- TDD 负责**测试铁律**，Phase 3 强制执行
- OpenSpec 负责**变更管理**，Phase 1 创建变更，Phase 4 归档变更
- CodeGraph 负责**代码理解**，Phase 2-3 加速代码探索

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
违规处理：
  发现未经用户确认的需求裁剪 → 立即报告
  用户未 approve 前不得进入 Phase 3
```

---

## BDD 智能缺口（Phase 1 自动激活）

**方法论定义**：见 `CLAUDE.md → 五、BDD 方法论`（原则定义、缺口扫描规则、标准默认假设、Auto Mode 协调）

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

### 与 Auto Mode 协调

```
场景 1：Auto Mode + 用户选择 "用默认假设"
  → 自动生成场景草图 → 自动继续 → 不等待

场景 2：Auto Mode + 用户选择 "跳过"
  → 记录缺口 → 自动继续 → 不等待

场景 3：Auto Mode + 用户选择 "手动补充"
  → STOP → 等待用户补充 → 非 Auto Mode 行为

关键：用户一次选择，不多次循环
```

---

## TDD 监察（Phase 3 自动激活）

**方法论定义**：见 `CLAUDE.md → 六、TDD 方法论`（Iron Law、Red-Green-Refactor、Verify RED/GREEN、REFACTOR、测试质量标准、常见借口）

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
  - 可跳过 librarian（保留 CodeGraph 探索）
  - Metis 可选
  - 仍需 BDD 缺口扫描 + AskUserQuestion
  - 仍需 Scenario Sketch
  - 仍需 /opsx:propose 创建 OpenSpec 变更

Phase 2 大幅简化：
  - plan agent 可选（保留 BDD）
  - Momus 跳过
  - Requirements Traceability Matrix 可选
  - OpenSpec tasks.md 简化（不需要完整 design.md）

Phase 3-4 完整保留：
  - TDD 铁律仍生效
  - Gate 5 验证仍必需
  - /opsx:apply 仍按 tasks.md 实施
  - /opsx:archive 仍归档

为什么这样设计：
  - 避免对小任务"过度杀伤"导致流程被整体跳过
  - 保留核心约束（OpenSpec 追溯、Gate 5 验证）
  - 跳过的是"分析规划"层级（Metis/Momus/plan agent），不是"执行验证"层级
```

**判定示例**：

```
✅ "修这个 5 行 bug" → 轻量模式
   - 1 文件，5 行改动
   - 跳过 Metis/Momus/plan agent
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

**与 Workflow 主流程的关系**：

```
轻量模式 vs 标准模式 是正交维度：
  - 轻量：减少分析规划层（跳过 Metis/Momus/plan agent）
  - 标准：走完整 Phase 1-4
  - 两者不可组合（轻量本身就是简化版标准模式）
```

---

## 六个门控（GATES）

### Gate 1: Design Approval + BDD Check

**位置**：Phase 1 结束 → Phase 2 前

```
检查项：
  ✅ brainstorming skill 完成
  ✅ AskUserQuestion 已询问（场景缺口）
  ✅ 用户已回答
  ✅ 生成了 Scenario Sketch（模型生成）
  ✅ OpenSpec 变更已创建（/opsx:propose 或 /opsx:explore）

不强制：
  ❌ Coverage Matrix 表格全部填写
  ❌ Given-When-Then 格式检查

Phase 1 输出：Approved Requirements List + Scenario Sketch + OpenSpec 变更
触发：用户说 "approved" / "继续" / "开始计划"
附加：展示 Scenario Sketch 供确认
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
     → 仍需 BDD 缺口扫描，但 Metis 可选

agent 自主判断豁免 → 不允许
  - "我判断任务够清晰" / "用户描述够具体" → 这些不构成豁免
  - 必须用户原话显式 approve 才行
```

---

### Gate 2: Requirements Completeness

**位置**：Phase 2 结束 → Phase 3 前

```
❌ 不开始实现、不执行 task、不调用 executing-plans
✅ Plan Agent（MANDATORY）→ Requirements Completeness Check → 用户 approve Completeness
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
  ✅ 正确：任务清单是输入，但 plan agent 的"完整性检查"和"简化"是 Gate 2 的核心价值

豁免机制（仅两种情况允许跳过 Gate 2）：
  1. 用户显式说："跳过 Gate 2" / "不用 plan" / "直接做"
     → 记录在 OpenSpec 变更的 proposal.md 中："用户显式豁免 Gate 2"
  2. 进入轻量模式 + < 2 文件 + 纯机械改动
     → plan agent 可选，但 RTM 矩阵仍需（哪怕简化版）

agent 自主判断豁免 → 不允许
  - "T1-T4 已经够清晰" / "有 OpenSpec 任务清单了" → 这些不构成豁免
  - Gate 2 的价值是"完整性检查"和"简化标注"，不是"任务细化"
```

### Gate 3: Test Witness

**位置**：每个 task 开始前

```
遵循 TDD Iron Law（见 TDD 监察）

✅ 确定变更范围
✅ 存在测试覆盖变更范围
✅ Verify Current State 已展示输出
✅ 当前状态符合预期（RED/GREEN）

不符合 → 必须先建立测试
跳过 Verify → STOP → 补充验证
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

**Manual QA（必须执行，零妥协）**：

| 场景 | 必须做什么 |
|------|-----------|
| CLI 命令 | Bash 实际运行，展示输出 |
| 构建产物 | 运行构建，验证输出 |
| API 行为 | 调用 endpoint，展示响应 |
| UI 渲染 | 浏览器验证 |
| 配置 | 加载并验证解析 |

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
⭐ CodeGraph 优先（解决 CodeGraph vs explore agent 冲突）：

有 CodeGraph 可用时：
  codegraph_status（MCP）→ codegraph_explore（MCP）→ codegraph_files（MCP）→ Metis
  → Gap Scan → AskUserQuestion → Scenario Sketch → /opsx:propose → [Gate 1]

无 CodeGraph 或 CodeGraph 不可用时：
  explore/librarian（并行）→ Metis → Gap Scan → AskUserQuestion → Scenario Sketch
  → /opsx:propose → [Gate 1]

关键：CodeGraph 已初始化时，不要用 explore 子 agent 读代码
       explore/librarian 只用于"找外部参考"（librarian）或"探索未知"
```

---

### Loop 2: Plan Revision（Phase 2）

```
plan agent → Lite Plan Check → Requirements Completeness → Momus → User review → [Gate 2]
```

---

### Loop 3: Red-Green-Refactor（每个 task）

```
[变更范围确认] → [Gate 3] → 委托到 category → [Gate 5] → [Gate 4]
```

---

### Loop 4: Review-Fix

```
Spec compliance（review-work/Momus）→ Issues? → Fix → Code quality → Issues? → Fix → [Gate 5] → Mark completed
```

**分歧 > 2 轮** → 提交用户裁决

---

### Loop 5: Complete Decision

```
Run test → [Gate 5] → review-work → git-master → /opsx:archive → 4 options → Execute

4 Options：Merge locally / Create Pull Request / Keep branch / Discard（需 typed confirmation）
```

---

## Phase 流程

### Phase 1: CLARIFY

```
调用（按优先级）：
  ⭐ 有 CodeGraph：codegraph_status + codegraph_explore + codegraph_files
     （不要用 explore 子 agent 读代码 — CodeGraph 是预建索引）
  + librarian（并行）→ 找外部参考（不读项目代码）
  + Metis（阻塞）→ 意图/边界/依赖分析
  + /opsx:explore 或 /opsx:propose → 创建 OpenSpec 变更

Announce："Phase 1: CodeGraph 探索 + 外部参考 + Metis 分析 + OpenSpec 变更创建"
输出：Approved Requirements List + Scenario Sketch + OpenSpec 变更
```

**OpenSpec 已有条目 → change 决策**：

```
场景：发现任务在 specs/ 中已有相关条目

| 已有条目位置 | 是否仍需 /opsx:propose 建 change | 理由 |
|------------|-------------------------------|------|
| optimization/spec.md | ✅ 强烈建议 | learned/spec.md 是事实记录，optimization/spec.md 是待办，但 change 是行动追溯 |
| learned/spec.md（API 路径/踩坑） | ✅ 必须 | 行动追溯（什么时候改、怎么改、改了什么）独立于事实记录 |
| architecture/spec.md（已有 ADR） | ✅ 必须 | 新 change 是对 ADR 的实施或修订，需要追溯 |
| references/spec.md（依赖） | ⚠️ 视情况 | 依赖升级可能用 change 也可能直接改 |
| 无任何条目 | ✅ 必须 | 全新需求，无记录 |

为什么"已有条目"不豁免 change：
  - learned 是"已知事实"（what is）
  - change 是"将做什么"（what to do）
  - archive.md 是"已完成的过去"（what was done）
  → 三个维度不可替代

何时可"快捷引用"：
  - 在 change 的 proposal.md 中引用已有条目
  - 例: "本 change 实施 optimization/O002 中记录的性能优化"
  - 这是追溯便利，不是豁免
```

**OpenSpec 缺失场景处理**：

```
场景：项目没有 OpenSpec 初始化

  ❌ 不豁免：跳过 /opsx:propose
  ✅ 处理：先调用 openspec-init（一次性），再继续
  → 这是 OpenSpec 体系的入口，不能跳过
```

### Phase 2: PLAN

```
调用：plan agent（MANDATORY）+ Momus（阻塞）
Announce："Phase 2: plan agent + Momus 评审 + OpenSpec 细化"
流程：plan agent → Lite Plan Check → Requirements Completeness → Momus → User review → [Gate 2]
```

如果计划太长请分步写入

### Phase 3: EXECUTE

```
核心：DELEGATE. DO NOT WORK YOURSELF.

调用：
  - category delegation（并行）→ deep/ultrabrain/visual-engineering/artistry/quick
  - oracle（阻塞）→ 架构决策/复杂 debug
  - /opsx:apply → 按任务清单实施

流程：Load plan → Create TodoWrite → For each task: [Gate 3] → 委托 → [Gate 5] → Review → Mark completed
**TaskCreate 铁律**: 每 Phase/Step 独立 Task，不合并；跳过必标 "SKIPPED: {原因}"; 报告前 TaskList 确认
```

### Phase 4: COMPLETE

```
调用：review-work（5 parallel）+ git-master + /opsx:archive
Announce："Phase 4: review-work + git-master + OpenSpec 归档"
流程：[Loop 5] → **Manual QA** → **5 问对账式自审（PASS 才 END）** → /opsx:archive → END

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
| **BDD 缺口选择** | STOP → 等待选择 | **用户选择后自动继续** |

**BDD Auto Mode 处理**：

```
Auto Mode 不跳过 AskUserQuestion（场景缺口）
但用户选择后：
  - "用默认假设" → 自动生成 Sketch → 自动继续
  - "跳过" → 记录缺口 → 自动继续
  - "手动补充" → STOP → 等待（非 Auto Mode 行为）

关键：AskUserQuestion 必须执行，但选择后可自动继续
```

---

## Skill Mapping

| Phase | Agent | 控制 |
|-------|-------|------|
| 1 | explore（并行）+ librarian（并行）+ Metis（阻塞）+ /opsx:explore 或 /opsx:propose + codegraph_explore | 并行探索 + 预规划 + 需求澄清 + 变更创建 + 代码理解 |
| 2 | plan agent（MANDATORY）+ Momus（阻塞）+ codegraph_impact | 任务分解 + 计划评审 + OpenSpec 细化 + 影响评估 |
| 3 | category delegation + oracle（阻塞）+ /opsx:apply + codegraph_* | 深度委托 + 架构决策 + 任务实施 + 代码索引 |
| 4 | review-work + git-master + /opsx:archive + codegraph_affected | Review + Git 操作 + 变更归档 + CI 集成 |

**监察层**：Karpathy 全 Phase、BDD Phase 1、TDD Phase 3、CodeGraph Phase 2-3，违规即报

---

## Category Domain + 委托规范（MANDATORY 匹配）

| Task Domain | Category | 说明 |
|-------------|----------|------|
| UI/样式/动画 | visual-engineering | 前端视觉类工作 |
| 硬逻辑/算法 | ultrabrain | 复杂推理、架构决策 |
| 自主研究+实现 | deep | 需要深入调研再实现的任务 |
| 非常规方案 | artistry | 需要跳出常规思维的问题 |
| 简单修改 | quick | 单文件修改、简单变更 |

---

## Red Flags

```
Phase 1:
❌ 未并行启动 explore/librarian → 效率 violation
❌ CodeGraph 可用时仍用 explore agent 读代码 → CodeGraph 优先 violation（取代上一行）
❌ Metis 未调用 → 预规划 violation
❌ 未询问场景缺口 → BDD violation
❌ 未创建 OpenSpec 变更 → 变更管理 violation
❌ 任务"看起来清晰"就跳过 Gate 1 → Gate 豁免 violation
❌ 自主判断豁免 Gate（需用户显式 approve 或轻量模式）→ 越权 violation
❌ specs/ 已有条目就跳过 change → OpenSpec 追溯 violation

Phase 2:
❌ TBD/TODO in plan → Lite Plan Check violation
❌ Requirements Traceability Matrix 未完成 → Gate 2 violation
❌ 跳过 plan agent → UltraWork violation
❌ Momus 未调用 → 计划评审 violation
❌ OpenSpec 未完善 → 变更管理 violation
❌ T1-T4 已清晰就跳过 Gate 2 → Gate 豁免 violation
❌ 轻量模式超范围使用（如 > 3 文件也用）→ 轻量模式越界 violation

Phase 3:
❌ 不委托直接自己写代码 → 委托 violation
❌ category 不匹配 task domain → Category violation
❌ 无测试变更代码 → Iron Law violation
❌ "Tests pass" without 输出片段 → Gate 5 violation

Phase 4:
❌ Skip Manual QA → UltraWork violation
❌ 未调用 review-work/git-master → Review violation
❌ 未归档 OpenSpec 变更 → 变更管理 violation
❌ 用 Read + Grep 而不用 codegraph_explore → CodeGraph 优先 violation
❌ 开 Explore 子 agent 读文件 → 浪费 violation
❌ 委托提示词中缺 codegraph_* 指令 → 委托 violation
❌ 未用 codegraph_impact 评估改动 → 影响评估 violation

General:
❌ "Should/probably" → Verification violation
❌ 未使用 task_id follow-up → Session Continuity violation
❌ 子 agent prompt 中缺失关键知识，期望它自己 skill() 加载 → 委托 violation
❌ 先 grep 反向验证 codegraph 结果 → 信任 violation
❌ 看到一处已存在就推断全部已检查（必须逐项独立运行检查命令）→ Self-audit violation
❌ 用 "基本/大致/应该" 代替实际输出（必须贴输出摘录）→ Self-audit violation
❌ 5 问自审用 "Phase 0~5 全部覆盖" 泛化掩盖空洞 → Self-audit violation
```

---

## Key Principles

```
六系统协作：workflow（执行）→ Karpathy（监察）→ BDD（缺口发现）→ TDD（测试）→ OpenSpec（变更管理）→ CodeGraph（代码理解）

原生 Agent 核心能力：
  explore/librarian：并行探索（FREE）
  Metis/Momus/oracle：阻塞咨询（EXPENSIVE）
  plan agent：MANDATORY
  category delegation：深度委托

Gate 控制 Phase 进入
Loop 控制 Phase 内完成

验证铁律：必须展示输出片段
TDD 铁律：变更必须有测试见证
委托铁律：不委托直接自己写代码
Skill 隔离铁律：skill() 仅限主 agent 调用，子 agent 所需知识全部写入 prompt
CodeGraph 铁律：用 codegraph_explore 替代 Read + Grep，不开 Explore 子 agent
遇阻即停不猜测
三次失败必须反思
Task Complete 条件：Gate 5 通过后才能 Mark completed

OpenSpec 集成：变更生命周期管理
CodeGraph 集成：按顶部铁律块使用
Auto Mode 适配
```
