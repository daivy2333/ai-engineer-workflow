---
name: openspec-act
description: 按已批准的 OpenSpec 计划和当前 Cycle 上下文执行 TDD、Gate 验证、任务自检、全量 diff Review，并记录实现反馈和工程经验候选。用于存在获批 change 和待执行 Cycle，且用户要求实现或验证本次执行时；不归档、不维护全局状态。
---

# OpenSpec Act

完成当前逻辑 Iteration 中当前 Cycle 的实施、验证和反馈。前置条件是 `openspec-plan` 的 Gate 1、Gate 2 已通过，或用户已显式豁免并留下记录。

## 前置规则

1. 复用当前会话中已读取且未变化的公共规则；缺失时读取 `AGENTS.md`。
2. 找到当前逻辑 Iteration 中最新且 `Plan Context` 为 `ready`、`Review Result` 为 `pending`、没有后继 Cycle 的 Cycle，完整读取当前 Cycle。Act Response 应为 `pending`、有明确当前 Cycle 修复意见的 `reported`，或为已获用户恢复指令的 `blocked`。
3. 只执行当前 Plan Context 列出的 task、repair item，或 Plan Review 明确要求且仍受当前执行契约约束的有限修复。不要为实施重新读取 SNAPSHOT、全局 tasks、M/R/I、Explorer Analysis、change 基线或 Cycle 模板。
4. 按 Task Contract 读取目标代码和测试所需的局部上下文；不重新调查调用链、影响范围或 Current-State Evidence。
5. 读取 `Persisted Evidence` 模式和全部 `required` 项。
6. 模式为 `required`，或决定主动保存证据时，完整读取 [references/evidence-format.md](references/evidence-format.md)。
7. 使用当前环境的任务追踪能力记录每个 Phase、Task、Gate 和跳过项。
8. 按 change 的 `tasks.md` 维护任务状态；报告前对照公共规则自检 change 文件结构。
9. 修改产品代码前建立测试见证。
10. Skill 完成不构成 Review、经验记录、维护或归档授权。写入反馈后终止。

Plan Review 明确要求当前 Cycle 修复时，Act 先把 `Act Response` 从 `reported` 改为 `pending`，只消费最新 Review，不恢复已被覆盖的文字历史。缺少具体修复目标、Acceptance gap、证据或验证依据时不恢复，返回 Plan 补全 Review。

## Gate 3：Test Witness

Plan 对基线和 Gate 2 负责。`Plan Context: ready` 即构成 Act 的执行授权；Act 不确认、复核或重新建立计划基线，也不为基线生成证据。完成前置读取后，当前 Cycle 不再经过新的执行就绪判断，直接进入首个 task 的测试见证；后续 task 也在修改前建立对应见证：

- 新功能和 Bug 修复观察预期 RED。
- 重构观察变更前 GREEN。
- Task Contract 要求新建测试时，先写测试再观察 RED。
- 无法按契约建立或运行见证，或见证不能证明目标且必须改变测试策略时，执行阻塞交接并返回 Plan。

铁律：`NO CHANGE WITHOUT TEST WITNESS`。

## Phase 3：EXECUTE

对每个 OpenSpec task 或 repair item 执行：

1. 标记任务进行中。
2. 建立当前 task 的测试见证。
3. 新功能和 Bug 验证预期 RED；重构验证变更前 GREEN。
4. 按任务执行契约做满足当前任务的最小改动。
5. 运行 GREEN → 验证 GREEN。
6. 必要时重构并保持 GREEN。
7. 执行 Gate 4 和 Gate 5。
8. Gate 5 通过后才能标记完成。

不要修改计划范围外的代码。目标文件或符号发生可直接定位的移动、等价局部实现与计划建议不同，或验证命令可作等价调整时，只要不构成公共规则定义的实质问题，即可在契约内处理并记录到 `Deviations from Plan`。

只有差异使 Task Contract 无法执行，或继续工作会构成实质问题时，才执行阻塞交接并终止。

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
- 没有身份型证据机制、自引用验证或只证明 capture、audit、qualification 工具自身正确的测试。

计划范围内的 Critical 和 Important 问题必须立即修复。修复后重跑受影响验证和 Gate 4；未受影响且覆盖范围未变化的验证结论继续有效。实质问题按 Gate 6 阻塞。Minor 问题可以记录并继续，不得伪装成已解决。

## Gate 5：Evidence-Based Verification

任何完成声明都按以下顺序：

1. 确定能证明声明的命令或操作。
2. 完整运行所选验证，不因“更保险”追加等价命令或扩大到无关测试。
3. 读取足以判断结果的输出和退出码；不要为了留证回显或复制完整长日志。
4. 每项只摘录不超过 20 行的决定性输出。
5. 判断证据是否支持声明。
6. 证据支持后再声明。

按覆盖范围记录验证结论（命令、行为和涉及的代码表面），使 Plan Review、后继 Cycle 和阻塞恢复可以采信。当前 Cycle 内早期验证的结论在覆盖范围未变化时直接引用，不重复运行；修改覆盖范围内的代码后才重新运行。

只有目标状态、输出、错误结果、协议结果或退出码等可观察行为可以支持 Acceptance。Hash、revision、run-id、peer、manifest 或时间顺序只能描述材料或现场，不能使验证通过。

验证范围按变更选择：

- 测试。
- 格式化和静态分析。
- 构建。
- CLI 实际运行。
- API 调用。
- UI 检查。
- 配置加载。

报告格式：

| 验证项 | 命令或操作 | 输出摘录 | 覆盖范围 | 结论 |
|---|---|---|---|---|
| 测试 | `<command>` | `<fresh output>` | `<行为或代码表面>` | PASS/FAIL |

Gate 需要新鲜验证结果——产生时真实运行过且覆盖范围未变化——但不要求原始输出文件。按直接目标、受影响边界、必要集成或全量 Gate 的顺序递增验证；结果足以判断 Acceptance 后停止。`none` 时把验证摘要写入 Act Response；`required` 时还要保存 Plan 指定的最小文件。

## 按需 Evidence

Evidence 使用 `.agents/changes/<change>/evidence/<iteration>/<cycle>/`。只有以下情况才创建：

- 用户明确要求保留。
- 结果无法低成本复现，或一次性环境即将消失。
- Incident 或实质 Blocker 需要保存关键现场。
- 摘要会丢失影响 Acceptance 判断的结构化信息。

Gate 数量、以后可能有用、便于审计、输出较长或 Plan 单纯写了 `required` 都不能单独构成保存理由。`required` 不满足白名单、必要性、预算或当前可采集性时，不收集；按 Gate 6 填写 Blocker Handoff，把 Act Response 改为 `blocked` 并交给 Plan Review。

不得为 Evidence 新增身份字段、握手、pin、freeze、manifest、Hash 链、时间顺序检查或 capture/audit/qualification 工具。Evidence 输出改变 worktree 或现场时，只记录该限制；不得创建排除路径或二级验证来维持身份检查。

决定保存 Evidence 后，完整读取并遵守 [references/evidence-format.md](references/evidence-format.md) 的目录、预算、记录、覆盖和归档规则。没有保存需要时不创建目录；计划外 Evidence 在 Act Response 说明理由。

计划偏差可复现或可用 20 行以内说明时，只在 Act Response 记录。只有实质 Blocker 满足上述白名单时才创建 `act-added / BLOCKED` Evidence。

## Gate 6：Stop on Blocker

遇到以下情况停止当前路径并记录：

- 缺失依赖。
- 当前状态验证失败且原因未知。
- Task Contract 无法覆盖达到既有 Acceptance 所需的工作。
- 实际代码与契约存在实质冲突，或继续实施会构成实质问题。
- `required` Evidence 不再满足白名单、必要性、预算或当前可采集性。
- 同一验证点连续失败 3 次。
- 同一问题连续修复 3 次仍未解决。

三次失败后：

1. 列出三次尝试和症状。
2. 检查 shared state、coupling 和错误的需求假设。
3. 判断应返回架构设计还是需求确认。
4. 禁止开始第四次同类尝试。

非实质差异不命中 Gate 6。Act 在契约内处理并记录，不建立 Blocker Handoff。

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

状态流转包括 `pending → reported`、`pending → blocked`、`blocked → pending`，以及 Plan 明确要求当前 Cycle 修复时的 `reported → pending`。恢复后必须先回到 `pending`，不得越过它改成 `reported`。

**恢复阻塞**

用户补充事实、给出解决办法或接受风险，并明确要求继续时：

1. 读取 Blocker Handoff、已有 Evidence 和工作区状态。
2. 确认当前 Cycle 没有后继 Cycle，`Review Result` 仍为 `pending`。
3. 在 Act Response 追加 `Blocker Resolution`，保留原 Blocker Handoff。
4. 记录用户指令、解决办法或豁免、风险、恢复点和所需验证。
5. 将状态从 `blocked` 改为 `pending`。
6. 对恢复点之后将要修改且既有见证已失效的 task 重新建立测试见证；工作区自阻塞前结论产生后未变化的部分直接采信既有见证并注明来源，再从恢复点继续。

不得只因 Cycle 曾被标记为 `blocked` 而拒绝恢复。若用户指令改变目标、范围、requirement、设计或测试策略，说明当前 Plan 无法覆盖的具体差异，再交给 Plan；阻塞状态本身不是拒绝理由。

## Phase 4：REPORT

当前 Cycle 的全部 task 或 repair item 正常完成后：

1. 对照当前 Cycle 的 requirements、scenarios、Task Contracts、Invariants 和 Non-goals。
2. 审查完整 diff，不只复用逐任务结论。
3. 检查跨任务交互、遗漏实现、计划外修改、回归风险和测试有效性。
4. 修复计划范围内的 Critical 和 Important 问题。
5. 对每项修复重跑受影响的 Gate 4 和 Gate 5；未受影响且覆盖范围未变化的验证结论引用上一轮 Response。
6. 实质问题按 Gate 6 阻塞并返回 Plan；其他局部问题在契约内处理或记录。
7. 运行完整验证套件。
8. 自检 change 文件结构。
9. initial 或 replan Cycle 更新所属 Iteration 状态时，只读取 change `tasks.md` 中对应 task 的必要上下文；rework Cycle 只记录本地 repair item 状态，不新增全局 task。
10. 首次报告填写当前 Cycle 的 `Act Response`；当前 Cycle 修复后覆盖整个 Response，使其成为包含原实施和最新修复的完整当前状态，不追加逐轮历史：
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

不得填写 `Plan Review`，不得创建下一 Cycle 或下一 Iteration。

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
7. 是否对照当前 Cycle 审查完整 diff？
8. Self-Review 是否没有未解决的 Critical 或 Important 问题？
9. Experience Candidates 是否已记录证据或明确写 `None`？

任一答案为否，不得声明完成。

## 输出与终止

- 已完成任务。
- 修改文件。
- 任务级和全量 diff Self-Review 结果。
- 已修复发现和遗留 Minor 问题。
- 验证命令、输出摘录和退出码。
- 当前 Iteration、Cycle 路径和 Act Response 状态。
- `blocked` 时的 Blocker Handoff 和 Evidence，或 `None required`。
- 恢复过阻塞时的 Blocker Resolution 和重跑 Gate。
- Persisted Evidence 路径，或未创建的原因。
- Experience Candidates 及其证据，或 `None`。
- 跳过项和阻塞项。

然后终止。提醒用户：

- 实现反馈已等待审计。
- 需要检查或修订时调用 `openspec-plan`。
- 调用 `openspec-plan` Review 当前 Cycle；有限修复按 Review 继续当前 Cycle，`rework-required` 或 `replan-required` 时由 Plan 创建对应后继 Cycle，`accepted` 且没有剩余 Iteration 后才调用 `openspec-docs-maintainer` 收尾。
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
- 修改全局任务、SNAPSHOT 或项目记忆。
- 调用 Maintainer、Plan 或 Archivist。
- 未经用户明确授权调用 Experience Recorder。
- 归档 change、清理分支或执行其他生命周期收尾。
- 覆盖 Plan Context 或填写 Plan Review。
- 自行补全 Plan 遗漏的设计或扩大变更面。
- 把平台专属工具名写成流程前提。
- 为每个 Cycle 强制创建空 Evidence 目录。
- 保存完整日志目录、源码副本、完整测试输出，或拆分、压缩产物绕过预算。
- 仅因日志较长、便于审计或以后可能有用而创建 Evidence。
- 把 change 内 Evidence 登记为 R 或单独执行 Artifact-Archive。
- 实现公共规则禁止的身份型证据工程。
