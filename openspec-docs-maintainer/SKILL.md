---
name: openspec-docs-maintainer
description: 维护 OpenSpec 项目的 tasks、SNAPSHOT、架构决策、学习记忆、参考索引和优化记录，并同步 change 生命周期。用于明确要求更新状态、记录知识或决策、登记 explorer 发现、同步 propose/apply/archive，或恢复归档条目时。
---

# OpenSpec Docs Maintainer

负责日常状态和知识写入。查询交给 `openspec-assistant`，表达压缩交给 `openspec-compressor`，生命周期清理交给 `openspec-archivist`。

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
5. 不删除历史；删除与归档交给 archivist。
6. 不改变 explorer 分析文档正文。
7. change 元数据由 OpenSpec 集成管理。

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
- change 同步：在 propose、apply、archive 后同步 tasks 与 SNAPSHOT。
- explorer 交接：接收 explorer 的候选 A/L/R 清单，去重后写入。

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
- 删除或归档条目。
- 压缩活跃文档。
- 直接修改 OpenSpec change 元数据。
