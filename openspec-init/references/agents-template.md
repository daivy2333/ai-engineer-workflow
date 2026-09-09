# AGENTS.md 模板

此模板生成项目公共规范。当前项目描述写入 SNAPSHOT，工作状态写入 tasks 或 change。

## 模板目录

- 文档地图与读取顺序
- Skill 职责与阶段边界
- 信息路由与记录边界
- BDD、TDD、Gate 和验证
- 任务追踪与迭代线程
- 文件编辑与完成检查

```markdown
# AGENTS.md

## 文档地图

| 内容 | 路径 | 写入者 |
|---|---|---|
| 公共规则 | `AGENTS.md` | 人工或 `openspec-init` |
| 当前项目描述 | `.agents/docs/SNAPSHOT.md` | `openspec-docs-maintainer` |
| Milestone roadmap | `.agents/docs/tasks.md` | `openspec-milestone-planner` |
| 全局任务和状态 | `.agents/docs/tasks.md` | `openspec-docs-maintainer` |
| 项目模型 | `.agents/memory/project-model.md` | `openspec-docs-maintainer` |
| 参考 | `.agents/memory/references.md` | `openspec-docs-maintainer` |
| 改进 | `.agents/memory/improvements.md` | `openspec-docs-maintainer` |
| 行为规格 | `.agents/specs/<domain>.md` | `openspec-docs-maintainer` 收尾合并 |
| 活跃变更 | `.agents/changes/` | plan、act |
| Change Evidence | `.agents/changes/<change>/evidence/` | `openspec-act` |
| 分析文档 | `.agents/analysis/` | `openspec-explorer` |
| Runbook | `.agents/runbooks/` | `openspec-experience-recorder` |
| Incident | `.agents/incidents/` | `openspec-experience-recorder` |

## 读取顺序

- 新会话：assistant 读取 AGENTS.md → SNAPSHOT → tasks → active changes，并按问题补充相关 M/R/I 和持久化产物。
- 当前会话中来源明确、细节仍可用且读取后未变化的信息直接复用；Skill 切换本身不触发重复读取。
- 后续 Skill 只补读当前任务缺失的信息和实际操作对象。只有概括而缺少所需细节、来源可能变化或需要新鲜运行证据时，才重新读取对应权威来源。
- Assistant 只恢复体系文档上下文，不替代 Explorer 的代码调查、Plan 的实现调查或各 Skill 对实际操作对象的检查。
- 探索：复用体系上下文 → 读取目标代码和测试 → 形成即时结论或 Analysis。
- 计划：复用 Explorer 的当前会话结论或 Analysis → 只补查缺失或失效的实现事实 → 形成自包含 Plan Context。
- 实施：当前 Iteration 的最新 Cycle → 目标代码和测试 → 按需 Evidence → act；不回读 Assistant 或 Explorer 来重建计划基线。
- 实现 Review：当前 Cycle → 实际代码、Act Response 和要求的 Evidence → plan。
- 操作任务：相关 Runbook。
- 故障复盘：Incident → analysis → project-model → specs → improvements/change。
- 查询：assistant。
- 路线规划：milestone-planner。
- 日常文档写入：docs-maintainer。

## Skill 职责

- `openspec-assistant`：只读。
- `openspec-milestone-planner`：规划 `MSxx` 路线，平衡工作量、验证边界和诊断边界；不创建 change。
- `openspec-plan`：需求、BDD、实现调查、逻辑 Iteration 规划、Cycle 创建和实施 Review。
- `openspec-act`：TDD、实施、任务自检、全量 diff Review、验证、按需 Evidence、经验候选和 Act Response。
- `openspec-experience-recorder`：根据已发生且有证据的过程创建、更新或恢复 Runbook、Incident。
- `openspec-docs-maintainer`：显式维护状态、M/R/I，收尾时合并行为规格，同步指定 change 结果，收尾最终 Review Result 为 `accepted` 的 change，并处理限定 R 登记。
- `openspec-explorer`：宏观或微观探索；输出即时回答或 `.agents/analysis/`。
- `openspec-compressor`：原地压缩，不改变状态。
- `openspec-archivist`：清理无法满足正常收尾条件的 change，并处理其他生命周期清理和 carrier 归档。

## 阶段边界

- Skill 完成不构成下一阶段授权。
- Milestone Planner 写入 roadmap 后终止，不调用 Explorer、Plan、Act 或 Maintainer。
- Plan 完成后终止，等待用户审计和 Act 指令。
- Act 写入反馈和 Experience Candidates 后终止，不创建经验产物、不归档、不维护全局状态。
- Plan Review 后终止，不自动调用 Act 或 Maintainer。
- Explorer 即时回答后终止，不调用 Maintainer。
- Explorer 生成分析文档后，可自动调用 Maintainer 登记对应 R 引用。
- Recorder 生成、更新或恢复 Runbook、Incident 后，可自动调用 Maintainer 创建或更新对应 R。
- 上述自动授权只覆盖对应 R，不覆盖 M/I、tasks 或 change。
- Maintainer 由用户直接调用时刷新 SNAPSHOT；Explorer、Recorder 的限定 R 登记不刷新 SNAPSHOT。
- Maintainer 直接调用时除 SNAPSHOT 外只修改用户点名内容；限定 R 登记只修改 references。
- Act 完成不构成 Recorder 授权；只有用户单独请求或预先明确授权串联时才执行 Recorder。
- 除上述例外，用户明确授权串联时才可继续下一阶段。
- Explorer 的结论是 Plan 可复用的调查输入。Plan 负责检查适用性、补齐缺口并把必要事实写入当前 Cycle；Act 不沿引用链回读 Explorer Analysis。

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
| 变更文件操作 | 用目录创建、git 移动和引用扫描完成 change 生命周期 |

平台工具名只是适配，不改变上述语义。

## 信息路由

- SNAPSHOT 只描述项目现在是什么：项目身份、组成、支持范围和仓库现场。
- SNAPSHOT 不保存工作状态、操作流程、约束、原因或历史记录。
- 其他文档只引用 SNAPSHOT，不复制当前项目描述。
- 项目路线、稳定基线和阶段边界写 tasks，编号 `MSxx`。
- 已承诺工作写 tasks 或 change。
- 当前开发约束写 project-model，编号 `Mxx`。
- 长期选择及其理由写 change 的 `design.md`，随 change 归档。
- 系统当前行为写 specs 语料库；maintainer 在 change 收尾时合并增量规格。
- 指针和检索元数据写 references，编号 `Rxx`。
- 有证据但未承诺实施的问题写 improvements，编号 `Ixx`。
- 可复用的构建、测试和其他命令行操作流程写入 Runbook。
- 已验证且可重复或高风险的操作由 Recorder 写入 Runbook，并登记 R。
- 已发生的重要故障由 Recorder 写入 Incident，并登记 R。
- 详细调查、实验和评估写 analysis，并登记 R。
- Cycle 的持久化日志和数据按 Iteration/Cycle 层级写入 change 内 Evidence，不登记 R。

一项信息只有一个权威位置。其他文档使用编号或路径引用，不复制正文。

Analysis、Iteration、Cycle、Act Response、Evidence 和 Incident 可以保留采集时的 revision、分支、环境和命令。这些字段属于历史现场，不是当前项目描述。

## 记录边界

- Model 只保存当前开发约束，不保存选择历史和行为描述。
- 语料库只保存验收过的行为；计划外的已验证结论沉淀在 analysis，可表达为行为要求的事实随下一个 change 进入语料库。
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

**Scope Control**

- 审查、查询和监控任务默认只读；没有明确的修改授权，不改变文件或外部状态。
- 修改任务只包含用户明确要求和完成结果不可缺少的必要后果。候选工作无法关联到用户目标、已批准 requirement、Acceptance 或可达代码和数据时，不实施。
- 增加用户未点名的工作前依次确认：用户是否要求；是否是完成结果的必要条件；哪些可达代码、数据、用户决定、法律、平台或验收证据证明必要；省略后是否会导致当前任务失败。任一项无法成立时停止扩展。
- 必要后果可以包含调用者、夹具、测试、可访问性、安全、兼容性和迁移，但必须有当前任务的可达证据。目标是最小正确结果，不是最少文件或最少代码。
- 验证只证明目标行为。环境、命令、版本和 revision 可以定位现场，但不得成为握手字段、匹配条件、拒绝条件或 Acceptance 的替代证据。
- 禁止为构建、测试、Qualification、Evidence 或运行归属新增 Hash/指纹、revision pin、run-id、session/execution ID、peer/host pin、source/index/worktree freeze、artifact manifest、日志 Hash 链、`TIME_ORDER` 时间证明及其 capture、audit、qualification 工具和专用测试。不得叠加多个身份机制证明同一次运行，也不得为证据工具自身造成的变化增加排除路径或二级验证。验证辅助代码一旦需要独立协议、CLI、fixture、负向测试或审计器，即按身份型证据工程处理。
- 发现身份型证据工程时，删除机制及其专用协议字段、CLI、构建宏、fixture、测试和工具，再运行目标行为验证；不得通过补测试或补审计链保留它。产品 requirement 明确要求的认证、完整性校验或多会话协议属于目标行为，不适用本条。
- 对已确认需要实施的工作，在同样满足 Acceptance 的方案中，依次优先复用项目已有实现、使用语言或平台原生能力、使用已有依赖，最后才新增最小必要代码或依赖；不为尚未发生的需求扩大当前实现。
- 证据足以支持当前结论后停止搜索、测试和 Review。可选改进仅在有助于用户决策时报告，不纳入当前实现。

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
- 现有测试、验证命令和基线结果；Explorer 或前序 Iteration 已实际运行且覆盖范围未变化的结果直接引用，只在缺少可采信结论时运行基线验证。
- 相关域行为可引用 `.agents/specs/` 语料库；语料库与实际代码矛盾时记入未知项。
- 当前行为、目标行为和影响范围。

影响行为、接口或错误语义、状态所有权、架构、范围、测试策略或 Acceptance 的问题属于实质问题；局部命名、辅助函数拆分、等价控制流、可直接定位的路径变化和非阻塞 Minor finding 不属于实质问题。Plan 通过 Gate 2 阻塞实质未知项，非实质选择可留给 Act。

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
- Gate 2：调查、设计、任务分轮、追踪和当前轮验证均达到执行就绪；非实质未知项不阻塞。
- Gate 3：每个任务在修改前有测试见证。
- Gate 4：每个任务先 spec review，后 code review。
- Gate 5：完成声明有新鲜证据或可采信的未失效结论。
- Gate 6：阻塞即停；三次失败后反思。

Gate BLOCK 必须记录原因。用户显式豁免必须保留原话和风险。

## 任务批次与续跑边界

- 每个 Phase 和可验证 Step 有状态。
- 任务列表只保存当前已授权且可执行的工作；完整状态以 change 产物为准。
- 跳过项标记 `SKIPPED: <reason>`。
- 只有验证通过后才能标记完成。
- 最终报告前检查全部任务状态。

按当前 skill 识别三类边界：

- 授权边界：下一步需要用户批准、选择或接受风险。
- 能力边界：下一步由用户或外部环境执行，或 agent 无法安全执行。
- 停止边界：当前 skill 要求停止、交接、阻塞或终止。

每批任务只覆盖当前位置到最近边界之前的工作。边界和等待事项不作为可执行任务。等待原因、证据要求和恢复条件写入权威产物；没有持久化产物时保留在当前对话。

没有后续任务不表示 change、Iteration、Cycle 或当前阶段已经完成。恢复执行时重新检查最近边界。用户或外部环境提交结果后，只有审核结果为 `PASS`，才能生成下一批任务。

agent 可执行的测试和 Review 不形成边界。验证失败时保留当前任务，不执行下游任务；重试和阻塞遵守当前 skill 的规则。

## Iteration 与 Cycle 线程

- Iteration 是 change Map 中的逻辑工作单元；Cycle 是该 Iteration 内的一次 Plan、Act、Review 执行闭环。
- Plan 在 change `tasks.md` 中把全部任务分配到工作量适中、可独立验证和诊断的 Iteration，只展开当前 Iteration 目录和当前 Cycle。
- 每个 change 从 `iterations/000-initial/000-initial.md` 开始；每个后续 Iteration 也从本目录的 `000-initial.md` 开始。
- 每个任务只归属一个 Iteration；首个与后续 Iteration 使用相同的聚合、拆分标准。
- Rework Cycle 使用 `001-rework.md` 等本地编号完成既有 Acceptance，不修改 Iteration Map；Replan Cycle 使用同一目录的后继编号执行修订后的计划。两者都不占用全局 Iteration 编号。
- Plan 只写 Cycle 的 `Plan Context` 和 `Plan Review`。
- Plan Context 包含所属 Iteration、Cycle 类型、Current-State Evidence、行为变化、变更面、任务或 repair item 契约和停止条件；状态在创建时为 `draft`，Gate 2 通过或明确豁免且计划获批后才改为 `ready`。
- Plan Context 必须自包含 Act 所需的实现事实和契约，不以 Assistant、Explorer、Analysis 或前序 Cycle 的引用代替必要正文。
- Task Contract 是 Act 的任务级执行依据；背景和调查证据不得给出与契约冲突的重复指令。
- Plan 把 Persisted Evidence 明确设为 `none` 或 `required`；`required` 项映射到 Gate 和通过条件。
- Act 只写当前 Cycle 的 `Act Response`。
- Act 每个 task 或 repair item 完成后执行 Gate 4，并在 Response 前重新审查完整 diff。
- Act 不建立或复核 Plan 基线；直接按 ready 的 Plan Context 建立测试见证并实施。
- Act 可处理非实质局部差异并在 Response 记录；实质问题返回 Plan。
- Act 修复当前 Cycle 计划范围内的问题；新设计或范围问题返回 Plan。
- Act Response 记录 Self-Review、已修复发现和遗留 Minor 问题。
- Act Response 记录有证据的 Runbook、Incident 候选；没有则写 `None`。
- Act Response 状态允许 `pending → reported`、`pending → blocked`、用户解决阻塞后的 `blocked → pending`，以及 Plan 要求当前 Cycle 修复时的 `reported → pending`。
- 计划偏差或 `required` Evidence 不再满足白名单、必要性、预算或可采集性时，Act 写 Blocker Handoff，将 Response 改为 `blocked`，并按需保存 `act-added / BLOCKED` Evidence。
- 用户解决阻塞并要求继续时，Act 追加 Blocker Resolution，保留原 Blocker Handoff，再恢复当前 Cycle。
- Review 保持 `pending` 且没有后继 Cycle 时，Plan 和 Act 可分别覆盖自己的区域为最新完整状态；进入终态或创建后继 Cycle 后，Cycle 冻结。Plan Context 始终不可改写。
- Act 只在用户明确要求、结果无法低成本复现、一次性环境即将消失、Incident/Blocker 需要保留现场，或摘要会丢失决定性结构时创建 `evidence/<iteration>/<cycle>/`。
- Evidence 目录与 Iteration/Cycle 层级一致，随 change 归档，不登记 R。
- Act 不得创建下一 Cycle 或下一 Iteration。
- Plan Review 必须检查代码和证据，不以 Act Self-Review 代替独立检查。
- Plan Review 把偏差分类为 Plan 遗漏、Plan 错误、Act 偏离、基线变化或新证据，并区分阻塞 Acceptance 与非阻塞 Minor finding。
- 既有 Acceptance 的有限修复仍受当前执行契约约束时，Plan 保持 Review Result 为 `pending` 并要求 Act 继续当前 Cycle；需要新执行契约时才创建 rework Cycle。
- Review Result 的终态为 `accepted | rework-required | replan-required`；Plan 写完 Review 和后继产物后最后更新。`rework-required` 不修改 Map；`replan-required` 调整计划并创建同一 Iteration 的 replan Cycle。
- 连续两个 rework Cycle 未缩小同一 Acceptance gap 时重新检查 Plan、设计和需求假设；同一问题三次失败后不得创建第四次同类 Cycle。
- 当前 Iteration 只有在 Review Result 为 `accepted` 后才能完成并展开 Map 中的下一 Iteration。
- 展开后继 Iteration 时，Current Baseline 优先引用前一 Iteration 最终 Act Response 的改动、验证结论和 accepted Review，只补查本次需求新涉及的代码表面。

## 验证

完成声明必须包含：

- 验证命令或操作。
- 每项不超过 20 行的决定性输出；输出更长时只保留能判断结果的片段。
- 退出码或明确结果。
- 证据支持的结论。

Gate 必须有新鲜验证结果，但不要求原始输出文件。验证按影响范围递增：直接目标测试 → 受影响边界 → 必要的集成或全量 Gate；现有结果足以判断 Acceptance 后停止。

验证结论的新鲜指产生时真实运行过且覆盖范围自产生后未变化，不要求本次会话重新运行。覆盖范围未变化的结论可以被后续角色和时间点采信：

- 采信方做一次只读基线检查（`git status`、`git diff`），确认覆盖范围内的材料与结论产生时一致。
- 在自己的 Review 或 Response 中注明来源和结论，不复制长输出；采信不创建 Evidence。
- 采信错误结论的责任跟随结论产生方，如同 Act 不复核 ready 的 Plan Context。

出现以下情况时重跑，不采信：

- 结论与代码、diff 或其他证据矛盾，或输出可疑。
- 验证本身不确定：已知 flaky、时序、性能或并发竞争类。
- 覆盖范围无法映射到当前要判断的 Acceptance。
- 用户显式要求独立复现。
- 采信方即将修改覆盖范围内的代码。修改前的测试见证观察当前基线；基线未变化时，既有结论就是当前基线的合法观察，恢复阻塞和 rework 场景按此采信。

基线检查用 git 现状判断覆盖范围是否变化，属于定位现场，不是身份型证据工程；Acceptance 仍由原始行为输出支持。

命令顺序由当前工作流状态和退出结果表达，时间戳只能辅助诊断。Hash、revision、run-id、peer、manifest 或时间顺序一致均不能使 Gate 通过；没有目标状态、输出、错误结果或退出码等行为证据时，验证结论为失败。

Persisted Evidence 默认 `none`。设为 `required` 前必须说明它支持哪个 Acceptance、为什么 Act Response 不够、为什么无法低成本重跑，以及缺少它会阻止哪个决定；任一项无法回答时保持 `none`。

每个 Cycle 的 Evidence 目录最多 5 个文件（含 README），整个 change 最多 20 个 Evidence 文件；单个文本文件最多 500 行且不超过 256 KiB。禁止保存完整日志目录、源码副本或完整测试套件输出，禁止通过增加 Cycle、拆分、压缩或改格式绕过限制。确有必要超出时，收集前取得用户明确批准；超限本身不阻塞实现或 Acceptance。

禁止使用“应该、大概、基本完成”替代证据。

change 结构自检覆盖：tasks 状态与实际完成一致，specs、design 与已实现行为一致，Iteration 与 Cycle 文件齐全，`Review Result` 与流程状态一致。

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
