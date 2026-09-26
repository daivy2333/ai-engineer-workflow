# Milestone Roadmap 格式

在 `.agents/docs/tasks.md` 中使用独立的 Milestone Roadmap。保留原有全局任务和 change 状态。

```markdown
## Milestone Roadmap

### MS01：<阶段成果>

- Status: planned | ready | active | blocked | completed | superseded
- Outcome: <完成后项目具备的结果>
- Rationale: <为何形成独立阶段>
- Dependencies: <MSxx 或 None>
- Scope: <包含的能力范围与工作类别>
- Non-goals: <推迟到其他阶段的内容>
- Stable baseline: <后续工作可依赖的状态>
- Related changes: <已有 change 或 None>
```

## 状态

- `planned`：路线已接受，前置条件尚未满足。
- `ready`：依赖已满足，可以选择后续工作。
- `active`：已有相关工作正在进行。
- `blocked`：阶段无法继续，原因已记录。
- `completed`：完成判据已有验证结果。
- `superseded`：被其他 milestone 替代，保留替代编号。

规划者创建和调整 `planned`、`ready`。Maintainer 按用户指令同步运行状态和关联 change。

## 编号和依赖

- 使用递增 `MSxx`，位数不足时继续扩展。
- 不复用已删除或归档编号。
- 依赖必须指向已有 milestone。
- 禁止循环依赖。
- 被替代项保留原编号和替代编号。

## 内容限制

- `Scope` 列能力范围和工作类别，不写 change tasks；验证与诊断边界由所属 Iteration Plan 承载。
- `Related changes` 只记录已有关系，不预先绑定数量。
