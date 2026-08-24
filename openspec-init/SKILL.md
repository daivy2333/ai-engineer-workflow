---
name: openspec-init
description: 初始化或升级 OpenSpec 项目规则、状态、变更和项目记忆体系。用于新项目设置规范，创建 project-model、decisions、knowledge、references、improvements，按语义条目全量迁移并归档旧 architecture、learned、optimization，或配置 Claude Code、OpenCode 和 Codex 共用入口。
---

# OpenSpec Init

初始化项目规则和文档结构。生成内容使用通用能力术语，不把 Claude Code、OpenCode 或 Codex 的专属工具写成流程前提。

## 必读引用

- 生成 `CLAUDE.md` 前完整读取 [references/claude-template.md](references/claude-template.md)。
- 为 Codex 和 OpenCode 生成规则入口前完整读取 [references/agents-adapter.md](references/agents-adapter.md)。
- 生成 specs 前完整读取 [references/spec-templates.md](references/spec-templates.md)。
- 生成 Cycle 模板前完整读取 [references/iteration-template.md](references/iteration-template.md)。
- 检测到旧文档结构时完整读取 [references/migration.md](references/migration.md)。

## Phase 0：环境检查

使用任务追踪能力为每个 Step 单独记录状态和证据。

1. 运行 `openspec --version`。
2. 分别检查：
   - `openspec/`
   - `.claude/docs/`
   - `CLAUDE.md`
3. 检查 Git 状态和现有用户修改。
4. 任一目标已存在时先确定处理策略。CLAUDE 和 SNAPSHOT 可重建；其他文档不覆盖原内容。
5. 发现旧体系文档时进入全量迁移模式，沿文档地图、引用、归档指引和历史 carrier 建立来源清单；不得按固定路径、价值或相关性选择迁移范围。
6. 从来源清单排除 CLAUDE 和 SNAPSHOT。迁移期间保持旧经验来源只读；记录路径、mtime、工作区状态和已归档 legacy carrier 路径，不生成内容哈希。

OpenSpec 未安装时停止并给出安装命令。不要静默创建不受验证的替代结构。

## Phase 1：项目分析

记录：

- 项目类型、语言和版本。
- 主要模块、组件和职责边界。
- 源码、测试和文档目录。
- 支持的平台和交付形态。
- Git 分支和工作区状态。
- 现有规则文件。
- Claude Code、OpenCode、Codex 中需要支持的平台。

## Phase 2：OpenSpec 配置

1. 使用当前环境可用的 OpenSpec 初始化能力。
2. 生成 `openspec/config.yaml`：
   - schema。
   - 技术栈 context。
   - 语言要求。
   - proposal/specs/design/tasks 规则。
3. 运行 OpenSpec specs 验证。

平台专属 slash command 只能出现在适配说明中，不能成为 OpenSpec 生命周期的唯一入口。

## Phase 3：Specs

创建或合并：

- `openspec/specs/project-model/spec.md`
- `openspec/specs/decisions/spec.md`
- `openspec/specs/knowledge/spec.md`
- `openspec/specs/references/spec.md`
- `openspec/specs/improvements/spec.md`

不创建 `rules/spec.md`。公共规则只存在于 `CLAUDE.md`。

所有 spec 必须满足 OpenSpec 当前格式要求，并包含可验证 Scenario。

`.claude/analysis/`、`.claude/runbooks/` 和 `.claude/incidents/` 是按需产物目录。没有内容时不创建占位文件。

Analysis 由 `openspec-explorer` 创建。Runbook 和 Incident 由 `openspec-experience-recorder` 根据已发生且有证据的过程创建。

## Phase 4：状态文档

按职责处理：

- 重建 `.claude/docs/SNAPSHOT.md`。
- 创建或合并 `.claude/docs/tasks.md`。
- 按当前模板生成 `.claude/docs/templates/change-cycle.md`。

SNAPSHOT 记录当前项目描述，不记录工作状态、操作流程、约束、原因或历史。tasks 支持 `MSxx` roadmap、`Txx` 任务、运行状态和 change 来源。
Cycle 模板定义 Plan Context、Act Response、Experience Candidates 和 Plan Review 的共享格式。Plan 在 change `tasks.md` 中规划全部逻辑 Iteration，只展开当前 Iteration 目录及其当前 Cycle；`rework-required` 在同一目录增加 rework Cycle，`replan-required` 更新计划后增加 replan Cycle。Evidence 位于 `openspec/changes/<change>/evidence/`，按 Iteration/Cycle 分层并由 Act 按需创建；初始化时不创建占位目录。

## Phase 5：公共规则

根据引用模板覆盖生成 `CLAUDE.md`：

- 文档地图。
- 读取顺序。
- Skill 职责。
- Skill 终止和显式授权规则。
- Experience Candidates 与 Recorder 的独立授权边界。
- 通用能力映射。
- Requirements Integrity。
- BDD、TDD、Gate、验证和三次失败规则。
- 精准编辑和证据要求。

生成或合并薄 `AGENTS.md` 适配器，要求 Codex 和 OpenCode 完整读取 `CLAUDE.md`。`AGENTS.md` 不复制公共规则。

禁止把任何平台专属任务 API、agent 配置或工具名写成唯一合法实现。

## Phase 6：旧体系全量迁移

仅在发现旧体系文档时执行。

完整执行 [references/migration.md](references/migration.md) 的来源发现、语义条目映射、覆盖验证、MIG 载体和失败处理。Init 负责迁移和生成载体；`openspec-archivist` 只核验并完整归档载体。载体归档成功后才能退出旧活动路径。

用户要求升级或迁移即构成创建、归档 migration carrier 和退出旧活动路径的授权，不需要重复确认。该授权不包括 Delete、Compress-Archive 或其他生命周期清理。

任一 migration Gate 失败时停止并保留旧活动文件，不得把部分迁移声明为完成。

## Phase 7：跨平台安装

技能内容保持同一份。按平台建立入口：

- Claude Code：`.claude/skills/<name>/SKILL.md`
- Codex：`.agents/skills/<name>/SKILL.md`
- OpenCode：优先复用 `.agents/skills` 或 `.claude/skills`

复制或符号链接都可以。不要维护三份内容副本。

## Gate

完成前逐项验证：

- OpenSpec CLI 可用。
- specs validate 通过。
- `CLAUDE.md` 只有一个公共规则来源。
- `CLAUDE.md` 不包含项目名称、技术栈、分支、路径现状或具体命令。
- 公共读取规则要求复用当前会话中来源明确且未变化的体系上下文，并明确 Assistant 不替代代码调查或实际操作对象检查。
- 当前项目描述只位于 SNAPSHOT。
- 可复用的构建、测试和其他命令行操作流程进入 Runbook。
- SNAPSHOT 不包含工作状态、操作流程、约束、原因或历史。
- `AGENTS.md` 只做入口适配，没有复制公共规则。
- assistant 是只读角色。
- Maintainer 是日常状态和知识写入者，负责指定 change 结果同步和正常收尾；无法满足正常收尾条件的 change 由 Archivist 处理。
- experience-recorder 是 Runbook 和 Incident 正文的唯一写入者。
- milestone-planner 负责 `MSxx` 的路线结构，Maintainer 只同步其运行状态。
- 活跃项目记忆使用 `M/D/K/R/I` 编号。
- 新项目不创建 architecture、learned 或 optimization spec。
- 升级项目通过 [references/migration.md](references/migration.md) 的全部覆盖、载体和失败检查，满足 `semantic entries = mapped entries = verified entries`、`unmapped = 0`、`skipped = 0`。
- migration carrier 保存完整原文和映射且不含内容哈希或核对过程日志；历史 carrier 保持不可变，CLAUDE 和 SNAPSHOT 已重建且不进入迁移载体。
- migration carrier 归档成功后才退出旧活动路径；旧经验文档未使用 Delete 或 Compress-Archive。
- skill frontmatter 只使用三端共同字段 `name` 和 `description`。
- 所有引用文件存在。
- Cycle 模板存在，Plan、Act 和 Review 区域职责分离；Plan Context 支持 `draft → ready`。
- change tasks 支持逻辑 Iteration Plan；`rework-required` 和 `replan-required` 在同一 Iteration 内创建对应后继 Cycle，只有后者修改未完成计划。
- tasks 支持 milestone roadmap，且 milestone 与 change 数量不绑定。
- Cycle 模板能声明 `none|required`；Evidence 按需创建且不登记 R，无效 `required` 进入 blocked Plan Review。
- Cycle 模板能记录 `Review Result: pending → accepted | rework-required | replan-required`、Acceptance gap 和收敛状态。
- Cycle 模板能记录 Experience Candidates，且候选不构成 Recorder 授权。
- Git diff 没有覆盖用户无关内容。

## 输出

- 检测结果。
- 创建和合并的文件。
- OpenSpec 验证输出。
- 三端入口路径。
- 旧编号到 M/D/K/R/I 的迁移映射。
- 语义条目覆盖统计和未映射计数。
- migration carrier 及恢复入口。
- 旧体系活动路径和旧引用的最终扫描结果。
- 按需产物目录的支持状态。
- 非迁移步骤的跳过项及原因。
- 需要用户决定的冲突。

## 禁止

- 把 AI 工具列为 Git co-author。
- 覆盖经验来源或迁移目标；CLAUDE 和 SNAPSHOT 的重建除外。
- 创建重复 rules spec。
- 只检查一个目录就推断初始化完成。
- 使用某个平台专属 frontmatter 破坏其他平台解析。
- 选择性、部分或抽样迁移旧经验文档。
- 把重复、过时、低价值或暂时无法分类作为不迁移理由。
- 用 Delete 或 Compress-Archive 处理旧经验文档。
- carrier 完整归档前移除旧活动文件。
