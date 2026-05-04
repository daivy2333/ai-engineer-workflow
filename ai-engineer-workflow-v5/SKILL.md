---
name: ai-engineer-workflow-v5
description: 强化验证、防止蔓延、架构反思、需求完整性。六门控，Phase 序列 1→2→3→4。
---

# AI Engineer Workflow V5

## 核心约束

```
1. 不探索清楚不实现
2. 不计划清楚不实现
3. 不完整覆盖需求不实现
4. 不测试通过不提交
5. 不验证成功不声明
6. 三种方案均失败必须停止
```

---

## 流程

### Phase 1: CLARIFY

```
前置：用户提出需求
步骤：
  0. 创建关键节点 Task（一次性，防 context 丢失）
     → TaskCreate: Phase 1 CLARIFY / Gate 1 / Phase 2 PLAN / Gate 2 / Phase 3 EXECUTE / Gate 3 / Gate 4 / Gate 5 / Gate 6 / Phase 4 COMPLETE
     → 后续每完成一个节点，TaskUpdate 标记 completed
  1. Skill Prep
     → 执行 claude plugin list → 按 description 关键词分类
     → 输出分类表格（类型 | 插件名 | 集成点）
     → 用户确认
  2. 探索
     → 调用 brainstorming skill → 代码库探索
  3. 需求整理
     → 输出 Requirements List 表格
     → 用户逐项勾选批准（"A-R1,R2,R3 执行"）
输出：Requirements List（已批准）
进入条件：[Gate 1] 通过
```

**Requirements List 格式**：
```
┌─────────────────────────────────────┐
│ REQUIREMENTS LIST                   │
│─────────────────────────────────────│
│ ID | Requirement | Scope | Success  │
│ R1 | 配置 ESLint | 全项目 | 0 errors │
│ R2 | 添加测试   | core/  | ≥80% cov │
│─────────────────────────────────────│
│ Total: N items                      │
└─────────────────────────────────────┘
```

### Phase 2: PLAN

```
前置：[Gate 1] 已通过
步骤：
  1. 有 Domain 插件 → 调用 skill 提取设计约束
  2. 调用 writing-plans skill → 生成 PLAN
  3. Lite Check → 检查 TBD|TODO|implement later|未定义引用 → 有则修复
  4. Self-review → 覆盖完整 / 类型一致 / 无悬空引用
  5. 输出 Traceability Matrix → 用户批准
输出：PLAN + Traceability Matrix（已批准）
进入条件：[Gate 2] 通过
```

**Traceability Matrix 格式**：
```
┌───────────────────────────────────────────────┐
│ TRACEABILITY MATRIX                           │
│───────────────────────────────────────────────│
│ Req | Tasks      | Coverage | Status         │
│ R1  | T1,T2,T3   | 100%     | ✅ Ready       │
│ R2  | T4,T5      | 100%     | ✅ Ready       │
│───────────────────────────────────────────────│
│ Coverage: 100% | Uncovered: 0                 │
│ User Approval: [签名]                         │
└───────────────────────────────────────────────┘
```

**Coverage 缺口处理**：
```
缺口类型 | 处理方式
需求裁剪 | STOP → 用户 explicit approval
技术限制 | STOP → 用户选择：放宽标准/换方案/保留缺口
时间约束 | STOP → 用户选择：优先级排序/分批执行
```

### Phase 3: EXECUTE

```
前置：[Gate 2] 已通过
循环：对 PLAN 中每个 task
  1. 范围确认 → git diff vs PLAN，超出则 STOP
  2. 测试先行 → 无 failing test 则先写一个
  3. 实现 → RED → GREEN → REFACTOR
  4. 验证 → 运行项目测试命令，≥3行输出，exit 0 [Gate 3]
  5. 审查 → spec 合规 + 代码质量 [Gate 4]
     → Critical 立即修 / Important 下 task 前修 / Minor 记录
  6. 标记完成 → TaskUpdate completed
中断：context >70% → checkpoint → /clear
阻碍：见 Gate 6
输出：所有 task completed
进入条件：0 task remaining + 0 Critical open
```

**执行模式**：
| 条件 | 模式 | Skill |
|------|------|-------|
| 单文件 / 简单逻辑 | Inline | `executing-plans` |
| 多文件 / 多模块 | Subagent | `subagent-driven-development` |

**并行策略**：
```
识别 task 依赖关系（DAG）
无依赖 → 可并行执行
有依赖 → 串行（依赖完成后触发）
每个 task 独立完成 验证→审查→标记，不等全部完成
```

### Phase 4: COMPLETE

```
前置：Phase 3 全部完成
步骤：
  1. 运行全部测试 [Gate 5]
  2. 0 failures → 调用 finishing-a-development-branch skill
  3. Merge / PR / Keep / Discard
输出：需求完成，等待下一需求
```

### Gate 定义

**Gate 1: Requirements List Approval**
- 用户逐项勾选：`"A-R1,R2,R3 执行"`
- 或明确声明 `"全部执行（含 R1-R3）"`
- 单独 `"全部执行"` 不算批准

**Gate 2: Traceability Matrix Approval**
- Coverage = 100%，Status 全部 ✅
- 缺口需用户 explicit approval

**Gate 3: Per-Task Verification**
- 运行项目测试命令（非硬编码 pytest）
- ≥3 行输出，exit 0
- 子代理报告 ≠ 已验证，必须自己跑
- timeout → spot-check（SUMMARY.md / git log）

**Gate 4: Review**
- 验证通过后执行
- Spec 合规 + 代码质量一并审查
- 分歧 >2 轮 → 用户裁决

**Gate 5: Evidence-Based Final Verification**
- Phase 3 全部 task 完成后执行
- 运行全部测试，确认 0 failures
- 同 Gate 3 标准

**Gate 6: Stop-On-Blocker + 3-Failure**

| 阻碍 | Interactive | Auto |
|------|-------------|------|
| 缺失依赖 | STOP | 自动安装 |
| 测试 errors | STOP | 自动调试 |
| 小 bug / 实现偏差 | STOP 问用户 | 自动修复 |
| 更优实现（未偏离计划） | STOP 问用户 | 自动采用 |
| 三种不同方案均失败 | 架构反思 | STOP → 报告 |
同一问题尝试 3 种不同方案均失败 → STOP → 记录每种方案及失败原因 → 检查架构问题 → 是则讨论重构，否则回 Phase 1

### Skill Mapping
superpowers
| Phase | Skill |
|-------|-------|
| 1 | brainstorming |
| 2 | writing-plans |
| 3 Inline | executing-plans |
| 3 Subagent | subagent-driven-development |
| 4 | finishing-a-development-branch |

---

## 执行规则

```
执行纪律：
  - Gate 子步骤用 TaskCreate 创建独立 task
  - TaskList 是唯一的进度真相来源
  - 子代理报告 ≠ 已验证，必须自己跑 Gate 3
  - 追加需求 → 合并到当前 PLAN → 重新过 Gate 2

Karpathy 监察：
  - Think Before Coding → 不清楚就问，不假设
  - Implementation Simplicity → 模型自主决策
  - Requirements Integrity → 需求变更必须用户 approval
  - Surgical Changes → Phase 3 只改必须改，不顺手

Auto Mode：
  触发："自动运行"/"全部都做"/"自动模式"
  规则：跳过所有"等待用户"步骤，保留所有 Gate 验证
  切换：用户主动干预则退回 Interactive
```

---

## 禁止规则

```
通用：
  - 需求裁剪必须用户 explicit approval
  - "实现简单" ≠ "需求裁剪"
  - 需求追加必须重新过 Gate 2

Phase 1：
  - 未探索就输出 Requirements List
  - 模糊批准（"全部执行"无具体勾选）
  - 跳过 Skill Prep 直接探索
  - 有 Domain 插件但不调用就规划

Phase 2：
  - PLAN 包含 TBD/TODO/未定义引用
  - Coverage < 100% 且无 explicit approval
  - 有 Domain 插件但不调用

Phase 3：
  - 无 failing test 就写实现
  - 变更超出 PLAN 范围
  - Gate 3 未通过就做 Review
  - Critical/Important open 时继续下一 task
  - 同一问题 3 种方案均失败不停止反思
  - 等所有 task 完成才开始验证

Phase 4：
  - 测试有 failures 就声明完成

Auto：
  - 跳过任何 Gate 验证
  - timeout 当失败处理（需 spot-check）

验证：
  - 声明完成必须有 ≥3 行命令输出
  - 子代理报告 ≠ 自己验证
  - 输出片段 < 3 行 → 不算通过
```
