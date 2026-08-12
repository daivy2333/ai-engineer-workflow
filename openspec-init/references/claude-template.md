# CLAUDE.md 模板

此模板只生成项目公共规范。当前项目描述写入 SNAPSHOT，工作状态写入 tasks 或 change。

## 模板目录

- 文档地图与读取顺序
- Skill 职责与阶段边界
- 信息路由与记录边界
- BDD、TDD、Gate 和验证
- 任务追踪与迭代线程
- 文件编辑与完成检查

```markdown
# CLAUDE.md

## 文档地图

| 内容 | 路径 | 写入者 |
|---|---|---|
| 公共规则 | `CLAUDE.md` | 人工或 `openspec-init` |
| 当前项目描述 | `.claude/docs/SNAPSHOT.md` | `openspec-docs-maintainer` |
| Milestone roadmap | `.claude/docs/tasks.md` | `openspec-milestone-planner` |
| 全局任务和状态 | `.claude/docs/tasks.md` | `openspec-docs-maintainer` |
| 迭代模板 | `.claude/docs/templates/change-iteration.md` | `openspec-init` |
| 项目模型 | `openspec/specs/project-model/spec.md` | `openspec-docs-maintainer` |
| 决策 | `openspec/specs/decisions/spec.md` | `openspec-docs-maintainer` |
| 知识 | `openspec/specs/knowledge/spec.md` | `openspec-docs-maintainer` |
| 参考 | `openspec/specs/references/spec.md` | `openspec-docs-maintainer` |
| 改进 | `openspec/specs/improvements/spec.md` | `openspec-docs-maintainer` |
| 活跃变更 | `openspec/changes/` | OpenSpec、plan、act |
| Change Evidence | `openspec/changes/<change>/evidence/` | `openspec-act` |
| 分析文档 | `.claude/analysis/` | `openspec-explorer` |
| Runbook | `.claude/runbooks/` | `openspec-experience-recorder` |
| Incident | `.claude/incidents/` | `openspec-experience-recorder` |

## 读取顺序

- 新会话：CLAUDE → SNAPSHOT → tasks → active changes。
- 新功能或 Bug：相关 project-model → decisions → knowledge → plan。
- 实施：change 基线 → 最新 iteration → 按需 Evidence → act。
- 实现 Review：当前 iteration → 实际代码、Act Response 和要求的 Evidence → plan。
- 操作任务：相关 Runbook。
- 故障复盘：Incident → knowledge → decisions/model → improvements/change。
- 查询：assistant。
- 路线规划：milestone-planner。
- 日常文档写入：docs-maintainer。

## Skill 职责

- `openspec-assistant`：只读。
- `openspec-milestone-planner`：规划 `MSxx` 路线，平衡工作量、验证边界和诊断边界；不创建 change。
- `openspec-plan`：需求、BDD、实现调查、change 任务分轮、当前 iteration 和实施 Review。
- `openspec-act`：TDD、实施、任务自检、全量 diff Review、验证、按需 Evidence、经验候选和 Act Response。
- `openspec-experience-recorder`：根据已发生且有证据的过程创建、更新或恢复 Runbook、Incident。
- `openspec-docs-maintainer`：显式维护状态、M/D/K/R/I 和指定 change 收尾，并处理限定 R 登记。
- `openspec-explorer`：宏观或微观探索；输出即时回答或 `.claude/analysis/`。
- `openspec-compressor`：原地压缩，不改变状态。
- `openspec-archivist`：生命周期清理和 carrier 归档。

## 阶段边界

- Skill 完成不构成下一阶段授权。
- Milestone Planner 写入 roadmap 后终止，不调用 Explorer、Plan、Act 或 Maintainer。
- Plan 完成后终止，等待用户审计和 Act 指令。
- Act 写入反馈和 Experience Candidates 后终止，不创建经验产物、不归档、不维护全局状态。
- Plan Review 后终止，不自动调用 Act 或 Maintainer。
- Explorer 即时回答后终止，不调用 Maintainer。
- Explorer 生成分析文档后，可自动调用 Maintainer 登记对应 R 引用。
- Recorder 生成、更新或恢复 Runbook、Incident 后，可自动调用 Maintainer 创建或更新对应 R。
- 上述自动授权只覆盖对应 R，不覆盖 M/D/K/I、tasks 或 change。
- Maintainer 由用户直接调用时刷新 SNAPSHOT；Explorer、Recorder 的限定 R 登记不刷新 SNAPSHOT。
- Maintainer 直接调用时除 SNAPSHOT 外只修改用户点名内容；限定 R 登记只修改 references。
- Act 完成不构成 Recorder 授权；只有用户单独请求或预先明确授权串联时才执行 Recorder。
- 除上述例外，用户明确授权串联时才可继续下一阶段。

## 通用能力

流程描述使用能力语义：

| 语义 | 要求 |
|---|---|
| 任务追踪 | 记录 Phase、Task、Gate、状态和非迁移步骤的跳过原因 |
| 用户决策 | 对需求、风险和不可逆动作取得明确选择 |
| 文件读取 | 完整读取所选规则和引用 |
| 精准编辑 | 只修改相关片段 |
| 命令执行 | 保留命令、输出和退出码 |
| 并行委托 | 仅在环境支持且任务可独立时使用 |
| OpenSpec 集成 | 按当前职责创建、应用、验证或归档 change |

平台工具名只是适配，不改变上述语义。

## 信息路由

- SNAPSHOT 只描述项目现在是什么：项目身份、组成、支持范围和仓库现场。
- SNAPSHOT 不保存工作状态、操作流程、约束、原因或历史记录。
- 其他文档只引用 SNAPSHOT，不复制当前项目描述。
- 项目路线、稳定基线和阶段边界写 tasks，编号 `MSxx`。
- 已承诺工作写 tasks 或 OpenSpec change。
- 当前跨模块约束写 project-model，编号 `Mxx`。
- 有替代方案的长期选择写 decisions，编号 `Dxx`。
- 已验证、非显然且可复用的结论写 knowledge，编号 `Kxx`。
- 指针和检索元数据写 references，编号 `Rxx`。
- 有证据但未承诺实施的问题写 improvements，编号 `Ixx`。
- 可复用的构建、测试和其他命令行操作流程写入 Runbook。
- 已验证且可重复或高风险的操作由 Recorder 写入 Runbook，并登记 R。
- 已发生的重要故障由 Recorder 写入 Incident，并登记 R。
- 详细调查、实验和评估写 analysis，并登记 R。
- iteration 的持久化日志和数据写 change 内 Evidence，不登记 R。

一项信息只有一个权威位置。其他文档使用编号或路径引用，不复制正文。

Analysis、iteration、Act Response、Evidence 和 Incident 可以保留采集时的 revision、分支、环境和命令。这些字段属于历史现场，不是当前项目描述。

## 旧体系迁移

- 升级必须沿文档地图、引用、归档指引和历史 carrier 发现来源，读取全文，逐信息单元迁移。
- 重复和过时信息仍要建立来源映射，并保留独有信息、状态和时间边界。
- 已归档 legacy carrier 保持不可变，但其中的信息也要迁移和验证。
- CLAUDE 和 SNAPSHOT 按新体系重建，不进入迁移清单或 carrier。
- 覆盖率达到 100%，且 `unmapped = 0`、`skipped = 0` 后才能归档旧文档。
- migration carrier 保存覆盖清单、编号映射和每份旧文档完整原文。
- 旧体系文档只允许完整 Archive，不允许 Delete 或 Compress-Archive。

## 记录边界

- Model 只保存当前有效约束，不保存选择历史。
- Decision 被替代后保留，并标记 `superseded`。
- Knowledge 不保存单纯路径、API 签名、链接或未验证猜测。
- Reference 不复制目标正文。
- Improvement 只保存未承诺工作；批准后创建 change 并标记 `promoted`。
- Milestone Planner 创建和调整 `planned`、`ready` 的 `MSxx`；Maintainer 只同步运行状态和 change 引用。
- Tasks 不保存未批准想法。
- 普通测试失败不创建 Incident。
- 一次性命令不创建 Runbook。
- Runbook 和 Incident 不由 Compressor 改写。
- 普通验证结果写 Act Response；没有持久化要求时不创建 Evidence 占位目录。

## 行为约束

**Think Before Coding**

- 陈述影响实现的假设。
- 多种解释会改变结果时请求用户决定。
- 不隐藏不确定性。

**Simplicity First**

- 不添加未要求功能。
- 不为一次使用提前抽象。
- 不增加无需求依据的配置。

**Surgical Changes**

- 只修改需求需要的内容。
- 不清理无关代码。
- 清理由本次改动产生的孤儿。

**Requirements Integrity**

- 用户明确要求必须全部覆盖。
- 实现简单不能成为裁剪需求的理由。
- 任何简化先写入 RTM 并取得批准。

## 执行约束

1. 不探索清楚不实现。
2. 不计划清楚不实现。
3. 不完整覆盖需求不实现。
4. 不测试通过不提交。
5. 不验证成功不声明。
6. 三次失败必须反思。
7. 不见测试见证不变更。
8. 不见场景缺口扫描不进设计。

## BDD

需求设计前扫描：

- Happy Path。
- Sad Path。
- Edge Case。
- 错误、超时、取消和兼容性。

输出场景草图：前置状态、动作、结果和失败边界。用户显式接受的缺口写入 proposal。

## Plan 调查

Plan 在制定任务前读取实际代码并记录：

- 入口、目标符号、调用者和被调用者。
- 数据流、状态变化、错误和并发边界。
- 现有测试、验证命令和基线结果。
- 当前行为、目标行为和影响范围。

Plan 负责确定接口语义、状态所有权、测试策略和停止条件。影响实现的未知项阻塞 Gate 2，不留给 Act 决定。

## TDD

铁律：`NO CHANGE WITHOUT TEST WITNESS`。

- 新功能：测试定义期望，观察 RED，再实现 GREEN。
- Bug：测试复现问题，观察 RED，再修复 GREEN。
- 重构：先观察 GREEN，重构后保持 GREEN。

每次变更执行：

1. 定位范围。
2. 建立测试。
3. 验证当前状态。
4. 修改。
5. 验证新状态。
6. Review。

## Gate

- Gate 1：需求、BDD、场景、范围和 change 获批。
- Gate 2：调查、设计、任务分轮、追踪和当前轮验证均达到执行就绪。
- Gate 3：计划基线有效且每个任务有测试见证。
- Gate 4：每个任务先 spec review，后 code review。
- Gate 5：完成声明有新鲜证据。
- Gate 6：阻塞即停；三次失败后反思。

Gate BLOCK 必须记录原因。用户显式豁免必须保留原话和风险。

## 任务批次与续跑边界

- 每个 Phase 和可验证 Step 有状态。
- 任务列表只保存当前已授权且可执行的工作；完整状态以 OpenSpec 产物为准。
- 非迁移步骤的跳过项标记 `SKIPPED: <reason>`；旧体系信息单元不得跳过。
- 只有验证通过后才能标记完成。
- 最终报告前检查全部任务状态。

按当前 skill 识别三类边界：

- 授权边界：下一步需要用户批准、选择或接受风险。
- 能力边界：下一步由用户或外部环境执行，或 agent 无法安全执行。
- 停止边界：当前 skill 要求停止、交接、阻塞或终止。

每批任务只覆盖当前位置到最近边界之前的工作。边界和等待事项不作为可执行任务。等待原因、证据要求和恢复条件写入权威产物；没有持久化产物时保留在当前对话。

没有后续任务不表示 change、iteration 或当前阶段已经完成。恢复执行时重新检查最近边界。用户或外部环境提交结果后，只有审核结果为 `PASS`，才能生成下一批任务。

agent 可执行的测试和 Review 不形成边界。验证失败时保留当前任务，不执行下游任务；重试和阻塞遵守当前 skill 的规则。

## 迭代线程

- Plan 在 change `tasks.md` 中把全部任务分配到工作量适中、可独立验证和诊断的 Iteration，只创建当前轮文件。
- 每个 change 从 `iterations/000-initial.md` 开始；后续轮次由 Plan Review 按零填充编号逐轮创建。
- 每个任务只归属一个 Iteration；首轮与后续轮次使用相同的聚合、拆分标准。
- Plan 只写 `Plan Context` 和 `Plan Review`。
- Plan Context 包含 Current-State Evidence、行为变化、变更面、任务契约和停止条件。
- Plan 把 Persisted Evidence 明确设为 `none` 或 `required`；`required` 项映射到 Gate 和通过条件。
- Act 只写 `Act Response`。
- Act 每个任务完成后执行 Gate 4，并在 Response 前重新审查完整 diff。
- Act 修复计划范围内的问题；新设计或范围问题返回 Plan。
- Act Response 记录 Self-Review、已修复发现和遗留 Minor 问题。
- Act Response 记录有证据的 Runbook、Incident 候选；没有则写 `None`。
- Act Response 状态允许 `pending → reported`、`pending → blocked` 和用户解决阻塞后的 `blocked → pending`。
- 计划偏差时，Act 写 Blocker Handoff，并按需保存 `act-added / BLOCKED` Evidence。
- 用户解决阻塞并要求继续时，Act 追加 Blocker Resolution，保留原 Blocker Handoff，再恢复当前 iteration。
- 已创建后继 iteration 时，不再恢复旧 iteration。
- Act 只在 `required` 或实际需要保留长日志、特殊格式和难复现输出时创建 `evidence/<NNN-title>/`。
- Evidence 目录名与 iteration 文件名一致，随 change 归档，不登记 R。
- 交接后的 Plan Context 不得改写。
- Act 不得创建下一轮 iteration。
- Plan Review 必须检查代码和证据，不以 Act Self-Review 代替独立检查。
- Plan Review 把偏差分类为 Plan 遗漏、Plan 错误、Act 偏离、基线变化或新证据。
- Plan Review 合并当前轮未完成任务、必要修复和原计划下一轮任务，重新平衡后只创建一个新 Iteration，不覆盖旧记录。

## 验证

完成声明必须包含：

- 验证命令或操作。
- 关键输出。
- 退出码或明确结果。
- 证据支持的结论。

Gate 必须有可验证依据，但持久化 Evidence 是按需产物。`none` 时由 Act Response 保存验证摘要；`required` 时对应文件缺失会阻塞 Gate。

禁止使用“应该、大概、基本完成”替代证据。

## 三次失败

同一问题连续失败 3 次：

1. 停止当前修复。
2. 记录三次尝试和症状。
3. 检查共享状态、耦合和需求假设。
4. 返回设计或需求阶段。
5. 不开始第四次同类盲试。

## 文件编辑

- 已有文件只做精准修改。
- 新文件才允许整体创建。
- 不覆盖用户无关改动。
- 移动或删除前检查引用。

## 完成前五问

1. 每一步是否有状态？
2. 跳过项是否有原因？
3. Gate 是否逐项通过或阻塞？
4. 完成声明是否有新鲜证据？
5. 最终报告前是否检查任务状态？
```

平台可以另外提供入口配置，但不得复制并改写这些规则。
