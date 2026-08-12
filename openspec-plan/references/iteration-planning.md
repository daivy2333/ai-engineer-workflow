# Iteration 规划

Plan 在 change 的 `tasks.md` 中规划全部任务和 Iteration，只为当前轮创建 `iterations/NNN-*.md`。

## Iteration Plan

```markdown
## Iteration Plan

### Iteration 000: <阶段结果>

- Tasks: T1, T2
- Depends on: None
- Stable baseline: <下一轮可依赖的结果>
- Verification boundary: <本轮独立完成判据>
- Diagnostic boundary: <失败时的排查范围>
- Non-goals: <留给后续轮次的内容>
```

- 每个 task 只分配给一个 Iteration，依赖只能指向同轮或更早轮次。
- Iteration 按依赖顺序编号。只有首轮或 Plan Review 确认的下一轮生成文件，后续轮次只保留在 `tasks.md`。
- 不按固定 task 数、文件数或代码行数切分。小 change 经审计后可以只有一个 Iteration。

## 平衡审计

每个 Iteration 应形成一个内聚结果，具有足够工作量、稳定基线、独立验证和明确诊断范围。

- 只有局部步骤、单项测试或观测，完成后不能形成稳定结果时，与相邻轮次合并。
- 包含多个可独立验收结果、不同故障域或无关验证时拆分。
- 跨模块不自动要求拆分；共同形成一个可验证结果时可以保留。
- 首轮不得因编号为 `000` 而承载整个 change；单轮必须通过相同审计。

## Review 后滚动

Plan Review 使用以下候选形成下一轮：

```text
当前轮未完成任务 + Review 必要修复任务 + 原计划下一轮任务
```

1. 为 Review 发现的必要修复建立或更新 change task，并保留 requirement、证据和来源 Iteration。
2. 重新执行平衡审计。修复是前置条件、候选过重或故障域不同时，先生成修复轮并顺延其他任务。
3. 更新 `tasks.md` 中未生成轮次的任务分配、依赖和边界；已交接的 Iteration 文件不改写。
4. 仍有工作时只创建一个下一编号 Iteration，并用当前代码重新建立 Current-State Evidence 和 Gate 2。
5. 没有 Review 修复且没有剩余任务时，在当前 Plan Review 记录 `no-follow-up`。
