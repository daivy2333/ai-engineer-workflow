---
name: openspec-plan
description: 需求探索、BDD 缺口扫描、计划制定和 OpenSpec 变更创建。用于新功能、Bug 修复、重构或其他需要在实施前明确需求、场景、完整性和任务映射的工作；完成后交给 openspec-act。
---

# OpenSpec Plan

完成 Phase 1-2：需求确认与实施计划。不要在本 skill 中修改产品代码。

## 前置规则

1. 读取项目 `CLAUDE.md`。它是公共执行规则的唯一事实来源。
2. 若项目缺少 `CLAUDE.md` 或 OpenSpec 结构，先使用 `openspec-init`。
3. 使用当前环境的任务追踪能力记录 Phase、Gate 和跳过项。
4. 使用当前环境可用的 OpenSpec 集成创建和检查 change。平台命令只属于适配层，不属于流程语义。
5. 不因任务小而裁剪用户需求。轻量模式只减少文档篇幅，不取消 BDD、完整性检查或变更追踪。

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

创建后把全局任务同步请求交给 `openspec-docs-maintainer`。`openspec-assistant` 只读，不执行同步。

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

## Gate 2：Requirements Completeness

全部满足才能交给 `openspec-act`：

- 没有 `Missing` requirement。
- 所有 `Simplified` requirement 已获用户批准。
- OpenSpec tasks、specs 和必要的 design 已完成。
- 用户批准计划。

用户显式要求跳过 Gate 2 时，将原话和未检查风险写入 proposal。轻量模式不构成自动豁免。

## 轻量模式

仅在以下条件全部满足时使用：

- 改动少于 3 个文件。
- 核心代码少于 60 行。
- 不跨模块。
- 不含架构决策。
- 不触及安全、数据或性能关键路径。

轻量模式仍要求：

- BDD 缺口扫描。
- 场景草图。
- OpenSpec change。
- 精简版 Requirements Traceability Matrix。
- 用户批准 Gate 1 和 Gate 2，除非用户显式豁免。

## 输出

交付：

- Approved Requirements List。
- Scenario Sketch。
- Requirements Traceability Matrix。
- OpenSpec change 路径。
- Gate 1、Gate 2 证据。
- 所有显式跳过项及原因。

下一步：调用 `openspec-act`。

## 禁止

- 需求未批准就实现。
- 需求缺口未扫描就设计。
- 用轻量模式取消追溯或验证。
- 把 `openspec-assistant` 当作写入者。
- 依赖某个平台专属任务工具或 slash command 才能执行流程。
