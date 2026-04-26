---
name: ai-engineer-workflow-v4
description: Optimized workflow with evidence-based verification, surgical changes detection, 3-failure reflection, and requirements integrity gate.
---

# AI Engineer Workflow V4

**工作流优化版：强化验证、防止蔓延、架构反思、需求完整性**

---

## 核心约束

```
1. 不探索清楚不实现
2. 不计划清楚不实现
3. 不完整覆盖需求不实现
4. 不测试通过不提交
5. 不验证成功不声明
6. 三次失败必须反思
```

---

## Karpathy 监察（全流程自动激活）

| 原则 | 约束对象 | 决策权 |
|------|----------|--------|
| **Think Before Coding** | 所有 Phase | 不假设，不清楚就问 |
| **Implementation Simplicity** | 实现方式、代码结构 | 模型自主 |
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

**位置：** Phase 1 结束 → Phase 2 前

**铁律：**
```
❌ 不写代码
❌ 不创建项目结构
❌ 不调用 plan skill

✅ brainstorming skill
✅ 探索 codebase
✅ 提问澄清
```

**触发：** 用户说 "approved" / "继续" / "开始计划"

---

### Gate 2: Requirements Completeness ⭐ V4 强化

**位置：** Phase 2 结束 → Phase 3 前

**铁律：**
```
❌ 不开始实现
❌ 不执行 task
❌ 不调用 executing-plans

✅ Lite Plan Check（正则扫描）
✅ Requirements Completeness Check
✅ 用户 approve Completeness
```

**Requirements Traceability Matrix（V4）：**
```
对于每个 Requirement（来自 Phase 1）：
  1. 找到对应的 Task(s)
  2. 检查 Task 是否完整实现该 Requirement
  3. 如果有简化 → 标记为 "Simplification"
  4. 如果没有对应 Task → 标记为 "Missing"

输出格式：

| Requirement | Task(s) | Coverage | Simplification | Status |
|-------------|---------|----------|----------------|--------|
| R1: 功能 X    | T1, T2 | 100%    | None            | ✅     |
| R2: 功能 Y    | T3     | 80%     | "Z 简化为 W"    | ⚠️     |
| R3: 功能 Z    | -      | 0%      | None            | ❌     |

Status 定义：
  ✅ = Covered（完全覆盖）
  ⚠️ = Simplified（需要用户 approval）
  ❌ = Missing（必须修复）
```

**Lite Plan Check（强制执行）：**
```
正则扫描模式：
- TBD|TODO|implement later|fill in details
- Add.*without code|handle edge cases
- Write tests for the above（无代码）
- Similar to Task N（无重复）
- 步骤描述无代码块
- 引用未定义的类型/函数

发现匹配 → 立即修复 → 重新扫描 → 通过后继续
```

**Gate 2 通过条件：**
```
1. 所有 Requirement 的 Status 是 ✅
2. 所有 ⚠️ 已获用户 explicit approval
3. 没有 ❌ Missing 状态
4. Lite Plan Check 通过
```

---

### Gate 3: Test-First

**位置：** 每个 task 开始前

**铁律：**
```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST

✅ 存在针对此 task 的测试
✅ 测试当前状态是 FAIL
✅ 失败原因是 feature missing
```

---

### Gate 4: Two-Stage Review

**位置：** 每个 task 完成后

**铁律（严格顺序）：**
```
1. Spec compliance review（先）
2. Code quality review（后）

❌ spec compliance ✅ 前开始 code quality
❌ 有 open Critical/Important issues 时继续下一 task
```

**Issue 级别：**
- Critical：立即修复
- Important：下一 task 前修复
- Minor：记录，稍后处理

---

### Gate 5: Evidence-Based Verification ⭐ V4 强化

**位置：** 任何声明工作状态时

**铁律：**
```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE

1. IDENTIFY：什么命令证明？
2. RUN：执行完整命令
3. READ：完整输出，exit code
4. EXTRACT：展示关键输出片段
5. VERIFY：输出确认声明？
6. ONLY THEN：做出声明
```

**验证格式（V4 强制）：**
```
| 验证项 | 命令 | 输出片段 | 结论 |
|--------|------|----------|------|
| 测试 | cargo test | "32 passed" | ✅ |
| Clippy | cargo clippy | "0 warnings" | ✅ |
```

**Manual QA 场景表：**

| 场景 | 必须做什么 |
|------|-----------|
| CLI 命令 | Bash 实际运行，展示输出 |
| 构建产物 | 运行构建，验证输出 |
| API 行为 | 调用 endpoint，展示响应 |
| UI 渲染 | 浏览器验证 |
| 配置 | 加载并验证解析 |

**禁止：**
- ❌ 只说 "tests pass" 无输出证据
- ❌ 使用 "应该/大概/似乎"

---

### Gate 6: Stop-On-Blocker + 3-Failure Reflection ⭐ V4 强化

**位置：** Phase 3 全程监测

| 障碍类型 | 检测点 | 行为 |
|----------|--------|------|
| 缺失依赖 | GREEN 编译失败 | STOP → 报告 → 提供安装命令 |
| 测试 errors | Verify RED | STOP → 报告 → 分析原因 |
| 指令不清晰 | 任何阶段 | STOP → 问用户澄清 |
| 计划缺口 | task 无法完成 | STOP → 回 Phase 2 补充 |
| 验证失败 3次 | 同一验证点 | STOP → 问用户决策 |
| **整体修复失败** | **同一 bug 修复 3 次** | **架构反思模式** |

**三次失败架构反思（V4 新增）：**
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
❌ 跳过架构检查直接回到 Phase 1
```

---

## 五个循环（LOOPS）

### Loop 1: Clarification（Phase 1）

```
Explore → Scope check → Ask Q → Propose → Present → Write Spec → User review → [Gate 1]
```

**约束：**
- 一次一个问题
- 多个子系统 → 立即 flag → decompose
- Placeholder/Consistency/Scope/Ambiguity 检查

---

### Loop 2: Plan Revision（Phase 2）

```
Plan Agent → [Lite Plan Check] → Requirements Completeness Check → Task Mapping → Self-review → User review → [Gate 2]
```

**Self-review Checklist：**
```
1. Requirements coverage：每个 Requirement 有对应 Task？
2. Completeness：所有 Status 是 ✅ 或 ⚠️（已获 approval）？
3. Lite Plan Check：正则扫描已执行并通过
4. Type consistency：前后类型签名一致？
```

---

### Loop 3: Red-Green-Refactor（Phase 3） ⭐ V4 强化

```
[变更范围确认] → [Gate 3] → RED → Verify RED → GREEN → Verify GREEN → REFACTOR → [Gate 5] → [Gate 4 + Loop 4]
```

**变更范围确认（V4 新增）：**
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
❌ 处理用户未提及的 edge case

触发顺手 → 报告用户 → 等待批准或 rollback
```

---

### Loop 4: Review-Fix

```
Stage 1: Spec compliance → Issues? → Fix → Re-check
                              ↓ ✅
Stage 2: Code quality → Issues? → Fix → Re-check
                              ↓ ✅
                   Task complete
```

**分歧 > 2 轮** → 提交用户裁决

---

### Loop 5: Complete Decision

```
Run test → [Gate 5 证据格式] → 0 failures → 声明 → 4 options → Execute
                            → N failures → Fix → Loop
```

**4 Options：**
```
1. Merge locally
2. Create Pull Request
3. Keep branch
4. Discard（需 typed confirmation）
```

---

## Phase 流程

### Phase 1: CLARIFY

**调用：** `superpowers:brainstorming`
**输出：** Approved Requirements List
**流程：** brainstorming → Requirements List → User approve → [Gate 1] → Phase 2

### Phase 2: PLAN

**调用：** `superpowers:writing-plans`
**流程：** writing-plans → [Lite Plan Check] → Requirements Completeness Check → Self-review → User approve → [Gate 2] → Phase 3

### Phase 3: EXECUTE

**执行模式：**

| 模式 | 描述 | 适用场景 |
|------|------|----------|
| **Inline** | 当前 session | 简单任务 |
| **Subagent** | 派发子代理，可并行 | 复杂任务、多 task |

**调用：**
- Inline: `superpowers:executing-plans`
- Subagent: `superpowers:subagent-driven-development`

**流程骨架：**
```
Load plan → Create TodoWrite

For each task:
  1. [变更范围确认]
  2. Mark in_progress
  3. [Gate 3] 检查测试存在且 FAIL
  4. RED → GREEN → REFACTOR
  5. [Gate 5 证据格式]
  6. [Gate 4 + Loop 4]
  7. Mark completed
  8. 遇障碍 → [Gate 6 三次失败规则]

Context > 70% → checkpoint → /clear → 恢复

All tasks → Phase 5
```

### Phase 5: COMPLETE

**调用：** `superpowers:finishing-a-development-branch`
**流程：** skill checklist → [Gate 5] → [Loop 5] → END

---

## Auto Mode

**触发：**
```
用户说：
  • "自动运行"
  • "离开一下"
  • "不用问我"
  • "继续跑"
```

### Auto Mode vs Interactive Mode

| 场景 | Interactive | Auto Mode |
|------|-------------|-----------|
| Gate 6 blocker | STOP → 等待决策 | 记录 → 自动尝试下一方案 |
| Review 发现问题 | STOP → 等待修复 | 自动修复 → 继续 |
| 测试失败 | STOP → 报告 | 自动调试 → 继续 |
| 用户 approval | 等待 | 自动继续 |

**注意：** Auto Mode 不改变 Requirements Integrity 约束
- ❌ 不能跳过用户 approval 的 Simplification
- ✅ 只能跳过"等待用户 decision"的环节

---

## Skill Mapping

| Phase | Skill | 控制 |
|-------|-------|------|
| 1 | brainstorming | Gate 1 + Requirements List |
| 2 | writing-plans | Gate 2 + Lite Plan Check + Completeness Check |
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
❌ TBD/TODO in plan → Lite Plan Check violation
❌ Requirements Traceability Matrix 未完成 → Gate 2 violation
❌ Simplification 未经用户 approval → Requirements Integrity violation
❌ 用户 approve "plan 格式" 而非 "Completeness" → Gate 2 violation

Phase 3:
❌ Code before test → Gate 3 violation
❌ Test passes immediately → Wrong test
❌ "Tests pass" without running → Gate 5 violation
❌ 变更超出 PLAN 范围 → Surgical Changes violation
❌ 继续第 4 次相同修复 → 3-Failure violation
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
❌ 用"实现简单"偷换"需求满足" → Requirements Integrity violation
❌ "Simplicity First" 用于需求约束 → Requirements Integrity violation

Auto Mode:
❌ Auto Mode 说"等待用户决策" → 应该继续
❌ Auto Mode 跳过用户需要的 approval → Requirements Integrity violation
```

---

## Key Principles

```
Requirements Integrity 优先于 Simplicity
  → 实现方式可以简单，需求范围不能擅自裁剪

V4 优化：
  Lite Plan Check → 防止模糊计划进入执行
  Requirements Completeness → 需求完整覆盖验证
  Evidence-Based → 消除幻觉式声明
  Surgical Changes → 防止范围蔓延
  3-Failure Reflection → 避免试错循环

Gate 控制 Phase 进入
Loop 控制 Phase 内完成
委托给 skill 执行细节
验证铁律不可违反
遇阻即停不猜测
三次失败必须反思
证据必须展示片段
变更必须范围确认
Auto Mode 适配
```