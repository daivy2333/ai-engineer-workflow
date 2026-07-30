# Change iteration 模板

将下面内容生成到 `.claude/docs/templates/change-iteration.md`。Plan 按此模板在 change 的 `iterations/` 下创建每一轮上下文。

```markdown
# Iteration <NNN>: <TITLE>

## Plan Context

- Status: ready
- Round: <NNN>
- Parent: <NONE_OR_PARENT>

**Objective**

<本轮可验证结果>

**Background**

<需求来源、历史问题和本轮原因>

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

| Task | Requirement/Scenario | File/Symbol | Current Responsibility | Planned Change |
|---|---|---|---|---|
| T1 | R1/S1 | `<path::symbol>` | <当前职责> | <计划变化> |

**Task Contracts**

对每个任务记录：

- 依赖和执行顺序。
- 当前行为和目标行为。
- 必须修改与禁止修改的内容。
- 测试位置、预期 RED 原因和 GREEN 条件。
- 验证命令、通过条件和失败含义。
- 计划失效时的停止条件。

**Invariants**

<不得破坏的行为、兼容性和架构约束>

**Non-goals**

<本轮不处理的内容>

**Acceptance**

<可观察验收条件及 requirement、scenario、design、task、代码和测试映射>

**Verification**

<测试、检查命令和所需证据>

**Gate 2 Readiness**

| Dimension | Status | Evidence |
|---|---|---|
| Investigation | PASS/BLOCKED/WAIVED | <当前实现与影响面证据> |
| Design | PASS/BLOCKED/WAIVED | <行为和接口设计证据> |
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

- Discovered at: <task / step / Gate>
- Expected: <Plan 预期>
- Actual: <实际情况>
- Impact: <为何不能按原计划继续>
- Completed work: <已完成任务>
- Partial work: <部分修改>
- Unstarted work: <未开始任务>
- Worktree state: <修改文件和安全状态>
- Gates: <已通过和阻塞的 Gate>
- Evidence: <证据编号、路径或 None required>
- Plan decision needed: <需要 Plan 重新决定的问题>
- Resume condition: <后续 iteration 的恢复条件>

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

<`None required`，或 `../evidence/<NNN-title>/README.md` 及证据编号>

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

<follow-up-required | no-follow-up>

**Findings**

<基于代码、diff 和验证证据的发现>

**Deviation Classification**

<PLAN-OMISSION | PLAN-INVALID | ACT-DEVIATION | BASELINE-CHANGED | NEW-EVIDENCE | None>

**Evidence**

<文件、符号、命令和输出>

**Follow-up Decision**

<下一步和范围>

**Next Iteration**

<新 iteration 路径或 None>
```

## 写入规则

- Plan 创建文件并填写 `Plan Context`。
- Plan 必须把 Persisted Evidence 明确设为 `none` 或 `required`。
- Act 只填写 `Act Response`。
- Act 在 Experience Candidates 中记录有证据的 Runbook 或 Incident 候选；没有则写 `None`。
- 正常完成时，Act 把状态从 `pending` 改为 `reported`。
- 计划偏差阻塞时，Act 填写 Blocker Handoff 并把状态改为 `blocked`。
- `blocked` iteration 不得恢复执行；Plan Review 后创建新 iteration。
- `required` 时，Act 按自身 Evidence 格式创建对应目录；`none` 时不创建占位目录。
- Plan Review 只填写 `Plan Review`。
- Experience Candidates 不构成 Recorder 授权，也不是 Act 完成 Gate。
- 已交接的区域只追加所属角色预留内容，不改写历史。
- Review 需要后续工作时创建下一编号文件。
- 文件名使用 `NNN-title.md`，编号从 `000` 递增。
