# 分析持久化格式

Explorer 文档模式自动调用 `openspec-docs-maintainer` 登记 R。其他候选需要用户明确授权。

## 分析文档

```markdown
# 标题

> Snapshot: [SNAPSHOT](../docs/SNAPSHOT.md)
> Captured revision: <revision>
> Observed branch: <branch>
> Captured at: YYYY-MM-DD
> See also: [关联文档](file.md)

## 目标与范围

## 已确认事实、推断与未确认项

## 调用链或数据流

## 边界与失败路径

## 测试、验证入口与影响面

## 关键文件
```

## R 候选

```text
类型: analysis
主题: <分析主题>
路径: .agents/analysis/<file>.md
日期: YYYY-MM-DD
用途: <文档覆盖内容>
状态: active
```

自动登记请求只能包含分析文档路径、主题、日期、用途和 references 目标。不得携带 M/I、tasks、SNAPSHOT、change 或归档请求。

## 其他候选

| 类型 | 进入条件 | 必要字段 |
|---|---|---|
| M | 当前有效的开发约束 | 分类、范围、不变量、证据、状态 |
| I | 有证据但未承诺实施 | 分类、问题、证据、影响、建议 |

文件位置、API 签名和链接进入 R。详细调查过程和已验证结论保留在 analysis，不复制进 M/I；能表达为行为要求的事实作为 spec 候选随下一个 change 进入语料库。
