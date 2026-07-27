---
name: omo-ulw
description: 在 OMO ultrawork 模式下为 OpenSpec 技能体系分配代理。用于运行 OpenSpec 的查询、探索、计划、实施、Review、维护、压缩、初始化或归档阶段时，借用 OMO 的代理分工能力，同时保持原有 Gate、授权、证据和持久化职责不变。
---

# OMO ULW

只借用 OMO 的代理分工能力。OpenSpec 仍负责工作流、状态、Gate、证据和持久化产物。

## 代理职责

| Agent | 职责 | 限制 |
|---|---|---|
| `sisyphus` | 协调当前 OpenSpec 阶段，分派任务并收集结果 | 不跨越阶段授权 |
| `prometheus` | 提供计划建议 | 不创建或替代 OpenSpec 权威计划 |
| `explore` | 搜索本地代码、调用链、测试和配置 | 不作设计决定 |
| `librarian` | 查询外部文档、上游实现和版本事实 | 不把外部模式当作项目事实 |
| `metis` | 查找需求、计划和任务契约的缺口 | 不写最终计划 |
| `momus` | 检查计划是否可执行、引用是否有效 | 不替代 Plan Review |
| `oracle` | 处理架构、复杂偏差和高风险判断 | 只提供建议，不接管状态 |
| `atlas` | 按已批准的任务顺序协调实现 | 不使用 OMO 状态替代 iteration |
| `hephaestus` | 完成边界明确的复杂实现或调试 | 不自行改变设计、范围或测试策略 |
| `sisyphus-junior` | 完成局部修改、验证和机械步骤 | 不处理未闭合任务 |
| `multimodal-looker` | 读取截图、图表、PDF 和其他视觉证据 | 不单独作出验收结论 |

## OpenSpec 分工

| Skill 或阶段 | 所有者 | 可调用代理 |
|---|---|---|
| `openspec-assistant` | `sisyphus` | `explore`、`librarian` |
| `openspec-explorer` | `sisyphus` | `explore`、`librarian`、`oracle`、`multimodal-looker` |
| `openspec-plan` | `sisyphus` | `prometheus`、`explore`、`librarian`、`metis`、`momus`、`oracle` |
| `openspec-act` | `sisyphus` | `atlas`、`hephaestus`、`sisyphus-junior`、`explore` |
| Act Self-Review | `sisyphus` | `momus`、`oracle`、`sisyphus-junior` |
| Plan Review | `sisyphus` | `explore`、`momus`、`oracle` |
| `openspec-docs-maintainer` | `sisyphus` | `sisyphus-junior`、`explore` |
| `openspec-compressor` | `sisyphus` | `sisyphus-junior`、`momus` |
| `openspec-archivist` | `sisyphus` | `explore`、`oracle`、`sisyphus-junior` |
| `openspec-init` | `sisyphus` | `explore`、`librarian`、`oracle`、`sisyphus-junior` |

`openspec-plan` 仍负责 change、Task Contract 和 Gate 2。

## 编排顺序

1. 加载当前阶段所属的 OpenSpec skill。
2. 由 `sisyphus` 保持该 skill 的职责、状态和写入边界。
3. 先调用 `explore` 或 `librarian` 建立依据。
4. 计划阶段调用 `metis` 查缺口，再调用 `momus` 检查可执行性。
5. 架构、歧义和高风险偏差交给 `oracle`。
6. Act 按任务契约选择 `atlas`、`hephaestus` 或 `sisyphus-junior`。
7. 子代理返回证据，由当前 OpenSpec skill 复核并写入原有产物。

子任务必须包含：

- 当前 OpenSpec skill 和 iteration。
- 目标、范围和依赖。
- Task Contract、不可修改项和停止条件。
- 需要加载的领域 skill。
- 验证命令、通过条件和证据格式。
- 只返回结果还是允许修改文件。

返回结果必须包含文件、符号、命令、输出、退出码、限制和未解决项。

## 调度规则

- 搜索和资料读取优先交给 `explore` 或 `librarian`。
- 局部、低风险和机械工作优先交给 `sisyphus-junior`。
- 已闭合且复杂的实现交给 `hephaestus`。
- 多任务实施只在依赖关系明确时交给 `atlas` 协调。
- 未闭合设计不得交给 `atlas`、`hephaestus` 或 `sisyphus-junior` 自行决定。
- 允许并行的只有无共享写入且依赖为空的调查任务。
- Plan、Act Response、Plan Review、编号和生命周期修改必须只有一个所有者。
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
