# Carrier 归档协议

## 目录

- 路径
- 执行顺序
- 内容要求
- 失败处理
- 恢复要求
- Migration carrier

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

Init 迁移载体使用 `MIG-YYYYMMDDhhmm`，目录结构与 ARC carrier 相同。ID 冲突时使用相同后缀规则。

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

- 原 M/D/K/R/I/MS/T 编号和 Legacy ID。
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

## Migration carrier

Init 旧体系全量迁移使用独立 migration carrier。其职责是保存可审计映射和旧经验文档完整原文，不是对旧内容再次取舍。

Proposal 除普通映射外必须包含：

- 全部经验来源路径和归档前 mtime。
- 按已有编号、可独立路由的同级标题或短文档整体建立的语义条目覆盖清单。
- 旧编号到新编号或路径的映射。
- 覆盖计数和未解决项；不保存正向、反向核对过程日志。
- `semantic entries = mapped entries = verified entries`。
- `unmapped = 0` 和 `skipped = 0`。
- 旧活动路径退出清单和恢复入口。

Carrier spec 必须逐文件保存活动经验源完整原文。不得摘要、改写、去重原文，也不得使用 Compress-Archive。旧内容即使重复、过时或已失效，也保留在载体中。

已经归档的 legacy carrier 不复制、不改写、不重复归档。覆盖清单记录其不可变路径，并按语义条目确认其中的信息已经进入新目标。

CLAUDE 和 SNAPSHOT 是可重建文档，不是经验源。MIG 载体不保存、映射或归档其旧内容。

执行顺序：

1. Init 枚举来源并保持活动经验源只读。
2. Init 按语义条目迁移并填写覆盖清单、编号映射和验证摘要。
3. 覆盖验证通过后创建 MIG 载体，保存历史 carrier 指针和每份活动经验源的一份原始全文。
4. Archivist 核对覆盖率、mtime、新目标和完整原文；mtime 变化时返回 Init 更新受影响映射。
5. 验证并归档 carrier。
6. 归档成功后移除旧体系活动路径。
7. 扫描旧路径、旧活动引用和新目标。

步骤 1-5 任一失败时保留全部旧活动文件。步骤 6 失败时报告剩余路径并继续完成退出，不重新迁移或删除载体。

Migration carrier 只允许 Archive。旧活动路径退出是完整原文已进入归档后的生命周期移动，不是 Delete。恢复时从 carrier 取回整份原文，或按覆盖清单把语义条目恢复到新目标。
