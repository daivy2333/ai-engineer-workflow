---
name: openspec-docs-maintainer
description: 按用户明确指令维护 OpenSpec 项目的 tasks、SNAPSHOT、架构决策、学习记忆、参考索引和优化记录，或同步、收尾、归档指定 change。用于用户要求更新状态、登记发现、处理已审计 change 或恢复归档条目时。
---

# OpenSpec Docs Maintainer

负责日常状态、知识写入和用户指定的 change 收尾。查询交给 `openspec-assistant`，表达压缩交给 `openspec-compressor`，文档生命周期清理交给 `openspec-archivist`。

## 写入范围

| 文档 | 编号 |
|---|---|
| `.claude/docs/tasks.md` | `Txx` |
| `.claude/docs/SNAPSHOT.md` | 无 |
| `openspec/specs/architecture/spec.md` | `Axx` |
| `openspec/specs/learned/spec.md` | `Lxx` |
| `openspec/specs/references/spec.md` | `Rxx` |
| `openspec/specs/optimization/spec.md` | `Oxx` |

## 约束

1. 只在有明确写入需求时修改。
2. 写入前搜索重复条目。
3. 读取最大编号后递增。
4. 精准修改，不全量覆盖。
5. 不删除或归档 A/L/R/O 等文档条目；这类操作交给 archivist。
6. 不改变 explorer 分析文档正文。
7. change 元数据由 OpenSpec 集成管理。
8. 只执行用户点名的维护动作。同步不隐含归档，归档不隐含其他清理。
9. Plan、Act 或 Explorer 的完成报告不是写入授权。

## 工作流

### 1. LOAD

- 确定写入类型和目标文件。
- 搜索已有条目。
- 涉及 change 时读取 `openspec list` 和对应 tasks。
- 列出本次允许修改的文件。

### 2. UPDATE

- 任务：维护进行中、待办、阻塞和最近完成，并保留 change 来源。
- 快照：根据 Git 状态和关键目录更新当前状态。
- 决策：写入日期、决策、原因、影响和替代方案。
- 学习：写入 API、文件位置、症状、根因、解决或技巧。
- 参考：登记依赖、外部文档或 `.claude/analysis/` 索引。
- 优化：记录问题、影响、建议、优先级和状态。
- change 同步：仅在用户明确要求时，同步指定 propose、apply 或 archive 结果。
- explorer 交接：接收 explorer 的候选 A/L/R 清单，去重后写入。
- change 收尾：用户明确要求收尾或归档即构成该动作授权。检查最新 iteration、任务和验证证据；运行 validate 后使用 OpenSpec 集成归档，再同步 tasks 与 SNAPSHOT。

### 3. VERIFY

- 运行 `git diff --check`。
- 检查编号唯一且递增。
- 涉及 OpenSpec 时运行相应 validate。
- 报告修改文件、编号和条目。

## 恢复归档条目

1. 从源文档的 `<!-- arc:` 定位 carrier proposal。
2. 按原编号读取归档条目。
3. 精准插回源文档。
4. 更新 arc 计数。
5. 追加 `<!-- restored: <编号> <日期> -->`。
6. 验证原编号可搜索且墓碑已按协议处理。

## 禁止

- 无需求写入。
- 重复记录。
- 编号冲突。
- 全量覆盖。
- 删除或归档文档条目。
- 压缩活跃文档。
- 直接修改 OpenSpec change 元数据。
- 根据其他 Skill 的完成声明自动写入或归档。
- 用户只要求同步时顺带归档。
- 用户只要求归档时顺带清理分支或无关文档。
