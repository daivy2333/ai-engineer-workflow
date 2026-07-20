# Carrier 归档协议

## 目录

- 路径
- 执行顺序
- 内容要求
- 失败处理
- 恢复要求

## 路径

每次清理创建独立 change：

```text
openspec/changes/ARC-YYYYMMDDhhmm/
├── proposal.md
├── specs/<source-domain>/spec.md
├── tasks.md
└── .openspec.yaml
```

ID 冲突时追加 `a`、`b`、`c`。

归档后路径由 OpenSpec 集成决定，常见形式为：

```text
openspec/archive/<date>-arc-.../
```

不要手工移动 change。

## 执行顺序

1. 记录源文档 mtime。
2. 验证现有 changes。
3. 生成 ARC ID。
4. 创建 proposal、specs、tasks 和元数据。
5. Archive 条目完整写入 carrier。
6. Compress-Archive 条目压缩写入，保留原编号。
7. 验证 carrier change。
8. 使用 OpenSpec 集成归档 carrier。
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

Carrier spec 保留：

- 原 M/D/K/R/I/T 编号和 Legacy ID。
- 旧 carrier 继续保留 A/L/R/O/T，不改写历史。
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
| carrier 验证失败 | 停止，不改源文档 |
| OpenSpec archive 失败 | 保留 change，源文档不变 |
| 源文档 mtime 改变 | 重新读取和分析 |
| 源文档编辑失败 | 停止，报告 carrier 已归档 |
| OpenSpec 不可用 | 停止，不静默降级 |

## 恢复要求

Maintainer 应能：

1. 从 arc 指引找到 proposal。
2. 从映射表找到原编号。
3. 从 carrier spec 读取条目。
4. 精准插回源位置。
5. 更新 arc 计数。
6. 追加 restored 标记。

因此不得删除 carrier 映射或原编号。
