# Change Cycle 模板

将下面内容生成到 `.claude/docs/templates/change-cycle.md`。Plan 在 change 的 `iterations/<III-title>/` 下为每次执行闭环创建一个 Cycle 文件。

```markdown
# Iteration <III> / Cycle <CCC>: <TITLE>

## Plan Context

- Status: draft
- Iteration: <III-title>
- Cycle: <CCC-title>
- Cycle Type: initial | rework | replan
- Parent cycle: None | <relative-path>

**Iteration Scope**

- Change tasks: <本逻辑 Iteration 的 task ID>
- Depends on: <前序 Iteration 或 None>
- Stable baseline: <完成后下一 Iteration 可依赖的结果>
- Verification boundary: <逻辑 Iteration 的独立完成判据>
- Diagnostic boundary: <失败时的排查范围>
- Deferred tasks: <后续 Iteration 的 task ID 或 None>

**Cycle Scope**

- Trigger: initial | rework-required | replan-required
- Acceptance gaps: <本 Cycle 必须关闭的既有验收缺口；initial 写 None>
- Repair items: <T2-R1 等本地 repair item；initial 和 replan 写 None>
- Inherited scope: <继续有效的 requirement、task 和约束>
- Excluded scope: <不属于当前 Iteration 的新需求、清理或其他工作>

**Objective**

<本 Cycle 完成后应达到的可验证结果；rework 仍服务于原 Iteration Acceptance>

**Background**

<需求来源、历史问题和本 Cycle 原因>

**Current Baseline**

<revision、当前实现、已有能力、已知限制和基线验证结果>

**Current-State Evidence**

<Plan 已确认且与实施直接相关的入口、目标符号、调用者、被调用者、动态边、状态、错误路径和测试入口；可引用 Explorer 来源，但不得要求 Act 回读才能执行>

**Relevant Code**

<文件、模块、符号及其职责>

**Critical Path**

<入口、调用链、数据流、状态变化和外部影响>

**Implementation Guidance**

<建议顺序、必要技术细节和关键取舍；不重复 Task Contract>

**Behavioral Change**

<当前行为、目标行为、接口、状态和错误语义的变化>

**Change Surface**

| Task/Repair | Requirement/Scenario | File/Symbol | Current Responsibility | Planned Change |
|---|---|---|---|---|
| T1 | R1/S1 | `<path::symbol>` | <当前职责> | <计划变化> |

**Task Contracts**

Task Contract 是 Act 的任务级执行依据。对每个 initial/replan task 或 rework repair item 使用：

### <Task/Repair ID>: <可验证结果>

- Requirement/Scenario: <映射>
- Depends on: <依赖或 None>
- Targets: <path::symbol，可多项>
- Current behavior: <当前可观察行为>
- Required behavior: <完成后可观察行为>
- Required changes: <必须完成的行为、接口、状态或错误语义变化>
- Preserve: <必须保持的约束>
- Forbidden: <不得修改或扩大的范围>
- Test witness: <位置、RED 或变更前 GREEN、命令和预期结果>
- GREEN condition: <修改后通过条件>
- Verification: <命令、通过条件和失败含义>
- Stop when: <契约失效或需要返回 Plan 的实质条件>

变量名、辅助函数拆分和等价局部控制流不写入契约，除非它们影响可观察行为或责任边界。

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
| Task Contracts | PASS/BLOCKED/WAIVED | <只读当前 Cycle 即可建立测试见证并实施的证据> |
| Traceability | PASS/BLOCKED/WAIVED | <RTM 证据> |
| Verification | PASS/BLOCKED/WAIVED | <测试和通过条件> |

**Persisted Evidence**

- Mode: none | required

<`none` 表示 Act Response 足以承载验证结果；`required` 时逐项列出 Acceptance、Act Response 不足原因、不可低成本重跑原因、缺失时受阻决定、文件和通过条件>

- Budget: 本 Cycle 最多 5 个文件（含 README），整个 change 最多 20 个 Evidence 文件；单个文本文件最多 500 行且不超过 256 KiB；超限需要用户明确批准。

**Risks and Notes**

<条件性风险、非实质未知项、WAIVED 项和额外注意事项；不得把需要 Act 决定契约语义的问题留在此处>

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

<命令或操作、每项不超过 20 行的决定性输出、退出码、支持的 Acceptance 和结论>

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

- Review Result: pending

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

<`rework-required` 必须写 None；`replan-required` 记录目标、范围、依赖、验证契约或验收边界变化；`accepted` 时记录 None>

**Next Cycle**

<`rework-required` 或 `replan-required` 创建的同一 Iteration 后继 Cycle；没有则写 None>

**Next Iteration**

<仅在当前 Iteration 被接受后记录下一逻辑 Iteration 路径；没有则写 None>
```

## 写入规则

- Plan 创建 Iteration 目录和 Cycle 文件时把 `Plan Context` 状态设为 `draft`；Gate 2 全部通过或被用户明确豁免且计划获批后，最后改为 `ready`。未通过时保持 `draft`，不得交给 Act。
- Plan 在 change `tasks.md` 中规划全部逻辑 Iteration，但只展开当前 Iteration 和当前 Cycle。
- 每个 Iteration 从 `000-initial.md` 开始；`rework-required` 和 `replan-required` 分别在同一目录创建下一编号的 `rework` 或 `replan` Cycle。
- Rework Cycle 使用本地 repair item 完成既有 Acceptance，不新增全局 change task，不修改 Iteration Map。
- Replan Cycle 使用更新后的 change tasks、specs、design 和 Iteration Plan 建立新 Plan Context，允许改变目标、范围、依赖、验证契约或 Acceptance，并重新通过 Gate 2。
- Plan 必须把 Persisted Evidence 明确设为 `none` 或 `required`；`required` 仅用于用户明确要求、无法低成本复现、一次性环境、Incident/Blocker 现场，或摘要会丢失决定性结构的结果。
- Act 只填写当前 Cycle 的 `Act Response`。
- Act 不复核 Plan 基线，直接按 ready 的 Task Contract 建立测试见证并实施。
- Act 在契约内处理非实质局部差异并记录；只有实质冲突才填写 Blocker Handoff。
- Act 在 Experience Candidates 中记录有证据的 Runbook 或 Incident 候选；没有则写 `None`。
- 正常完成时，Act 把状态从 `pending` 改为 `reported`。
- 计划偏差构成公共规则定义的实质问题，导致契约无法继续时，Act 填写 Blocker Handoff 并把状态改为 `blocked`。
- 用户解决阻塞并要求继续时，Act 追加 Blocker Resolution，执行 `blocked → pending` 后恢复当前 Cycle。
- 已创建后继 Cycle 或 `Review Result` 不再为 `pending` 时，不再恢复旧 Cycle。
- 有效的 `required` 由 Act 按自身 Evidence 格式和公共预算创建对应目录；`none` 时不创建占位目录。`required` 不再满足白名单、必要性、预算或可采集性时，Act 按 Gate 6 改为 `blocked` 并返回 Plan，不强行收集。
- `Plan Review` 的 `Review Result` 初始为 `pending`。Plan 写完 Review，完成所需计划更新，并写入、验证后继 Cycle 或 Iteration 后，最后改为 `accepted`、`rework-required` 或 `replan-required`。
- Review 重入时，若 `Review Result` 仍为 `pending`，但已存在 `Next Cycle` 或 `Next Iteration` 指向的产物，Plan 验证一致后复用，不重复创建。
- `accepted` 才能完成当前 Iteration 并展开 Map 中的下一 Iteration。
- `rework-required` 只能创建同一 Iteration 内的下一 Cycle。
- `replan-required` 才能调整 Iteration Plan，并在同一 Iteration 创建下一 `replan` Cycle；旧 Cycle 不改写。
- Experience Candidates 不构成 Recorder 授权，也不是 Act 完成 Gate。
- 已交接的区域只追加所属角色预留内容，不改写历史。
- Iteration 目录使用 `<III-title>/`，Cycle 文件使用 `<CCC-title>.md`；两级编号都从 `000` 递增。
