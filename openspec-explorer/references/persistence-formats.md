# 分析持久化格式

Explorer 文档模式自动调用 `openspec-docs-maintainer` 登记 R。其他候选需要用户明确授权。

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
类型: analysis
主题: <分析主题>
路径: .claude/analysis/<file>.md
日期: YYYY-MM-DD
用途: <文档覆盖内容>
状态: active
```

自动登记请求只能包含分析文档路径、主题、日期、用途和 references 目标。不得携带 M/D/K/I、tasks、SNAPSHOT、change 或归档请求。

## 其他候选

| 类型 | 进入条件 | 必要字段 |
|---|---|---|
| M | 当前有效的跨模块约束 | 分类、范围、不变量、证据、状态 |
| D | 有替代方案的长期选择 | 决定、原因、替代、影响、状态 |
| K | 已验证、非显然且可复用 | 结论、证据、范围、边界 |
| I | 有证据但未承诺实施 | 分类、问题、证据、影响、建议 |

文件位置、API 签名和链接进入 R，不进入 K。详细调查过程保留在 analysis，不复制进 M/D/K/I。
