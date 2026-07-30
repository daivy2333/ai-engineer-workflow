---
name: omo-ulw
description: 在 OMO ultrawork 模式下按需为 OpenSpec 工作分配代理。用于运行查询、探索、计划、实施、Review、经验记录、维护、压缩、初始化或归档阶段时，以少量代理补充调查、判断和复杂实现，同时保持原有 Gate、授权、证据和持久化职责不变。
---

# OMO ULW

只借用 OMO 的代理分工能力。OpenSpec 仍负责工作流、状态、Gate、证据和持久化产物。

## 代理职责

| Agent | 职责 | 限制 |
|---|---|---|
| `sisyphus` | 持有当前阶段，执行普通工作，按需分派并验收结果 | 不跨越阶段授权，不把最终责任交给子代理 |
| `explore` | 搜索本地代码、调用链、测试和配置 | 不作设计决定 |
| `oracle` | 处理架构、复杂偏差和高风险判断 | 只提供建议，不接管状态 |
| `hephaestus` | 完成已有明确契约的复杂实现或深度调试 | 不解释需求，不扩大范围，不改变设计或验收策略 |

`sisyphus` 是默认执行者。小型、机械或上下文紧密的工作由它完成，不为使用代理而委派。

`sisyphus` 决定为什么做、做什么和何时整体完成。`hephaestus` 只决定如何完成一个封闭实现单元。目标、范围、约束和独立验收方式都明确后，才能调用它。

`hephaestus` 可以修改同一目标下的多个文件，也可以补充测试和运行验证。需要改变 requirement、设计、milestone、change、iteration 或验收标准时，立即停止并返回证据。

## 按需分工

下表是弱映射，不是固定调用链。

| 工作类型 | 默认所有者 | 按需调用 |
|---|---|---|
| 查询、维护和压缩 | `sisyphus` | 缺少本地事实时调用 `explore` |
| 项目探索 | `sisyphus` | 本地调查调用 `explore`；高风险架构结论调用 `oracle` |
| Milestone 和 change 规划 | `sisyphus` | 核对本地事实调用 `explore`；重大取舍调用 `oracle` |
| Act | `sisyphus` | 封闭的复杂实现调用 `hephaestus`；调查调用 `explore`；高风险偏差调用 `oracle` |
| 经验记录 | `sisyphus` | 只使用已有证据；证据不足时停止 |
| Review、初始化和归档 | `sisyphus` | 证据核对调用 `explore`；高风险判断调用 `oracle` |

各 OpenSpec skill 保持原有职责。代理只补充执行能力，不成为技能之间的新交接要求。


## 编排顺序

1. 加载当前阶段所属的 OpenSpec skill。
2. `sisyphus` 确认授权、目标、边界和验收方式。
3. 能独立完成时不调用子代理。
4. 存在事实、判断或封闭实现缺口时，只选择对应代理。
5. `sisyphus` 复核返回证据，完成集成、最终验证和持久化。

子任务必须包含：

- 当前 OpenSpec skill 和 iteration。
- 目标、范围和依赖。
- Task Contract、不可修改项和停止条件。
- 需要加载的领域 skill。
- 验证命令、通过条件和证据格式。
- 只返回结果还是允许修改文件。

返回结果必须包含文件、符号、命令、输出、退出码、限制和未解决项。

## 调度规则

- 默认只运行 `sisyphus`。没有明确收益时不得委派。
- 缺少本地代码事实时调用 `explore`。
- 需要独立的高风险判断时调用 `oracle`。
- 任务契约闭合且需要持续深入实现或调试时调用 `hephaestus`。
- 无法写清目标、范围、约束和验收方式时，不得调用 `hephaestus`。
- 默认一次只调用一个子代理。只有相互独立、无共享写入的调查任务才能并行。
- 外部资料和视觉材料由 `sisyphus` 按需使用工具读取，不设置常驻代理。
- Milestone roadmap、Plan、Act Response、Plan Review、编号和生命周期修改必须只有一个所有者。
- 代理升级不能代替用户授权、Gate、停止条件或新鲜证据。
- 同一问题反复失败时遵守所属 skill 的三次失败规则，不靠更换代理继续盲试。

## 不可越过的边界

- `ulw` 不得把 Plan 完成视为 Act 授权。
- `ulw` 不得把 Act 完成视为 Review、维护或归档授权。
- 不创建 `.omo` 计划或状态作为 OpenSpec 的事实来源。
- 不使用 OMO 的持久化状态替代 change、iteration、Evidence 或 Response。
- 子代理不得改变 requirement、设计、Gate、任务状态或证据标准。
- 子代理发现计划偏差时停止并返回当前 OpenSpec skill。
- 最终结论必须由当前 OpenSpec skill 根据新鲜证据给出。
