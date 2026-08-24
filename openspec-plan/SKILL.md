---
name: openspec-plan
description: 为已采用 OpenSpec 的新功能、Bug 修复或重构完成需求与 BDD、实现调查、change 任务和逻辑 Iteration 规划，或 Review openspec-act 反馈并在 Iteration 内生成返工 Cycle；只调查、规划和 Review，不修改产品代码。
---

# OpenSpec Plan

完成需求确认、实现调查、实施计划和 Cycle Review。不要在本 skill 中修改产品代码。

## 前置规则

1. 复用当前会话中已读取且未变化的 CLAUDE、SNAPSHOT、tasks、M/D/K/R/I 和 change 信息，只补读当前模式缺失的体系文档；独立调用时按需建立这些上下文。
2. 新计划先消费当前会话中的 Explorer 结论或相关 Analysis，检查捕获 revision、工作区变化、适用范围和未知项，只补查缺失或失效的实现事实。没有 Explorer 输入时由 Plan 完成所需调查。
3. Review 模式只读取当前 Cycle、实际代码、diff、Act Response 和要求的 Evidence；发现涉及体系约束时才补读对应权威文档，不执行新计划模式的全量恢复。
4. 若项目缺少规则、OpenSpec 结构或 `.claude/docs/templates/change-cycle.md`，先使用 `openspec-init`。
5. 使用当前环境的任务追踪能力记录 Phase、Gate 和跳过项。
6. 使用当前环境可用的 OpenSpec 集成创建和检查 change。平台命令只属于适配层，不属于流程语义。
7. 不因任务小而裁剪用户需求。轻量模式只减少篇幅，不取消 BDD、完整性检查或变更追踪。
8. Skill 完成不构成下一阶段授权。输出交接信息后终止，等待用户决定。
9. 制定 change 计划或 Review Cycle 前，完整读取 [references/iteration-planning.md](references/iteration-planning.md)。

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

### Step 4：建立需求基线和 OpenSpec change

使用可用的 OpenSpec 集成生成或完善：

- `proposal.md`
- Delta specs

若当前 schema 同时生成 `design.md` 和 `tasks.md`，此时只把它们视为草稿。完成实现调查前，不得把设计、任务或 Gate 2 标记为 ready。

不要同步全局任务，也不要调用 `openspec-docs-maintainer`。change 获批不等于用户授权更新项目现状。

## Gate 1：Requirements and Scope Approval

全部满足才能进入 Phase 2：

- BDD 缺口扫描完成。
- 用户已处理场景缺口。
- 场景草图存在。
- OpenSpec change 存在。
- 用户批准需求和范围。

用户显式要求跳过 Gate 1 时，将原话和风险写入 proposal；不要静默豁免。

## Phase 2：INVESTIGATE AND PLAN

### Step 1：调查当前实现

制定计划前，先整理 Explorer 已确认且仍适用于当前工作区的事实，再读取实际代码补齐本次需求所缺的 Current-State Evidence：

- 定位入口、目标文件、符号及职责。
- 追踪调用者、被调用者和动态调用边。
- 记录数据流、状态变化和状态所有权。
- 检查错误、取消、超时、并发和资源生命周期。
- 定位现有测试、测试夹具和验证命令。
- 检查相关 M/D/K、活跃 change 和兼容性约束。
- 运行必要的只读基线验证，记录命令、关键输出和退出码。
- 列出影响实现的未知项；只有实质未知项才阻塞。

不得无条件重复 Explorer 已完成且仍有效的调用链或影响面调查。调查深度以支持本次修改为限；计划不得把定位必要调用者、判断实质影响范围、选择测试策略或决定接口语义留给 Act。

### Step 2：闭合设计

把调查结论写入 specs、design 和当前 Cycle：

- 描述当前行为和目标行为。
- 明确输入、输出、状态、错误和兼容性语义。
- 列出需要修改、保持和明确禁止修改的责任边界。
- 记录关键技术选择、替代方案和选择理由。
- 按条件处理并发、数据迁移、安全、性能和多平台风险。
- 给出实现顺序及其依赖原因。

影响契约语义的选择不得留作 TBD。非实质选择可留给 Act；无法通过只读调查解决的实质问题才阻塞 Gate 2 并请求用户决定。

### Step 3：制定任务和 Iteration Plan

按 Cycle 模板为每个单一范围的任务填写 Task Contract：映射 requirement/scenario，明确依赖、目标位置、当前与目标行为、必须保持和禁止修改的边界、测试见证、GREEN、验证和停止条件。默认用 Act Response 保存 Gate 结果；Gate、测试或 Review 的数量不能成为创建 Evidence 的理由。

Task Contract 是 Act 的任务级执行依据。背景、调查证据和 Implementation Guidance 不得给出冲突指令，也不规定非实质实现选择。

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

### Step 6：创建首个 Iteration 和 Cycle

按 `.claude/docs/templates/change-cycle.md` 创建：

```text
openspec/changes/<change>/iterations/000-initial/000-initial.md
```

`Plan Context` 按 Cycle 模板写入：

- 状态先写为 `draft`。
- Cycle 身份、范围、目标、背景和当前基线。
- Current-State Evidence、关键路径、行为变化和 Change Surface。
- Task Contracts、共享不变量、非目标、RTM、Acceptance 和 Verification。
- Gate 2 证据、风险、`Persisted Evidence` 模式和后续任务边界。

Plan Context 必须直接写入 Act 所需事实，不以 Explorer Analysis、Assistant 输出或前序 Cycle 引用代替必要正文。引用可以保留证据来源，但 Act 不需要沿引用链才能理解任务。

`none` 表示命令、每项不超过 20 行的决定性输出、退出码、修改文件和符号写入 Act Response 即可。只有用户明确要求、结果无法低成本复现、一次性环境即将消失、Incident/Blocker 需要保留现场，或摘要会丢失决定性结构时才能设为 `required`。

每个 `required` 项必须写明：支持的 Acceptance；Act Response 为什么不足；为什么无法低成本重跑；缺少它会阻止的决定；文件和通过条件。任一问题无答案时使用 `none`。Plan 不创建 `evidence/` 或实际证据文件，也不得规划超过公共 Evidence 预算的产物；确需超限时必须先取得用户明确批准。

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
- 验证充分：任务类型对应的测试见证、修改后 GREEN、回归命令和通过条件能证明验收目标。
- 没有需要 Act 决定的实质未知项或 TBD；非实质选择不阻塞。
- OpenSpec tasks、specs、design、当前 Iteration 和当前 Cycle 一致。
- Persisted Evidence 模式明确；`required` 项满足白名单、必要性问题和公共预算，并映射到 Gate 和验收条件。
- 用户批准计划。

为每个检查项记录 `PASS`、`BLOCKED` 或 `WAIVED` 及证据。只有全部 `PASS`，或用户明确承担风险的 `WAIVED`，Gate 2 才能通过。

用户显式要求跳过 Gate 2 时，将原话和未检查风险写入 proposal。轻量模式不构成自动豁免。

Gate 2 全部 `PASS`，或用户明确承担全部 `WAIVED` 风险并批准计划后，Plan 最后把当前 `Plan Context` 状态从 `draft` 改为 `ready`。Gate 未通过时保持 `draft`，不得交给 Act。

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
- OpenSpec change。
- 精简版 Requirements Traceability Matrix。
- 用户批准 Gate 1 和 Gate 2，除非用户显式豁免。

## 实施反馈 Review

用户要求检查 Act 结果时：

1. 读取 `reported` 或 `blocked` Cycle 的 `Plan Context` 和 `Act Response`，确认其所属逻辑 Iteration 和 `Review Result` 仍为 `pending`。若中断前已写入后继 Cycle 或 Iteration，先验证并复用，不重复创建。
2. 检查实际代码、diff、Act Response、Self-Review 和计划要求的 Evidence。
3. Act 的 Self-Review 只作为输入，不得代替 Plan 的独立检查。
4. 状态为 `blocked` 时，检查 Blocker Handoff、部分实现、工作区状态和按需存在的 BLOCKED Evidence。
5. `required` 时检查 `evidence/<iteration>/<cycle>/README.md` 和所列文件；`none` 时不得仅因 Evidence 目录不存在提出问题。
6. 把偏差分类为 `PLAN-OMISSION`、`PLAN-INVALID`、`ACT-DEVIATION`、`BASELINE-CHANGED` 或 `NEW-EVIDENCE`。
   - 非实质 finding 不阻塞。
   - 实质问题或既有 Acceptance 未满足才构成阻塞 finding。
7. 按 [references/iteration-planning.md](references/iteration-planning.md) 的 Review 分类判断 `accepted | rework-required | replan-required`，并在当前 Cycle 的 `Plan Review` 记录结论、证据、Acceptance Gaps 和收敛状态。
8. 按该引用创建同一 Iteration 的 rework/replan Cycle，或在 `accepted` 后展开下一 Iteration；`accepted` 且没有剩余 Iteration 时记录 `Next Iteration: None`，但不归档或同步状态。
9. 当前 `Review Result` 不再是 `pending`，或后继 Cycle 已创建后，不再恢复旧 Cycle；此前用户可要求 Act 恢复 `blocked` Cycle。
10. 输出结果后终止，等待用户审计和下一步指令。

不要为风格偏好、局部命名、等价实现方式、可直接修正的路径变化或不阻塞 Acceptance 的 Minor finding 创建 rework Cycle。记录 finding 并返回 `accepted`。

旧 Cycle 只允许追加对应角色的空白区域。不得重写历史指令、反馈或 Review。

## 输出与终止

交付：

- Approved Requirements List。
- Scenario Sketch。
- Current-State Evidence 和未确认项。
- Requirements Traceability Matrix。
- change tasks 中的 Iteration Plan 和平衡审计结果。
- OpenSpec change 路径。
- 当前 Iteration、Cycle 路径和编号。
- Persisted Evidence 模式和 `required` 项，或 `none`。
- Gate 1、Gate 2 检查项、状态和证据。
- 所有显式跳过项及原因。

Review 模式改为交付：

- 实际代码和证据的检查结果。
- Blocker Handoff 的处理结果，或正常完成说明。
- 当前 Cycle 的 `Review Result`。
- Acceptance Gaps、收敛判断和 Iteration Plan 是否保持不变。
- 新 Cycle 路径、新 Iteration 路径，或 None。
- 未确认问题和用户需决定的内容。

然后终止。提醒用户：

- 当前 Plan/Cycle 产物已等待审计。
- 存在待执行 Cycle 时，审计通过后可调用 `openspec-act`。
- 没有后续任务时，可调用 `openspec-docs-maintainer` 收尾。
- 未调用 Act、Maintainer 或其他 Skill。

## 禁止

- 需求未批准就实现。
- 需求缺口未扫描就设计。
- 未调查实际代码就制定实施任务。
- 把必要调用链、实质影响范围、接口语义或测试策略留给 Act 决定。
- 让影响契约语义或 Acceptance 的未知项通过 Gate 2。
- 用轻量模式取消追溯或验证。
- 把 `openspec-assistant` 当作写入者。
- 自动调用 Act 或 Maintainer。
- 自动同步 tasks、SNAPSHOT 或归档 change。
- 覆盖旧 Cycle 的 Plan Context、Act Response 或 Plan Review。
- 把 `rework-required` 作为新增全局 task 或修改 Iteration Map 的理由。
- 把新目标、范围变化或验收变化伪装为 rework Cycle。
- 在原计划为 `none` 时，把缺少 Evidence 目录本身作为 Review 问题。
- 依赖某个平台专属任务工具或 slash command 才能执行流程。
