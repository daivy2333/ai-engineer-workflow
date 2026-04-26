---
name: ai-engineer-workflow-v4-ulw
description: UltraWork mode workflow. Mandatory explore, Plan Agent, deep delegation, manual QA, zero compromise. Auto-mode aware for unattended execution.
---

# AI Engineer Workflow V4 — UltraWork Mode

**完整版：Requirements Completeness Gate 内嵌，Simplicity/Integrity 原则分离**

---

## 核心约束

```
1. 不探索清楚不实现
2. 不计划清楚不实现
3. 不完整覆盖需求不实现
4. 不测试通过不提交
5. 不验证成功不声明
```

---

## 三系统分工

| 系统 | 角色 | 职责 |
|------|------|------|
| **本 workflow** | 主执行 | brainstorm → plan → execute → review → complete |
| **GSD** | 记忆层 | 持久化 context/milestone |
| **Karpathy** | 监察层 | 原则 1-4（见下方） |

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
Requirements Integrity 约束：

❌ 模型不得用"实现简单"偷换"需求满足"
❌ 需求范围的简化必须用户 explicit approval
❌ 功能约束的裁剪必须用户 explicit approval
❌ "Simplicity First" 不能用于需求约束

✅ "Simplicity First" 只适用于：
    • 实现方式的选择
    • 代码结构的设计
    • 技术方案的选择

违规处理：
    • 发现未经用户确认的需求裁剪 → 立即报告
    • 用户未 approve 前不得进入 Phase 3
```

---

## 六个门控（GATES）

### Gate 1: Design Approval

**位置**：Phase 1 结束 → Phase 2 前

**铁律**：
```
❌ 不写代码
❌ 不创建项目结构
❌ 不调用 plan skill

✅ brainstorming skill
✅ 探索 codebase
✅ 提问澄清
```

**Phase 1 输出**：Requirements List（用户 approved）

**触发**：用户说 "approved" / "继续" / "开始计划"

**未触发**：继续提问 → 提方案 → 修改

---

### Gate 2: Requirements Completeness（重命名）

**位置**：Phase 2 结束 → Phase 3 前

**铁律**：
```
❌ 不开始实现
❌ 不执行 task
❌ 不调用 executing-plans

✅ Plan Agent（MANDATORY）
✅ Requirements Completeness Check
✅ 用户 approve Completeness（不是 approve plan 格式）
```

**MANDATORY Plan Agent 调用**：
```
task(subagent_type="plan", run_in_background=false, prompt="<context>")
task_id 用于 session continuity
```

---

### Gate 3: Test-First

**位置**：每个 task 开始前

**铁律**：
```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST

✅ 存在针对此 task 的测试
✅ 测试当前状态是 FAIL
✅ 失败原因是 feature missing
```

**不符合** → 必须先写/修正测试

---

### Gate 4: Two-Stage Review

**位置**：每个 task 完成后

**铁律（严格顺序）**：
```
1. Spec compliance review（先）
2. Code quality review（后）

❌ spec compliance ✅ 前开始 code quality
❌ 有 open Critical/Important issues 时继续下一 task
```

**Issue 级别**：
```
Critical：立即修复
Important：下一 task 前修复
Minor：记录，稍后处理
```

---

### Gate 5: Verification Iron Law

**位置**：任何声明工作状态时

**铁律**：
```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE

1. IDENTIFY：什么命令证明？
2. RUN：执行完整命令
3. READ：完整输出，exit code
4. VERIFY：输出确认声明？
5. ONLY THEN：做出声明
```

**MANUAL QA（必须执行）**：

| 场景 | 必须做什么 |
|------|-----------|
| CLI 命令 | Bash 实际运行，展示输出 |
| 构建产物 | 运行构建，验证输出 |
| API 行为 | 调用 endpoint，展示响应 |
| UI 渲染 | 浏览器验证 |
| 配置 | 加载并验证解析 |

---

### Gate 6: Stop-On-Blocker

**位置**：Phase 3 全程监测

**障碍类型及处理**：

| 障碍 | 检测点 | 行为 |
|------|--------|------|
| 缺失依赖 | GREEN 阶段编译 | STOP → 报告 → 提供安装命令 |
| 测试 errors | Verify RED | STOP → 报告 → 分析原因 |
| 指令不清晰 | 任何阶段 | STOP → 问用户澄清 |
| 计划缺口 | task 无法完成 | STOP → 回 Phase 2 补充 |
| 验证失败 3次 | 同一验证点 | STOP → 报告 → 问决策 |
| 3+ 修复失败 | 同一 bug | STOP → 架构分析 |

---

## 五个循环（LOOPS）

### Loop 1: Clarification（Phase 1）

```
Explore → Scope check → Ask Q → Propose → Present → Write Spec → User review → [Gate 1]
```

**Phase 1 输出**：Approved Requirements List

**约束**：
- 一次一个问题
- 多个子系统 → 立即 flag → decompose
- Placeholder/Consistency/Scope/Ambiguity 检查

---

### Loop 2: Plan Revision（Phase 2）

```
Plan Agent → Requirements Completeness Check → Task Mapping → Self-review → User review → [Gate 2]
```

**新增：Requirements Completeness Check**

```
对于每个 Requirement（来自 Phase 1）：
  1. 找到对应的 Task(s)
  2. 检查 Task 是否完整实现该 Requirement
  3. 如果有简化 → 标记为 "Simplification"
  4. 如果没有对应 Task → 标记为 "Missing"

输出格式（Requirements Traceability Matrix）：

| Requirement | Task(s) | Coverage | Simplification | Status |
|-------------|---------|----------|-----------------|--------|
| R1: 功能 X    | T1, T2 | 100%    | None            | ✅     |
| R2: 功能 Y    | T3     | 80%     | "Z 简化为 W"    | ⚠️     |
| R3: 功能 Z    | -      | 0%      | None            | ❌     |

Status 定义：
  ✅ = Covered（完全覆盖）
  ⚠️ = Simplified（需要用户 approval）
  ❌ = Missing（必须修复）
```

**Self-review Checklist**：
```
1. Requirements coverage：每个 Requirement 有对应 Task？
2. Completeness：所有 Status 是 ✅ 或 ⚠️（Simplified 已获 approval）？
3. Placeholder scan：禁止 TBD/TODO/"implement later"
4. Type consistency：前后类型签名一致？
```

**禁止**：
```
❌ TBD, TODO, "fill in details"
❌ "Add appropriate error handling"（无代码）
❌ "Write tests for the above"（无代码）
❌ "Similar to Task N"（必须重复代码）
❌ 无代码块的步骤
❌ 未经用户 approval 的 Simplification
```

**Gate 2 通过条件**：
```
1. 所有 Requirement 的 Status 是 ✅
2. 所有 ⚠️ 已获用户 explicit approval
3. 没有 ❌ Missing 状态
4. 用户 approve Completeness（不是 approve plan 格式）
```

---

### Loop 3: Red-Green-Refactor（每个 task）

```
[Gate 3] → RED → Verify RED → GREEN → Verify GREEN → REFACTOR → Verify GREEN → Commit → [Gate 5] → [Gate 4]
```

**Verify RED**：
```
- 测试失败（不是 error）
- 失败消息是预期的
- 因为 feature missing

不符合 → STOP
```

**Verify GREEN**：
```
- 测试通过
- 其他测试仍然通过
- 输出干净

不符合 → Fix code，不是 fix test
```

**REFACTOR**：
```
- 保持绿色
- 不添加新行为
- 只移除重复/改进命名
```

---

### Loop 4: Review-Fix

```
Stage 1: Spec compliance → Issues? → Fix → Re-check
                                         ↓ ✅
Stage 2: Code quality → Issues? → Fix → Re-check
                                         ↓ ✅
                              Task complete → Mark completed
```

**分歧 > 2 轮** → 提交用户裁决

---

### Loop 5: Complete Decision

```
Run test → [Gate 5] → 0 failures → 声明 → 4 options → Execute
                    → N failures → Fix → Loop（不继续到 options）
```

**4 Options**：
```
1. Merge locally
2. Create Pull Request
3. Keep branch
4. Discard（需 typed confirmation）
```

---

## Phase 流程

### Phase 1: CLARIFY

**调用**：brainstorming skill

**Announce**："Using brainstorming skill."

**输出**：Approved Requirements List

**流程**：brainstorming → Requirements List → User approve → [Gate 1] → Phase 2

---

### Phase 2: PLAN

**调用**：Plan Agent → writing-plans skill

**Announce**："Using writing-plans skill."

**流程**：
```
Plan Agent
    ↓
Requirements Completeness Check（NEW - 检查 Requirements ↔ Tasks 映射）
    ↓
Task Mapping（NEW - 生成 Requirements Traceability Matrix）
    ↓
Self-review
    ↓
User review（approve Completeness，不是 plan 格式）
    ↓
[Gate 2 PASS] → Offer execution choice → Phase 3
```

---

### Phase 3: EXECUTE

**模式**：

| 模式 | 适用 |
|------|------|
| Inline | 简单任务、单 session |
| Subagent | 复杂任务、多 task 并行 |

**调用**：
- Inline：`executing-plans` skill
- Subagent：`subagent-driven-development` skill

**Announce**："Using [executing-plans/subagent-driven] skill."

**流程骨架**：
```
Load plan → Create TodoWrite

For each task:
  1. Mark in_progress
  2. [Gate 3] → 检查测试
  3. [Loop 3] → TDD
  4. [Gate 5] → Commit 后验证
  5. [Gate 4 + Loop 4] → Review
  6. Mark completed

Context > 70% → checkpoint → /clear → 恢复

All tasks → External review → Phase 5
```

---

### Phase 5: COMPLETE

**调用**：`finishing-a-development-branch` skill

**Announce**："Using finishing-a-development-branch skill."

**流程**：[Loop 5] → END

---

## Auto Mode

**触发**：
```
用户说：
  • "自动运行"
  • "离开一下"
  • "不用问我"
  • "继续跑"
  • "等我回来"
```

### Auto Mode vs Interactive Mode

| 场景 | Interactive | Auto Mode |
|------|-------------|-----------|
| Gate 6 blocker | STOP → 等待决策 | 记录 → 自动尝试下一方案 |
| Review 发现问题 | STOP → 等待修复 | 自动修复 → 继续 |
| 测试失败 | STOP → 报告 | 自动调试 → 继续 |
| 用户 approval | 等待 | 自动继续 |

**注意**：Auto Mode 不改变 Requirements Integrity 约束
- ❌ 不能跳过用户 approval 的 Simplification
- ✅ 只能跳过"等待用户 decision"的环节

---

## Skill Mapping

| Phase | Skill | 控制 |
|-------|-------|------|
| 1 | brainstorming | Gate 1 + Requirements List |
| 2 | Plan Agent + writing-plans | Gate 2 + Requirements Completeness Check |
| 3 Inline | executing-plans | Gate 3/4/5/6 + Loop 3/4 |
| 3 Subagent | subagent-driven-development | Gate 3/4/5/6 + Loop 3/4 + 并行 |
| 5 | finishing-a-development-branch | Gate 5 + Loop 5 |

---

## Red Flags

```
Phase 1:
❌ "Too simple to need design" → Gate 1 violation
❌ Code before design approved → Gate 1 violation
❌ Not asking when unclear → Karpathy violation

Phase 2:
❌ TBD/TODO in plan → Placeholder violation
❌ No self-review → Process violation
❌ Plan before Plan Agent → Gate 2 violation
❌ Requirements Traceability Matrix 未完成 → Gate 2 violation
❌ Simplification 未经用户 approval → Requirements Integrity violation
❌ 用户 approve "plan 格式" 而非 "Completeness" → Gate 2 violation

Phase 3:
❌ Code before test → Gate 3 violation
❌ Test passes immediately → Wrong test
❌ "Tests pass" without running → Gate 5 violation
❌ Blockers without stopping → Gate 6 violation

REVIEW:
❌ Code quality before spec compliance → Gate 4 violation
❌ Moving to next task with open Critical/Important → Gate 4 violation

Phase 5:
❌ Proceeding with failing tests → Gate 5 violation
❌ No typed confirmation for discard → Process violation

General:
❌ "Should/probably" → Verification violation
❌ "顺手" adding features → Karpathy violation
❌ Partial work → Zero tolerance violation
❌ 用"实现简单"偷换"需求满足" → Requirements Integrity violation
❌ "Simplicity First" 用于需求约束 → Requirements Integrity violation

Auto Mode:
❌ Auto Mode 说"等待用户决策" → 应该继续
❌ Auto Mode 跳过用户需要的 approval → Requirements Integrity violation
```

---

## Key Principles

```
三系统协作：
  SP 主执行
  GSD 记忆
  Karpathy 监察

Gate 控制 Phase 进入
Loop 控制 Phase 内完成
委托给 skill 执行细节

Requirements Integrity 优先于 Simplicity
  → 实现方式可以简单，需求范围不能擅自裁剪

验证铁律不可违反
遇阻即停不猜测
Two-stage 顺序严格
TDD 红绿必经
Auto Mode 适配
顺手必须报告
```
