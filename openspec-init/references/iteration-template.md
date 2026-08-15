# Change Cycle 模板

将下面内容生成到 `.claude/docs/templates/change-cycle.md`。Plan 在 change 的 `iterations/<III-title>/` 下为每次执行闭环创建一个 Cycle 文件。

```markdown
# Iteration <III> / Cycle <CCC>: <TITLE>

## Plan Context

- Status: ready
- Iteration: <III-title>
- Cycle: <CCC-title>
- Cycle Type: initial | rework
- Parent cycle: None | <relative-path>

**Iteration Scope**

- Change tasks: <本逻辑 Iteration 的 task ID>
- Depends on: <前序 Iteration 或 None>
- Stable baseline: <完成后下一 Iteration 可依赖的结果>
- Verification boundary: <逻辑 Iteration 的独立完成判据>
- Diagnostic boundary: <失败时的排查范围>
- Deferred tasks: <后续 Iteration 的 task ID 或 None>

**Cycle Scope**

- Trigger: initial | rework-required
- Acceptance gaps: <本 Cycle 必须关闭的既有验收缺口；initial 写 None>
- Repair items: <T2-R1 等本地 repair item；initial 写 None>
- Inherited scope: <继续有效的 requirement、task 和约束>
- Excluded scope: <不属于当前 Iteration 的新需求、清理或其他工作>

**Objective**

<本 Cycle 完成后应达到的可验证结果；rework 仍服务于原 Iteration Acceptance>

**Background**

<需求来源、历史问题和本 Cycle 原因>

**Current Baseline**

<revision、当前实现、已有能力、已知限制和基线验证结果>

**Current-State Evidence**

<入口、目标符号、调用者、被调用者、动态边、状态、错误路径、测试入口及证据位置>

**Relevant Code**

<文件、模块、符号及其职责>

**Critical Path**

<入口、调用链、数据流、状态变化和外部影响>

**Implementation Guidance**

<建议顺序、必要技术细节和关键取舍>

**Behavioral Change**

<当前行为、目标行为、接口、状态和错误语义的变化>

**Change Surface**

| Task/Repair | Requirement/Scenario | File/Symbol | Current Responsibility | Planned Change |
|---|---|---|---|---|
| T1 | R1/S1 | `<path::symbol>` | <当前职责> | <计划变化> |

**Task Contracts**

对 initial Cycle 中的 task 或 rework Cycle 中的 repair item 记录：

- 依赖和执行顺序。
- 当前行为和目标行为。
- 必须修改与禁止修改的内容。
- 测试位置、任务类型对应的 RED 或变更前 GREEN 见证，以及修改后 GREEN 条件。
- 验证命令、通过条件和失败含义。
- 计划失效时的停止条件。

**Invariants**

<不得破坏的行为、兼容性和架构约束>

**Non-goals**

<本 Cycle 不处理的内容；rework 不得扩大原 Iteration 范围>

**Acceptance**

<可观察验收条件及 requirement、scenario、design、task、代码和测试映射>

**Verification**

<测试、检查命令和所需证据>

**Gate 2 Readiness**

| Dimension | Status | Evidence |
|---|---|---|
| Investigation | PASS/BLOCKED/WAIVED | <当前实现与影响面证据> |
| Design | PASS/BLOCKED/WAIVED | <行为和接口设计证据> |
| Iteration Plan | PASS/BLOCKED/WAIVED | <逻辑 Iteration 的任务、依赖和平衡审计> |
| Cycle Scope | PASS/BLOCKED/WAIVED | <initial 范围或 rework Acceptance gap 与 repair item> |
| Task Contracts | PASS/BLOCKED/WAIVED | <任务可执行性证据> |
| Traceability | PASS/BLOCKED/WAIVED | <RTM 证据> |
| Verification | PASS/BLOCKED/WAIVED | <测试和通过条件> |

**Persisted Evidence**

- Mode: none | required

<`none` 表示 Act Response 足以承载验证结果；`required` 时列出 Gate、文件、格式和通过条件>

**Risks and Notes**

<条件性风险、未确认项、WAIVED 项和额外注意事项>

## Act Response

- Status: pending

**Implemented**

<实际完成内容>

**Changed Files and Symbols**

<文件、符号和作用>

**Deviations from Plan**

<偏差、原因和影响；没有则写 None>

**Blocker Handoff**

<正常完成写 None；blocked 时填写：>

- Discovered at: <task / repair item / step / Gate>
- Expected: <Plan 预期>
- Actual: <实际情况>
- Impact: <为何不能按当前 Cycle 继续>
- Completed work: <已完成任务>
- Partial work: <部分修改>
- Unstarted work: <未开始任务>
- Worktree state: <修改文件和安全状态>
- Gates: <已通过和阻塞的 Gate>
- Evidence: <证据编号、路径或 None required>
- Plan decision needed: <需要 Plan 重新决定的问题>
- Resume condition: <当前 Cycle 可恢复的条件；需 Review 时说明>

**Blocker Resolution**

<未恢复时写 None；用户要求继续时追加：>

- User instruction: <用户提供的事实、办法或风险豁免>
- Resolution: <阻塞如何解除>
- Accepted risk: <已接受风险或 None>
- Resume point: <恢复的 task / step>
- Required verification: <恢复前后需要重跑的 Gate>

**Self-Review**

- Plan compliance: PASS | BLOCKED
- Full diff reviewed: PASS | BLOCKED
- Critical findings unresolved: <数量>
- Important findings unresolved: <数量>
- Minor findings unresolved: <数量>

<记录 Act 自检发现、已修复内容、重跑验证和遗留 Minor 问题>

**Verification Evidence**

<命令或操作、关键输出、退出码和结论>

**Persisted Evidence**

<`None required`，或 `../../evidence/<III-title>/<CCC-title>/README.md` 及证据编号>

**Experience Candidates**

| Type | Candidate | Evidence | Reason |
|---|---|---|---|
| Runbook / Incident | <候选主题> | <Act Response 或 Evidence> | <满足产物门槛的原因> |

<没有候选时写 None。候选不构成创建授权>

**Remaining Issues**

<未解决问题或 None>

**Commit or Diff Reference**

<可选引用；本字段不要求创建 Git commit>

## Plan Review

- Status: pending

**Review Result**

<accepted | rework-required | replan-required>

**Findings**

<基于代码、diff 和验证证据的发现；区分阻塞 Acceptance 与非阻塞 Minor finding>

**Deviation Classification**

<PLAN-OMISSION | PLAN-INVALID | ACT-DEVIATION | BASELINE-CHANGED | NEW-EVIDENCE | None>

**Acceptance Gaps**

<未满足的既有 Acceptance 及证据；没有则写 None>

**Convergence**

<Acceptance gap 相比父 Cycle 为 reduced | unchanged | expanded；initial Cycle 无父项时写 N/A>

**Evidence**

<文件、符号、命令和输出>

**Follow-up Decision**

<为何接受、为何在同一 Iteration 返工，或为何必须重新规划>

**Iteration Plan Update**

<`rework-required` 必须写 None；`replan-required` 记录目标、范围、依赖或验收边界变化；`accepted` 时记录 None>

**Next Cycle**

<同一 Iteration 内的新 Cycle 路径；没有则写 None>

**Next Iteration**

<当前 Iteration 被接受后展开的下一逻辑 Iteration 路径；没有则写 None>
```

## 写入规则

- Plan 创建 Iteration 目录和 Cycle 文件，并填写 `Plan Context`。
- Plan 在 change `tasks.md` 中规划全部逻辑 Iteration，但只展开当前 Iteration 和当前 Cycle。
- 每个 Iteration 从 `000-initial.md` 开始；只有 `rework-required` 才在同一目录创建下一编号的 `rework` Cycle。
- Rework Cycle 使用本地 repair item 完成既有 Acceptance，不新增全局 change task，不修改 Iteration Map。
- Plan 必须把 Persisted Evidence 明确设为 `none` 或 `required`。
- Act 只填写当前 Cycle 的 `Act Response`。
- Act 在 Experience Candidates 中记录有证据的 Runbook 或 Incident 候选；没有则写 `None`。
- 正常完成时，Act 把状态从 `pending` 改为 `reported`。
- 计划偏差阻塞时，Act 填写 Blocker Handoff 并把状态改为 `blocked`。
- 用户解决阻塞并要求继续时，Act 追加 Blocker Resolution，执行 `blocked → pending` 后恢复当前 Cycle。
- 已创建后继 Cycle 或完成 Plan Review 时，不再恢复旧 Cycle。
- `required` 时，Act 按自身 Evidence 格式创建对应目录；`none` 时不创建占位目录。
- Plan Review 只填写 `Plan Review`。
- `accepted` 才能完成当前 Iteration 并展开 Map 中的下一 Iteration。
- `rework-required` 只能创建同一 Iteration 内的下一 Cycle。
- `replan-required` 才能调整 Iteration Plan；旧 Cycle 不改写。
- Experience Candidates 不构成 Recorder 授权，也不是 Act 完成 Gate。
- 已交接的区域只追加所属角色预留内容，不改写历史。
- Iteration 目录使用 `<III-title>/`，Cycle 文件使用 `<CCC-title>.md`；两级编号都从 `000` 递增。
