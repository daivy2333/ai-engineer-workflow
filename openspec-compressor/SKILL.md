---
name: openspec-compressor
description: 原地压缩 OpenSpec 活跃文档，在不移动、不归档、不删除有效信息、不改变规则或状态的前提下减少重复表达。用于精简 CLAUDE、SNAPSHOT、tasks、M/D/K/R/I 和 analysis；不处理 Runbook、Incident 或 change Evidence。
---

# OpenSpec Compressor

只改变表达密度，不改变信息、状态、编号或生命周期。

## 边界

- `openspec-assistant`：只读查询。
- `openspec-docs-maintainer`：日常状态和知识写入。
- `openspec-explorer`：生成分析文档。
- `openspec-experience-recorder`：生成和更新 Runbook、Incident。
- `openspec-compressor`：原地压缩表达。
- `openspec-archivist`：归档、删除、移动和墓碑。

## Phase 1：SCAN

1. 读取用户指定文档；未指定时检查常见目标是否存在。
2. 记录压缩前行数。
3. 查找重复背景、同义句、过细过程和无事实过渡。
4. 标记风险：
   - LOW：删除重复修饰。
   - MEDIUM：压缩过程但保留结论和约束。
   - HIGH：可能改变规则、模型约束、决策或任务意图。

HIGH 风险项必须获得用户确认。

## Phase 2：PLAN

对每个候选说明：

- 文件与条目。
- 压缩方式。
- 必须保留的信息。
- 风险级别。

## Phase 3：COMPRESS

使用精准替换。优先结构：

- 模型：分类 / 范围 / 不变量 / 证据 / 状态。
- 决策：选择 / 原因 / 替代 / 影响 / 状态。
- 知识：结论 / 证据 / 范围 / 边界。
- 改进：问题 / 证据 / 影响 / 建议 / 状态。
- 任务：目标 / 验收 / 阻塞。
- Milestone：成果 / 工作量 / 稳定基线 / 验证边界 / 诊断边界 / 状态。
- 参考：类型 / 位置 / 日期或版本 / 用途 / 状态。

必须保留：

- `Mxx/Dxx/Kxx/Rxx/Ixx/MSxx/Txx` 和 Legacy ID。
- 路径、命令、版本、日期和阈值。
- 失败症状和根因。
- 约束、例外和风险。
- 未解决问题。

旧体系全量迁移开始后，旧来源文档和 migration carrier 不得压缩。分类迁移和旧文档完整归档交给 `openspec-init` 与 `openspec-archivist`。

Change Evidence 保存采集时的原始输出和审计上下文，不属于活跃文档压缩范围。不要压缩、改写或删除 `evidence/` 中的文件。

Runbook 和 Incident 保存已验证操作与事件历史，由 `openspec-experience-recorder` 精准更新。不要压缩或改写其正文。

## Phase 4：VERIFY

1. `git diff --check`
2. 检查编号仍可搜索。
3. 对比压缩前后行数。
4. 审查 diff，确认状态和意图未变。

## 禁止

- 删除完整条目。
- 移动内容到 archive。
- 合并不同编号的独立条目。
- 改变任务状态、模型约束、决策结论或规则含义。
- 删除 milestone 的工作量依据、稳定基线、验证边界或诊断边界。
- 为减少行数而删除未解决问题。
- 压缩迁移来源、覆盖清单或 migration carrier。
- 压缩或改写 change 内 Evidence。
- 压缩或改写 Runbook、Incident。
