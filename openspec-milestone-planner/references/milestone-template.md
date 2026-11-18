# Milestone Roadmap 格式

在 `.agents/docs/tasks.md` 中使用独立的 Milestone Roadmap。保留原有全局任务和 change 状态。

```markdown
## Milestone Roadmap

### MS01：<阶段成果>

- Status: planned | ready | active | completed | superseded
- Outcome: <完成后项目具备的结果>
- Rationale: <为何形成独立阶段>
- Dependencies: <硬前置 MSxx 或 None；建议执行序写在路线叙述，不入此字段>
- Scope: <包含的能力范围与工作类别>
- Non-goals: <推迟到其他阶段的内容>
- Stable result: <后续工作可依赖的状态>
- Related changes: <已有 change 或 None>
- Consumes: <本阶段消耗的 ISSxx / Ixx 或 None>
- Split signals: <执行中触发拆分或并回的信号>
```

## 状态

- `planned`：路线已接受，前置条件尚未满足。
- `ready`：依赖已满足，可以选择后续工作。
- `active`：已有相关工作正在进行。
- `completed`：完成判据已有验证结果。
- `superseded`：被其他 milestone 替代，保留替代编号。

阻塞由所属 change 的 Cycle 状态承载，MS 层不设 `blocked`。

## D-candidates（可选）

不归入当前里程碑的候选池：标题、不建议现在做的原因、何时重评。已被路线吸收的行迁入对应 `MSxx` 的 Consumes，不在两处保留。

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
