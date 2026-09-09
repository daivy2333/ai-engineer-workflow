# 项目记忆与行为语料库模板

记忆文件使用扁平 markdown 台账。行为语料库按域组织，由 maintainer 在 change 收尾时合并增量规格。初始化后按项目事实填充，不创建占位条目。

## 目录

- Project Model
- References
- Improvements
- 行为语料库
- 状态文档

## Project Model

路径：`.agents/memory/project-model.md`

记录当前有效的开发约束：代码结构和贡献者必须遵守的跨模块规则，不是产品行为描述。条目使用 `Mxx`。

分类：architecture、domain、quality、security、compatibility、runtime。

条目字段：分类、范围、不变量、证据、状态。

## References

路径：`.agents/memory/references.md`

只记录检索元数据，不复制目标正文。条目使用 `Rxx`。

类型：analysis、external-doc、dependency、schema、benchmark、runbook、incident。

条目字段：类型、路径或 URL、版本或日期、用途、状态。

Change Evidence 位于所属 change 内，随 change 归档，不登记 R。

## Improvements

路径：`.agents/memory/improvements.md`

记录有证据但尚未承诺实施的问题。条目使用 `Ixx`。

分类：性能、可维护性、安全、可靠性、开发体验、技术债、文档、测试。

条目字段：分类、问题、证据、影响、建议、状态。批准实施时创建 change，并把原条目标记 `promoted`。

## 行为语料库

路径：`.agents/specs/<domain>.md`

记录已验收的系统当前行为，是行为权威描述。域按产品结构划分；域文件由 maintainer 在 change 收尾时创建和更新，不手工撰写，首次合并前不创建文件。

条目使用 Requirement 和 Scenario 结构：

```markdown
### Requirement: <可验证行为>

<系统 SHALL ...>

#### Scenario: <场景名>

- **WHEN** <前置与触发>
- **THEN** <可观察结果>
```

合并规则：

- ADDED Requirements 追加到对应域文件，域文件不存在时创建。
- MODIFIED Requirements 替换同名 Requirement；被替换的历史保留在归档 change 中。
- REMOVED Requirements 从域文件删除。
- 合并冲突（同名不同义、增量与域文件矛盾）时停止并请求用户决定。
- archivist 归档的异常 change 不合并。

计划外的已验证行为事实作为 spec 候选，随下一个相关 change 进入语料库；无法表达为行为要求的事实写 analysis，可重复操作写 Runbook，故障事件写 Incident。

## 状态文档

`SNAPSHOT.md` 记录：

- 项目名称、用途和范围。
- 技术栈及版本。
- 主要模块、组件和职责边界。
- 源码、测试、文档等关键目录。
- 支持的平台和交付形态。
- 当前分支和工作区状态。
- 同步 revision、时间和状态。
- 其他权威文档的链接，不复制其摘要。

SNAPSHOT 只描述项目现在是什么。工作状态、操作流程、约束、原因和历史记录由对应文档保存。

同步状态使用 `current` 或 `stale`。`stale` 必须记录刷新失败原因，不得沿用旧值并声称同步成功。

`tasks.md` 记录：

- milestone roadmap，使用 `MSxx`。
- 每个 milestone 的成果、工作量、稳定基线、验证边界、诊断边界和依赖。
- 进行中。
- 已承诺待办。
- 阻塞。
- 最近完成。
- 与 change 的同步规则。

Milestone 与 change 数量不绑定。路线规划由 `openspec-milestone-planner` 负责，运行状态由 `openspec-docs-maintainer` 按用户指令同步。

未批准的想法不进入 tasks。AGENTS.md 不记录项目事实。
