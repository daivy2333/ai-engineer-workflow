# OpenSpec spec 模板

记忆域使用 OpenSpec 支持的 Requirement 和 Scenario 结构。行为语料库按产品域组织，由 maintainer 在 change 收尾时合并增量规格。初始化后按项目事实填充，不创建占位条目。

## 目录

- Project Model
- References
- Improvements
- 行为语料库
- 状态文档

## Project Model

路径：`openspec/specs/project-model/spec.md`

记录当前有效的开发约束：代码结构和贡献者必须遵守的跨模块规则，不是产品行为描述。条目使用 `Mxx`。

分类可以是：

- architecture
- domain
- quality
- security
- compatibility
- runtime

```markdown
## Purpose

记录当前有效的项目模型、边界和跨模块约束。

## Requirements

### Requirement: 项目模型可验证

长期有效的跨模块约束 SHALL 记录范围、不变量、证据和状态。

#### Scenario: 确认稳定约束

- **WHEN** 已验证某项约束会影响多个模块或后续变更
- **THEN** 使用递增 M 编号记录分类、范围、不变量、证据和状态
```

## References

路径：`openspec/specs/references/spec.md`

只记录检索元数据，不复制目标正文。条目使用 `Rxx`。

Change Evidence 位于所属 change 内，由 change 提供索引和归档入口，不登记 R。

类型可以是：

- analysis
- external-doc
- dependency
- schema
- benchmark
- runbook
- issue

```markdown
## Purpose

索引项目依赖的内部产物和外部资料。

## Requirements

### Requirement: 参考可定位

参考 SHALL 记录类型、路径或 URL、版本或日期、用途和状态。

#### Scenario: 登记持久化产物

- **WHEN** 新分析、Runbook 或 Issue 需要跨会话复用
- **THEN** 使用递增 R 编号登记检索元数据
```

## Improvements

路径：`openspec/specs/improvements/spec.md`

记录有证据但尚未承诺实施的问题。条目使用 `Ixx`。

分类可以是性能、可维护性、安全、可靠性、开发体验、技术债、文档或测试。

```markdown
## Purpose

记录尚未承诺实施的改进机会。

## Requirements

### Requirement: 改进项可评估

改进项 SHALL 包含分类、问题、证据、影响、建议和状态。

#### Scenario: 发现未排期问题

- **WHEN** 已有证据表明存在改进机会但尚未批准实施
- **THEN** 使用递增 I 编号记录

#### Scenario: 批准实施

- **WHEN** 用户批准实施改进项
- **THEN** 创建 OpenSpec change 并把原条目标记 promoted
```

## 行为语料库

路径：`openspec/specs/<domain>/spec.md`

记录已验收的系统当前行为，是行为权威描述。域按产品结构划分，与 project-model、references、improvements 三个记忆域共存于 `openspec/specs/`；行为域由 maintainer 在 change 收尾时合并增量规格创建和更新，不手工撰写，首次合并前不创建域文件。

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

计划外的已验证行为事实作为 spec 候选，随下一个相关 change 进入语料库；无法表达为行为要求的事实写 analysis，可重复操作写 Runbook，缺陷写 Issue。

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
- 与 OpenSpec changes 的同步规则。

Milestone 与 change 数量不绑定。路线规划由 `openspec-milestone-planner` 负责，运行状态由 `openspec-docs-maintainer` 按用户指令同步。

未批准的想法不进入 tasks。CLAUDE 不记录项目事实。
