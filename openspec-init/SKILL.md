---
name: openspec-init
description: 初始化或升级项目规则、状态、change 和项目记忆体系。用于新项目创建 AGENTS.md 公共规则、.agents/ 文档结构、memory 项目记忆、Cycle 模板和三端技能入口；不做旧体系迁移和兼容适配。
---

# OpenSpec Init

初始化项目规则和文档结构。生成内容使用通用能力术语，不把 Claude Code、OpenCode 或 Codex 的专属工具写成流程前提。

## 必读引用

- 生成 `AGENTS.md` 前完整读取 [references/agents-template.md](references/agents-template.md)。
- 生成 memory 记忆文件前完整读取 [references/spec-templates.md](references/spec-templates.md)。
- 生成 Cycle 模板前完整读取 [references/iteration-template.md](references/iteration-template.md)。

## Phase 0：环境检查

使用任务追踪能力为每个 Step 单独记录状态和证据。

1. 分别检查：
   - `.agents/`
   - `AGENTS.md`
2. 检查 Git 状态和现有用户修改。
3. 任一目标已存在时先确定处理策略。AGENTS 和 SNAPSHOT 可重建；其他文档不覆盖原内容。

## Phase 1：项目分析

记录：

- 项目类型、语言和版本。
- 主要模块、组件和职责边界。
- 源码、测试和文档目录。
- 支持的平台和交付形态。
- Git 分支和工作区状态。
- 现有规则文件。
- Claude Code、OpenCode、Codex 中需要支持的平台。

## Phase 2：项目记忆

按 [references/spec-templates.md](references/spec-templates.md) 创建或合并：

- `.agents/memory/project-model.md`
- `.agents/memory/decisions.md`
- `.agents/memory/knowledge.md`
- `.agents/memory/references.md`
- `.agents/memory/improvements.md`

已有内容时合并，保留有效条目和编号。每个记忆文件包含模板定义的字段结构，条目使用递增编号。

公共规则只存在于 `AGENTS.md`，不创建单独的规则文件。

`.agents/analysis/`、`.agents/runbooks/` 和 `.agents/incidents/` 是按需产物目录。没有内容时不创建占位文件。

Analysis 由 `openspec-explorer` 创建。Runbook 和 Incident 由 `openspec-experience-recorder` 根据已发生且有证据的过程创建。

## Phase 3：状态文档

按职责处理：

- 重建 `.agents/docs/SNAPSHOT.md`。
- 创建或合并 `.agents/docs/tasks.md`。
- 按当前模板生成 `.agents/docs/templates/change-cycle.md`。

SNAPSHOT 记录当前项目描述，不记录工作状态、操作流程、约束、原因或历史。tasks 支持 `MSxx` roadmap、`Txx` 任务、运行状态和 change 来源。

Cycle 模板定义 Plan Context、Act Response、Experience Candidates 和 Plan Review 的共享格式。Plan 在 change `tasks.md` 中规划全部逻辑 Iteration，只展开当前 Iteration 目录及其当前 Cycle；有限修复沿用当前 Cycle，需要新执行契约时才增加 rework Cycle，`replan-required` 更新计划后增加 replan Cycle。Evidence 位于 `.agents/changes/<change>/evidence/`，按 Iteration/Cycle 分层并由 Act 按需创建；初始化时不创建占位目录。

## Phase 4：公共规则

根据引用模板生成或合并 `AGENTS.md`：

- 文档地图。
- 读取顺序。
- Skill 职责。
- Skill 终止和显式授权规则。
- Experience Candidates 与 Recorder 的独立授权边界。
- 通用能力映射。
- Requirements Integrity。
- BDD、TDD、Gate、验证和三次失败规则。
- 精准编辑和证据要求。

已有 `AGENTS.md` 时按模板合并，保留项目原有说明。禁止把任何平台专属任务 API、agent 配置或工具名写成唯一合法实现。

## Phase 5：跨平台安装

技能内容保持同一份，项目级源目录为 `.agents/skills/`。按平台建立入口：

- Codex 和 OpenCode：直接读取 `.agents/skills/`
- Claude Code：`.claude/skills/<name>/SKILL.md`，用符号链接指向 `.agents/skills/<name>`；不需要项目级发现时使用用户级 `~/.claude/skills/`

复制或符号链接都可以。不要维护多份内容副本。

## Gate

完成前逐项验证：

- `AGENTS.md` 只有一个公共规则来源。
- `AGENTS.md` 不包含项目名称、技术栈、分支、路径现状或具体命令。
- 公共读取规则要求复用当前会话中来源明确且未变化的体系上下文，并明确 Assistant 不替代代码调查或实际操作对象检查。
- 当前项目描述只位于 SNAPSHOT。
- 可复用的构建、测试和其他命令行操作流程进入 Runbook。
- SNAPSHOT 不包含工作状态、操作流程、约束、原因或历史。
- assistant 是只读角色。
- Maintainer 是日常状态和知识写入者，负责指定 change 结果同步和正常收尾；无法满足正常收尾条件的 change 由 Archivist 处理。
- experience-recorder 是 Runbook 和 Incident 正文的唯一写入者。
- milestone-planner 负责 `MSxx` 的路线结构，Maintainer 只同步其运行状态。
- 活跃项目记忆使用 `M/D/K/R/I` 编号，位于 `.agents/memory/`。
- 五个记忆文件存在且字段结构完整，条目可检索。
- skill frontmatter 只使用三端共同字段 `name` 和 `description`。
- 所有引用文件存在。
- Cycle 模板存在，Plan、Act 和 Review 区域职责分离；Plan Context 支持 `draft → ready`。
- change 目录支持逻辑 Iteration Plan；`rework-required` 和 `replan-required` 在同一 Iteration 内创建对应后继 Cycle，只有后者修改未完成计划。
- tasks 支持 milestone roadmap，且 milestone 与 change 数量不绑定。
- Cycle 模板能声明 `none|required`；Evidence 按需创建且不登记 R，无效 `required` 进入 blocked Plan Review。
- 公共规则、Plan、Act 和 Cycle 模板禁止身份型证据工程，要求 Gate 只由目标行为、状态、输出、错误结果或退出码通过。
- Cycle 模板能记录 `Review Result: pending → accepted | rework-required | replan-required`、Acceptance gap 和收敛状态。
- Cycle 模板能记录 Experience Candidates，且候选不构成 Recorder 授权。
- 活跃 change 通过 `.agents/changes/` 目录存在性表达，不引入元数据文件。
- Git diff 没有覆盖用户无关内容。

## 输出

- 检测结果。
- 创建和合并的文件。
- 记忆条目编号。
- 三端入口路径。
- 按需产物目录的支持状态。
- 跳过项及原因。
- 需要用户决定的冲突。

## 禁止

- 把 AI 工具列为 Git co-author。
- 覆盖用户无关的已有文档；AGENTS 和 SNAPSHOT 的重建除外。
- 创建重复规则文件。
- 只检查一个目录就推断初始化完成。
- 使用某个平台专属 frontmatter 破坏其他平台解析。
- 把平台专属任务 API、agent 配置或工具名写成唯一合法实现。
