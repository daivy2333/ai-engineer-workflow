# 生命周期判断规则

## 目录

- 动作定义
- 通用阈值
- 分文档规则
- 条目边界

## 动作定义

### Archive

完整内容进入 carrier，源条目移除并留下 arc 指引。

适用：

- 过期但仍有历史或恢复价值。
- 已完成任务超过 30 天。
- 已完成优化。
- 被新 ADR 替代。
- 有活跃引用，必须保留完整内容。
- 核心机制仍可能再次遇到。

### Compress-Archive

压缩后的内容进入 carrier，源条目移除并留下 arc 指引。

适用：

- 次要且不太可能重现的问题。
- 已迁移 API。
- 已废弃命令。
- 超过 200 字但事实可在 3 行内完整保留。

有活跃引用、可能回滚或机制仍有效时升级为 Archive。

### Keep

活跃、未解决、当前有效或受保护内容。

### Delete

只用于无引用且没有历史价值的误录、空占位或长期未启动任务。

### Stale-Warn

状态不能确认但已经变旧。格式：

```text
⚠️ STALE [YYYY-MM-DD] — 建议在 30 天内确认、更新或归档
```

### Promote

learned 中同一稳定模式出现至少 2 次时，候选提升到规则或 ADR。提升写入交给 maintainer，原条目保留提升标记。

### Merge

两个以上条目内容重叠超过 60% 时，保留完整条目和独有信息。

### Analysis-Archive

移动 `.claude/analysis/` 文件到 `.claude/analysis/archive/`，保留 R 编号并更新路径和 `[ARCHIVED YYYY-MM-DD]` 标记。不进入 carrier。

## 通用阈值

| 条目 | 条件 | 默认动作 |
|---|---|---|
| API 无引用 | >90 天 | Archive |
| API 未确认 | 30-90 天 | Stale-Warn |
| 构建命令无引用 | >30 天 | Archive |
| 踩坑不可确认 | >180 天 | Archive |
| 已完成任务 | >30 天 | Archive |
| 未启动任务 | >90 天 | Delete，需无引用 |
| 待办任务 | 30-90 天 | Stale-Warn |
| 分析文档孤立 | >180 天 | Analysis-Archive |

时间结论需要 Git 历史或文档日期支持，不能只按当前日期猜测。

## 分文档规则

### tasks

- `进行中`：永不归档。
- `阻塞项`：Keep，除非用户明确处理。
- 近期完成：Keep。
- 长期完成：Archive。
- 长期未启动且无引用：Delete。

### architecture

- 当前有效 ADR：Keep。
- 被新 ADR 明确替代：Archive，并记录替代编号。
- 疑似被替代但无明确关系：Stale-Warn。

### learned

- 活跃 API、文件和技巧：Keep。
- 重复稳定技巧：Promote 候选。
- 旧 API 或命令：Archive 或 Compress-Archive。
- 症状和机制仍可能重现：Archive。

### references

- 有效且仍使用：Keep。
- 失效链接：Archive，并标记 `[DEAD]`。
- 重复依赖：Merge。
- 不再使用的依赖：Archive。

### optimization

- 未解决且相关：Keep。
- 已完成：Archive。
- 已完成且冗长：Compress-Archive。
- 无法判断：Stale-Warn。

### SNAPSHOT

- 当前状态：Keep。
- 超过 30 天的历史修改：Archive。
- 疑似过时的关键文件表：Stale-Warn。

### CLAUDE.md

永不自动修改。只能报告：

- `SUGGEST-REVIEW`
- `SUGGEST-MERGE`

### OpenSpec changes

- 活跃：Keep。
- 完成：建议使用 OpenSpec 集成归档。
- 超过 90 天无活动：提交用户判定。
- 空 change：提交用户判定。

## 条目边界

- 编号注释到下一个同类编号。
- H3 ADR 或踩坑标题到下一个同级标题。
- 表格中每个数据行为独立条目。
- checkbox 每行为独立任务。
- 没有编号的旧条目在执行写入前分配编号。
