---
name: openspec-plan
description: 需求探索、BDD 缺口扫描、计划制定、OpenSpec 变更创建和实施反馈 Review。用于新功能、Bug 修复、重构，或根据 openspec-act 的实现反馈检查代码并生成下一轮任务上下文；只规划和 Review，不修改产品代码。
---

# OpenSpec Plan

完成需求确认、实施计划和迭代 Review。不要在本 skill 中修改产品代码。

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

### Step 4：创建 OpenSpec change

使用可用的 OpenSpec 集成生成或完善：

- `proposal.md`
- Delta specs
- `design.md`
- `tasks.md`

不要同步全局任务，也不要调用 `openspec-docs-maintainer`。change 获批不等于用户授权更新项目现状。

## Gate 1：Design Approval

全部满足才能进入 Phase 2：

- BDD 缺口扫描完成。
- 用户已处理场景缺口。
- 场景草图存在。
- OpenSpec change 存在。
- 用户批准需求和范围。

用户显式要求跳过 Gate 1 时，将原话和风险写入 proposal；不要静默豁免。

## Phase 2：PLAN

### Step 1：制定任务

每个任务必须：

- 范围单一。
- 有依赖关系。
- 有验收标准。
- 有验证命令或可观察证据。
- 能映射到至少一个需求。
- 标明相关文件、模块或符号。
- 说明实现顺序和关键路径。
- 记录不得破坏的约束和明确不做的内容。

计划过长时分段写入，避免一次性覆盖整个文件。

### Step 2：完整性检查

生成 Requirements Traceability Matrix：

| Requirement | Task(s) | Coverage | Simplification | Status |
|---|---|---:|---|---|
| R1 | T1, T2 | 100% | None | Covered |

状态规则：

- `Covered`：完整覆盖。
- `Simplified`：存在需求简化，必须获得用户批准。
- `Missing`：没有任务覆盖，Gate 2 失败。

轻量模式可以使用精简矩阵，但不能省略覆盖检查。

### Step 3：审查计划

依次检查：

1. 是否存在 TBD/TODO。
2. 是否有未批准的需求裁剪。
3. tasks、specs、design 是否互相一致。
4. 每个任务是否有验证方法。
5. 是否修改了无关范围。
6. 新会话中的 Act 是否只靠 change 和当前迭代文档就能执行。

### Step 4：创建实施迭代

按 `.claude/docs/templates/change-iteration.md` 创建：

```text
openspec/changes/<change>/iterations/000-initial.md
```

`Plan Context` 必须包含：

- 目标、背景和当前基线。
- 相关文件、模块和符号。
- 入口、调用链、数据流或状态变化。
- 实现顺序和必要技术细节。
- 不变量、兼容性要求和非目标。
- 验收条件、验证方法和风险。

交接后不得改写 `Plan Context`。后续反馈使用迭代 Review 流程。

## Gate 2：Requirements Completeness

全部满足才能交给 `openspec-act`：

- 没有 `Missing` requirement。
- 所有 `Simplified` requirement 已获用户批准。
- OpenSpec tasks、specs 和必要的 design 已完成。
- `000-initial.md` 足以支持无会话上下文的 Act 执行。
- 用户批准计划。

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
- OpenSpec change。
- 精简版 Requirements Traceability Matrix。
- 用户批准 Gate 1 和 Gate 2，除非用户显式豁免。

## 实施反馈 Review

用户要求检查 Act 结果时：

1. 读取当前迭代的 `Plan Context` 和 `Act Response`。
2. 检查实际代码、diff 和验证证据，不以 Act 自述代替检查。
3. 在当前文件的 `Plan Review` 追加结论。
4. 按需更新 change 的 tasks、specs 或 design，并保留 requirement 映射。
5. 有遗留问题时，创建下一个零填充编号文件。
6. 新文件补齐独立执行所需上下文，不只写“修复 Review 问题”。
7. 没有后续任务时，记录 `no-follow-up`，但不归档或同步状态。
8. 输出结果后终止，等待用户审计和下一步指令。

旧迭代只允许追加对应角色的空白区域。不得重写历史指令、反馈或 Review。

## 输出与终止

交付：

- Approved Requirements List。
- Scenario Sketch。
- Requirements Traceability Matrix。
- OpenSpec change 路径。
- 当前迭代路径和编号。
- Gate 1、Gate 2 证据。
- 所有显式跳过项及原因。

Review 模式改为交付：

- 实际代码和证据的检查结果。
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
- 用轻量模式取消追溯或验证。
- 把 `openspec-assistant` 当作写入者。
- 自动调用 Act 或 Maintainer。
- 自动同步 tasks、SNAPSHOT 或归档 change。
- 覆盖旧迭代的 Plan Context、Act Response 或 Plan Review。
- 依赖某个平台专属任务工具或 slash command 才能执行流程。
