# 分析持久化格式

Explorer 生成候选条目。文档模式自动调用 `openspec-docs-maintainer` 去重、编号并写入 R 引用。A/L 候选仍需用户明确授权登记。

## 分析文档

```markdown
# 标题

> Project: <name>
> Branch: <branch>
> Date: YYYY-MM-DD
> See also: [关联文档](file.md)

## 结论

## 调用链或数据流

## 边界与失败路径

## 关键文件
```

## R 候选

```text
主题: <分析主题>
路径: .claude/analysis/<file>.md
概要: <文档覆盖内容>
```

Maintainer 写入格式：

```markdown
<!-- Rxx --> | <主题> | .claude/analysis/<file>.md | <概要> |
```

自动登记请求只能包含：

- 新建或实质更新的分析文档路径。
- 主题和概要。
- `references/spec.md` 这一目标。

不得携带 A/L/O、tasks、SNAPSHOT、change 或归档请求。

## L 候选

候选类型：

- API：名称、签名、路径、用途。
- 文件：名称、路径、用途。
- 踩坑：症状、根因、解决、预防。
- 技巧：适用条件、做法、限制。

## A 候选

只有以下内容进入候选：

- 模块间通信方式。
- 状态管理模式。
- 关键设计决策。
- 架构约束。

格式：

```text
标题:
决策:
原因:
影响:
替代:
证据:
```

实现细节和分析正文不重复写入 A/L/R。
