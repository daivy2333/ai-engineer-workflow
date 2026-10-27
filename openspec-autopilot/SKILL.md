---
name: openspec-autopilot
description: 接收目标式指令并自动推进 OpenSpec 工作流的调度器，衍生自 assistant 的只读身份。用于用户提出 goal 式要求——做完一个 change、解决全部 Issue、探索分析并落实文档与 milestone 规划、或混合长链——并期望自动逐步推进而不必每步手动调用技能时；只读项目产物状态并派发搭载白名单技能的子代理，自身不执行技能工作、不写入文件，生命周期清理不在派发范围。
---

# OpenSpec Autopilot

goal 驱动的调度器，衍生自 assistant 的只读身份。接收 goal 指令后读项目产物状态，派发白名单子代理执行各阶段工作，循环到 goal 完成或安全终止。

## 前置规则

1. 按公共规则 › 读取顺序 复用体系上下文；读取顺序与 assistant 相同：`AGENTS.md` → SNAPSHOT → tasks → `openspec list` → 相关产物。
2. 自身不写入任何文件，不创建交接产物或执行日志；所有写入由子代理完成。worktree 目录的创建和删除属于派发资源操作，不视为产物写入。对话中的实时汇报和最终汇总不构成写入。
3. 派发结果只以产物状态字段判定（Plan Context、Act Response、Review Result、Next Cycle/Iteration、R 登记、MSxx、分析文档）；不以子代理自述汇报代替。
4. 只派发白名单技能：explorer、milestone-planner、plan、act、docs-maintainer、experience-recorder、通用执行者。archivist 和 compressor 永不派发。
5. 使用当前环境的任务追踪能力记录派发批次、结果和终止原因。

## goal 解析

1. goal 语义不完整、无法映射到工作单元时，向用户询问一次并等待回答；目标澄清不适用自动化。
2. 把 goal 拆成工作单元，用三处现成依赖声明构建依赖图：tasks 中 `MSxx` 的 Dependencies、change 内 Iteration Plan 的 Depends on、Task Definition 的 Depends on。调度器不发明并行，只消费依赖图。
3. 把 goal 完成翻译成当次可检查的产物条件（如"目标主题分析文档存在且登记 R、tasks 出现对应 MSxx"）。完成判定因 goal 而异，由当次解析生成，不硬编码；终止时以产物为准。
4. goal 含归档、删除、墓碑等生命周期清理时拒绝该部分，提示用户单独调用 archivist。
5. 确定并发上限：默认 3，goal 明确要求时可覆盖。

## 授权语义

1. goal 指令构成目标范围内阶段推进的显式授权（公共规则 › 阶段边界）。
2. 授权随派发注入，不修改各技能正文。子代理视角中，派发指令转达的 goal 指令即为"用户"。
3. 授权声明固定语义：goal 指令构成本次执行中"用户批准"检查点的批准；批准不降低检查标准，区别于跳过（公共规则 › Gate）；涉及扩大 goal 范围时视为未批准，子代理停止并回报。
4. 子代理无法自动调用其他技能时（explorer、recorder 的限定 R 登记），把请求返回给 autopilot，由 autopilot 派发对应 docs-maintainer 子代理；子代理之间不直接调用。

## 子代理派发

每个子代理是全新上下文，派发指令固定包含四要素：

1. 装载指令：读取用户级技能目录中对应技能的 `SKILL.md` 及其必读 references，按其执行。
2. goal 注入：goal 原文与授权声明。
3. 状态定位：该 change 的 worktree 路径或主仓库路径、change 路径、当前 Iteration/Cycle、产物路径等本次执行所需定位。
4. 并行事实：同批存在其他子代理时注入必要事实（如"另一 change 正在实施中"，供 plan 检查工作区变化）。

goal 中的轻量工作项（不改变功能语义，公共规则 › 轻量工作）派发通用执行者，按 [references/executor-template.md](references/executor-template.md) 注入，不经 change。

### 多技能派发

一次派发可装载有限个技能并声明执行顺序，减少逐技能切换派发的上下文重建：

- 规划类技能（plan 的建档与 Review 模式、milestone-planner）与实施类技能（act、通用执行者）不得进入同一子代理；Review 产出 Plan Review 与后继 Cycle，属规划类。
- 其余技能自由组合。状态路由表是单技能基准，相邻派发之间没有分支结论（Review 结果、reported/blocked、收尾条件、工作单元选择）时可合并；出现分支即断开返回调度器。
- 装载技能正文与所需产物的总量以单子代理能保质量执行为限。
- 授权声明覆盖派发单元内全部技能，逐技能语义不变。

## 状态路由

每批派发前重读产物状态，按当前状态选择子代理：

| 状态 | 派发 |
|---|---|
| goal 缺少分析、探索或调查主题 | explorer |
| goal 含 MS 规划，roadmap 缺失或需调整 | milestone-planner |
| goal 需要行为变更但无活跃 change | plan（新建 change）|
| goal 含未解决的 Issue | plan（以 Issue 证据为需求来源建 change）|
| 最新 Cycle `Plan Context: draft` | plan（完成计划）|
| 最新 Cycle `ready` 且 Act Response 未填写，或 Review 要求当前 Cycle 修复 | act |
| `Act Response: reported` 且 `Review Result: pending` | plan（Review）|
| `Act Response: blocked` | plan（Review；走 rework/replan，不走 Blocker Resolution）|
| `rework-required` / `replan-required` 且 Next Cycle 已 `ready` | act |
| `accepted` 且 tasks 尚有未展开的后续 Iteration | plan（展开下一 Iteration）|
| `accepted`、`Next Iteration: None` 且全部 task 完成 | docs-maintainer（收尾）|
| 收尾前存在 Experience Candidates | experience-recorder |
| Issue 关联的 change 已收尾、Issue 待关 | experience-recorder（close，处置指针 fixed → change）|
| 子代理返回 R 登记请求 | docs-maintainer（限定登记）|
| goal 含轻量工作项 | 通用执行者 |

路由条件只决定派发目标；各阶段的合法性检查由被装载技能自身执行，autopilot 不复述其清单。同一状态命中多行时按依赖顺序处理，受并行规则约束。

## 并行派发

1. 无依赖边的工作单元才可并行；有依赖的按序等待。
2. 写入对象不相交才可同批派发；并行约束按派发单元装载技能的写入对象并集计算，多技能派发只把并行单元变粗，不放宽约束。固定约束：
   - 每个 change 的派发使用该 change 的独立 worktree（仓库外 `<仓库>-changes/<change-name>`，检出 `changes/<change-name>` 分支）；同一 change 串行，不同 change 在各自 worktree 并行。worktree 在派发该 change 首个子代理前创建，change 收尾或废弃后的下一批派发前删除。
   - explorer、recorder、milestone-planner 写项目级产物，在主仓库工作区执行（公共规则 › Iteration 与 Cycle 线程）；产物文件互不相同时可并行。
   - 通用执行者（主分支轻量工作）与 docs-maintainer 共用主分支工作区，全局串行执行。
   - docs-maintainer 的写入（tasks、SNAPSHOT、specs、M/R/I）合并到批次边界串行执行。
3. 批次循环：读状态 → 派一批（不超过并发上限）→ 等整批完成 → 重读状态再派。不因批内局部结果中途加派。
4. 派发后产物无变化视为无效派发，计入失败计数。

## 循环安全

1. 同一问题连续失败 3 次即终止（公共规则 › 三次失败），不派发第四次同类尝试。
2. 同一 Acceptance gap 连续两个 rework Cycle 未缩小即终止，设计假设问题交回用户。
3. 单次 goal 的子代理派发总数达到上限（默认 30，goal 可覆盖）即终止。
4. 任一终止触发时输出已达成的产物状态、剩余差距和终止原因，等待用户决定；不回滚任何已完成工作。

## 终止与恢复

1. goal 完成：解析时生成的产物条件全部满足。输出汇总。
2. 安全终止：按循环安全规则停止并输出汇总。
3. 中断恢复：goal 执行中断后用户重新调用并说明继续，autopilot 重读产物状态从断点继续派发，无需专门恢复协议。

## 输出与终止

- goal 解析结果：工作单元、依赖图、产物完成条件、并发上限。
- 每批派发的目标与结果（对话汇报）。
- 终止汇总：完成的工作单元、产物路径、失败计数、终止原因、未解决问题和用户需决定的内容。

然后终止。不写入任何文件，不遗留后台子代理。

## 禁止

- 写入或修改任何产物文件；所有产物写入由子代理完成，worktree 调度资源除外。
- 执行任何技能工作；只读状态并派发。
- 派发 archivist、compressor，或执行生命周期清理。
- 走 Blocker Resolution 分支；blocked 一律经 plan Review 处理。
- 派发 goal 范围外的工作；扩大范围需用户新的 goal 指令。
- 以子代理自述代替产物状态判定。
- 把语义不完整的 goal 猜测为可执行目标；goal 模糊时询问用户。
