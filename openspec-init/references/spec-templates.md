# 项目记忆模板

五个记忆文件使用扁平 markdown 台账。初始化后按项目事实填充，不创建占位条目。

## 目录

- Project Model
- Decisions
- Knowledge
- References
- Improvements
- 状态文档

## Project Model

路径：`.agents/memory/project-model.md`

记录当前有效的跨模块模型和约束，不记录历史选择过程。条目使用 `Mxx`。

分类：architecture、domain、quality、security、compatibility、runtime。

条目字段：分类、范围、不变量、证据、状态。

## Decisions

路径：`.agents/memory/decisions.md`

记录有替代方案且影响长期维护的选择。条目使用 `Dxx`。被替代后保留历史，标记 `superseded` 和替代编号。

条目字段：决定、原因、替代方案、影响、状态、关联模型。

## Knowledge

路径：`.agents/memory/knowledge.md`

记录已验证、非显然且可能复用的结论。条目使用 `Kxx`。

不记录单纯文件位置、可从签名读取的 API、未验证猜测或一次性实现细节。

条目字段：结论、证据、适用范围、边界。

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
