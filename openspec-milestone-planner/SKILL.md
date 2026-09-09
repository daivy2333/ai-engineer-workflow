---
name: openspec-milestone-planner
description: 将项目目标规划为工作量适中、可独立验证和排障的 OpenSpec 里程碑路线，并按用户批准结果维护 tasks 中的 MSxx。用于创建或调整项目 roadmap、拆分过重阶段、合并过细阶段，或在 change 规划前确定后续开发方向；不创建 change，不调查实现，不修改产品代码。
---

# OpenSpec Milestone Planner

规划项目阶段，不执行具体 change。让每个 milestone 形成可复用的稳定基线，同时避免阶段过重或过碎。

开始前完整读取：

- [references/decomposition-rules.md](references/decomposition-rules.md)
- [references/milestone-template.md](references/milestone-template.md)

## 职责边界

- 读取项目目标、SNAPSHOT、tasks、M/R 和已有 analysis。
- 创建、拆分、合并、排序尚未执行的 `MSxx`。
- 定义阶段成果、工作范围、稳定基线、验证边界和诊断边界。
- 只在用户批准后写入 `.agents/docs/tasks.md`。
- 不要求 Explorer、Plan、Act 或 Maintainer 生成专用交接。
- 不调用其他 skill，不创建 OpenSpec change，不修改产品代码。
- 不替代 `openspec-plan` 的 BDD、实现调查、设计和 Task Contract。
- 不替代 `openspec-docs-maintainer` 同步运行状态和 change 结果。
- 不替代 `openspec-archivist` 处理已完成或被替代条目的生命周期。

Milestone 与 change 不绑定数量。一个 milestone 可以由一个或多个 change 完成，具体拆分留给后续工作。

## Phase 1：LOAD

复用当前会话中 Assistant 已读取且未变化的体系上下文，只补读规划所缺的信息：

1. `AGENTS.md`、`.agents/docs/SNAPSHOT.md` 和 `.agents/docs/tasks.md`；当前上下文没有具体内容时再读取。
2. 相关 project-model 和 references。
3. 已存在且与目标相关的 analysis。
4. 活跃 change 的名称、目标和状态。

Analysis 是可选依据。缺少足够信息时，列出规划缺口并停止；不要求 Explorer 扩展职责，也不自行深挖代码。

明确本次允许调整的 roadmap 范围。默认不改写 `active`、`blocked`、`completed` 或 `superseded` milestone。

## Phase 2：MODEL

从项目目标提取：

- 需要获得的阶段成果。
- 成果之间的依赖关系。
- 每个阶段完成后可依赖的稳定基线。
- 能独立判断完成的验证边界。
- 失败时可限制排查范围的诊断边界。
- 明确推迟到后续阶段的内容。

先建立依赖关系，再分配编号。不要按目录、团队、工种或时间段机械切分。

## Phase 3：BALANCE

按 [references/decomposition-rules.md](references/decomposition-rules.md) 对每个候选 milestone 执行聚合和拆分审计。合并不能独立形成稳定基线的局部步骤；拆分包含多个独立成果或故障域的阶段。不要用固定文件数、代码行数或 change 数量代替判断。

## Phase 4：APPROVE

写入前向用户展示：

- milestone 顺序和依赖。
- 每项阶段成果与工作量依据。
- 稳定基线。
- 验证和诊断边界。
- Non-goals。
- 合并与拆分理由。
- 尚未解决的规划缺口。

用户批准前不修改 tasks。用户可以批准全部、限制范围或要求重新平衡。

## Phase 5：WRITE

按模板精准更新 `.agents/docs/tasks.md`：

1. 读取现有最大 `MSxx` 后递增。
2. 保留现有 `Txx`、change 状态和用户无关内容。
3. 新建 milestone 使用 `planned` 或 `ready`。
4. 只调整用户批准范围内的 `planned` 和 `ready` 条目。
5. 检查依赖无环，所有依赖编号存在。
6. 检查目标覆盖，没有无依据的阶段。
7. 运行 `git diff --check` 并审查完整 diff。

规划者可以修改 milestone 的目标、范围、顺序和边界。运行中的状态变化由 Maintainer 按用户指令同步。

## 完成检查

- 每个 milestone 是否有足够工作量？
- 每个 milestone 是否只形成一个阶段成果？
- 是否能独立验证，不依赖后续 milestone？
- 失败时是否有明确排查范围？
- 是否形成后续工作可依赖的稳定基线？
- 是否保留 Non-goals 和拆分信号？
- 依赖是否完整且无环？
- 是否没有修改 Explorer、Plan、Act 或 change？

任一答案为否，不得声明 roadmap 完成。

## 输出与终止

报告：

- 新建、拆分、合并和重排的 `MSxx`。
- 依赖顺序。
- 聚合审计与拆分审计结果。
- 修改文件。
- 未解决的规划缺口。
- 跳过项及原因。

然后终止。不要自动进入 Explorer、Plan、Act、Maintainer 或 Archivist。

## 禁止

- 把每个小功能或代码修改设为 milestone。
- 把多个独立成果或故障域塞进同一 milestone。
- 把测试、观测和排障能力统一推迟到路线末端。
- 预先规定 milestone 必须对应一个 change。
- 为后续 Plan 编写实现细节、代码符号或测试契约。
- 未经批准写入 tasks。
- 静默改写运行中或历史 milestone。
