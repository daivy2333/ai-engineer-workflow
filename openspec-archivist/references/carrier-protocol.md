# Carrier 归档协议

## 目录

- 路径
- 执行顺序
- 内容要求
- 失败处理
- 恢复要求

## 路径

每次清理创建独立 change 目录：

```text
.agents/changes/ARC-YYYYMMDDhhmm/
├── proposal.md
└── entries/<source-domain>.md
```

ID 冲突时追加 `a`、`b`、`c`。

归档位置：

```text
.agents/archive/changes/<date>-arc-.../
```

归档动作是 `git mv`。执行顺序的步骤 8 完成前不得移动任何源文档。

## 执行顺序

1. 记录源文档 mtime。
2. 预检目标条目的活动状态和交叉引用。
3. 生成 ARC ID。
4. 创建 proposal 和 entries 文件。
5. Archive 条目完整写入 entries。
6. Compress-Archive 条目压缩写入，保留原编号。
7. 验证 carrier 内容与源文档一致。
8. 用 `git mv` 把 carrier change 移入 `.agents/archive/changes/`。
9. 再次检查源文档 mtime。
10. 精准移除源条目。
11. 在源文档追加 arc 指引。

步骤 2-8 任一失败时，不修改源文档。

## 内容要求

Proposal 映射表至少包含：

- 原编号。
- 源文档。
- 动作。
- 归档位置。
- 判断理由。
- 交叉引用。
- 恢复条件。
- 本次明确排除的条目。

entries/<source-domain>.md 保留：

- 原 `M/R/I/MS/T` 编号。
- Archive 的完整内容。
- Compress-Archive 的关键事实、状态和替代方案。

压缩副本最多 3 行；无法完整保留时升级为 Archive。

源文档指引：

```markdown
<!-- arc: ARC-YYYYMMDDhhmm --> N 条已归档 (YYYY-MM-DD) → <proposal-relative-path>
```

该 arc 指引是源文档的规范墓碑。逐条编号和恢复位置保存在 proposal 映射表中，不再为同一批次复制一组冗长墓碑。

## 失败处理

| 失败点 | 处理 |
|---|---|
| 预检失败 | 停止，不创建归档 |
| carrier 内容验证失败 | 停止，不移动、不改源文档 |
| git mv 失败 | 保留 carrier 于 `.agents/changes/`，源文档不变 |
| 源文档 mtime 改变 | 重新读取和分析 |
| 源文档编辑失败 | 停止，报告 carrier 已归档 |

## 恢复要求

Maintainer 应能：

1. 从 arc 指引找到 proposal。
2. 从映射表找到原编号。
3. 从 entries 文件读取条目。
4. 精准插回源位置。
5. 更新 arc 计数。
6. 追加 restored 标记。

因此不得删除 proposal 映射或原编号。
