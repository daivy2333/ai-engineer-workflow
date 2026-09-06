# Iteration 与 Cycle 规划

Plan 在 change 的 `tasks.md` 中规划全部逻辑 Iteration。每个 Iteration 表示一个稳定、可验证、可排障的阶段成果；Iteration 内的 Cycle 记录为达到该成果发生的 Plan、Act 和 Review 执行闭环。

```text
Iteration = 逻辑工作单元，进入 change 的 Iteration Plan
Cycle     = 一次执行尝试，只存在于所属 Iteration 目录
```

返工不自动产生新 Iteration。只有目标、范围、依赖、验证契约或验收边界发生实质变化时，才调整 Iteration Plan，并在当前 Iteration 建立后继 replan Cycle。

## Iteration Plan

```markdown
## Iteration Plan

### Iteration 000: <阶段结果>

- Tasks: T1, T2
- Depends on: None
- Stable baseline: <下一 Iteration 可依赖的结果>
- Verification boundary: <本 Iteration 独立完成判据>
- Diagnostic boundary: <失败时的排查范围>
- Non-goals: <留给后续 Iteration 的内容>
```

- 每个 task 只分配给一个 Iteration，依赖只能指向同一或更早的 Iteration。
- Iteration 按依赖顺序编号。Plan 只为当前 Iteration 创建目录和当前 Cycle 文件；后续 Iteration 保留在 `tasks.md`。
- 不按固定 task 数、文件数或代码行数切分。小 change 经审计后可以只有一个 Iteration。
- Cycle 在所属 Iteration 内从 `000-initial.md` 开始，后继 Cycle 按 `001-rework.md`、`002-replan.md` 等递增，不占用全局 Iteration 编号。

目录结构：

```text
.agents/changes/<change>/iterations/
├── 000-foundation/
│   ├── 000-initial.md
│   └── 001-rework.md
└── 001-integration/
    └── 000-initial.md
```

## 平衡审计

每个 Iteration 应形成一个内聚结果，具有足够工作量、稳定基线、独立验证和明确诊断范围。

- 只有局部步骤、单项测试或观测，完成后不能形成稳定结果时，与相邻 Iteration 合并。
- 包含多个可独立验收结果、不同故障域或无关验证时拆分。
- 跨模块不自动要求拆分；共同形成一个可验证结果时可以保留。
- 首个 Iteration 不得因编号为 `000` 而承载整个 change；单 Iteration 也必须通过相同审计。

Initial 和 rework Cycle 只能完成所属 Iteration 的既有 Acceptance，不能引入新成果或扩大范围。Replan Cycle 在更新 Iteration Plan 后重新执行平衡审计，并以修订后的 Acceptance 为边界。

## Review 分类

Plan Review 先判断发现是否阻塞当前 Iteration 的既有 Acceptance：

| 发现 | Review Result | 后续动作 |
|---|---|---|
| 既有 Acceptance 未满足，但修复仍受当前 Plan Context 约束，不需要新的执行上下文 | 保持 `pending` | Plan 在 Review 给出当前 Cycle 修复意见；不创建后继 Cycle |
| 实现不达标、Act 偏离计划，或 Plan 遗漏需要新的 Current-State Evidence、repair item、Task Contract 或 Gate 2 | `rework-required` | 在同一 Iteration 目录创建下一 Cycle；Iteration Plan 不变 |
| 只有不阻塞 Acceptance 的 Minor finding | `accepted` | 记录 finding；按职责决定是否另建后续 task，不强制返工 |
| 目标、范围、依赖、requirement、设计、验证契约或验收边界需要改变 | `replan-required` | 停止普通返工；更新 change 和未完成 Iteration Plan，再创建后继 replan Cycle |
| Acceptance 已满足且没有阻塞项 | `accepted` | 完成当前 Iteration；存在后续 Iteration 时只展开下一个 |

判断问题：

```text
该工作是否是达到当前 Iteration 原有 Acceptance 的必要条件？
```

答案为“是”时留在当前 Iteration；答案为“否”时不得以返工名义扩大当前 Cycle。
范围或验证契约变化必须使用 `replan-required`，不得伪装为普通返工。

当前 Cycle 修复与 rework Cycle 的边界不是文件数、代码行数或预计时间，而是 Act 是否需要新的自包含执行契约。Plan Review 已能给出有限修复目标，且原 Task Contract、Change Surface、不变量和验证方法仍足以约束 Act 时，留在当前 Cycle；需要重新调查、拆分 repair item、建立新基线或重新通过 Gate 2 时，创建 rework Cycle。

`Review Result` 初始为 `pending`。Plan 写完 Review、所需计划更新和后继产物并验证后，最后将它改为终态；写入失败时保持 `pending`。

Review 重入时，若 `Review Result` 仍为 `pending`，但 `Next Cycle` 或 `Next Iteration` 指向的产物已经存在，Plan 验证它与当前 Review 一致后复用并继续，不创建重复后继产物。

## 当前 Cycle 修复

Plan 判断有限修复可由当前执行契约覆盖时：

1. 覆盖当前 `Plan Review` 为最新完整审查，填写具体 Findings、Acceptance Gaps、Evidence 和 Convergence；`Iteration Plan Update`、`Next Cycle`、`Next Iteration` 均为 `None`。
2. 最后在 `Follow-up Decision` 明确要求 Act 在当前 Cycle 修复，`Review Result` 保持 `pending`。该字段写完前，`reported` 的 Act 不得恢复。
3. Act 把状态从 `reported` 改为 `pending`，只读取最新 Review 和修复所需的任务局部上下文，按当前契约建立测试见证并实施。
4. Act 完成后覆盖 `Act Response` 为当前 Cycle 的最新完整快照，再改为 `reported`；Plan 随后覆盖 Review 并重新判断。
5. 覆盖前若已有当前 Cycle 反馈，Convergence 与上一版 Acceptance Gaps 比较；否则沿用父 Cycle 比较规则。gap 为 `reduced` 且剩余修复仍受当前契约约束时可以继续；`unchanged`、`expanded` 或需要新执行契约时改为 rework。Act 的实际修复尝试仍受 Gate 6 约束。

覆盖只适用于 `Review Result: pending`、没有后继 Cycle 的当前活跃 Cycle。Plan Context 始终不可改写；Plan 和 Act 只能覆盖各自区域，且覆盖内容必须是当前 Cycle 的完整最新状态，不保存逐轮文字历史。Review 进入终态或后继 Cycle 已创建后，Cycle 冻结。Blocked Handoff、Resolution 和持久化 Evidence 仍按各自规则保留。

## Rework Cycle

`rework-required` 时：

1. 为每项 Acceptance gap 建立本地 repair item，并映射到原 task、requirement、证据和来源 Cycle。repair item 可使用 `T2-R1` 形式，但不作为新的全局 change task，也不修改 Iteration Map。
2. 在当前 Iteration 目录创建下一 Cycle 文件，记录父 Cycle、偏差分类、Acceptance gap、继承范围、repair item、当前代码基线、验证方法和停止条件。
3. Plan 根据父 Cycle、Act Response 和当前代码补齐 Acceptance gap 所需的 Current-State Evidence，并重新通过 Gate 2；不重复调查未变化范围。新 Cycle 仍直接写入 Act 所需事实，不要求 Act 回读父 Cycle。
4. Act 和 Plan 分别填写新 Cycle 的 Act Response 与 Plan Review；旧 Cycle 不改写。
5. 连续两个 rework Cycle 未缩小同一 Acceptance gap 时，Review 必须检查 Plan、设计和需求假设；只有确认目标、范围、依赖、requirement、设计、验证契约或验收边界需要改变时才进入 replan。同一问题连续失败三次时触发三次失败规则，不创建第四次同类 Cycle。

## Replan Cycle

`replan-required` 时：

1. 按需更新 change 的 tasks、specs、design 和未完成 Iteration Plan，保留 requirement 映射；不得改写已交接 Cycle。
2. 在当前 Iteration 目录创建下一编号的 replan Cycle，记录父 Cycle、变化原因、修订后的任务和 Acceptance。
3. Replan Cycle 使用更新后的全局 task，不创建 rework repair item；Plan Context 从 `draft` 开始并重新通过 Gate 2 后变为 `ready`。
4. 当前 Iteration 在 replan Cycle 获得 `accepted` 前保持未完成；后续 Iteration 只保留在修订后的 Map 中。

Act 因 `required` Evidence 不再满足白名单、必要性、预算或可采集性而阻塞时，Plan Review 将其分类为 `PLAN-INVALID` 或 `NEW-EVIDENCE`，使用 `replan-required` 修正 Evidence 契约，不要求 Act 按原计划继续收集。父 Cycle 的无效 `required` 由该 Review 和 `Next Cycle` 形成的 replan 链替代，正常收尾不再要求为它补建 Evidence。

## 推进下一 Iteration

只有当前 Cycle 的 Review Result 为 `accepted`，当前 Iteration 才算完成。

1. 若 `tasks.md` 仍有后续 Iteration，Plan 按既有 Map 展开下一个 Iteration 目录及其 `000-initial.md`，不因当前 Iteration 的 Cycle 数量修改或顺延编号。
2. 若没有剩余 Iteration，在当前 Cycle 的 Plan Review 记录 `accepted` 和 `Next Iteration: None`。
3. `rework-required` 只创建同目录的下一 Cycle。
4. `replan-required` 调整未完成的 Iteration Plan，并创建同目录的下一 replan Cycle；已交接的 Cycle 文件保持不可变。
