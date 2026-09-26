# Change Cycle 模板

Plan 创建 Cycle 文件时使用本模板。每个 Cycle 文件位于 change 的 `iterations/<III-title>/` 下。模板随 plan 技能分发，不生成项目级副本。

```markdown
# Iteration <III> / Cycle <CCC>: <TITLE>

## Plan Context

- Status: draft
- Cycle Type: initial | rework | replan

**Cycle Scope**

- Change tasks: <本逻辑 Iteration 的 task ID>
- Acceptance gaps: <本 Cycle 必须关闭的既有验收缺口；initial 写 None>
- Repair items: <T2-R1 等本地 repair item；initial 和 replan 写 None>
- Inherited scope: <继续有效的 requirement、task 和约束>
- Excluded scope: <不属于当前 Iteration 的新需求、清理或其他工作>

**Objective**

<本 Cycle 完成后应达到的可验证结果；rework 仍服务于原 Iteration Acceptance>

**Background**

<rework 和 replan 记录需求来源、历史问题和本 Cycle 原因；initial 没有新增背景时整节省略>

**Investigation Facts**

- Current Baseline: <revision、当前实现、已有能力、已知限制和基线验证结果；可引用未失效的既有结论并注明来源>
- Current-State Evidence: <Plan 已确认且与实施直接相关的入口、目标符号、调用者、被调用者、动态边、状态、错误路径和测试入口；可引用 Explorer 来源，但不得要求 Act 回读才能执行>
- Code and Critical Path: <文件、模块、符号及其职责；入口、调用链、数据流、状态变化和外部影响>

**Implementation Guidance**

<建议顺序、必要技术细节和关键取舍；不重复 Task Contract>

**Task Contracts**

Task Contract 是 Act 的任务级执行依据，其 Targets、Current/Required behavior 和 Preserve/Forbidden 共同表达变更面与责任边界。对每个 initial/replan task 或 rework repair item 使用：

### <Task/Repair ID>: <可验证结果>

- Requirement/Scenario: <映射>
- Depends on: <依赖或 None>
- Targets: <path::symbol，可多项>
- Current behavior: <当前可观察行为>
- Required behavior: <完成后可观察行为，含必须完成的接口、状态或错误语义变化>
- Preserve: <必须保持的约束>
- Forbidden: <不得修改或扩大的范围>
- Test witness: <位置、RED 或变更前 GREEN、命令和预期结果>
- GREEN condition: <修改后通过条件>
- Verification: <自动命令或人工步骤、通过条件和失败含义；人工步骤写最短操作与直接可观察结果>
- Stop when: <契约失效或需要返回 Plan 的实质条件>

变量名、辅助函数拆分和等价局部控制流不写入契约，除非它们影响可观察行为或责任边界。

**Invariants**

<不得破坏的行为、兼容性和架构约束>

**Non-goals**

<本 Cycle 不处理的内容；rework 不得扩大原 Iteration 范围>

**Acceptance**

<可观察验收条件及 requirement、scenario、design、task、代码和测试映射；跨任务行为语义写在此处或 Invariants>

**Verification**

<逐 scenario 的最简直接判定：自动命令或人工步骤与通过依据；不得使用身份型证据工程或判定层替代行为验证（公共规则 › 验证）>

**Gate 2 Readiness**

<一行结论；只逐项列 BLOCKED/WAIVED 及证据。检查项清单见 openspec-plan 的 Gate 2>

**Persisted Evidence**

- Mode: none | required

<`none` 表示 Act Response 足以承载验证结果；`required` 时逐项列出 Acceptance、Act Response 不足原因、不可低成本重跑原因、缺失时受阻决定、文件和通过条件>

**Risks and Notes**

<条件性风险、非实质未知项、WAIVED 项和额外注意事项；不得把需要 Act 决定契约语义的问题留在此处>

## Act Response

- Status: pending

**Implemented**

<实际完成内容；含修改的文件、符号和作用>

**Deviations from Plan**

<偏差、原因和影响；没有则整节省略>

**Blocker Handoff**

<正常完成整节省略；blocked 时填写：>

- Discovered at: <task / repair item / step / Gate>
- Expected vs Actual: <Plan 预期与实际情况>
- Impact: <为何不能按当前 Cycle 继续>
- Remaining work: <已完成与未开始任务、工作区状态一行>
- Resume condition: <当前 Cycle 可恢复的条件；需 Review 时说明>

**Blocker Resolution**

<未恢复时整节省略；用户要求继续时追加：>

- User instruction: <用户提供的事实、办法或风险豁免>
- Resolution: <阻塞如何解除>
- Accepted risk: <已接受风险或 None>
- Resume point: <恢复的 task / step>
- Required verification: <恢复前后需要重跑的 Gate>

**Self-Review**

<自检发现、已修复内容和遗留 Minor 问题；没有发现则整节省略>

**Verification Evidence**

<命令或操作、每项不超过 20 行的决定性输出、退出码、支持的 Acceptance 和结论；采信既有结论时注明来源>

**Persisted Evidence**

<`None required`，或 `../../evidence/<III-title>/<CCC-title>/README.md` 及证据编号>

**Experience Candidates**

<没有候选则整节省略；有候选时记录类型、主题、证据和满足产物门槛的原因>

**Remaining Issues**

<未解决问题；没有则整节省略>

## Plan Review

- Review Result: pending

**Findings**

<基于代码、diff 和验证证据的发现；区分阻塞 Acceptance 与非阻塞 Minor finding，偏差原因（Plan 遗漏、Plan 错误、Act 偏离、基线变化或新证据）并入本节>

**Acceptance Gaps**

<未满足的既有 Acceptance 及证据；没有则整节省略>

**Evidence**

<文件、符号、命令和输出；采信 Act Response 未失效结论时注明来源>

**Follow-up Decision**

<为何接受、为何留在当前 Cycle 修复、为何创建 rework Cycle，或为何必须重新规划>

**Iteration Plan Update**

<仅 `replan-required` 填写目标、范围、依赖、验证契约或验收边界变化；没有则整节省略>

**Next Cycle**

<`rework-required` 或 `replan-required` 创建的同一 Iteration 后继 Cycle；当前 Cycle 修复或没有后继时写 None>

**Next Iteration**

<仅在当前 Iteration 被接受后记录下一逻辑 Iteration 路径；没有则写 None>
```

## 写入规则

模板结构与目录命名：

- Plan 创建 Iteration 目录和 Cycle 文件；Iteration 目录使用 `<III-title>/`，Cycle 文件使用 `<CCC-title>.md`，两级编号都从 `000` 递增。
- Plan 创建文件时把 `Plan Context` 状态设为 `draft`；Gate 2 全部通过或被用户明确豁免且计划获批后，最后改为 `ready`。未通过时保持 `draft`，不得交给 Act。
- Plan 在 change `tasks.md` 中规划全部逻辑 Iteration，但只展开当前 Iteration 和当前 Cycle。

Cycle 的状态迁移、覆盖与冻结、Review Result 终态与重入、rework 与 replan 边界、阻塞恢复、Experience Candidates 授权和 Persisted Evidence 规则，按公共规则 › Iteration 与 Cycle 线程 执行；本文件不重复协议正文。
