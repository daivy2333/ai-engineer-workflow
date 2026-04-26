# AI Engineer Workflow

**Optimized AI Engineer workflow with evidence-based verification, surgical changes detection, and requirements integrity gate.**

---

## 项目简介

AI Engineer Workflow 是一个结构化的 AI 辅助开发工作流，专为高质量软件工程设计。核心特点：

- **六门控系统 (Gates)**: 设计审批 → 需求完整性 → 测试优先 → 双阶段评审 → 证据验证 → 阻塞停止
- **五循环系统 (Loops)**: 澄清 → 计划修订 → 红绿重构 → 审查修复 → 完成决策
- **Karpathy 监察**: Think Before Coding, Implementation Simplicity, Requirements Integrity, Surgical Changes
- **Auto Mode**: 支持无人值守自动运行

---

## 项目结构

```
ai-engineer-workflow/
├── ai-engineer-workflow-v4-ulw/     # UltraWork 模式 (GSD 集成版)
│   └── SKILL.md
├── ai-engineer-workflow-v4/         # 标准优化版
│   └── SKILL.md
└── README.md
```

---

## 依赖的 Skills

### 核心 Phase Skills

| Phase | Skill | 用途 |
|-------|-------|------|
| Phase 1 | `brainstorming` | 需求澄清与范围确认 |
| Phase 2 | `writing-plans` | 计划编写与完整性检查 |
| Phase 3 | `executing-plans` | 计划执行 (Inline 模式) |
| Phase 3 | `subagent-driven-development` | 计划执行 (并行 Subagent 模式) |
| Phase 5 | `finishing-a-development-branch` | 完成与分支决策 |

### 辅助 Skills

| Skill | 用途 |
|-------|------|
| `superpowers:brainstorming` | 头脑风暴与需求挖掘 |
| `superpowers:writing-plans` | 结构化计划编写 |
| `superpowers:executing-plans` | 计划执行引擎 |
| `superpowers:subagent-driven-development` | 多任务并行执行 |
| `superpowers:finishing-a-development-branch` | 分支完成决策 |
| `superpowers:requesting-code-review` | 代码审查请求 |
| `superpowers:receiving-code-review` | 代码审查接收 |
| `superpowers:verification-before-completion` | 完成前验证 |
| `gsd-*` 系列 | GSD 项目管理技能 |

---

## 标准工作流

### Claude Code 使用 (推荐)

Claude Code 使用完整版 `ai-engineer-workflow-v4` 技能:

```
/ai-engineer-workflow-v4-ulw
```

**Phase 流程:**
```
Phase 1 (CLARIFY) → brainstorming skill → Requirements List → [Gate 1]
Phase 2 (PLAN) → writing-plans skill → Requirements Completeness Check → [Gate 2]
Phase 3 (EXECUTE) → executing-plans / subagent-driven-development → [Gate 3/4/5/6]
Phase 5 (COMPLETE) → finishing-a-development-branch → [Gate 5] → END
```

**关键约束:**
- 不探索清楚不实现
- 不计划清楚不实现
- 不完整覆盖需求不实现
- 不测试通过不提交
- 不验证成功不声明

---

### OpenCode 使用 (omo 模式)

OpenCode 使用 `ai-engineer-workflow-v4-ulw` 配合 omo 插件:

```
/ai-engineer-workflow-v4
```

**OpenCode 专用工作流:**

```
1. 启动 UltraWork 模式
   /ai-engineer-workflow-v4-ulw

2. 或使用 omo 命令
   omo workflow --mode ultrawork
```

**omo 模式特点:**
- 内置 session 管理
- 自动上下文保存/恢复
- 并行任务协调
- 进度跟踪与报告

---

## Quick Start

### Claude Code

```bash
# 启动 AI Engineer Workflow
/ai-engineer-workflow-v4

# 按提示进行 Phase 1-5
```

### OpenCode + omo

```bash
# 初始化项目
omo init

# 启动工作流
omo workflow --mode ultrawork --project ./my-project

# 或使用内置命令
/ai-engineer-workflow-v4-ulw
```

---

## 门控检查清单

| Gate | 检查项 | 通过条件 |
|------|--------|----------|
| Gate 1 | Design Approval | 用户批准 Requirements List |
| Gate 2 | Requirements Completeness | Requirements Traceability Matrix 完整，无 Missing |
| Gate 3 | Test-First | 测试存在且 FAIL (feature missing) |
| Gate 4 | Two-Stage Review | Spec compliance → Code quality 顺序执行 |
| Gate 5 | Evidence-Based | 有命令输出证据，无 "应该/大概" |
| Gate 6 | Stop-On-Blocker | 3次失败触发架构反思 |

---

## Red Flags (红线)

```
❌ Code before design approved (Gate 1 violation)
❌ TBD/TODO in plan (Gate 2 violation)
❌ Code before test (Gate 3 violation)
❌ "Tests pass" without running (Gate 5 violation)
❌ 变更超出 PLAN 范围 (Surgical Changes violation)
❌ 3次相同修复失败未反思 (3-Failure violation)
❌ 用"实现简单"偷换"需求满足" (Requirements Integrity violation)
```
