---
name: ai-engineer-workflow-v5-ulw
description: UltraWork V5 + TDD监察 + BDD智能缺口。强制探索、Plan Agent、深度委托、Manual QA、零妥协、Auto-mode aware。
---

# AI Engineer Workflow V5 — UltraWork Mode

**完整版：Requirements Completeness Gate 内嵌，TDD铁律，BDD智能缺口，零妥协**

---

## 核心约束

```
1. 不探索清楚不实现
2. 不计划清楚不实现
3. 不完整覆盖需求不实现
4. 不测试通过不提交
5. 不验证成功不声明
6. 三次失败必须反思
7. 不见见证不变更（TDD Iron Law）
8. 不见场景缺口不进设计（BDD智能缺口）
```

---

## 四系统分工

| 系统 | 角色 | 职责 | 激活时机 |
|------|------|------|----------|
| **本 workflow** | 主执行 | brainstorm → plan → execute → review → complete | 全流程 |
| **Karpathy** | 监察层 | 原则监察 | 全流程 |
| **BDD** | 缺口发现 | 智能扫描 + 用户选择 + 场景草图 | Phase 1 |
| **TDD** | 测试监察 | Iron Law + Verify RED/GREEN | Phase 3 |

**协作边界**：
- workflow 负责**执行流程**，Gate/Loop 控制
- Karpathy 负责**原则监察**，违规即报
- BDD 负责**缺口发现 + 用户选择**，Phase 1 强制询问
- TDD 负责**测试铁律**，Phase 3 强制执行

---

## Karpathy 监察（全流程自动激活）

| 原则 | 约束对象 | 决策权 |
|------|----------|--------|
| **Think Before Coding** | 所有 Phase | 不假设，不清楚就问 |
| **Implementation Simplicity** | 实现方式、代码结构、技术选型 | 模型自主 |
| **Requirements Integrity** | 需求范围、功能约束 | **必须用户 approval** |
| **Surgical Changes** | Phase 3 | 只改必须改，不顺手 |

### Requirements Integrity（关键原则）

```
❌ 模型不得用"实现简单"偷换"需求满足"
❌ 需求范围的简化必须用户 explicit approval
❌ 功能约束的裁剪必须用户 explicit approval
❌ "Simplicity First" 不能用于需求约束

✅ "Simplicity First" 只适用于：实现方式、代码结构、技术选型

违规处理：
  发现未经用户确认的需求裁剪 → 立即报告
  用户未 approve 前不得进入 Phase 3
```

---

## BDD 智能缺口（Phase 1 自动激活）

| 原则 | 约束对象 | 决策权 |
|------|----------|--------|
| **Gap Scan** | 需求描述 | 自动扫描，发现缺口 |
| **One-Ask Choice** | 用户交互 | 一次 AskUserQuestion |
| **Scenario Sketch** | 场景文档 | 模型生成，用户确认 |
| **Default Assumptions** | Auto Mode | 用户选择后自动填充 |

### 核心流程（精简版）

```
Step 1：需求扫描（自动）
  读取需求 → 自动识别：
    - Happy Path（隐含，必须有）
    - 明确的 Sad Path（已写出）
    - 隐含的 Edge/Boundary/Error（需推断）

Step 2：缺口发现 → AskUserQuestion（一次）

  AskUserQuestion({
    header: "场景缺口",
    question: "检测到以下场景缺口，如何处理？",
    options: [
      "用默认假设补充（推荐 Auto Mode）",
      "手动补充具体场景",
      "跳过，需求已足够清晰"
    ],
    preview: "缺口列表：\n- [需求X] 缺少 Sad Path\n- [需求Y] 缺少边界异常"
  })

Step 3：用户选择处理

  用户选择 "用默认假设" → 模型自动生成场景草图 → 继续
  用户选择 "手动补充" → 询问具体缺口 → 补充 → 继续
  用户选择 "跳过" → 记录缺口到 PLAN.md 前言 → 继续

Step 4：生成场景草图（模型生成，用户确认）

  不要求用户填写 Given-When-Then 表格
  模型自动生成简化的场景描述：

  | Requirement | Happy | Sad | Edge | Notes |
  |-------------|-------|-----|------|-------|
  | AgentTool query | 查询成功返回结果 | 无 AgentTool 时报错 | query 为空 | 默认假设 |
  | Plugin system | 加载成功 | 文件不存在时 fallback | 无 plugins 目录 | 手动补充 |

  仅展示给用户确认，不要求手动填写
```

### 缺口扫描规则（自动执行）

```
扫描需求文本，检查关键词：

Sad Path 检测：
  - "失败" / "错误" / "异常" / "错误码" / "返回空"
  - 无这些关键词 → 缺口："缺少失败场景"

Edge Case 检测：
  - "边界" / "空" / "最大" / "最小" / "超出"
  - 无这些关键词 → 缺口："缺少边界异常"

Error Handling 检测：
  - "超时" / "网络" / "中断" / "重试" / "fallback"
  - 无这些关键词 → 缺口："缺少异常处理"
```

### Default Assumptions（Auto Mode 使用）

```
用户选择 "用默认假设" 时，模型使用以下标准假设：

Sad Path 默认：
  - API 调用失败 → 返回错误信息，不崩溃
  - 数据不存在 → 返回空结果或 None
  - 权限不足 → 返回权限错误

Edge Case 默认：
  - 空输入 → 返回空结果或默认值
  - 超大输入 → 截断或拒绝
  - 边界值 → 正常处理

Error Handling 默认：
  - 网络 timeout → 返回超时错误
  - 服务不可用 → 返回服务错误，不阻塞

记录：所有默认假设必须写入 PLAN.md 前言的 "Scenario Assumptions" 部分
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

| 原则 | 约束对象 | 决策权 |
|------|----------|--------|
| **Iron Law** | Phase 3 所有代码 | 严格遵守，无例外 |
| **Minimal Test** | 每个 RED 阶段 | 模型自主 |
| **Watch It Fail** | RED → GREEN 之前 | **必须展示失败输出** |

### Iron Law（核心铁律）

```
NO CHANGE WITHOUT TEST WITNESS

核心：任何代码变更必须有测试见证状态变化

三场景统一：
  New Feature：测试定义期望 → RED → 实现 → GREEN
  Bug Fix：测试复现问题 → RED → 修复 → GREEN
  Refactor：测试记录行为 → GREEN → 重构 → 保持 GREEN

执行铁律：
  1. 确定变更范围
  2. 建立测试覆盖变更范围
  3. Verify Current State → 展示输出
  4. Make Change
  5. Verify New State → 展示输出
  6. Done

禁止：
❌ 无测试直接变更代码
❌ 跳过 Verify Current/New State
❌ 测试范围超出变更范围（除非用户要求）
❌ "太简单不用测"
❌ "先写代码再补测试"
❌ "手动测过了"
```

### Red-Green-Refactor 循环

```
RED → Verify RED → GREEN → Verify GREEN → REFACTOR → 保持绿色 → 下一行为
         ↓                    ↓
    展示失败输出            展示通过输出
```

**Verify RED（强制）**：

```
执行测试 → 展示失败输出片段 → 认认：
  ✅ 失败（不是 error）
  ✅ 失败消息预期
  ✅ 失败因为 feature missing（不是 typo）

不通过？→ 修测试，不写代码
```

**Verify GREEN（强制）**：

```
执行测试 → 展示通过输出片段 → 硜认：
  ✅ 测试通过
  ✅ 其他测试仍然通过
  ✅ 输出干净（无 error/warning）

不通过？→ 修代码，不修测试
```

**REFACTOR**：保持绿色、不添加新行为、只移除重复/改进命名

### 测试质量标准

| 指标 | ✅ 好 | ❌ 坏 |
|------|-------|-------|
| 粒度 | 单一行为 | name 含 "and" |
| 命名 | 描述行为 | `test1`, `test2` |
| 内容 | 真实代码 | mock 一切 |

### 常见借口（自动驳回）

```
"太简单不用测"       → 简单代码也会坏，测试只需 30 秒
"先写代码再补测试"   → 测试立即通过 = 证明不了任何事
"手动测过了"         → 无记录、不可重复、遗漏边界
"保留参考再写测试"   → 会"适配"现有代码，不是真 TDD
"测试难写 = 设计问题" → 听测试的，简化接口
"这次情况特殊"       → 没有"特殊情况"，删除重来
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

不强制：
  ❌ Coverage Matrix 表格全部填写
  ❌ Given-When-Then 格式检查

Phase 1 输出：Approved Requirements List + Scenario Sketch
触发：用户说 "approved" / "继续" / "开始计划"
附加：展示 Scenario Sketch 供确认
```

---

### Gate 2: Requirements Completeness

**位置**：Phase 2 结束 → Phase 3 前

```
❌ 不开始实现、不执行 task、不调用 executing-plans
✅ Plan Agent（MANDATORY）→ Requirements Completeness Check → 用户 approve Completeness
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
Explore → Decompose → Gap Scan → AskUserQuestion（一次）→ Scenario Sketch → [Gate 1]

Phase 1 输出：Approved Requirements List + Scenario Sketch
约束：
  - 必须询问场景缺口（一次 AskUserQuestion）
  - 用户选择后生成 Scenario Sketch
  - 不强制填写 Given-When-Then 表格
  - 多子系统 → decompose → 各自独立 Sketch
```

---

### Loop 2: Plan Revision（Phase 2）

```
Plan Agent（MANDATORY）→ Lite Plan Check → Requirements Completeness Check → Task Mapping → Self-review → User review → [Gate 2]
```

**Lite Plan Check（正则扫描）**：

```
扫描模式：TBD|TODO|implement later|fill in details|Add.*without code|handle edge cases|Write tests for the above（无代码）|Similar to Task N（无重复）|步骤描述无代码块|引用未定义的类型/函数

发现匹配 → 立即修复 → 重新扫描 → 通过后继续
```

**Self-review Checklist**：

```
1. Requirements coverage：每个 Requirement 有对应 Task？
2. Completeness：所有 Status 是 ✅ 或 ⚠️（已获 approval）？
3. Lite Plan Check：正则扫描通过
4. Type consistency：前后类型签名一致？
5. Scenario Assumptions：PLAN.md 前言记录了场景假设？
```

---

### Loop 3: Red-Green-Refactor（每个 task）

```
[变更范围确认] → [Gate 3] → TDD 循环（见 TDD 监察）→ [Gate 5] → [Gate 4]
```

**变更范围确认**：

```
步骤：
  1. 读取 PLAN 中此 task 的 Files 列表
  2. 对比当前 git status
  3. 超出声明的变更？
     - YES → STOP → 报告差异 → 等待用户批准
     - NO → 继续

禁止：
❌ 修改文件数 > PLAN 中声明的
❌ 新增功能不在 success criteria 中
❌ "顺手" refactor adjacent code
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
Run test → [Gate 5] → 0 failures → 声明 → 4 options → Execute
                    → N failures → Fix → Loop（不继续到 options）

4 Options：Merge locally / Create Pull Request / Keep branch / Discard（需 typed confirmation）
```

---

## Phase 流程

### Phase 1: CLARIFY（精简版）

```
调用：brainstorming skill
Announce："Using brainstorming skill."
输出：Approved Requirements List + Scenario Sketch

流程（精简版）：
  1. brainstorming → Explore → Decompose
  2. Gap Scan（自动扫描需求，发现缺口）
  3. AskUserQuestion（一次，场景缺口选择）
  4. 用户选择 → 
     - "用默认假设" → 自动生成 Scenario Sketch → 继续
     - "手动补充" → 询问具体缺口 → 补充 → 继续
     - "跳过" → 记录缺口 → 继续
  5. 展示 Scenario Sketch → 用户确认
  6. [Gate 1] → Phase 2

约束：
  - 不强制 Given-When-Then 格式填写
  - 不强制 Coverage Matrix 表格填写
  - 只强制一次 AskUserQuestion（场景缺口选择）
  - 模型生成 Scenario Sketch，用户确认即可
```

### Phase 2: PLAN

```
调用：Plan Agent（MANDATORY）→ writing-plans skill
Announce："Using writing-plans skill."
流程：Plan Agent → Lite Plan Check → Requirements Completeness Check → Task Mapping → Self-review → User review → [Gate 2] → Phase 3

PLAN.md 前言必须包含：
  - Scenario Assumptions（记录场景假设或缺口跳过）
```

### Phase 3: EXECUTE

```
模式：Inline（简单任务） / Subagent（复杂任务、并行、深度委托）

调用：
  Inline：executing-plans skill
  Subagent：subagent-driven-development skill（深度委托）

流程骨架：
  Load plan → Create TodoWrite
  For each task:
    1. [变更范围确认]
    2. Mark in_progress
    3. [Gate 3] 建立测试 + Verify Current State
    4. [Loop 3] TDD 循环（Iron Law + 状态见证）
    5. [Gate 5] Verify New State（展示输出片段）
    6. [Gate 4 + Loop 4] Review
    7. Mark completed（仅 Gate 5 通过后）

  Context > 70% → checkpoint → /clear → 恢复
  All tasks → Phase 5
```

### Phase 5: COMPLETE

```
调用：finishing-a-development-branch skill
Announce："Using finishing-a-development-branch skill."
流程：[Loop 5] → Manual QA（零妥协）→ END
```

---

## Auto Mode

**触发**："自动运行" / "离开一下" / "不用问我" / "继续跑" / "等我回来"

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

**注意**：Auto Mode 不改变 Requirements Integrity、Iron Law、BDD 缺口询问
- ❌ 不能跳过用户 approval 的 Simplification
- ❌ 不能跳过 Verify RED/GREEN
- ❌ 不能跳过 AskUserQuestion（场景缺口）
- ✅ 用户选择 "用默认假设/跳过" 后可自动继续

---

## Skill Mapping

| Phase | Skill | 控制 |
|-------|-------|------|
| 1 | brainstorming | Gate 1 + Gap Scan + AskUserQuestion + Scenario Sketch |
| 2 | Plan Agent（MANDATORY）+ writing-plans | Gate 2 + Lite Plan Check + Completeness Check + Scenario Assumptions |
| 3 Inline | executing-plans | Gate 3/4/5/6 + Loop 3/4 + Iron Law |
| 3 Subagent | subagent-driven-development | Gate 3/4/5/6 + Loop 3/4 + 并行 + Iron Law + 深度委托 |
| 5 | finishing-a-development-branch | Gate 5 + Loop 5 + Manual QA |

**监察层**：Karpathy 全 Phase、BDD Phase 1（缺口发现）、TDD Phase 3，违规即报

---

## Red Flags

```
Phase 1:
❌ "Too simple to need design" → Gate 1 violation
❌ Code before design approved → Gate 1 violation
❌ 未询问场景缺口 → BDD violation
❌ 用户选择"手动补充"但未等待 → Process violation
❌ Auto Mode 未询问直接跳过 → BDD violation
❌ 未生成 Scenario Sketch → Gate 1 violation

Phase 2:
❌ TBD/TODO in plan → Lite Plan Check violation
❌ Requirements Traceability Matrix 未完成 → Gate 2 violation
❌ PLAN.md 缺少 Scenario Assumptions → BDD violation
❌ Simplification 未经用户 approval → Requirements Integrity violation
❌ 用户 approve "plan 格式" 而非 "Completeness" → Gate 2 violation
❌ 跳过 Plan Agent → UltraWork violation

Phase 3:
❌ 无测试变更代码 → Iron Law violation
❌ 跳过 Verify Current State → Iron Law violation
❌ 跳过 Verify New State → Iron Law violation
❌ "Tests pass" without running → Gate 5 violation
❌ "Tests pass" without 输出片段 → Gate 5 violation
❌ "太简单不用测" → Iron Law violation
❌ "保留作为参考" → Iron Law violation
❌ "先写代码再补测试" → Iron Law violation
❌ "手动测过了" → Iron Law violation
❌ 变更超出 PLAN 范围 → Surgical Changes violation
❌ 继续第 4 次相同修复 → 3-Failure violation
❌ Blockers without stopping → Gate 6 violation

REVIEW:
❌ Code quality before spec compliance → Gate 4 violation
❌ Moving to next task with open Critical/Important → Gate 4 violation
❌ "Task complete" without fresh verification evidence → Gate 5 violation

Phase 5:
❌ Proceeding with failing tests → Gate 5 violation
❌ No typed confirmation for discard → Process violation
❌ Skip Manual QA → UltraWork violation

General:
❌ "Should/probably" → Verification violation
❌ "顺手" adding features → Karpathy violation
❌ 用"实现简单"偷换"需求满足" → Requirements Integrity violation
❌ "这次情况特殊" → Iron Law violation

Auto Mode:
❌ Auto Mode 说"等待用户决策"但用户已选择 → 应该继续
❌ Auto Mode 跳过用户需要的 approval → Requirements Integrity violation
❌ Auto Mode 跳过 Verify RED/GREEN → Iron Law violation
❌ Auto Mode 跳过 AskUserQuestion（场景缺口） → BDD violation
```

---

## Key Principles

```
四系统协作：
  workflow（执行）→ Karpathy（监察）→ BDD（缺口发现）→ TDD（测试）
  权责清晰，违规即报

UltraWork 特性：
  Plan Agent MANDATORY
  深度委托
  Manual QA 零妥协
  Auto-mode aware

Requirements Integrity 优先于 Simplicity
Iron Law 优先于 所有借口
Gap Scan 优先于 手动填写表格

Gate 控制 Phase 进入
Loop 控制 Phase 内完成

BDD 精简铁律：缺口扫描 → 用户选择 → 模型生成草图 → 不强制填写
验证铁律：必须展示输出片段
TDD 铁律：变更必须有测试见证
遇阻即停不猜测
三次失败必须反思：禁止继续第4次修复
变更必须范围确认：对比 git status
证据必须展示片段：验证格式表强制
Manual QA 必须执行：零妥协
Task Complete 条件：Gate 5 通过后才能 Mark completed

Auto Mode 适配
顺手必须报告
借口自动驳回
假设自动驳回
BDD 缺口：必须询问，但选择后可自动继续
```