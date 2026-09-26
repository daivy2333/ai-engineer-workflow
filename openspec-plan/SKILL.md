---
name: openspec-plan
description: 为已采用 OpenSpec 的新功能、Bug 修复或重构完成需求与 BDD、实现调查、change 任务和逻辑 Iteration 规划，或 Review openspec-act 反馈并在 Iteration 内生成返工 Cycle；只调查、规划和 Review，不修改产品代码。
---

# OpenSpec Plan

完成需求确认、实现调查、实施计划和 Cycle Review。不要在本 skill 中修改产品代码。

## 前置规则

1. 按公共规则 › 读取顺序 复用体系上下文，只补读当前模式缺失的体系文档；独立调用时按需建立。
2. 新计划先消费当前会话中的 Explorer 结论、相关 Analysis，以及后继 Iteration 对应的前一 Iteration 最终 Act Response 和 accepted Review；检查捕获 revision、工作区变化、适用范围和未知项，只补查缺失或失效的实现事实。没有可采信输入时由 Plan 完成所需调查。
3. Review 模式只读取当前 Cycle、实际代码、diff、Act Response 和要求的 Evidence；发现涉及体系约束时才补读对应权威文档，不执行新计划模式的全量恢复。
4. 若项目缺少 `AGENTS.md` 或 `.agents/` 结构，先使用 `openspec-init`。
5. 使用当前环境的任务追踪能力记录 Phase、Gate 和跳过项。
6. change 是 `.agents/changes/<name>/` 下的普通目录和 markdown 文件，用文件操作创建和检查，不依赖平台专属命令或外部 CLI。
7. 不因任务小而裁剪用户需求。轻量模式只减少篇幅，不取消 BDD、完整性检查或变更追踪。
8. Skill 完成不构成下一阶段授权（公共规则 › 阶段边界）。输出交接信息后终止，等待用户决定。
9. 制定 change 计划或 Review Cycle 前，完整读取 [references/iteration-planning.md](references/iteration-planning.md)；创建 Cycle 文件前完整读取 [references/cycle-template.md](references/cycle-template.md)。

## Phase 1：CLARIFY

### Step 1：扫描需求

提取：

- 用户目标与验收条件。
- Happy Path。
- Sad Path。
- Edge Case。
- 错误处理、取消、超时、并发和兼容性要求。
- 明确不做的内容。

### Step 2：处理场景缺口

向用户提交一次集中决策：

- 使用明确标注的默认假设补齐。
- 由用户补充。
- 用户显式接受缺口并记录到 proposal。

不要以“需求看起来清晰”为由跳过扫描。

### Step 3：生成场景草图

每个场景至少包含：

- 前置状态。
- 触发动作。
- 可观察结果。
- 失败结果或边界条件。

### Step 4：建立需求基线和 change

创建 `.agents/changes/<name>/` 目录并生成或完善：

- `proposal.md`
- Delta specs

若当前 schema 同时生成 `design.md` 和 `tasks.md`，此时只把它们视为草稿。完成实现调查前，不得把设计、任务或 Gate 2 标记为 ready。

不要同步全局任务，也不要调用 `openspec-docs-maintainer`。change 获批不等于用户授权更新项目现状。

## Gate 1：Requirements and Scope Approval

全部满足才能进入 Phase 2：

- BDD 缺口扫描完成。
- 用户已处理场景缺口。
- 场景草图存在。
- change 目录存在。
- 用户批准需求和范围。

用户显式要求跳过 Gate 1 时，将原话和风险写入 proposal；不要静默豁免。

## Phase 2：INVESTIGATE AND PLAN

### Step 1：调查当前实现

制定计划前，先按前置规则 2 整理可采信输入，再读取实际代码补齐本次需求所缺的 Current-State Evidence：

- 入口、目标符号、调用者与被调用者、数据流、状态变化、错误和并发边界、现有测试、夹具、验证命令和基线结论按公共规则 › Plan 调查 记录；补跑基线时记录命令、关键输出和退出码。
- 追踪动态调用边，记录状态所有权，检查取消、超时和资源生命周期。
- 检查相关 M/R/I、活跃 change 和兼容性约束。
- 列出影响实现的未知项；只有实质未知项才阻塞。

不得无条件重复 Explorer 已完成且仍有效的调用链或影响面调查。调查深度以支持本次修改为限；计划不得把定位必要调用者、判断实质影响范围、选择测试策略或决定接口语义留给 Act。

### Step 2：闭合设计

把调查结论写入 specs、design 和当前 Cycle：

- 描述当前行为和目标行为。
- 明确输入、输出、状态、错误和兼容性语义。
- 列出需要修改、保持和明确禁止修改的责任边界。
- 记录关键技术选择、替代方案和选择理由；选择理由随 change 归档，是长期决策的权威记录。
- 按条件处理并发、数据迁移、安全、性能和多平台风险。
- 给出实现顺序及其依赖原因。
- 验证设计直接观察目标状态、输出、错误结果或退出码，逐 scenario 选择最简直接判定（公共规则 › 验证），不建立身份型证据系统或判定层（公共规则 › 行为约束）。

影响契约语义的选择不得留作 TBD。非实质选择可留给 Act；无法通过只读调查解决的实质问题才阻塞 Gate 2 并请求用户决定。

### Step 3：制定任务和 Iteration Plan

按 Cycle 模板为每个单一范围的任务填写 Task Contract：映射 requirement/scenario，明确依赖、目标位置、当前与目标行为、必须保持和禁止修改的边界、测试见证、GREEN、验证和停止条件。默认用 Act Response 保存 Gate 结果；Gate、测试或 Review 的数量不能成为创建 Evidence 的理由。

背景、调查证据和 Implementation Guidance 不得给出与 Task Contract 冲突的指令，也不规定非实质实现选择（公共规则 › Iteration 与 Cycle 线程）。

不得规划身份型证据工程或判定层（公共规则 › 行为约束）。产品 requirement 明确要求的认证、完整性校验或多会话协议作为目标行为进入 requirement、scenario 和 Acceptance。

把全部任务写入 change 的 `tasks.md`，再按引用规则规划逻辑 Iteration：

- 每个任务只归属一个 Iteration，并满足依赖顺序。
- 每个 Iteration 记录阶段结果、稳定基线、验证边界、诊断边界和 Non-goals。
- 对每个 Iteration 执行聚合和拆分审计，避免过碎或过重。
- 只展开第一个 Iteration 目录及其 `000-initial.md`；后续 Iteration 此时不创建目录或 Cycle 文件。

计划过长时分段写入，避免一次性覆盖整个文件。

### Step 4：完整性检查

生成 Requirements Traceability Matrix：

| Requirement | Scenario | Design | Task | Iteration | Code Surface | Test Witness | Simplification | Status |
|---|---|---|---|---|---|---|---|---|
| R1 | S1 | D1 | T1 | 000 | `path::symbol` | `test_name` | None | Covered |

状态规则：

- `Covered`：需求、场景、设计、任务、代码位置和测试形成可验证链路。
- `Simplified`：存在需求简化，必须获得用户批准。
- `Missing`：任一必要映射缺失，Gate 2 失败。

轻量模式可以使用精简矩阵，但不能省略覆盖检查。

### Step 5：审查计划

依次检查：

1. 是否存在 TBD/TODO。
2. 是否有未批准的需求裁剪。
3. tasks、specs、design 是否互相一致。
4. Current-State Evidence 是否来自实际代码和新鲜基线。
5. 每个任务是否包含完整执行契约。
6. 调用者、影响范围和测试入口是否已经定位。
7. 是否修改了无关范围。
8. Iteration Plan 是否覆盖全部任务并通过平衡审计。
9. 只读取公共规则和当前 Cycle 的新 Act，是否无需回读 Assistant、Explorer、Analysis、前序 Cycle 或其他规划资料，无需重新调查或设计，就能建立第一个测试见证并执行。
10. 非实质未知项是否留在 Risks and Notes，且不会迫使 Act 决定契约语义。
11. 验证是否直接证明目标行为，且没有身份型证据工程、判定层、自引用验证或为工具测试工具。

### Step 6：创建首个 Iteration 和 Cycle

按 [references/cycle-template.md](references/cycle-template.md) 创建：

```text
.agents/changes/<change>/iterations/000-initial/000-initial.md
```

`Plan Context` 按 Cycle 模板写入：

- 状态先写为 `draft`。
- Cycle 身份、范围、目标和背景。
- Investigation Facts：当前基线、Current-State Evidence、代码与关键路径。
- 行为变化，以及 Task Contracts（含变更面）、共享不变量、非目标、RTM、Acceptance 和 Verification。
- Gate 2 证据、风险、`Persisted Evidence` 模式和后续任务边界。

Plan Context 的自包含要求按公共规则 › Iteration 与 Cycle 线程 执行。

`none` 表示命令、决定性输出、退出码、修改文件和符号写入 Act Response 即可，输出上限见公共规则 › 验证。只有满足公共规则 Evidence 白名单（公共规则 › Iteration 与 Cycle 线程）的情形才能设为 `required`。

每个 `required` 项按公共规则 › 验证 说明必要性，并按 Cycle 模板列出文件和通过条件；任一问题无答案时使用 `none`。Plan 不创建 `evidence/` 或实际证据文件，也不得规划超过公共 Evidence 预算的产物；确需超限时必须先取得用户明确批准。

交接后不得改写 `Plan Context`。后续反馈使用 Cycle Review 流程。

## Gate 2：Execution Readiness

全部满足才能交给 `openspec-act`：

- 没有 `Missing` requirement。
- 所有 `Simplified` requirement 已获用户批准。
- 调查完整：当前实现、调用链、状态、测试和影响面都有证据。
- 设计闭合：行为差异、接口、错误语义和关键选择已经明确。
- 任务可执行：每个任务都有代码位置、行为变化、测试见证和停止条件。
- 分轮合理：全部任务已分配，依赖有序，每轮工作量、稳定基线、验证和诊断边界明确。
- 追踪完整：requirement、scenario、design、task、代码和测试形成链路。
- 验证充分：覆盖全部已批准 scenario（含 sad path 和 edge case），每条为最简直接判定，任务类型对应的测试见证、修改后 GREEN、回归命令和通过条件能证明验收目标。
- 验证没有用身份型证据工程或判定层替代目标行为（公共规则 › 行为约束）。
- 没有需要 Act 决定的实质未知项或 TBD；非实质选择不阻塞。
- change 的 tasks、specs、design、当前 Iteration 和当前 Cycle 一致。
- Persisted Evidence 模式明确；`required` 项满足白名单、必要性问题和公共预算，并映射到 Gate 和验收条件。
- 用户批准计划。

为每个检查项记录 `PASS`、`BLOCKED` 或 `WAIVED` 及证据。只有全部 `PASS`，或用户明确承担风险的 `WAIVED`，Gate 2 才能通过。

用户显式要求跳过 Gate 2 时，将原话和未检查风险写入 proposal。轻量模式不构成自动豁免。

Gate 2 全部 `PASS`，或用户明确承担全部 `WAIVED` 风险并批准计划后，`Plan Context` 才能按 Cycle 模板 › 写入规则 离开 `draft`。Gate 未通过时不得交给 Act。

## 轻量模式

仅在以下条件全部满足时使用：

- 改动少于 3 个文件。
- 实现代码少于 60 行。
- 不跨模块。
- 不新增项目模型或长期决策。
- 不触及安全、数据或性能关键路径。

轻量模式仍要求：

- BDD 缺口扫描。
- 场景草图。
- 聚焦的实现调查和 Current-State Evidence。
- change 目录。
- 精简版 Requirements Traceability Matrix。
- 用户批准 Gate 1 和 Gate 2，除非用户显式豁免。

## 实施反馈 Review

用户要求检查 Act 结果时：

1. 读取 `reported` 或 `blocked` Cycle 的 `Plan Context` 和 `Act Response`，确认其所属逻辑 Iteration 和 `Review Result` 仍为 `pending`。若中断前已写入后继 Cycle 或 Iteration，先验证并复用，不重复创建。
2. 独立阅读实际代码和 diff，检查 Act Response、Self-Review 和计划要求的 Evidence。
3. Act 已报告且覆盖范围未失效的验证结论直接采信并注明来源，Plan 只补跑 Act 未覆盖的检查；出现公共规则 › 验证 列出的重跑情形时重跑，并把差异记入 Findings。Act 的 Self-Review 只作为输入，不得代替 Plan 对代码和 Acceptance 的独立检查。
4. 状态为 `blocked` 时，已完成且验证结论未失效的任务直接采信；审查集中在 Blocker Handoff、部分实现、工作区状态和按需存在的 BLOCKED Evidence。
5. `required` 时检查 `evidence/<iteration>/<cycle>/README.md` 和所列文件；`none` 时不得仅因 Evidence 目录不存在提出问题。
6. 把偏差分类为 `PLAN-OMISSION`、`PLAN-INVALID`、`ACT-DEVIATION`、`BASELINE-CHANGED` 或 `NEW-EVIDENCE`。
   - 非实质 finding 不阻塞。
   - 实质问题或既有 Acceptance 未满足才构成阻塞 finding。
   - 当前 change 范围外的实质缺陷作为 Issue 候选报告，不落账（公共规则 › Iteration 与 Cycle 线程）。
   - 身份型证据工程属于 `PLAN-INVALID`：Plan 把删除机制及其专用接口、fixture、测试和工具列为修复目标，再要求 Act 以目标行为重新验证；不得要求 Act 完善该框架。
7. 按 [references/iteration-planning.md](references/iteration-planning.md) 判断当前 Cycle 修复或 `accepted | rework-required | replan-required`，并在 `Plan Review` 记录结论、证据、Acceptance Gaps 和收敛状态。
8. 有限修复受当前执行契约约束时，覆盖 Review 为最新完整反馈，保持 `Review Result: pending`，在 `Follow-up Decision` 明确要求当前 Cycle 修复，且不创建后继产物。否则按该引用创建 rework/replan Cycle，或在 `accepted` 后展开下一 Iteration；`accepted` 且没有剩余 Iteration 时记录 `Next Iteration: None`。
9. 当前 Cycle 修复完成后重新 Review。`Review Result` 不再是 `pending`，或后继 Cycle 已创建后，不再恢复旧 Cycle；此前用户可要求 Act 恢复有明确当前 Cycle 反馈的 `reported` Cycle，或已解决阻塞的 `blocked` Cycle。
10. 输出结果后终止，等待用户审计和下一步指令。

不要为风格偏好、局部命名、等价实现方式、可直接修正的路径变化或不阻塞 Acceptance 的 Minor finding 创建修复。记录 finding 并返回 `accepted`。阻塞 Acceptance 但无需新执行契约的有限修复留在当前 Cycle。

Plan Context 始终不可改写。当前活跃 Cycle 的覆盖与冻结条件按公共规则 › Iteration 与 Cycle 线程 执行。

## 输出与终止

交付：

- Approved Requirements List。
- Scenario Sketch。
- Current-State Evidence 和未确认项。
- Requirements Traceability Matrix。
- change tasks 中的 Iteration Plan 和平衡审计结果。
- change 路径。
- 当前 Iteration、Cycle 路径和编号。
- Persisted Evidence 模式和 `required` 项，或 `none`。
- Gate 1、Gate 2 检查项、状态和证据。
- 所有显式跳过项及原因。

Review 模式改为交付：

- 实际代码和证据的检查结果。
- Blocker Handoff 的处理结果，或正常完成说明。
- 当前 Cycle 的 `Review Result`。
- Acceptance Gaps、收敛判断和 Iteration Plan 是否保持不变。
- 当前 Cycle 修复意见，或无需当前 Cycle 修复。
- 新 Cycle 路径、新 Iteration 路径，或 None。
- 报告的 Issue 候选，或 None。
- 未确认问题和用户需决定的内容。

然后终止。提醒用户：

- 当前 Plan/Cycle 产物已等待审计。
- Plan Review 要求当前 Cycle 修复或存在待执行 Cycle 时，审计通过后可调用 `openspec-act`。
- 没有后续任务时，可调用 `openspec-docs-maintainer` 收尾。
- 未调用 Act、Maintainer 或其他 Skill。

## 禁止

- 覆盖 Plan Context、其他角色区域，或已经终结、已有后继产物的 Cycle。
