---
name: openspec-compressor
description: 'OpenSpec 文档压缩器 - 原地压缩 CLAUDE.md、openspec/specs/learned/spec.md、references/spec.md、optimization/spec.md、architecture/spec.md、.claude/docs/SNAPSHOT.md、tasks.md 等易膨胀 Markdown 文档，在不移动、不归档、不删除有效信息的前提下提升信息密度。TRIGGER when: 用户说"压缩文档"、"精简文档"、"瘦身文档"、"压缩 learned"、"精简 references"、"压缩 SNAPSHOT"、"压缩 tasks"、"文档太长但不要归档"、"保持信息量减少篇幅"。'
---

# OpenSpec Compressor — 文档压缩器

原地压缩 OpenSpec 文档体系。目标是减少篇幅，不改变文档位置、条目归属和生命周期状态。

此 skill 不负责归档。涉及移动、删除、墓碑、carrier spec、`openspec archive` 或恢复协议时，使用 `openspec-archivist`。

## 边界

### 负责

- 原地压缩冗长段落、重复解释、过细过程。
- 合并同一条目内部的重复表达。
- 保留编号标记，如 `<!-- L03 -->`、`<!-- R04 -->`、`<!-- A02 -->`。
- 保留事实、路径、命令、版本、日期、原因、后果、边界条件。
- 输出压缩报告，说明改了哪些文档和压缩策略。

### 不负责

- 不移动文件。
- 不归档条目。
- 不删除仍有信息价值的条目。
- 不创建 `openspec/changes/ARC-*`。
- 不运行 `openspec archive`。
- 不改写规则意图。
- 不把多个独立条目合成一个新条目，除非用户明确要求。

## 目标文档

| 文档 | 压缩重点 |
|------|----------|
| `openspec/specs/learned/spec.md` | 踩坑档案、技巧模式、重复 API 说明 |
| `openspec/specs/references/spec.md` | 冗长摘要、重复链接说明、过期背景描述 |
| `openspec/specs/optimization/spec.md` | 优化讨论过程、已明确的方案描述 |
| `openspec/specs/architecture/spec.md` | ADR 中重复背景、替代方案冗述 |
| `.claude/docs/SNAPSHOT.md` | 历史修改、结构说明、状态重复 |
| `.claude/docs/tasks.md` | 任务描述冗长、重复验收描述 |
| `CLAUDE.md` | 仅在用户明确指定时压缩，且不得改变规则含义 |

## 工作流

### Phase 1: SCAN

1. 读取用户指定文档；未指定时扫描上述目标文档是否存在。
2. 用 `wc -l` 获取行数。
3. 用 `rg -n` 查找高膨胀信号：
   - 段落超过 5 句。
   - 单条踩坑、优化、ADR 超过 200 字。
   - 重复出现的背景说明。
   - 不增加事实的信息。
4. 生成候选清单，标注风险：
   - LOW：删重复修饰、合并同义句。
   - MEDIUM：压缩过程描述但保留结论。
   - HIGH：可能影响规则、ADR、任务意图。

### Phase 2: PLAN

按文档给出压缩计划。计划必须说明：

- 文件路径。
- 候选条目或章节。
- 预计压缩方式。
- 信息保留点。
- 风险级别。

HIGH 风险项必须等用户确认。LOW/MEDIUM 可在用户要求自动压缩时直接执行。

### Phase 3: COMPRESS

使用精准替换编辑文件。禁止全量覆盖。

压缩规则：

- 表格行优先保留，少写段落。
- 长踩坑压成：症状 / 根因 / 解决 / 预防。
- 长 ADR 压成：决策 / 原因 / 影响 / 替代。
- 长任务压成：目标 / 验收 / 阻塞。
- 长参考压成：资源 / 用途 / 关键点。
- 删除空泛过渡句。
- 合并同一条目内部的重复句。

不得删除：

- 编号标记。
- 命令和关键输出。
- API 路径、文件路径、版本号。
- 时间、阈值、状态。
- 失败症状和根因。
- 约束、例外、风险。
- 仍未解决的问题。

### Phase 4: VERIFY

压缩后必须验证：

1. `git diff --check`
2. `rg "<!-- [A-Z][0-9]+" <被改文件>` 确认编号标记仍可搜索。
3. 对每个被改文件运行 `wc -l` 对比压缩前后行数。
4. 人工复核 diff，确认没有改变条目状态和规则意图。

最终报告包含：

- 修改文件。
- 行数变化。
- 保留的关键信息类型。
- 未压缩的高风险项及原因。

## 压缩模板

### 踩坑档案

```markdown
<!-- Lxx --> ### [标题]
- 症状：...
- 根因：...
- 解决：...
- 预防：...
```

### ADR

```markdown
<!-- Axx --> ### YYYY-MM-DD - 标题
- 决策：...
- 原因：...
- 影响：...
- 替代：...
```

### 优化点

```markdown
<!-- Oxx --> - 问题：...；影响：...；建议：...；状态：...
```

### 任务

```markdown
<!-- Txx --> - [ ] 目标：...；验收：...；阻塞：...
```

## 与其他 skill 的关系

| Skill | 分工 |
|-------|------|
| `openspec-assistant` | 日常增量记录，尽量写准写短 |
| `openspec-compressor` | 原地压缩，保留信息量 |
| `openspec-archivist` | 归档、删除、移动、墓碑、恢复 |
| `openspec-explorer` | 生成分析文档和反哺知识 |

## Red Flags

```
❌ 删除条目而不是压缩 → 应转交 archivist 或请求用户确认
❌ 移动内容到 archive → 越界
❌ 改变任务状态、ADR 结论、规则含义 → 信息损坏
❌ 删除编号标记 → grep 定位失效
❌ 压缩后只剩结论，丢失症状/根因/约束 → 信息量下降
❌ 使用 Write 全量覆盖已有文档 → 内容丢失风险
❌ 为追求行数减少删除未解决问题 → 需求损坏
```
