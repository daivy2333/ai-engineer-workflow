---
name: openspec-assistant
description: 只读恢复和查询 OpenSpec 项目的规则、状态、任务、变更、架构、知识、参考与优化记录。用于询问当前进度、项目规则、文档位置、已有决策或应使用哪个 OpenSpec skill；不执行任何写入。
---

# OpenSpec Assistant

只读建立项目上下文。发现需要写入时，路由到对应 skill，不代替它执行。

## 读取顺序

上下文恢复时依次读取：

1. `CLAUDE.md`
2. `.claude/docs/SNAPSHOT.md`
3. `.claude/docs/tasks.md`
4. `openspec list`
5. 与问题相关的 specs、changes 或 analysis

文件不存在时报告缺失，不创建模板。

## 文档地图

| 内容 | 路径 | 写入者 |
|---|---|---|
| 公共规则 | `CLAUDE.md` | `openspec-init` 或人工 |
| 当前状态 | `.claude/docs/SNAPSHOT.md` | `openspec-docs-maintainer` |
| 全局任务 | `.claude/docs/tasks.md` | `openspec-docs-maintainer` |
| 架构决策 | `openspec/specs/architecture/spec.md` | `openspec-docs-maintainer` |
| 学习记忆 | `openspec/specs/learned/spec.md` | `openspec-docs-maintainer` |
| 外部参考 | `openspec/specs/references/spec.md` | `openspec-docs-maintainer` |
| 优化记录 | `openspec/specs/optimization/spec.md` | `openspec-docs-maintainer` |
| 活跃变更 | `openspec/changes/` | OpenSpec 集成与 plan/act |
| 深度分析 | `.claude/analysis/` | `openspec-explorer` |

## 路由

| 请求 | Skill |
|---|---|
| 初始化规则和目录 | `openspec-init` |
| 需求与计划 | `openspec-plan` |
| 实施、验证、填写 Act Response | `openspec-act` |
| Review 实现、生成下一轮上下文 | `openspec-plan` |
| 更新 tasks、SNAPSHOT、A/L/R/O，收尾指定 change | `openspec-docs-maintainer` |
| 深度阅读并生成分析文档 | `openspec-explorer` |
| 原地压缩表达 | `openspec-compressor` |
| 归档、删除、墓碑 | `openspec-archivist` |

## 输出

- 已读取的文档。
- 当前状态或查询结果。
- 活跃 change。
- 证据路径。
- 后续应使用的 skill。

## 禁止

- 修改任何文件。
- 同步任务。
- 追加知识或 ADR。
- 压缩、归档、删除或恢复条目。
- 忽略活跃 change。
