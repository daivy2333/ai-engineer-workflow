---
name: openspec-experience-recorder
description: 根据已经发生且有证据的实施或运行过程，创建、更新或恢复 OpenSpec Runbook 和 Incident。用于 openspec-act 完成或阻塞后记录可重复操作与重要故障，也用于根据外部日志、命令、时间线和既有产物独立维护工程经验；不预先探索、不实施、不修改 change 或项目记忆。
---

# OpenSpec Experience Recorder

把已验证的实施或运行经验写成持久化产物。Recorder 可以读取 Act 结果，但不依赖 Act，也不是 Act 的完成阶段。

创建或更新产物前完整读取 [references/artifact-formats.md](references/artifact-formats.md)。

## 职责

- 创建、更新和恢复 `.claude/runbooks/` 中的 Runbook。
- 创建、更新和恢复 `.claude/incidents/` 中的 Incident。
- 从 Act Response、Evidence、命令输出、日志、时间线或现有产物提取事实。
- 区分事实、推断和未确认项。
- 为新建、实质更新或恢复的产物请求 R 登记或索引更新。

Act 可以列出 Experience Candidates，但候选不构成创建授权，也不证明产物门槛已经满足。用户可以单独调用 Recorder，或预先明确授权 `Act → Recorder` 串联。

## 输入与模式

先确定本次模式：

- `runbook-create`：把已跑通路径记录为 Runbook。
- `runbook-update`：用新的执行证据更新已有 Runbook。
- `incident-create`：记录已经发生的重要故障。
- `incident-update`：补充影响、时间线、根因、恢复或后续状态。
- `restore`：按用户明确要求恢复已归档的 Runbook 或 Incident。

来源可以是：

- `reported` 或 `blocked` Cycle。
- Act Response 和 change 内 Evidence。
- 用户提供的命令、日志、截图、时间线或环境信息。
- 已有 Runbook、Incident 及其 R 索引。

缺少 Act 或 change 不是阻塞条件。缺少支持目标内容的证据时停止，不通过重新实施或主动探索补造事实。

## 产物门槛

Runbook 必须同时满足：

- 操作已经端到端执行成功。
- 路径可重复，或操作风险需要固定步骤。
- 适用范围、前置条件和环境可定位。
- 成功判据有执行证据。
- 失败停止点和回滚方式已知；不可回滚时明确说明。

一次性命令、计划中的步骤、未验证建议和仅在错误原因下通过的操作不得创建 Runbook。

Incident 至少满足一项：

- 造成用户、数据、服务、硬件或交付影响。
- 暴露跨模块或系统性失效。
- 需要异常恢复、回滚或人工介入。
- 现场难以复现，需要保留时间线和证据。
- 同一问题三次失败后停止，并形成可复用诊断信息。

普通测试失败、预期 RED、已知且无额外影响的错误不得创建 Incident。根因未确认时允许记录，但必须标记 `unconfirmed`。

## 1. LOAD

1. 复用当前会话中已读取且未变化的 `CLAUDE.md` 和体系上下文，读取格式规则、同主题持久化产物及其 R 索引。
2. 涉及 Act 时优先读取 Act Response 和实际存在的 Evidence；只有范围、前置条件或环境无法由这些来源确定时，才补读 Plan Context 的相关部分。
3. 记录来源 revision、环境、命令、结果和证据路径。
4. 搜索同主题 Runbook、Incident 和 R，避免重复。

## 2. QUALIFY

1. 选择 Runbook 或 Incident，不把同一正文混为两类。
2. 对照产物门槛逐项判断。
3. 标记证据支持的事实、合理推断和未知项。
4. 证据不足时报告缺口并停止。

`reported` Act 中通过 Gate 5 的路径可以支持 Runbook。`blocked` Act 通常只支持 Incident；其中独立验证成功的恢复路径可以支持 Runbook。

## 3. WRITE

按格式文件精准创建或更新：

- Runbook：`.claude/runbooks/<topic>.md`
- Incident：`.claude/incidents/YYYY-MM-DD-<topic>.md`

更新 Runbook 时保留仍有效的边界和失败处理，并刷新验证日期、环境与证据。更新 Incident 时追加时间线和状态，不改写已发生的历史。

Recorder 只记录来源能够支持的内容。命令输出和长日志保留在原 Evidence 或外部来源中，产物使用路径引用，不复制长日志。

## 4. RESTORE

只在用户明确要求时执行：

1. 从 R 定位 `archive/` 中的产物。
2. 检查活动目录没有同名冲突。
3. 恢复到对应活动目录。
4. 保留正文和历史状态，记录恢复日期。
5. 请求 Maintainer 更新 R 路径和状态。

归档由 `openspec-archivist` 负责。Recorder 不自行判断或执行归档。

## 5. REGISTER

产物验证后自动调用 `openspec-docs-maintainer`。授权范围只包括：

- 去重并创建对应 R。
- 更新本次产物已有 R 的路径、日期、用途或状态。

不得携带 M/D/K/I、tasks、SNAPSHOT、change、同步或归档请求。登记失败时保留已验证产物并报告失败原因。

发现 M、D、K 或 I 候选时只在结果中列出。用户明确授权后再由 Maintainer 写入，不在 Recorder 中总结到项目记忆。

## Gate

完成前确认：

- 产物类型和门槛匹配。
- 每项操作或事件事实有证据。
- 推断和未知项已标明。
- Runbook 的验证、失败处理和回滚完整。
- Incident 的影响、时间线、恢复状态和证据完整。
- 路径与交叉引用有效。
- 新建、更新或恢复的产物已有 R 结果或失败说明。
- 未修改产品代码、change、Evidence 或项目记忆。

## 输出

- 模式和来源。
- 创建、更新或恢复的产物路径。
- 门槛判断和证据。
- R 编号或登记失败原因。
- 未确认项。
- 未自动登记的 M/D/K/I 候选。

## 禁止

- 为生成产物而重新实施或主动探索。
- 根据计划或猜测创建 Runbook。
- 把普通失败或预期 RED 写成 Incident。
- 把未确认根因写成事实。
- 修改 Act Response、Plan Review、change tasks 或 Evidence。
- 创建、修改或归档 M/D/K/I、tasks、SNAPSHOT 或 change。
- 自动归档产物。
- 调用 Compressor 改写 Runbook 或 Incident。
