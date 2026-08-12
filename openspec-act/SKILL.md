---
name: openspec-act
description: 按已批准的 OpenSpec 计划和当前迭代上下文执行 TDD、Gate 验证、任务自检、全量 diff Review，并记录实现反馈和工程经验候选。用于存在获批 change 和待执行 iteration，且用户要求实现或验证本轮任务时；不归档、不维护全局状态。
---

# OpenSpec Act

完成当前迭代的实施、验证和反馈。前置条件是 `openspec-plan` 的 Gate 1、Gate 2 已通过，或用户已显式豁免并留下记录。

## 前置规则

1. 读取 `CLAUDE.md`、SNAPSHOT、tasks、相关 M/D/K 和 change 基线。
2. 读取 `.claude/docs/templates/change-iteration.md`。
3. 找到最新且 `Plan Context` 为 `ready` 的迭代。Act Response 应为 `pending`，或为已获用户恢复指令的 `blocked`。
4. 核对 change `tasks.md` 的 Iteration Plan，只执行当前 Plan Context 列出的任务。
5. 读取 `Persisted Evidence` 模式和全部 `required` 项。
6. 模式为 `required`，或决定主动保存证据时，完整读取 [references/evidence-format.md](references/evidence-format.md)。
7. 使用当前环境的任务追踪能力记录每个 Phase、Task、Gate 和跳过项。
8. 使用当前环境可用的 OpenSpec 集成执行 apply 和 validate。
9. 修改产品代码前建立测试见证。
10. Skill 完成不构成 Review、经验记录、维护或归档授权。写入反馈后终止。

## Gate 3：Plan Baseline and Test Witness

每个任务开始前确认：

- Plan 已列出变更符号、调用者、影响范围和任务停止条件。
- 实际代码仍符合 Plan 的 Current-State Evidence。
- 计划指定的测试存在，或可按计划建立。
- 已运行当前状态验证。
- 新功能和 Bug 修复已观察到预期 RED。
- 重构已观察到变更前 GREEN。

计划基线失效、关键调用者遗漏或测试无法证明目标时，执行阻塞交接并返回 Plan。Act 不重新选择接口语义、状态所有权、架构或测试策略。

铁律：`NO CHANGE WITHOUT TEST WITNESS`。

## Phase 3：EXECUTE

对每个 OpenSpec task 执行：

1. 标记任务进行中。
2. 建立 Gate 3 证据。
3. 新功能和 Bug 验证预期 RED；重构验证变更前 GREEN。
4. 按任务执行契约做满足当前任务的最小改动。
5. 运行 GREEN → 验证 GREEN。
6. 必要时重构并保持 GREEN。
7. 执行 Gate 4 和 Gate 5。
8. Gate 5 通过后才能标记完成。

不要修改计划范围外的代码。发现计划缺口、错误基线或停止条件时，执行阻塞交接并终止。等待用户解决阻塞，或调用 `openspec-plan` 调整计划。

## Gate 4：Two-Stage Review

每个任务完成 GREEN 后，严格按顺序执行：

1. Spec compliance review。
2. Code quality review。

Spec review 重新读取任务契约并检查：

- requirement、scenario 和目标行为完整实现。
- 计划列出的文件、符号、调用者和错误路径均已处理。
- 不变量、兼容性和禁止修改项未被破坏。
- 测试见证符合任务类型，修改后 GREEN 能证明目标行为或行为保持。
- Gate 证据覆盖任务的通过条件。

Code quality review 检查：

- diff 没有计划外修改。
- 错误、边界、状态和资源生命周期正确。
- 没有新增警告、死代码、重复实现或无依据复杂度。
- 测试不会因错误原因通过。
- 命名和局部结构符合项目惯例。

计划范围内的 Critical 和 Important 问题必须立即修复。修复后重跑受影响验证和 Gate 4。需要改变设计、范围或测试策略时，按 Gate 6 阻塞。Minor 问题可以记录，但不得伪装成已解决。

## Gate 5：Evidence-Based Verification

任何完成声明都按以下顺序：

1. 确定能证明声明的命令或操作。
2. 运行完整验证。
3. 读取完整输出和退出码。
4. 摘录关键输出。
5. 判断证据是否支持声明。
6. 证据支持后再声明。

验证范围按变更选择：

- 测试。
- 格式化和静态分析。
- 构建。
- CLI 实际运行。
- API 调用。
- UI 检查。
- 配置加载。
- OpenSpec validate。

报告格式：

| 验证项 | 命令或操作 | 输出摘录 | 结论 |
|---|---|---|---|
| 测试 | `<command>` | `<fresh output>` | PASS/FAIL |

Gate 需要可验证依据，但不要求每轮都创建持久化 Evidence。`none` 时把验证摘要写入 Act Response；`required` 时还要保存 Plan 指定的文件。

## 按需 Evidence

Evidence 使用 `openspec/changes/<change>/evidence/<iteration>/`。只有以下情况才创建：

- Plan 把 Persisted Evidence 设为 `required`。
- Act 需要保留长日志、特殊格式、难以复现的环境输出或意外故障信息。

首次创建时生成 change 级 `evidence/README.md` 和 iteration 级 `README.md`。目录名与 iteration 文件名一致。结构化说明使用 Markdown，原始文本输出使用 `.log`，其他证据保留原格式。

每项证据记录来源、结论、采集环境、结果和限制。Plan 要求的文件缺失时，对应 Gate 不得通过。Act 主动增加证据时，在 README 和 Act Response 中说明原因。失败、超时和跳过也是证据。

Evidence 不登记 R，不单独归档。没有保存需要时不创建空目录。Act Response 引用证据文件或编号，不复制长日志；状态变为 `reported` 后，不静默覆盖已有证据。

计划偏差简单且可复现时，只在 Act Response 记录。需要保留长日志、复杂调用链、结构化数据或难复现输出时，创建 `act-added / BLOCKED` Evidence。

## Gate 6：Stop on Blocker

遇到以下情况停止当前路径并记录：

- 缺失依赖。
- 当前状态验证失败且原因未知。
- 计划无法覆盖任务。
- 计划基线与实际代码不一致。
- 实现需要新的接口、状态所有权、架构或测试策略选择。
- 同一验证点连续失败 3 次。
- 同一问题连续修复 3 次仍未解决。

三次失败后：

1. 列出三次尝试和症状。
2. 检查 shared state、coupling 和错误的需求假设。
3. 判断应返回架构设计还是需求确认。
4. 禁止开始第四次同类尝试。

### 阻塞交接

命中 Gate 6 时：

1. 停止计划外修改，不回滚用户或既有工作。
2. 记录发现偏差的 task、step 和 Gate。
3. 对比 Plan 预期与实际情况，并说明影响。
4. 列出已完成、部分完成和未开始的任务。
5. 记录修改文件、工作区状态和已通过的 Gate。
6. 按需保存 `act-added / BLOCKED` Evidence；简单偏差写 `None required`。
7. 填写 Act Response 的 `Blocker Handoff` 和证据引用。
8. 将 Act Response 状态从 `pending` 改为 `blocked`。
9. 终止并说明恢复条件。用户可以解决阻塞，或调用 `openspec-plan`。

状态流转包括 `pending → reported`、`pending → blocked` 和 `blocked → pending`。恢复后必须先回到 `pending`，不得越过它改成 `reported`。

**恢复阻塞**

用户补充事实、给出解决办法或接受风险，并明确要求继续时：

1. 读取 Blocker Handoff、已有 Evidence 和工作区状态。
2. 确认当前 iteration 没有后继 iteration，Plan Review 仍为 `pending`。
3. 在 Act Response 追加 `Blocker Resolution`，保留原 Blocker Handoff。
4. 记录用户指令、解决办法或豁免、风险、恢复点和所需验证。
5. 将状态从 `blocked` 改为 `pending`。
6. 重跑受影响的 Gate 3，再从恢复点继续。

不得只因 iteration 曾被标记为 `blocked` 而拒绝恢复。若用户指令改变目标、范围、requirement、设计或测试策略，说明当前 Plan 无法覆盖的具体差异，再交给 Plan；阻塞状态本身不是拒绝理由。

## Phase 4：REPORT

本轮全部任务正常完成后：

1. 重新读取 Plan Context、requirements、scenarios、Task Contracts、Invariants 和 Non-goals。
2. 审查完整 diff，不只复用逐任务结论。
3. 检查跨任务交互、遗漏实现、计划外修改、回归风险和测试有效性。
4. 修复计划范围内的 Critical 和 Important 问题。
5. 对每项修复重跑受影响的 Gate 4 和 Gate 5。
6. 新设计、范围或测试策略问题按 Gate 6 阻塞并返回 Plan。
7. 运行完整验证套件。
8. 验证 OpenSpec change。
9. 只更新 change 内本轮任务状态。
10. 只填写当前迭代的 `Act Response`：
   - 实际改动。
   - 文件和符号。
   - 与计划的偏差及原因。
   - Self-Review 检查结果、已修复发现和遗留 Minor 问题。
   - 验证命令、输出和退出码。
   - Persisted Evidence 路径和编号，或 `None required`。
   - Experience Candidates，或 `None`。
   - 未解决问题。
   - 可选 commit 或 diff 引用。
11. 将 `Act Response` 状态改为 `reported`。
12. 终止并等待用户审计。

不得填写 `Plan Review`，不得创建下一轮 iteration。

Experience Candidates 只记录可能满足以下条件的实施经验：

- Runbook：已经端到端验证成功，且可重复或风险较高的操作路径。
- Incident：造成显著影响、需要异常恢复、难以复现或包含系统性诊断信息的故障。

候选必须引用 Act Response 或 Evidence。普通测试失败、预期 RED、一次性命令和未验证建议不构成候选。Act 不创建持久化产物；用户可以随后调用 `openspec-experience-recorder`，或预先明确授权串联执行。

## 完成前检查

1. 每个计划任务是否都有状态和证据？
2. 所有跳过步骤是否记录原因？
3. Gate 3-6 是否逐项通过或明确阻塞？
4. 完成声明是否有新鲜输出？
5. `Act Response` 是否与实际代码和证据一致？
6. 所有 `required` Evidence 是否存在，或对应 Gate 已明确阻塞？
7. 是否重新读取计划并审查完整 diff？
8. Self-Review 是否没有未解决的 Critical 或 Important 问题？
9. Experience Candidates 是否已记录证据或明确写 `None`？

任一答案为否，不得声明完成。

## 输出与终止

- 已完成任务。
- 修改文件。
- 任务级和全量 diff Self-Review 结果。
- 已修复发现和遗留 Minor 问题。
- 验证命令、输出摘录和退出码。
- 当前 iteration 路径和 Act Response 状态。
- `blocked` 时的 Blocker Handoff 和 Evidence，或 `None required`。
- 恢复过阻塞时的 Blocker Resolution 和重跑 Gate。
- Persisted Evidence 路径，或未创建的原因。
- Experience Candidates 及其证据，或 `None`。
- 跳过项和阻塞项。

然后终止。提醒用户：

- 实现反馈已等待审计。
- 需要检查或修订时调用 `openspec-plan`。
- 调用 `openspec-plan` Review 本轮结果并生成下一轮；Review 确认没有后续任务后，才调用 `openspec-docs-maintainer` 收尾。
- 未归档 change，未同步全局文档，未清理分支。

## 禁止

- 无测试见证修改代码。
- 用“应该通过”代替运行结果。
- Spec review 前做 code quality review。
- 只依赖逐任务 Review，跳过 Response 前的完整 diff Review。
- Self-Review 存在未解决的 Critical 或 Important 问题时标记 `reported`。
- 从 `blocked` 越过 `pending` 改成 `reported`。
- 用户已解决阻塞并要求继续时，仅因旧状态为 `blocked` 而拒绝恢复。
- 三次失败后继续盲试。
- 修改全局任务、SNAPSHOT 或知识文档。
- 调用 Maintainer、Plan 或 Archivist。
- 未经用户明确授权调用 Experience Recorder。
- 归档 change、清理分支或执行其他生命周期收尾。
- 覆盖 Plan Context 或填写 Plan Review。
- 自行补全 Plan 遗漏的设计或扩大变更面。
- 把平台专属工具名写成流程前提。
- 为每轮 iteration 强制创建空 Evidence 目录。
- 把 change 内 Evidence 登记为 R 或单独执行 Artifact-Archive。
