# 旧文档迁移

迁移采用分类和映射，不把旧文件整体改名。

## 路径映射

| 旧来源 | 新目标 |
|---|---|
| `.claude/docs/architecture.md` | project-model 或 decisions |
| `openspec/specs/architecture/spec.md` | project-model 或 decisions |
| `.claude/docs/learned.md` | knowledge、references、runbooks 或 incidents |
| `openspec/specs/learned/spec.md` | knowledge、references、runbooks 或 incidents |
| `.claude/docs/references.md` | `openspec/specs/references/spec.md` |
| `.claude/docs/optimization.md` | `openspec/specs/improvements/spec.md` |
| `openspec/specs/optimization/spec.md` | `openspec/specs/improvements/spec.md` |
| `.claude/docs/rules.md` | `CLAUDE.md` |
| SNAPSHOT、tasks | 保留 |

## 内容分类

- 当前仍有效的跨模块约束进入 project-model。
- 有替代方案和选择原因的记录进入 decisions。
- 已验证、非显然且可复用的结论进入 knowledge。
- 文件位置、链接和外部资料进入 references。
- 可重复或高风险操作进入 runbooks。
- 重要故障的事件过程进入 incidents。
- 有证据但未承诺实施的问题进入 improvements。
- 已承诺工作进入 tasks 或 OpenSpec change。

## 编号迁移

新活动编号为 `Mxx/Dxx/Kxx/Rxx/Ixx/Txx`。

- 旧 `Axx` 按内容迁移为 M 或 D。
- 旧 `Lxx` 按内容迁移为 K、R、Runbook 或 Incident。
- 旧 `Rxx` 保留编号。
- 旧 `Oxx` 迁移为 I。
- 每个改号条目保留 `Legacy ID`。
- 生成旧编号、新编号和新路径映射。
- 更新活跃交叉引用。
- 不改写已归档 carrier；恢复时按映射还原到新目标。

## 执行顺序

1. 读取全部旧文档和活跃引用。
2. 创建五个新 spec。
3. 逐条分类，搜索重复和冲突。
4. 迁移规则到 CLAUDE。
5. 迁移项目事实和命令到 SNAPSHOT。
6. 迁移已承诺工作到 tasks 或 change。
7. 写入新条目和 Legacy ID。
8. 创建必要的 Runbook 或 Incident，并登记 R。
9. 更新活跃引用和编号映射。
10. 生成 change iteration 模板。
11. 验证全部 OpenSpec specs。
12. 展示旧文件处理建议，等待用户确认。

用户确认前不删除或归档旧文件。迁移完成后不同时维护旧、新两套活动记录。
