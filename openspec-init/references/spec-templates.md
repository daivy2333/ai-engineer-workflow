# OpenSpec spec 模板

所有 spec 使用当前 OpenSpec 支持的 Requirement 和 Scenario 结构。初始化后按项目事实填充，不创建占位条目。

## 目录

- Project Model
- Decisions
- Knowledge
- References
- Improvements
- 状态文档

## Project Model

路径：`openspec/specs/project-model/spec.md`

记录当前有效的跨模块模型和约束，不记录历史选择过程。条目使用 `Mxx`。

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

## Decisions

路径：`openspec/specs/decisions/spec.md`

记录有替代方案且影响长期维护的选择。条目使用 `Dxx`，被替代后保留历史。

```markdown
## Purpose

记录重要选择的原因、替代方案、影响和状态。

## Requirements

### Requirement: 决策可追溯

重要选择 SHALL 记录决定、原因、替代方案、影响、状态和关联模型。

#### Scenario: 接受长期选择

- **WHEN** 开发者确认跨模块、兼容性或长期设计选择
- **THEN** 使用递增 D 编号记录 accepted 决策

#### Scenario: 替代旧决策

- **WHEN** 新决策替代已有选择
- **THEN** 保留旧条目并标记 superseded 和替代编号
```

## Knowledge

路径：`openspec/specs/knowledge/spec.md`

记录已验证、非显然且可能复用的知识。条目使用 `Kxx`。

不要记录单纯文件位置、可从签名读取的 API、未验证猜测或一次性实现细节。

```markdown
## Purpose

记录已验证的行为、根因、适用范围和失效边界。

## Requirements

### Requirement: 项目知识可复用

项目知识 SHALL 包含结论、证据、适用范围和边界。

#### Scenario: 验证非显然知识

- **WHEN** 问题根因或行为规律已经验证且可能再次使用
- **THEN** 使用递增 K 编号记录结论、证据、范围和边界
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
- incident

```markdown
## Purpose

索引项目依赖的内部产物和外部资料。

## Requirements

### Requirement: 参考可定位

参考 SHALL 记录类型、路径或 URL、版本或日期、用途和状态。

#### Scenario: 登记持久化产物

- **WHEN** 新分析、Runbook 或 Incident 需要跨会话复用
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

## 状态文档

`SNAPSHOT.md` 记录：

- 项目名称和用途。
- 技术栈及版本。
- 构建、测试、格式化和静态分析命令。
- 当前分支和工作区状态。
- 源码、测试、文档等关键目录。
- 当前 change 和最新 iteration。
- 最近验证结果及日期。
- 已知环境约束。

`tasks.md` 记录：

- 进行中。
- 已承诺待办。
- 阻塞。
- 最近完成。
- 与 OpenSpec changes 的同步规则。

未批准的想法不进入 tasks。CLAUDE 不记录项目事实。
