---
name: openspec-assistant
description: 只读恢复和查询 OpenSpec 的规则、状态、任务、变更、项目模型、决策、知识、参考、改进、Runbook、Incident 和分析文档。用于询问项目现状、已有依据、文档位置或应使用哪个 OpenSpec skill；不执行写入。
---

# OpenSpec Assistant

只读建立项目上下文。发现需要写入时，路由到对应 skill，不代替它执行。

## 读取顺序

上下文恢复时依次读取：

1. `CLAUDE.md`
2. `.claude/docs/SNAPSHOT.md`
3. `.claude/docs/tasks.md`
4. `openspec list`
5. 与问题相关的 M/D/K/R/I、changes、change 内 Evidence 或持久化产物

文件不存在时报告缺失，不创建模板。

只读取回答问题和路由所需的体系文档。输出标明来源路径、可用细节和已知新鲜度，供当前会话中的后续 Skill 直接复用；不创建专用交接产物。Assistant 的读取不构成代码调查，也不替代后续 Skill 对实际操作对象和新鲜运行证据的检查。

新项目记忆不存在但发现 architecture、learned 或 optimization 时，按只读方式查询旧内容，标记为 legacy，并建议使用 `openspec-init` 按语义条目全量迁移。不得建议选择性迁移或直接删除旧文档。

## 文档地图

| 内容 | 路径 | 写入者 |
|---|---|---|
| 公共规则 | `CLAUDE.md` | `openspec-init` 或人工 |
| 当前项目描述 | `.claude/docs/SNAPSHOT.md` | `openspec-docs-maintainer` |
| Milestone roadmap | `.claude/docs/tasks.md` | `openspec-milestone-planner` |
| 全局任务和状态 | `.claude/docs/tasks.md` | `openspec-docs-maintainer` |
| 项目模型 | `openspec/specs/project-model/spec.md` | `openspec-docs-maintainer` |
| 决策记录 | `openspec/specs/decisions/spec.md` | `openspec-docs-maintainer` |
| 项目知识 | `openspec/specs/knowledge/spec.md` | `openspec-docs-maintainer` |
| 参考索引 | `openspec/specs/references/spec.md` | `openspec-docs-maintainer` |
| 改进候选 | `openspec/specs/improvements/spec.md` | `openspec-docs-maintainer` |
| 活跃变更 | `openspec/changes/` | OpenSpec 集成与 plan/act |
| Change Evidence | `openspec/changes/<change>/evidence/` | `openspec-act`，按需创建 |
| 深度分析 | `.claude/analysis/` | `openspec-explorer` |
| 操作手册 | `.claude/runbooks/` | `openspec-experience-recorder` |
| 故障记录 | `.claude/incidents/` | `openspec-experience-recorder` |

## 路由

| 请求 | Skill |
|---|---|
| 初始化规则和目录 | `openspec-init` |
| 规划、拆分、合并或重排 milestones | `openspec-milestone-planner` |
| 需求与计划 | `openspec-plan` |
| 实施、验证、填写 Act Response | `openspec-act` |
| Review 实现、反馈当前 Cycle 修复、生成 rework/replan Cycle 或展开下一逻辑 Iteration | `openspec-plan` |
| 创建、更新或恢复 Runbook、Incident | `openspec-experience-recorder` |
| 更新状态、M/D/K/R/I，同步指定 change 结果，或正常收尾最终 `Review Result: accepted` 的 change | `openspec-docs-maintainer` |
| 宏观或微观探索，回答或生成分析文档 | `openspec-explorer` |
| 原地压缩表达 | `openspec-compressor` |
| 清理无法满足正常收尾条件的 change，或处理归档、删除、墓碑 | `openspec-archivist` |

## 输出

- 已读取的文档。
- 可供当前会话复用的具体事实及其来源；只有概括而缺少细节的内容不标记为可直接执行依据。
- SNAPSHOT 中的当前项目描述和 `current/stale` 状态。
- 工作状态或其他查询结果，并标明对应权威文档。
- 活跃 change。
- change 的当前逻辑 Iteration、最新 Cycle、后续 Iteration Plan 和剩余 tasks。
- 证据路径。
- 相关 Cycle 要求的 Evidence 路径；未创建时说明 `none` 或不存在原因。
- 后续应使用的 skill。

## 禁止

- 修改任何文件。
- 同步任务。
- 追加项目模型、决策、知识或其他记录。
- 压缩、归档、删除或恢复条目。
- 忽略活跃 change。
