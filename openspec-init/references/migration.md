# 旧文档迁移

## 映射

| 旧路径 | 新路径 |
|---|---|
| `.claude/docs/architecture.md` | `openspec/specs/architecture/spec.md` |
| `.claude/docs/learned.md` | `openspec/specs/learned/spec.md` |
| `.claude/docs/references.md` | `openspec/specs/references/spec.md` |
| `.claude/docs/optimization.md` | `openspec/specs/optimization/spec.md` |
| `.claude/docs/rules.md` | 合并到 `CLAUDE.md` |
| `.claude/docs/SNAPSHOT.md` | 保留 |
| `.claude/docs/tasks.md` | 保留 |

## 步骤

1. 读取全部旧文档。
2. 搜索重复和冲突。
3. 将规则合并到唯一 `CLAUDE.md`。
4. 将 CLAUDE 中的项目名称、技术栈、命令和现状迁移到 SNAPSHOT。
5. 将当前任务和阻塞项迁移到 tasks。
6. 将知识按 A/L/R/O 分类并保留来源。
7. 生成 `.claude/docs/templates/change-iteration.md`。
8. 保留 SNAPSHOT 和 tasks 的有效历史。
9. 验证 OpenSpec specs。
10. 旧文件的删除或归档必须由用户确认。

不要同时维护旧、新两套规则。
