# AI Engineer Workflow Skill Collection

> Claude Code 技能集合：AI 工程师工作流程、项目文档管理、插件生态

---

## 概述

本项目包含 6 个 Claude Code 技能（Skills），用于：

1. **开发流程管理** — openspec-plan + openspec-act（需求探索 + TDD 执行，可独立或串联使用）
2. **项目文档管理** — 文档生成器 + 日常助手 + 智能归档
3. **插件生态** — 管理 3 个 marketplace 的专业插件

---

## 技能列表

### 1. openspec-plan

**描述**：需求探索、BDD 智能缺口扫描、计划制定、OpenSpec 变更创建 — Phase 1-2 的前置工作流。

**触发**：开始新功能、需要需求澄清、创建开发计划、生成 OpenSpec 变更时。

**核心特性**：
- BDD 智能缺口：自动扫描 Happy/Sad/Edge → 用户选择 → 场景草图
- Requirements Integrity Gate：需求完整性优先于实现简化
- 轻量模式：小任务自动简化流程
- OpenSpec 集成：一键创建变更提案

**Phase 流程**：
```
Phase 1: CLARIFY → BDD 缺口扫描 + /opsx:propose → Approved Requirements + Scenario Sketch
Phase 2: PLAN → Plan Agent + Requirements Completeness → 完善的 OpenSpec 变更
```

完成后进入 openspec-act 执行。

---

### 2. openspec-act

**描述**：TDD 执行、Gate 验证、Review、归档收尾 — Phase 3-4 的实施工作流。

**触发**：openspec-plan 完成后，开始写代码实现、运行测试、代码审查、归档时。

**核心特性**：
- TDD Iron Law：NO CHANGE WITHOUT TEST WITNESS
- Evidence-Based Verification：零妥协的证据验证
- Manual QA：CLI/API/UI 实际运行验证
- Three-Strike Architecture Reflection：三次失败强制架构反思
- OpenSpec 集成：按任务清单实施 + 归档

**Phase 流程**：
```
Phase 3: EXECUTE → TDD 循环 + Gate 5 验证 → 所有 task 完成
Phase 4: COMPLETE → 5 问自审 + /opsx:archive → Merge/PR/Keep/Discard
```

由 openspec-plan 产出的计划驱动。

---

### 3. plugin-loader

**描述**：管理 Claude Code 插件生态。支持三个 marketplace：claude-plugins-official（官方 34 internal + 15 external）、claude-code-workflows（77 个专业领域插件）、claude-hud（状态栏）。提供全局/项目/文件夹三种部署方式。

**触发**：用户提到"安装插件"、"添加 marketplace"、"插件管理"、"需要某个功能的专业插件"时。

**Marketplace 概览**：

| Marketplace | 插件数 | 类型 |
|-------------|--------|------|
| claude-plugins-official | 49 | 官方（34 internal + 15 external） |
| claude-code-workflows | 77 | 专业领域插件 |
| claude-hud | 1 | 实时状态栏 |

**部署 Scope**：
- `--scope user`：全局，所有项目共享
- `--scope project`：项目级，仅该 git 仓库
- `--scope local`：文件夹级，无需 git 仓库

**快速开始**：
```bash
# 配置 marketplace
claude plugin marketplace add anthropics/claude-plugins-official
claude plugin marketplace add wshobson/agents
claude plugin marketplace add jarrod-watts/claude-hud

# 安装插件
claude plugin install python-development@claude-code-workflows --scope user
claude plugin install rust-analyzer-lsp@claude-plugins-official --scope user
```

---

### 4. project-docs-generator-ulw

**描述**：项目文档生成器 - 为项目初始化完整的 .claude/ 文档体系（7 份单一职责 .md 文件），包含三大规则体系、架构决策、项目快照、任务清单、外部参考、优化方向。

**触发**：用户想要初始化项目文档、设置项目规则、创建 CLAUDE.md 体系、或说"初始化项目约束"、"生成项目文档"等。

**生成文档**（8 份）：
1. `CLAUDE.md` — 入口索引
2. `.claude/docs/rules.md` — 编码规范与行为约束（完整三大规则）
3. `.claude/docs/architecture.md` — 架构决策记录
4. `.claude/docs/snapshot.md` — 项目状态快照
5. `.claude/docs/tasks.md` — 任务清单
6. `.claude/docs/learned.md` — 学习记忆（API路径、踩坑经验）
7. `.claude/docs/references.md` — 外部参考资料
8. `.claude/docs/optimization.md` — 优化方向与技术债务

**嵌入的三大规则**：
- Karpathy Guidelines（行为约束）：Think Before Coding、Simplicity First、Surgical Changes、Requirements Integrity
- 务实编码原则（代码质量）：十大铁律
- Workflow Designer（流程框架）：Phase/Gate/Task/Loop

---

### 5. project-docs-assistant-ulw

**描述**：项目文档助手 - 日常开发中按需读取 .claude/docs/ 文档，维护任务、快照、架构决策、学习记忆、参考和优化记录。按需加载、精准更新、主动记录学习发现。

**触发**：用户说"更新任务"、"更新快照"、"记录一个决策"、"记录学习"、"添加参考资料"、"记一个优化点"、或在编码过程中需要查询规范/架构/知识时。

**10 种行为模式**：
1. 上下文恢复 — 读取 snapshot.md + tasks.md
2. 规范查询 — 读取 rules.md 确认编码规范
3. 架构查询 — 读取 architecture.md 了解技术决策
4. 知识回忆 — 读取 learned.md 获取 API/技巧/踩坑
5. 任务更新 — 修改 tasks.md
6. 快照更新 — 修改 snapshot.md
7. 决策记录 — 追加 architecture.md ADR
8. 学习记忆更新 — 追加 learned.md（API/踩坑/技巧）
9. 参考添加 — 追加 references.md
10. 优化点记录 — 追加 optimization.md

**核心原则**：按需加载、精准修改、主动学习

---

### 6. project-archivist

**描述**：项目归档器 - 智能清理 .claude/docs/ 文档膨胀，按条目级别判断（归档/简化保留/保留/删除/预警/提升/合并），生成审核计划后执行，所有移动留墓碑标记可追溯。

**触发**：用户说"归档"、"清理文档"、"压缩记忆"、"整理 learned"、"优化膨胀"、"清理优化记录"、"整理项目文档"、"释放上下文"、"减肥"。

**核心特性**：
- 七类判断框架：Archive / Simplify-Keep / Keep / Delete / Stale-Warn / Promote / Merge
- 两阶段工作流：Phase 1 分析产出 ARCHIVE-PLAN.md → Gate 1 用户审批 → Phase 2 执行
- 分文档判断标准：每个 `.claude/docs/` 文件有专属的判定规则
- 墓碑标记：所有归档条目原位留 `> Archived to archive.md §{文档} #{编号} {日期}` 可追溯
- 交叉引用检查：归档前自动扫描其他文档引用，防止断链
- 提升机制：learned.md 中 ≥2 次出现的模式自动建议提升到 rules.md
- rules.md 保护：永不自驱归档，仅标记建议审查

**与 project-docs-assistant 协调**：assistant 负责日常增改（只增不改），archivist 负责周期性清理（只减不增），两者互补。

**Phase 流程**：
```
Phase 1: ANALYZE → 读取全部文档 → 逐条目判断 → 交叉引用扫描 → 生成 ARCHIVE-PLAN.md
Gate 1: 用户审批（支持全部/按置信度/按类型/按文档/逐条目调整）
Phase 2: EXECUTE → Promote → Merge → Archive → Simplify → Delete → Stale-Warn
Gate 2: 验证（Tombstone 数量匹配、源文档无损坏）
```

---

## 安装

将 skill 目录复制到 `~/.claude/skills/`：

```bash
# 复制到用户 skill 目录
cp -r openspec-plan ~/.claude/skills/
cp -r openspec-act ~/.claude/skills/
cp -r plugin-loader ~/.claude/skills/
cp -r project-docs-assistant-ulw ~/.claude/skills/
cp -r project-docs-generator-ulw ~/.claude/skills/
cp -r project-archivist ~/.claude/skills/

# 验证安装
claude skill list
```

或使用 symbolic link（推荐）：

```bash
ln -s /path/to/ai-engineer-workflow/openspec-plan ~/.claude/skills/openspec-plan
ln -s /path/to/ai-engineer-workflow/openspec-act ~/.claude/skills/openspec-act
ln -s /path/to/ai-engineer-workflow/plugin-loader ~/.claude/skills/plugin-loader
ln -s /path/to/ai-engineer-workflow/project-docs-assistant-ulw ~/.claude/skills/project-docs-assistant-ulw
ln -s /path/to/ai-engineer-workflow/project-docs-generator-ulw ~/.claude/skills/project-docs-generator-ulw
ln -s /path/to/ai-engineer-workflow/project-archivist ~/.claude/skills/project-archivist
```

---

## 推荐组合

### 新项目初始化

```
project-docs-generator-ulw → 初始化文档体系 → project-docs-assistant-ulw → 日常维护
```

### 功能开发

```
openspec-plan → 需求探索 + 计划制定 → openspec-act → TDD 执行 + 验证归档
```

### 扩展能力

```
plugin-loader → 安装专业插件（Python/前端/K8s/安全等）
```

### 文档维护

```
project-docs-assistant-ulw → 日常增改（只增不改）
             ↓ 文档膨胀时
project-archivist → 智能归档清理（只减不增，审核先行）
```

---

## 核心方法论

### TDD Iron Law

```
NO CHANGE WITHOUT TEST WITNESS

三场景：
  New Feature：测试定义期望 → RED → 实现 → GREEN
  Bug Fix：测试复现问题 → RED → 修复 → GREEN
  Refactor：测试记录行为 → GREEN → 重构 → 保持 GREEN

禁止：
❌ 无测试直接变更代码
❌ 跳过 Verify Current/New State
❌ "太简单不用测"
❌ "先写代码再补测试"
```

### BDD 智能缺口

```
Gap Scan → AskUserQuestion → Scenario Sketch

扫描规则：
  Sad Path：检测 "失败/错误/异常/错误码/返回空"
  Edge Case：检测 "边界/空/最大/最小/超出"
  Error Handling：检测 "超时/网络/中断/重试/fallback"

用户选择：
  "用默认假设" → 自动生成场景草图
  "手动补充" → 询问具体缺口
  "跳过" → 记录缺口到 PLAN.md
```

### Requirements Integrity

```
需求完整性优先于实现简化

违规处理：
  发现未经用户确认的需求裁剪 → 立即报告 → 用户未 approve 前不得进入实现

"Simplicity First" 不能用于需求约束
```

---

## Red Flags（违规检测）

```
Phase 1:
❌ "Too simple to need design" → Gate 1 violation
❌ 未询问场景缺口 → BDD violation

Phase 2:
❌ TBD/TODO in plan → Lite Plan Check violation
❌ Requirements Traceability Matrix 未完成 → Gate 2 violation

Phase 3:
❌ 无测试变更代码 → Iron Law violation
❌ "Tests pass" without 输出片段 → Gate 5 violation
❌ 继续第 4 次相同修复 → 3-Failure violation

General:
❌ "Should/probably" → Verification violation
❌ Gate BLOCK 不记录 → Workflow violation
❌ 需求裁剪未经用户 approval → Requirements Integrity violation
```

---

## 版本历史

| 版本 | 更新内容 |
|------|----------|
| v6 | 工作流拆分为 openspec-plan + openspec-act，移除 CodeGraph 和 ULW |
| v5 | 新增 BDD 智能缺口、Requirements Integrity Gate、Auto Mode 适配 |
| v4 | 基础 workflow + TDD监察 + 六门控五循环 |

---

## 许可证

MIT License

---

## 相关链接

- [Claude Code Skills 文档](https://docs.anthropic.com/claude-code/skills)
- [claude-plugins-official](https://github.com/anthropics/claude-plugins-official)
- [claude-code-workflows](https://github.com/wshobson/agents)
- [claude-hud](https://github.com/jarrodwatts/claude-hud)