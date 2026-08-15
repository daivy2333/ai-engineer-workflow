# Iteration 与 Cycle 规划

Plan 在 change 的 `tasks.md` 中规划全部逻辑 Iteration。每个 Iteration 表示一个稳定、可验证、可排障的阶段成果；Iteration 内的 Cycle 记录为达到该成果发生的 Plan、Act 和 Review 执行闭环。

```text
Iteration = 逻辑工作单元，进入 change 的 Iteration Plan
Cycle     = 一次执行尝试，只存在于所属 Iteration 目录
```

返工不自动产生新 Iteration。只有目标、范围、依赖或验收边界发生实质变化时，才调整 Iteration Plan。

## Iteration Plan

```markdown
## Iteration Plan

### Iteration 000: <阶段结果>

- Tasks: T1, T2
- Depends on: None
- Stable baseline: <下一 Iteration 可依赖的结果>
- Verification boundary: <本 Iteration 独立完成判据>
- Diagnostic boundary: <失败时的排查范围>
- Non-goals: <留给后续 Iteration 的内容>
```

- 每个 task 只分配给一个 Iteration，依赖只能指向同一或更早的 Iteration。
- Iteration 按依赖顺序编号。Plan 只为当前 Iteration 创建目录和当前 Cycle 文件；后续 Iteration 保留在 `tasks.md`。
- 不按固定 task 数、文件数或代码行数切分。小 change 经审计后可以只有一个 Iteration。
- Cycle 在所属 Iteration 内从 `000-initial.md` 开始，返工按 `001-rework.md`、`002-rework.md` 递增，不占用全局 Iteration 编号。

目录结构：

```text
openspec/changes/<change>/iterations/
├── 000-foundation/
│   ├── 000-initial.md
│   └── 001-rework.md
└── 001-integration/
    └── 000-initial.md
```

## 平衡审计

每个 Iteration 应形成一个内聚结果，具有足够工作量、稳定基线、独立验证和明确诊断范围。

- 只有局部步骤、单项测试或观测，完成后不能形成稳定结果时，与相邻 Iteration 合并。
- 包含多个可独立验收结果、不同故障域或无关验证时拆分。
- 跨模块不自动要求拆分；共同形成一个可验证结果时可以保留。
- 首个 Iteration 不得因编号为 `000` 而承载整个 change；单 Iteration 也必须通过相同审计。

Cycle 不重新执行 Iteration 平衡审计。它只能完成所属 Iteration 的既有 Acceptance，不能引入新成果或扩大范围。

## Review 分类

Plan Review 先判断发现是否阻塞当前 Iteration 的既有 Acceptance：

| 发现 | Review Result | 后续动作 |
|---|---|---|
| 实现不达标、Act 偏离计划，或 Plan 遗漏了达到既有 Acceptance 必需的工作 | `rework-required` | 在同一 Iteration 目录创建下一 Cycle；Iteration Plan 不变 |
| 只有不阻塞 Acceptance 的 Minor finding | `accepted` | 记录 finding；按职责决定是否另建后续 task，不强制返工 |
| 目标、范围、依赖、requirement、设计或验收边界需要改变 | `replan-required` | 停止普通返工，更新 change 和 Iteration Plan |
| Acceptance 已满足且没有阻塞项 | `accepted` | 完成当前 Iteration；存在后续 Iteration 时只展开下一个 |

判断问题：

```text
该工作是否是达到当前 Iteration 原有 Acceptance 的必要条件？
```

答案为“是”时留在当前 Iteration；答案为“否”时不得以返工名义扩大当前 Cycle。

## Rework Cycle

`rework-required` 时：

1. 为每项 Acceptance gap 建立本地 repair item，并映射到原 task、requirement、证据和来源 Cycle。repair item 可使用 `T2-R1` 形式，但不作为新的全局 change task，也不修改 Iteration Map。
2. 在当前 Iteration 目录创建下一 Cycle 文件，记录父 Cycle、偏差分类、Acceptance gap、继承范围、repair item、当前代码基线、验证方法和停止条件。
3. 新 Cycle 使用当前代码重新建立 Current-State Evidence，并重新通过 Gate 2。
4. Act 和 Plan 分别填写新 Cycle 的 Act Response 与 Plan Review；旧 Cycle 不改写。
5. 连续两个 rework Cycle 未缩小同一 Acceptance gap 时，Review 必须检查 Plan、设计和需求假设。同一问题连续失败三次时触发三次失败规则，不创建第四次同类 Cycle。

## 推进下一 Iteration

只有当前 Cycle 的 Review Result 为 `accepted`，当前 Iteration 才算完成。

1. 若 `tasks.md` 仍有后续 Iteration，Plan 按既有 Map 展开下一个 Iteration 目录及其 `000-initial.md`，不因当前 Iteration 的 Cycle 数量修改或顺延编号。
2. 若没有剩余 Iteration，在当前 Cycle 的 Plan Review 记录 `accepted` 和 `Next Iteration: None`。
3. `rework-required` 只创建同目录的下一 Cycle。
4. `replan-required` 才允许调整未完成的 Iteration Plan；已交接的 Cycle 文件保持不可变。
