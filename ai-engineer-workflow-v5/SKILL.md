---
name: ai-engineer-workflow-v5
description: 强化验证、防止蔓延、架构反思、需求完整性。六门控五循环，Phase 序列 1→2→3→4，按需技能部署。
---

# AI Engineer Workflow V5

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

## 三系统分工

| 系统 | 角色 | 职责 |
|------|------|------|
| workflow | 主执行 | Gate/Loop 控制 |
| 记忆层（可选） | 持久化 | GSD/milestone 跨 session |
| Karpathy | 监察 | 原则约束，违规即报 |

---

## Karpathy 监察

| 原则 | 束对象 | 决策权 |
|------|----------|--------|
| Think Before Coding | 所有 Phase | 不假设，不清楚就问 |
| Implementation Simplicity | 实现方式/代码结构/技术选型 | 模型自主 |
| Requirements Integrity | 需求范围/功能约束 | **必须用户 approval** |
| Surgical Changes | Phase 3 | 只改必须改，不顺手 |

```
❌ "实现简单" ≠ "需求裁剪"
❌ 需求简化必须用户 explicit approval
违规 → 立即报告 → 未 approve 前禁止 Phase 3
```

---

## 六门控（GATES）

### Gate 1: Design Approval
**Phase 1 → Phase 2**
```
❌ 写代码/创建结构/调用 plan skill
✅ brainstorming/探索/提问
触发："approved"/"继续"/"开始计划"
```

### Gate 2: Requirements Completeness
**Phase 2 → Phase 3**
```
❌ 开始实现/执行 task
✅ Lite Plan Check → Completeness → User approve
```
**Traceability Matrix**：
| Requirement | Tasks | Coverage | Status |
|-------------|-------|----------|--------|
| R1 | T1,T2 | 100% | ✅ Covered |
| R2 | T3 | 80% | ⚠️ Simplified（需 approval） |
| R3 | - | 0% | ❌ Missing（必须修复） |

**Lite Plan Check**：`TBD|TODO|implement later|fill in details|引用未定义类型` → 立即修复

### Gate 3: Test-First
**每个 task 开始前**
```
NO CODE WITHOUT FAILING TEST
✅ 测试存在 → FAIL → feature missing
不符合 → 先写测试
```

### Gate 4: Two-Stage Review
**每个 task 完成后（Gate 5 先通过）**
```
顺序：Gate 5 → Spec compliance → Code quality
❌ Gate 5 未通过就 Review
❌ Critical/Important open 时继续下一 task
Severity：Critical 立即修复 / Important 下 task 前 / Minor 记录
```

**Review 执行方式**：
| Review 类型 | 执行 Skill |
|-------------|------------|
| Spec compliance | superpowers:requesting-code-review 或 comprehensive-review |
| Code quality | superpowers:receiving-code-review + 修复循环 |

### Gate 5: Evidence-Based Verification
**任何声明状态时**
```
步骤：IDENTIFY → RUN → READ → EXTRACT(≥3行) → VERIFY → 声明
格式：
  命令：pytest -v
  输出：(≥3行)
  Exit：0
  结论：✅
```

**批量 Agent 规则**：
```
每个 Agent 完成 → 立即 Gate 5 → Gate 4 → Mark completed
不等"全部完成"
Timeout ≠ 失败 → spot-check: SUMMARY.md/git log
❌ 子代理报告 ≠ 自己验证完成
```

### Gate 6: Stop-On-Blocker + 3-Failure
**Phase 3 全程触发**
```
障碍处理：
  缺失依赖 → STOP → 报告 → 提供安装命令
  测试 errors → STOP → 报告 → 分析原因
  指令不清晰 → STOP → 问用户
  验证失败3次 → STOP → 问用户决策
  
同一问题修复 ≥3次 → 架构反思：
  1. STOP → 记录每次尝试
  2. 检查：shared state暴露？大规模重构？其他症状？
  3. YES → 架构问题，讨论重构
     NO → 回 Phase 1
❌ 继续第4次相同修复
```

---

## 五循环（LOOPS）

### Loop 1: Clarification + Skill Prep
`Explore → Scope → Ask (+ Skill Deploy if gap identified) → Spec → [Gate 1]`

**技能部署触发与流程**：
```
触发条件：澄清过程中发现缺乏专业知识，可能导致问题描述不准确或遗漏关键细节
执行流程：
  1. 发现知识缺口（对某领域不熟悉，无法提出精准问题）
  2. 匹配 plugin-loader 中的相关插件（见下方匹配表）
  3. 向用户说明需要该技能的原因
  4. 用户确认后调用 Skill: plugin-loader 执行安装
  5. 验证安装成功（claude plugin list 确认）
  6. 继续澄清
时机：在澄清完成前部署，不等到 Gate 1 之后
```

**插件匹配规则**：
| 需求关键词 | 推荐插件 |
|------------|----------|
| Python/fastapi/django | `python-development`, `pyright-lsp` |
| React/Next.js/前端 | `frontend-mobile-development`, `typescript-lsp` |
| API/后端/微服务 | `backend-development` |
| K8s/Kubernetes/Docker | `kubernetes-operations` |
| 安全/审计/合规 | `security-scanning`, `comprehensive-review` |
| LLM/AI/Agent | `llm-application-dev`, `agent-orchestration` |
| 测试/TDD | `tdd-workflows`, `unit-testing` |
| 数据库/SQL | `database-design` |
| Rust/系统编程 | `systems-programming`, `rust-analyzer-lsp` |

**Scope 选择**：git 仓库 → `--scope project`，否则 → `--scope local`

### Loop 2: Plan Revision
`Plan → Lite Check → Completeness → Self-review → User review → [Gate 2]`

Self-review：覆盖完整 / Status ✅或⚠️(已approve) / 类型一致

### Loop 3: Red-Green-Refactor
```
[范围确认] → [Gate 3] → RED → GREEN → REFACTOR → [Gate 5] → [Gate 4]
范围确认：对比 PLAN Files 和 git status → 超出 → STOP → 等批准
```

### Loop 4: Review-Fix
```
Stage 1: Spec → Fix → [Gate 5]
Stage 2: Quality → Fix → [Gate 5] → Mark completed
分歧 >2轮 → 用户裁决
```

### Loop 5: Complete
`测试 → [Gate 5] → 0 failures → 声明 → Merge/PR/Keep/Discard`

---

## Phase 流程

### Phase 1: CLARIFY
`brainstorming → Requirements List → User approve → [Gate 1] → Phase 2`

**技能部署**：见 Loop 1，发现知识缺口时立即部署。

### Phase 2: PLAN
`Plan Agent → Lite Check → Completeness → Self-review → User review → [Gate 2] → Phase 3`

**规划阶段知识缺口处理**：
```
触发：制定计划时发现缺乏某领域专业知识，可能影响计划质量
处理：暂停计划 → 部署技能（流程同 Loop 1）→ 技能就绪后继续规划
```

### Phase 3: EXECUTE
```
流程：
  Load plan → Create tasks
  For each task:
    1. 范围确认
    2. Mark in_progress
    3. [Gate 3] Test-First
    4. [Loop 3] TDD
    5. [Gate 5] 验证
    6. [Gate 4] Review
    7. Mark completed
    8. 知识缺口检测：如遇不熟悉领域 → 部署技能 → 继续
  Context >70% → checkpoint → /clear
  All tasks → Phase 4
```

**执行模式选择**：
| 条件 | 模式 | Skill |
|------|------|-------|
| 单文件改动 / 简单逻辑 | Inline | `executing-plans` |
| 多文件/多模块 / 有依赖关系 | Subagent | `subagent-driven-development` |

**Subagent 并行策略**：
```
并行边界划分：
  1. 识别 task 依赖关系（DAG）
  2. 无依赖的 task 可并行执行
  3. 有依赖的 task 串行执行（依赖完成后触发）
  
并行执行规则：
  ✅ 每个 task 独立完成 Gate 5 → Gate 4 → Mark completed
  ✅ 使用 TaskCreate/TaskUpdate 跟踪进度
  ✅ 一个 task 卡住 → 其他 task 继续执行
  ❌ 等所有 task 完成才开始验证
```

**执行阶段知识缺口处理**：
```
触发：执行时发现缺乏某领域知识
处理：当前 task 暂停 → 部署所需技能 → task 重试
失败：重试仍失败 → 标记 blocker → [Gate 6] → 询问用户
```

### Phase 4: COMPLETE
`finishing-a-development-branch → [Loop 5] → END`

---

## Auto Mode

**触发**："自动运行"/"离开一下"/"全部都做"/"自动模式"

| 可以跳过 | 禁止跳过 |
|----------|----------|
| 等待 approval（已授权） | Gate 5 验证 |
| 等待选择（"你决定"） | Gate 4 Review |
| 等待 decision 环节 | Gate 3 测试 |
| | Requirements Integrity |

```
误解纠正：
❌ "全部都做" ≠ 跳过验证
❌ 子代理报告 ≠ 自己验证
❌ timeout ≠ 失败
```

| 阻碍 | Interactive | Auto |
|------|-------------|------|
| blocker | STOP | 尝试下一方案 |
| Review 问题 | STOP | 自动修复 |
| 测试失败 | STOP | 自动调试 |
| 缺失依赖 | STOP | 自动安装 |
| Agent timeout | - | spot-check |

---

## Skill Mapping
superpowers
| Phase | Skill |
|-------|-------|
| 1 | brainstorming + plugin-loader (按需) |
| 2 | writing-plans |
| 3 Inline | executing-plans |
| 3 Subagent | subagent-driven-development |
| 4 | finishing-a-development-branch |

---

## Red Flags

```
Gate 违规：
  ❌ 无 failing test 就写代码 → Gate 3
  ❌ Gate 5 未通过就 Review → Gate 4
  ❌ 等全部完成才验证单个 → Wave-Based
  ❌ timeout 不 spot-check → Gate 5
  ❌ 输出片段 <3行 → Gate 5
  ❌ 子代理报告直接信任 → Gate 5

流程违规：
  ❌ Code before design → Gate 1
  ❌ TBD/TODO in plan → Lite Check
  ❌ 变更超 PLAN 范围 → Surgical Changes
  ❌ 继续4次相同修复 → 3-Failure (Gate 6)
  ❌ Critical/Important open 继续下 task → Gate 4

需求违规：
  ❌ 需求裁剪无 approval → Requirements Integrity
  ❌ "实现简单"偷换"需求满足"

Auto 违规：
  ❌ 跳过 Gate 3/4/5
  ❌ timeout 当失败不 spot-check
```

---

## Key Principles

```
Gate 控制 Phase 进入
Loop 控制 Phase 内完成

Phase 序列：1(Clarify) → 2(Plan) → 3(Execute) → 4(Complete)
技能部署：发现知识缺口时立即部署，不等规划阶段

验证铁律：≥3行输出 / timeout→spot-check / 不等全部完成
Review 顺序：Gate 5 → Spec → Quality
Auto 边界：跳过等待 / 禁止跳过验证
三次失败：架构反思 (Gate 6)
范围确认：对比 git status
```

---

## 工作流生命周期

**核心概念**：需求 = 一个完整工作流周期。项目开发通过一次次工作流完成而推进。

```
工作流序列：
  Phase 1 → Phase 2 → Phase 3 → Phase 4 → END
                                          ↓
                              用户提出新需求 → Phase 1
```

### 状态转换

| 当前状态 | 用户提出需求 | 动作 |
|----------|-------------|------|
| Phase 4 完成 | 新需求 | → Phase 1 新建需求 |
| 工作流进行中 | 同一需求追加 | → 合并到当前 PLAN |

### 与 Auto Mode 区别

```
Auto Mode：减少等待，持续执行（用户授权后自动推进）
工作流生命周期：需求级别的循环迭代

❌ Continuous Workflow ≠ Auto Mode
✅ 每个工作流独立完整，信息跨工作流共享
```

### 结束规则

```
Phase 4 完成时：
  1. 验证所有 Gate 通过（刚测试过则不重复）
  2. 记录 milestone 状态，更新项目文档
  3. 等待用户下一需求
  4. 收到需求 → 立即进入 Phase 1

❌ 工作流完成后主动探索新需求
✅ 只响应用户明确提出的需求
```