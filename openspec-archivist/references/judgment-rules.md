# 生命周期判断规则

## 目录

- 动作定义
- 通用阈值
- 分文档规则
- 条目边界

## 动作定义

**Archive**

完整内容进入 carrier，源条目移除并留下 arc 指引。

适用于被替代、有历史价值或仍需恢复的条目。

**Compress-Archive**

压缩内容进入 carrier，源条目移除并留下 arc 指引。有关联引用、回滚价值或有效机制时改用 Archive。

**Keep**

用于活跃、未解决、当前有效或受保护内容。

**Delete**

只用于无引用、无历史价值的误录、空占位或长期未启动任务。

**Stale-Warn**

状态无法确认时标记：

```text
⚠️ STALE [YYYY-MM-DD] — 建议在 30 天内确认、更新或归档
```

**Promote**

当条目职责改变时迁移到目标类型：

- K 成为强制约束时，候选提升到 M 或 CLAUDE。
- I 获准实施时，提升为 change，并标记 `promoted`。

提升写入交给 Maintainer。原条目保留目标编号或路径。

**Merge**

两个以上条目内容重叠超过 60% 时，保留完整条目和各自独有信息。

**Artifact-Archive**

移动 Analysis、Runbook 或 Incident 到对应 `archive/` 子目录。保留 R 编号并更新路径和 `[ARCHIVED YYYY-MM-DD]` 状态，不进入 carrier。

## 通用阈值

| 条目 | 条件 | 默认动作 |
|---|---|---|
| 已完成任务 | 超过 30 天 | Archive |
| 未启动任务 | 超过 90 天且无引用 | Delete |
| 待办任务 | 30-90 天无活动 | Stale-Warn |
| 失效参考 | 已确认不可访问或不再使用 | Archive |
| 孤立 Analysis | 超过 180 天 | Artifact-Archive |
| 过时 Runbook | 依赖的系统或命令已失效 | Artifact-Archive |
| 已解决 Incident | 无活跃后续动作且必要关联已记录 | Artifact-Archive |

时间结论需要 Git 历史或文档日期支持，不能只按当前日期推断。

## Init 全量迁移例外

旧体系迁移不使用价值、时效、重复度、引用数或相关性阈值决定去留。

- 每个来源信息单元必须进入一个或多个新目标。
- 重复内容可以在新目标合并，但每个来源映射都保留。
- 过时或失效内容仍要迁移，并保留状态和时间边界。
- 无法分类时停止并返回 Init，不得改判 Delete、Keep 或跳过。
- 100% 映射并验证后，旧经验文档整份进入 migration carrier。
- 旧经验文档只允许 Archive，不允许 Compress-Archive 或 Delete。
- CLAUDE 和 SNAPSHOT 按新体系重建，不参与迁移判断或归档。

这项例外只适用于 Init 的旧体系升级，不改变日常生命周期清理规则。

## 分文档规则

**tasks**

- `planned`、`ready`、`active` 和 `blocked` milestone：Keep。
- 已完成 milestone：按时间和引用判断 Keep 或 Archive。
- 被替代 milestone：保留替代编号；按引用判断 Keep 或 Archive。
- 进行中和阻塞项：Keep。
- 近期完成：Keep。
- 长期完成：Archive。
- 长期未启动且无引用：Delete。
- 未批准想法：迁移到 I 或删除误录。

**project-model**

- 当前有效约束：Keep。
- 已失效且有历史价值：Archive。
- 与当前代码冲突但无法判定：Stale-Warn。
- 选择原因混入 M：迁移到 D。

**decisions**

- accepted：Keep。
- superseded：保留替代编号；按引用决定 Keep 或 Archive。
- 疑似被替代但无明确关系：Stale-Warn。
- 当前约束正文重复：保留 D 原因，M 保存现行约束。

**knowledge**

- 已验证且仍适用：Keep。
- 失效但可能再次遇到：Archive。
- 单纯路径、签名或链接：迁移到 R。
- 强制约束：Promote 到 M 或 CLAUDE。

**references**

- 有效且仍使用：Keep。
- 失效链接：Archive，并标记 `[DEAD]`。
- 重复索引：Merge。
- 目标文件已移动：先更新路径。
- 目标正文复制进 R：压缩为检索元数据。

**improvements**

- 未承诺且仍相关：Keep。
- 已批准：Promote 为 change，I 标记 `promoted`。
- change 已归档：Archive。
- 无证据或无法判断：Stale-Warn。

**Runbook**

- 仍可执行且验证有效：Keep。
- 命令或环境疑似过时：Stale-Warn。
- 被新版替代：Artifact-Archive，并更新 R。

**Incident**

- 后续动作仍活跃：Keep。
- 已解决但必要关联尚未记录：Keep。
- 已解决且结论、决策、动作或 Runbook 已有目标引用：Artifact-Archive。

Incident 的 M/D/K/I 或 Runbook 候选由 `openspec-experience-recorder` 在创建或更新时列出。Archivist 只检查引用是否存在，不在清理阶段总结事件经验。

**SNAPSHOT**

- 当前项目描述：Keep。
- `stale` 状态：保留并交给 Maintainer 刷新。
- 工作状态、操作流程、约束、原因或历史记录：移出 SNAPSHOT 后按对应类型判断。

**CLAUDE.md**

永不自动修改。只能报告 `SUGGEST-REVIEW` 或 `SUGGEST-MERGE`。

**OpenSpec changes**

- 活跃：Keep。
- 完成：建议使用 OpenSpec 集成归档。
- 超过 90 天无活动：提交用户判定。
- 空 change：提交用户判定。
- change 内 Evidence 随 change 处理，不单独判断、登记 R 或 Artifact-Archive。

## 条目边界

- 编号注释到下一个同类编号，包括 `MSxx`。
- 同级条目标题到下一个同级标题。
- 表格中每个数据行为独立条目。
- checkbox 每行为独立任务。
- 没有编号的旧条目在写入前分配编号。
- 迁移条目的 Legacy ID 属于对应新条目。
