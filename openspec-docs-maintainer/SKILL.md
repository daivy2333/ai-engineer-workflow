---
name: openspec-docs-maintainer
description: 维护 OpenSpec 的 SNAPSHOT、任务与 milestone 状态、M/D/K/R/I，或同步、收尾、归档指定 change。用户直接调用时默认刷新 SNAPSHOT；也接收 Explorer、Recorder 只写 R 的限定登记请求。
---

# OpenSpec Docs Maintainer

负责状态、项目记忆、检索索引和用户指定的 change 收尾。查询交给 `openspec-assistant`，工程经验正文交给 `openspec-experience-recorder`，表达压缩交给 `openspec-compressor`，生命周期清理交给 `openspec-archivist`。

## 写入范围

| 文档 | 编号 |
|---|---|
| `.claude/docs/tasks.md` | `Txx`；已有 `MSxx` 的状态和 change 引用 |
| `.claude/docs/SNAPSHOT.md` | 无 |
| `openspec/specs/project-model/spec.md` | `Mxx` |
| `openspec/specs/decisions/spec.md` | `Dxx` |
| `openspec/specs/knowledge/spec.md` | `Kxx` |
| `openspec/specs/references/spec.md` | `Rxx` |
| `openspec/specs/improvements/spec.md` | `Ixx` |

## 约束

1. 用户直接调用时，除 SNAPSHOT 默认刷新外只修改明确要求的内容；Explorer 和 Recorder 的限定 R 登记只写 references。
2. 写入前搜索重复条目。
3. 读取最大编号后递增。
4. 直接调用时 SNAPSHOT 默认增量更新；其他已有文档只做精准修改。
5. 不删除或归档 M/D/K/R/I 等条目；这类操作交给 archivist。
6. 不改变 Explorer、Recorder 管理的持久化产物正文。
7. change 元数据由 OpenSpec 集成管理。
8. 直接调用默认刷新 SNAPSHOT；限定 R 登记跳过 SNAPSHOT。同步不隐含归档，归档不隐含其他清理。
9. Plan 和 Act 的完成报告不是写入授权。
10. Explorer 自动请求只授权 Analysis 的 R 登记；Recorder 自动请求只授权本次 Runbook 或 Incident 的 R 创建或更新。
11. 每项信息只有一个权威位置；其他文档使用编号或路径引用。
12. Change Evidence 属于 change，不登记 R，也不作为独立持久化产物维护。
13. `MSxx` 的目标、范围、依赖、验证和诊断边界由 `openspec-milestone-planner` 规划；Maintainer 只同步已有 milestone 的运行状态和 change 引用。

## 工作流

### 1. LOAD

- 确定写入类型和目标文件。
- 直接调用时读取 SNAPSHOT 的同步 revision、时间和状态；限定 R 登记只读取 references 和目标产物元数据。
- 直接调用时比较当前 Git 状态，确定能否可靠计算 SNAPSHOT 增量；没有可靠同步基线时记录全量刷新原因。
- 搜索已有条目。
- 读取相关 M/D/K/R/I 条目，检查职责重叠。
- 涉及 change 时读取 `openspec list` 和对应 tasks。
- 列出本次允许修改的文件。

### 2. UPDATE

- 任务：维护进行中、待办、阻塞和最近完成，并保留 change 来源。
- Milestone 状态：按用户指令同步 `active`、`blocked`、`completed`、`superseded` 和已有 change 引用，不拆分、合并或重写路线。
- 快照：优先按同步 revision 与当前 Git 差异做增量刷新，只更新受影响的项目描述字段。
- 快照回退：无法可靠计算增量时执行全量刷新；刷新失败时标记 `stale`，记录原因，不声称同步成功。
- 模型：记录当前有效的跨模块不变量、范围、证据和状态。
- 决策：记录选择、原因、替代方案、影响、状态和关联模型。
- 知识：记录已验证的非显然结论、证据、范围和边界。
- 参考：只登记类型、路径或 URL、版本或日期、用途和状态。
- 改进：记录有证据但未承诺实施的问题、影响、建议和状态。
- change 同步：仅在用户明确要求时，同步指定 propose、apply 或 archive 结果。
- explorer 自动登记：只处理分析文档 R 候选，去重后写入 references。
- recorder 自动登记：只处理本次 Runbook 或 Incident 的 R 候选或索引更新，去重后写入 references。
- explorer 其他交接：M/D/K/I 候选仅在用户明确要求时去重和写入。
- recorder 其他交接：M/D/K/I 候选仅在用户明确要求时去重和写入。
- change 收尾：用户明确要求收尾或归档即构成该动作授权。确认全部 change tasks 完成、Iteration Plan 无剩余任务、最新 Cycle 的 Plan Review 为 `accepted` 且 `Next Iteration: None`，再检查 Act Response 和 `required` Evidence；validate 通过后归档并同步 tasks 与 SNAPSHOT。Evidence 随 change 归档，不单独移动或登记 R。

路由规则：

- 当前项目描述写 SNAPSHOT，只包括项目身份、组成、支持范围和仓库现场。
- 已承诺工作写 tasks 或 change。
- 当前跨模块约束写 M。
- 有替代方案的长期选择写 D。
- 已验证、非显然且可复用的结论写 K。
- 指针和检索元数据写 R。
- 未承诺改进写 I；批准后创建 change 并标记 `promoted`。
- 可复用的构建、测试和其他命令行操作流程写 Runbook。
- Runbook 和 Incident 正文交给 `openspec-experience-recorder`。

### 3. VERIFY

- 运行 `git diff --check`。
- 直接调用时检查 SNAPSHOT 的同步 revision、时间和 `current/stale` 状态与本次刷新结果一致。
- 直接调用时检查 SNAPSHOT 没有工作状态、操作流程、约束、原因或历史记录。
- 检查编号唯一且递增。
- 检查 I 与 tasks/change 没有重复活跃工作。
- 检查 Runbook、Incident 和 analysis 有 R 索引。
- 检查每个 `required` Iteration/Cycle Evidence 目录和 README 可定位；`none` 的 Cycle 不要求 Evidence 目录。
- 涉及 OpenSpec 时运行相应 validate。
- 报告修改文件、编号和条目。

## 恢复归档条目

Carrier 条目：

1. 从源文档的 `<!-- arc:` 定位 carrier proposal。
2. 按原编号读取归档条目。
3. 精准插回源文档。
4. 更新 arc 计数。
5. 追加 `<!-- restored: <编号> <日期> -->`。
6. 验证原编号可搜索且墓碑已按协议处理。

Analysis：

1. 从 R 条目定位 `archive/` 路径。
2. 恢复到 `.claude/analysis/`。
3. 更新 R 路径和状态。
4. 检查交叉引用。

Runbook 和 Incident 的正文恢复交给 `openspec-experience-recorder`。Maintainer 只接受其限定请求更新 R 路径和状态。

## 禁止

- 无需求写入。
- 重复记录。
- 编号冲突。
- 在 SNAPSHOT 回退以外全量覆盖已有文档。
- 删除或归档文档条目。
- 压缩活跃文档。
- 手工修改 OpenSpec change 元数据。
- 根据 Plan 或 Act 的完成声明自动写入或归档。
- 借 Explorer 自动登记修改 R 以外的文档。
- 借 Recorder 自动登记修改 R 以外的文档。
- 创建、修改或恢复 Runbook 和 Incident 正文。
- 把单纯路径、API 签名或未验证猜测写入 K。
- 把已承诺工作继续作为活跃 I 保留。
- 创建、拆分、合并或重排 `MSxx`。
- 在 R 中复制目标文档正文。
- 用户只要求同步时顺带归档。
- 用户只要求归档时顺带清理分支或无关文档。
- 为 change 内 Evidence 创建 R、独立归档或补写实际证据。
