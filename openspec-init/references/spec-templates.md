# OpenSpec spec 模板

所有 spec 使用当前 OpenSpec 支持的 Requirement 和 Scenario 结构。下面是最小模板，项目初始化后按实际事实填充。

## Architecture

```markdown
## Purpose

记录影响模块边界、通信、状态、兼容性和运行约束的架构决策。

## Requirements

### Requirement: 记录架构决策

重要决策 SHALL 记录决策、原因、影响和替代方案。

#### Scenario: 新决策

- **WHEN** 开发者做出跨模块或长期设计选择
- **THEN** 使用递增 A 编号记录 ADR
```

## Learned

```markdown
## Purpose

记录可复用的 API、文件位置、踩坑和技巧。

## Requirements

### Requirement: 记录已验证知识

项目知识 SHALL 带来源和适用边界。

#### Scenario: 解决复杂问题

- **WHEN** 问题根因和解决方式已经验证
- **THEN** 使用递增 L 编号记录症状、根因、解决和预防
```

## References

```markdown
## Purpose

记录依赖、外部资料和分析文档索引。

## Requirements

### Requirement: 参考可追溯

外部依赖和分析文档 SHALL 有路径、版本或链接。

#### Scenario: 登记分析文档

- **WHEN** explorer 生成 `.claude/analysis/` 文档
- **THEN** maintainer 使用递增 R 编号登记主题、路径和概要
```

## Optimization

```markdown
## Purpose

记录未解决的性能、复杂度和技术债问题。

## Requirements

### Requirement: 优化项可评估

优化项 SHALL 包含问题、影响、建议、优先级和状态。

#### Scenario: 发现优化项

- **WHEN** 已有证据表明存在可改进问题
- **THEN** maintainer 使用递增 O 编号记录
```

## 状态文档

`SNAPSHOT.md` 建议字段：

- 项目与技术栈。
- 当前分支。
- 关键目录。
- 当前 change。
- 最近验证状态。

`tasks.md` 建议区域：

- 进行中。
- 待办。
- 阻塞。
- 最近完成。
- 与 OpenSpec changes 的同步规则。
