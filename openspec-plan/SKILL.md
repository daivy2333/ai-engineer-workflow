---
name: openspec-plan
description: 需求探索、实现调查、BDD 缺口扫描、可执行计划制定、OpenSpec 变更创建和实施反馈 Review。用于新功能、Bug 修复、重构，或根据 openspec-act 的实现反馈检查代码并生成下一轮任务上下文；只调查、规划和 Review，不修改产品代码。
---

# OpenSpec Plan

完成需求确认、实现调查、实施计划和迭代 Review。不要在本 skill 中修改产品代码。

## 前置规则

1. 读取项目 `CLAUDE.md`。它是公共执行规则的唯一事实来源。
2. 读取 SNAPSHOT、tasks、相关 project-model、decisions、knowledge 和 change。
3. 若项目缺少规则、OpenSpec 结构或 `.claude/docs/templates/change-iteration.md`，先使用 `openspec-init`。
4. 使用当前环境的任务追踪能力记录 Phase、Gate 和跳过项。
5. 使用当前环境可用的 OpenSpec 集成创建和检查 change。平台命令只属于适配层，不属于流程语义。
6. 不因任务小而裁剪用户需求。轻量模式只减少篇幅，不取消 BDD、完整性检查或变更追踪。
7. Skill 完成不构成下一阶段授权。输出交接信息后终止，等待用户决定。

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

制定计划前，读取实际代码并建立 Current-State Evidence：

- 定位入口、目标文件、符号及职责。
- 追踪调用者、被调用者和动态调用边。
- 记录数据流、状态变化和状态所有权。
- 检查错误、取消、超时、并发和资源生命周期。
- 定位现有测试、测试夹具和验证命令。
- 检查相关 M/D/K、活跃 change 和兼容性约束。
- 运行必要的只读基线验证，记录命令、关键输出和退出码。
- 列出影响实现的未知项，并在制定任务前解决或标记阻塞。

调查深度以支持本次修改为限。计划不得把定位调用者、判断影响范围、选择测试策略或决定接口语义留给 Act。

### Step 2：闭合设计

把调查结论写入 specs、design 和当前 iteration：

- 描述当前行为和目标行为。
- 明确输入、输出、状态、错误和兼容性语义。
- 列出需要修改、保持和明确禁止修改的责任边界。
- 记录关键技术选择、替代方案和选择理由。
- 按条件处理并发、数据迁移、安全、性能和多平台风险。
- 给出实现顺序及其依赖原因。

影响实现的选择不得留作 TBD。无法通过只读调查解决时，阻塞 Gate 2 并请求用户决定。

### Step 3：制定任务

每个任务必须：

- 范围单一。
- 有依赖关系。
- 映射到 requirement 和 scenario。
- 说明目标文件、符号、调用者及其当前职责。
- 描述当前行为和计划后的可观察行为。
- 说明要修改的行为、接口、状态或错误语义。
- 记录必须保持的约束和明确禁止的修改。
- 指定测试位置、预期 RED 原因和 GREEN 通过条件。
- 给出验证命令、通过条件和失败含义。
- 列出发现计划失效时的停止条件。
- 判断 Gate 是否需要持久化证据；默认使用 Act Response，不因存在 Gate 自动要求 Evidence 目录。

任务说明固定行为契约和责任边界，不规定变量名、辅助函数拆分等局部表达。

计划过长时分段写入，避免一次性覆盖整个文件。

### Step 4：完整性检查

生成 Requirements Traceability Matrix：

| Requirement | Scenario | Design | Task | Code Surface | Test Witness | Simplification | Status |
|---|---|---|---|---|---|---|---|
| R1 | S1 | D1 | T1 | `path::symbol` | `test_name` | None | Covered |

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
8. 新会话中的 Act 是否无需重新设计就能执行。

### Step 6：创建实施迭代

按 `.claude/docs/templates/change-iteration.md` 创建：

```text
openspec/changes/<change>/iterations/000-initial.md
```

`Plan Context` 必须包含：

- 目标、背景和当前基线。
- Current-State Evidence 及基线验证结果。
- 入口、调用链、数据流、状态变化和影响面。
- 当前行为、目标行为和变更面。
- 每个任务的执行契约、依赖和停止条件。
- 不变量、兼容性要求和非目标。
- RTM、验收条件、验证方法和条件性风险。
- Gate 2 各检查项的状态和证据。
- `Persisted Evidence` 模式：`none` 或 `required`。

`none` 表示命令、关键输出、退出码、修改文件和符号写入 Act Response 即可。`required` 时逐项写明关联 Gate、证据内容、文件格式、采集环境和通过条件。Plan 只提出要求，不创建 `evidence/` 或实际证据文件。

交接后不得改写 `Plan Context`。后续反馈使用迭代 Review 流程。

## Gate 2：Execution Readiness

全部满足才能交给 `openspec-act`：

- 没有 `Missing` requirement。
- 所有 `Simplified` requirement 已获用户批准。
- 调查完整：当前实现、调用链、状态、测试和影响面都有证据。
- 设计闭合：行为差异、接口、错误语义和关键选择已经明确。
- 任务可执行：每个任务都有代码位置、行为变化、测试见证和停止条件。
- 追踪完整：requirement、scenario、design、task、代码和测试形成链路。
- 验证充分：RED、GREEN、回归命令和通过条件能证明验收目标。
- 没有影响实现的未知项、TBD 或需要 Act 决定的设计问题。
- OpenSpec tasks、specs、design 和当前 iteration 一致。
- Persisted Evidence 模式明确，`required` 项能映射到 Gate 和验收条件。
- 用户批准计划。

为每个检查项记录 `PASS`、`BLOCKED` 或 `WAIVED` 及证据。只有全部 `PASS`，或用户明确承担风险的 `WAIVED`，Gate 2 才能通过。

用户显式要求跳过 Gate 2 时，将原话和未检查风险写入 proposal。轻量模式不构成自动豁免。

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

1. 读取 `reported` 或 `blocked` iteration 的 `Plan Context` 和 `Act Response`。
2. 检查实际代码、diff、Act Response、Self-Review 和计划要求的 Evidence。
3. Act 的 Self-Review 只作为输入，不得代替 Plan 的独立检查。
4. 状态为 `blocked` 时，检查 Blocker Handoff、部分实现、工作区状态和按需存在的 BLOCKED Evidence。
5. `required` 时检查 `evidence/<iteration>/README.md` 和所列文件；`none` 时不得仅因 Evidence 目录不存在提出问题。
6. 把偏差分类为 `PLAN-OMISSION`、`PLAN-INVALID`、`ACT-DEVIATION`、`BASELINE-CHANGED` 或 `NEW-EVIDENCE`。
7. 在当前文件的 `Plan Review` 追加结论。
8. 按需更新 change 的 tasks、specs 或 design，并保留 requirement 映射。
9. 有遗留问题时，重新调查受影响范围并创建下一个零填充编号文件。
10. 新文件补齐独立执行所需上下文，不只写“修复 Review 问题”。
11. 新 iteration 必须重新通过 Gate 2，才能交给 Act。
12. 用户可在 Plan Review 完成前让 Act 恢复 `blocked` iteration。已创建后继 iteration 时，不再恢复旧 iteration。
13. 没有后续任务时，记录 `no-follow-up`，但不归档或同步状态。
14. 输出结果后终止，等待用户审计和下一步指令。

旧迭代只允许追加对应角色的空白区域。不得重写历史指令、反馈或 Review。

## 输出与终止

交付：

- Approved Requirements List。
- Scenario Sketch。
- Current-State Evidence 和未确认项。
- Requirements Traceability Matrix。
- OpenSpec change 路径。
- 当前迭代路径和编号。
- Persisted Evidence 模式和 `required` 项，或 `none`。
- Gate 1、Gate 2 检查项、状态和证据。
- 所有显式跳过项及原因。

Review 模式改为交付：

- 实际代码和证据的检查结果。
- Blocker Handoff 的处理结果，或正常完成说明。
- 当前 iteration 的 Plan Review 状态。
- 新 iteration 路径，或 `no-follow-up`。
- 未确认问题和用户需决定的内容。

然后终止。提醒用户：

- 本轮 Plan 产物已等待审计。
- 存在待执行 iteration 时，审计通过后可调用 `openspec-act`。
- 没有后续任务时，可调用 `openspec-docs-maintainer` 收尾。
- 未调用 Act、Maintainer 或其他 Skill。

## 禁止

- 需求未批准就实现。
- 需求缺口未扫描就设计。
- 未调查实际代码就制定实施任务。
- 把调用链、影响范围、接口语义或测试策略留给 Act 决定。
- 让影响实现的未知项通过 Gate 2。
- 用轻量模式取消追溯或验证。
- 把 `openspec-assistant` 当作写入者。
- 自动调用 Act 或 Maintainer。
- 自动同步 tasks、SNAPSHOT 或归档 change。
- 覆盖旧迭代的 Plan Context、Act Response 或 Plan Review。
- 在原计划为 `none` 时，把缺少 Evidence 目录本身作为 Review 问题。
- 依赖某个平台专属任务工具或 slash command 才能执行流程。
