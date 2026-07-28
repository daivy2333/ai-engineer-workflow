# 旧文档全量迁移

迁移必须覆盖旧体系中的全部信息。分类只决定新位置，不决定是否迁移。

## 路径映射

| 旧来源 | 新目标 |
|---|---|
| `.claude/docs/architecture.md` | project-model 和 decisions |
| `openspec/specs/architecture/spec.md` | project-model 和 decisions |
| `.claude/docs/learned.md` | knowledge、references、runbooks、incidents 或其他匹配类型 |
| `openspec/specs/learned/spec.md` | knowledge、references、runbooks、incidents 或其他匹配类型 |
| `.claude/docs/references.md` | references |
| `openspec/specs/references/spec.md` | 新 references，R 编号保持不变 |
| `.claude/docs/optimization.md` | improvements |
| `openspec/specs/optimization/spec.md` | improvements |
| `.claude/docs/rules.md` | CLAUDE |
| 旧 tasks | milestone roadmap、新 tasks、change 或其他匹配类型 |
| 已归档的旧 carrier | 按内容进入全部匹配类型，历史 carrier 保持不变 |

表中路径是常见来源，不是迁移白名单。还要沿旧文档地图、活动引用、归档指引和历史 carrier 枚举其他旧体系文档。表中目标也不是限制；一个来源单元包含多类信息时，拆分到多个目标。

`CLAUDE.md` 和 SNAPSHOT 是可重建文档，不属于经验迁移来源：

- `CLAUDE.md` 按新模板覆盖，旧内容不逐条迁移或归档。
- SNAPSHOT 按迁移后的代码、配置和活动状态重建。
- 两者不进入覆盖清单、MIG 原文副本和恢复范围。

## 全量约束

- 读取每份经验来源全文。
- 除 CLAUDE 和 SNAPSHOT 外，活动旧文档和已归档 legacy carrier 都纳入来源清单。
- 把所有正文拆成可追溯信息单元。
- 每个单元至少有一个新目标。
- 不按价值、时效、重复度或主观相关性筛选。
- 不允许 `skip`、`drop`、`ignore` 或未分类单元。
- 重复单元可以合并到同一目标，但每个来源都要登记映射。
- 合并时保留各来源的独有事实、边界、原因和状态。
- 已过时信息仍要迁移，并在新目标标记状态或时间边界。
- 无法分类时停止迁移，请求用户定义目标；不得自行丢弃。

标题、段落、列表、表格行、编号条目、注释和代码块都属于覆盖范围。纯格式字符可以随所属单元迁移，不单独建立条目。

## 信息分类

- 当前事实进入 SNAPSHOT。
- 项目路线和阶段基线进入 milestone roadmap。
- 已承诺工作进入 tasks 或 change。
- 跨模块约束进入 project-model。
- 选择、原因和替代方案进入 decisions。
- 已验证结论进入 knowledge。
- 路径、链接和检索元数据进入 references。
- 未承诺问题进入 improvements。
- 可重复或高风险操作进入 runbooks。
- 故障事件过程进入 incidents。
- 执行规范进入 CLAUDE。
- 详细调查过程进入 analysis。

分类不改变原信息的含义。一个单元可以拆分，但拆分后的目标合计必须保留原信息。

## 覆盖清单

迁移前创建逐条清单：

| Source | Source Unit | Hash | Target Type | Target ID/Path | Status |
|---|---|---|---|---|---|
| `<path>` | `<heading/id/row>` | `<hash>` | `M/D/K/R/I/...` | `<id/path>` | `mapped` |

规则：

- `Source Unit` 能定位原始内容。
- `Hash` 用于确认迁移期间来源未变化。
- 拆分到多个目标时使用多行。
- 多个来源合并时保留多条来源行。
- 完成状态只有 `mapped` 和 `verified`。
- 清单不得出现空目标或跳过状态。

迁移验证需要同时满足：

```text
source units = mapped source units
mapped source units = verified source units
unmapped = 0
skipped = 0
```

## 编号迁移

新活动编号为 `Mxx/Dxx/Kxx/Rxx/Ixx/MSxx/Txx`。

- 旧 `Axx` 按内容拆分为 M、D 或其他匹配类型。
- 旧 `Lxx` 按内容拆分为 K、R、Runbook、Incident 或其他匹配类型。
- 旧 `Rxx` 保留编号。
- 旧 `Oxx` 迁移为 I；已完成也迁移并标记状态。
- 每个改号条目保留 `Legacy ID`。
- 生成旧编号、新编号和新路径映射。
- 更新所有活动交叉引用。
- 已归档 carrier 不改写；恢复时使用映射进入新目标。
- 已归档 legacy carrier 的内容仍逐条迁移；只是不修改或重复归档历史 carrier。

## 执行顺序

1. 沿旧文档地图、活动引用、归档指引和历史 carrier 枚举全部旧体系来源。
2. 记录来源文件 hash 和工作区状态。
3. 在修改任何经验来源或目标前创建 MIG 工作载体，写入每份活动经验源完整原文、hash 和历史 carrier 指针。
4. 拆分全部信息单元并生成覆盖清单。
5. 创建五个新 spec 和必要的持久化产物。
6. 逐条迁移，保留 Legacy ID 和来源。
7. 更新 CLAUDE、SNAPSHOT、tasks、changes 和活动引用。
8. 对每个来源单元执行正向核对。
9. 从每个目标执行反向来源核对。
10. 运行全部 OpenSpec 和文档验证。
11. 确认覆盖率为 100%，且 unmapped、skipped 均为 0。
12. 把完整覆盖清单、编号映射和验证证据写入 MIG 载体。
13. 验证并归档 migration carrier。
14. carrier 归档成功后移除旧活动路径。
15. 再次扫描旧活动路径、旧引用和新文档完整性。

用户要求升级或迁移即授权步骤 3 和 12-14。此授权只覆盖迁移载体和旧经验文档的完整归档，不覆盖删除、压缩归档或其他清理。

## 归档与失败处理

- 旧经验文档只能使用完整 Archive，禁止 Delete 和 Compress-Archive。
- carrier 必须保存旧文件完整原文，不得只保存摘要。
- 已归档 legacy carrier 保持不可变，不重复归档；其全部信息单元仍须出现在覆盖清单和新目标中。
- 旧活动文件的移除表示已经归档，不表示删除内容。
- MIG 载体保存原文前不得改写任何经验来源或迁移目标。
- CLAUDE 和 SNAPSHOT 可按新体系覆盖，不等待旧内容映射或归档。
- carrier 归档前不移除任何旧活动文件。
- 来源 hash 变化时停止，重新生成受影响映射。
- 任一单元未映射或验证失败时停止，不归档经验来源。
- carrier 归档失败时保留全部旧活动文件。
- carrier 已归档但旧路径移除失败时，报告剩余路径并继续清理，不重做迁移。
- 最终报告必须给出覆盖清单、carrier 路径、旧活动路径扫描和恢复入口。
