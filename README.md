# AI Engineer Workflow Skill Collection

> Claude Code 技能集合：AI 工程师工作流程、项目文档管理、插件生态

---

## 概述

本项目包含 5 个 Claude Code 技能（Skills），用于：

1. **开发流程管理** — AI Engineer Workflow V5（TDD监察、BDD智能缺口、零妥协验证）
2. **项目文档管理** — 文档生成器 + 日常助手
3. **插件生态** — 管理 3 个 marketplace 的专业插件

---

## 技能列表

### 1. ai-engineer-workflow-v5

**描述**：V4 + TDD监察 + BDD智能缺口。强化验证、防止蔓延、架构反思、需求完整性、TDD铁律、智能场景澄清。

**触发**：实现功能、修复 bug、重构、需要完整开发流程时。

**核心特性**：
- 四系统协作：workflow（执行）→ Karpathy（监察）→ BDD（缺口发现）→ TDD（测试）
- 六个门控（GATES）：Design Approval → Requirements Completeness → Test Witness → Two-Stage Review → Evidence-Based Verification → Stop-On-Blocker
- 五个循环（LOOPS）：Clarification → Plan Revision → Red-Green-Refactor → Review-Fix → Complete Decision
- BDD 智能缺口：自动扫描 Happy/Sad/Edge → 用户选择 → 场景草图
- TDD Iron Law：NO CHANGE WITHOUT TEST WITNESS
- Auto Mode 适配

**Phase 流程**：
```
Phase 1: CLARIFY → brainstorming skill → Approved Requirements + Scenario Sketch
Phase 2: PLAN → Plan Agent + writing-plans → Gate 2 → Requirements Completeness
Phase 3: EXECUTE → executing-plans / subagent-driven-development → TDD 循环
Phase 5: COMPLETE → finishing-a-development-branch → Merge/PR/Keep/Discard
```

---

### 2. ai-engineer-workflow-v5-ulw

**描述**：UltraWork V5 + TDD监察 + BDD智能缺口。强制探索、Plan Agent、深度委托、Manual QA、零妥协、Auto-mode aware。

**触发**：复杂任务、需要并行探索、强制委托时。

**UltraWork 特性**（相比 v5）：
- **强制探索**：Phase 1 必须并行启动 explore + librarian + Metis
- **Plan Agent MANDATORY**：Phase 2 必须调用 plan agent + Momus 评审
- **深度委托**：Phase 3 不直接写代码，必须委托到 category（deep/ultrabrain/visual-engineering/artistry/quick）
- **Manual QA 零妥协**：Gate 5 必须实际运行验证（CLI/构建/API/UI）
- **阻塞咨询**：oracle 用于架构决策/复杂 debug

**Phase 流程**：
```
Phase 1: 并行 explore/librarian → Metis 阻塞 → Gap Scan → AskUserQuestion
Phase 2: plan agent（MANDATORY）→ Momus 阻塞 → Gate 2
Phase 3: category delegation（并行）→ oracle（阻塞）→ Gate 5 Manual QA
Phase 5: review-work（5 parallel）+ git-master → END
```

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

## 安装

将 skill 目录复制到 `~/.claude/skills/`：

```bash
# 复制到用户 skill 目录
cp -r ai-engineer-workflow-v5 ~/.claude/skills/
cp -r ai-engineer-workflow-v5-ulw ~/.claude/skills/
cp -r plugin-loader ~/.claude/skills/
cp -r project-docs-assistant-ulw ~/.claude/skills/
cp -r project-docs-generator-ulw ~/.claude/skills/

# 验证安装
claude skill list
```

或使用 symbolic link（推荐）：

```bash
ln -s /path/to/ai-engineer-workflow/ai-engineer-workflow-v5 ~/.claude/skills/ai-engineer-workflow-v5
ln -s /path/to/ai-engineer-workflow/ai-engineer-workflow-v5-ulw ~/.claude/skills/ai-engineer-workflow-v5-ulw
ln -s /path/to/ai-engineer-workflow/plugin-loader ~/.claude/skills/plugin-loader
ln -s /path/to/ai-engineer-workflow/project-docs-assistant-ulw ~/.claude/skills/project-docs-assistant-ulw
ln -s /path/to/ai-engineer-workflow/project-docs-generator-ulw ~/.claude/skills/project-docs-generator-ulw
```

---

## 推荐组合

### 新项目初始化

```
project-docs-generator-ulw → 初始化文档体系 → project-docs-assistant-ulw → 日常维护
```

### 复杂功能开发

```
ai-engineer-workflow-v5-ulw → 并行探索 + 强制委托 + Manual QA
```

### 简单功能/修复

```
ai-engineer-workflow-v5 → 基础 workflow + TDD/BDD
```

### 扩展能力

```
plugin-loader → 安装专业插件（Python/前端/K8s/安全等）
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
| v5 | 新增 BDD 智能缺口、Requirements Integrity Gate、Auto Mode 适配 |
| v5-ulw | UltraWork 版本：强制探索、Plan Agent MANDATORY、深度委托、Manual QA 零妥协 |
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