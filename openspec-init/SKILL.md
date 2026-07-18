---
name: openspec-init
description: 初始化或升级 OpenSpec 项目规则、specs、changes、CLAUDE.md、SNAPSHOT 和 tasks。用于新项目设置规范、创建 OpenSpec 结构、迁移旧文档体系，或让同一套技能在 Claude Code、OpenCode 和 Codex 中使用。
---

# OpenSpec Init

初始化项目规则和文档结构。生成内容使用通用能力术语，不把 Claude Code、OpenCode 或 Codex 的专属工具写成流程前提。

## 必读引用

- 生成 `CLAUDE.md` 前完整读取 [references/claude-template.md](references/claude-template.md)。
- 为 Codex 和 OpenCode 生成规则入口前完整读取 [references/agents-adapter.md](references/agents-adapter.md)。
- 生成 specs 前完整读取 [references/spec-templates.md](references/spec-templates.md)。
- 检测到旧文档结构时完整读取 [references/migration.md](references/migration.md)。

## Phase 0：环境检查

使用任务追踪能力为每个 Step 单独记录状态和证据。

1. 运行 `openspec --version`。
2. 分别检查：
   - `openspec/`
   - `.claude/docs/`
   - `CLAUDE.md`
3. 检查 Git 状态和现有用户修改。
4. 任一目标已存在时，先确定合并策略，不直接覆盖。

OpenSpec 未安装时停止并给出安装命令。不要静默创建不受验证的替代结构。

## Phase 1：项目分析

记录：

- 项目类型、语言和版本。
- 构建、测试、格式化和 lint 命令。
- 源码、测试和文档目录。
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

- `openspec/specs/architecture/spec.md`
- `openspec/specs/learned/spec.md`
- `openspec/specs/references/spec.md`
- `openspec/specs/optimization/spec.md`

不创建 `rules/spec.md`。公共规则只存在于 `CLAUDE.md`。

所有 spec 必须满足 OpenSpec 当前格式要求，并包含可验证 Scenario。

## Phase 4：状态文档

创建或合并：

- `.claude/docs/SNAPSHOT.md`
- `.claude/docs/tasks.md`

SNAPSHOT 记录当前项目事实。tasks 记录全局进行中、待办、阻塞和 change 来源。

## Phase 5：公共规则

根据引用模板生成 `CLAUDE.md`：

- 文档地图。
- 读取顺序。
- Skill 职责。
- 通用能力映射。
- Requirements Integrity。
- BDD、TDD、Gate、验证和三次失败规则。
- 精准编辑和证据要求。

生成或合并薄 `AGENTS.md` 适配器，要求 Codex 和 OpenCode 完整读取 `CLAUDE.md`。`AGENTS.md` 不复制公共规则。

禁止把任何平台专属任务 API、agent 配置或工具名写成唯一合法实现。

## Phase 6：跨平台安装

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
- `AGENTS.md` 只做入口适配，没有复制公共规则。
- assistant 是只读角色。
- maintainer 是日常状态和知识写入者。
- skill frontmatter 只使用三端共同字段 `name` 和 `description`。
- 所有引用文件存在。
- Git diff 没有覆盖用户无关内容。

## 输出

- 检测结果。
- 创建和合并的文件。
- OpenSpec 验证输出。
- 三端入口路径。
- 跳过项及原因。
- 需要用户决定的冲突。

## 禁止

- 把 AI 工具列为 Git co-author。
- 全量覆盖已有规则或文档。
- 创建重复 rules spec。
- 只检查一个目录就推断初始化完成。
- 使用某个平台专属 frontmatter 破坏其他平台解析。
