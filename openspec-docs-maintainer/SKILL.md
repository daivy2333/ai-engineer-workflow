---
name: openspec-docs-maintainer
description: 按用户明确指令维护 OpenSpec 的 SNAPSHOT、tasks、project model、decisions、knowledge、references、improvements、runbooks 和 incidents，或同步、收尾、归档指定 change；也接收 openspec-explorer 文档模式发出的限定 R 登记请求。
---

# OpenSpec Docs Maintainer

负责状态、项目记忆、持久化产物和用户指定的 change 收尾。查询交给 `openspec-assistant`，表达压缩交给 `openspec-compressor`，生命周期清理交给 `openspec-archivist`。

创建 Runbook 或 Incident 前完整读取 [references/artifact-templates.md](references/artifact-templates.md)。

## 写入范围

| 文档 | 编号 |
|---|---|
| `.claude/docs/tasks.md` | `Txx` |
| `.claude/docs/SNAPSHOT.md` | 无 |
| `openspec/specs/project-model/spec.md` | `Mxx` |
| `openspec/specs/decisions/spec.md` | `Dxx` |
| `openspec/specs/knowledge/spec.md` | `Kxx` |
| `openspec/specs/references/spec.md` | `Rxx` |
| `openspec/specs/improvements/spec.md` | `Ixx` |
| `.claude/runbooks/<topic>.md` | R 索引 |
| `.claude/incidents/YYYY-MM-DD-<topic>.md` | R 索引 |

## 约束

1. 只在用户明确要求时修改；Explorer 文档模式的 R 登记是唯一自动例外。
2. 写入前搜索重复条目。
3. 读取最大编号后递增。
4. 精准修改，不全量覆盖。
5. 不删除或归档 M/D/K/R/I 等条目；这类操作交给 archivist。
6. 不改变 explorer 分析文档正文。
7. change 元数据由 OpenSpec 集成管理。
8. 除 Explorer 的限定 R 登记外，只执行用户点名的维护动作。同步不隐含归档，归档不隐含其他清理。
9. Plan 和 Act 的完成报告不是写入授权。
10. Explorer 自动请求只授权分析文档 R 登记，不授权其他维护。
11. 每项信息只有一个权威位置；其他文档使用编号或路径引用。

## 工作流

### 1. LOAD

- 确定写入类型和目标文件。
- 搜索已有条目。
- 读取相关 M/D/K/R/I 条目，检查职责重叠。
- 涉及 change 时读取 `openspec list` 和对应 tasks。
- 列出本次允许修改的文件。

### 2. UPDATE

- 任务：维护进行中、待办、阻塞和最近完成，并保留 change 来源。
- 快照：根据 Git 状态和关键目录更新当前状态。
- 模型：记录当前有效的跨模块不变量、范围、证据和状态。
- 决策：记录选择、原因、替代方案、影响、状态和关联模型。
- 知识：记录已验证的非显然结论、证据、范围和边界。
- 参考：只登记类型、路径或 URL、版本或日期、用途和状态。
- 改进：记录有证据但未承诺实施的问题、影响、建议和状态。
- Runbook：记录可重复或高风险操作，并登记 R。
- Incident：记录重要故障的影响、时间线、根因、恢复和后续动作，并登记 R。
- change 同步：仅在用户明确要求时，同步指定 propose、apply 或 archive 结果。
- explorer 自动登记：只处理分析文档 R 候选，去重后写入 references。
- explorer 其他交接：M/D/K/I 候选仅在用户明确要求时去重和写入。
- change 收尾：用户明确要求收尾或归档即构成该动作授权。检查最新 iteration、任务和验证证据；运行 validate 后使用 OpenSpec 集成归档，再同步 tasks 与 SNAPSHOT。

路由规则：

- 短期当前事实写 SNAPSHOT。
- 已承诺工作写 tasks 或 change。
- 当前跨模块约束写 M。
- 有替代方案的长期选择写 D。
- 已验证、非显然且可复用的结论写 K。
- 指针和检索元数据写 R。
- 未承诺改进写 I；批准后创建 change 并标记 `promoted`。
- 可重复或高风险操作写 Runbook。
- 重要故障事件写 Incident。

### 3. VERIFY

- 运行 `git diff --check`。
- 检查编号唯一且递增。
- 检查 I 与 tasks/change 没有重复活跃工作。
- 检查 Runbook、Incident 和 analysis 有 R 索引。
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

Analysis、Runbook 或 Incident：

1. 从 R 条目定位 `archive/` 路径。
2. 恢复到对应活动目录。
3. 更新 R 路径和状态。
4. 检查交叉引用。

## 禁止

- 无需求写入。
- 重复记录。
- 编号冲突。
- 全量覆盖。
- 删除或归档文档条目。
- 压缩活跃文档。
- 手工修改 OpenSpec change 元数据。
- 根据 Plan 或 Act 的完成声明自动写入或归档。
- 借 Explorer 自动登记修改 R 以外的文档。
- 把单纯路径、API 签名或未验证猜测写入 K。
- 把已承诺工作继续作为活跃 I 保留。
- 在 R 中复制目标文档正文。
- 为普通测试失败创建 Incident。
- 为一次性命令创建 Runbook。
- 用户只要求同步时顺带归档。
- 用户只要求归档时顺带清理分支或无关文档。
