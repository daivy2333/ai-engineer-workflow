---
name: openspec-compressor
description: 原地压缩 OpenSpec 活跃文档，在不移动、不归档、不删除有效信息、不改变规则或状态的前提下减少重复表达。用于精简 CLAUDE.md、SNAPSHOT、tasks、architecture、learned、references 或 optimization 文档。
---

# OpenSpec Compressor

只改变表达密度，不改变信息、状态、编号或生命周期。

## 边界

- `openspec-assistant`：只读查询。
- `openspec-docs-maintainer`：日常状态和知识写入。
- `openspec-explorer`：生成分析文档。
- `openspec-compressor`：原地压缩表达。
- `openspec-archivist`：归档、删除、移动和墓碑。

## Phase 1：SCAN

1. 读取用户指定文档；未指定时检查常见目标是否存在。
2. 记录压缩前行数。
3. 查找重复背景、同义句、过细过程和无事实过渡。
4. 标记风险：
   - LOW：删除重复修饰。
   - MEDIUM：压缩过程但保留结论和约束。
   - HIGH：可能改变规则、ADR 或任务意图。

HIGH 风险项必须获得用户确认。

## Phase 2：PLAN

对每个候选说明：

- 文件与条目。
- 压缩方式。
- 必须保留的信息。
- 风险级别。

## Phase 3：COMPRESS

使用精准替换。优先结构：

- 踩坑：症状 / 根因 / 解决 / 预防。
- ADR：决策 / 原因 / 影响 / 替代。
- 优化：问题 / 影响 / 建议 / 状态。
- 任务：目标 / 验收 / 阻塞。
- 参考：资源 / 用途 / 关键点。

必须保留：

- `Axx/Lxx/Rxx/Oxx/Txx` 编号。
- 路径、命令、版本、日期和阈值。
- 失败症状和根因。
- 约束、例外和风险。
- 未解决问题。

## Phase 4：VERIFY

1. `git diff --check`
2. 检查编号仍可搜索。
3. 对比压缩前后行数。
4. 审查 diff，确认状态和意图未变。

## 禁止

- 删除完整条目。
- 移动内容到 archive。
- 合并不同编号的独立条目。
- 改变任务状态、ADR 结论或规则含义。
- 为减少行数而删除未解决问题。
