---
name: project-docs-generator
description: 项目文档生成器 - 为项目初始化完整的 .claude/ 文档体系（7 份单一职责文档）。TRIGGER when: 用户想要初始化项目文档、设置项目规则、创建 CLAUDE.md 体系、或说"初始化项目约束"、"生成项目文档"等。
---

## Project Docs Generator

**一次性生成 7 份项目文档，构建 Agent 的知识地基。**

---

## 执行流程

### Phase 1: 项目扫描

```
扫描项目：
  1. 检测项目类型（Python/JS/Go/Rust/Mixed）
  2. 检测项目规模（小型/中型/大型）
  3. 检测现有 .claude/ 目录和文档
  4. 分析源码目录结构、关键文件
  5. 提取技术栈（Cargo.toml/package.json/go.mod/requirements.txt 等）
  6. 检查 git 状态（分支、最近提交）
```

### Phase 2: 生成文档体系

```
按顺序生成以下 7 份文档：

  1. CLAUDE.md           - 入口索引
  2. .claude/docs/rules.md    - 编码规范（三大规则体系）
  3. .claude/docs/architecture.md - 架构决策记录
  4. .claude/docs/snapshot.md - 项目状态快照
  5. .claude/docs/tasks.md    - 任务清单
  6. .claude/docs/references.md - 外部参考资料
  7. .claude/docs/optimization.md - 优化方向与技术债务
```

### Phase 3: 验证与报告

```
验证：
  - 所有 7 份文件已创建
  - CLAUDE.md 指针路径正确
  - rules.md 包含完整三大规则
  - snapshot.md 反映当前项目状态

报告：
  - 列出已创建文档及位置
  - 提醒：日常维护请用 project-docs-assistant
```

---

## 文档模板

### 1. CLAUDE.md

```markdown
# CLAUDE.md

> 项目文档入口 | 上次更新：{timestamp}

## 项目简介

{一句话描述}

## 技术栈

- **语言**: {language}
- **构建**: {build_tool}
- **测试**: {test_framework}
- **格式化**: {formatter}

## 文档体系

| 文档 | 用途 | 何时读取 |
|------|------|----------|
| [rules.md](.claude/docs/rules.md) | 编码规范 | 编码前 |
| [architecture.md](.claude/docs/architecture.md) | 架构决策 | 设计/重构时 |
| [snapshot.md](.claude/docs/snapshot.md) | 项目状态 | 恢复上下文时 |
| [tasks.md](.claude/docs/tasks.md) | 任务清单 | 开始任务时 |
| [references.md](.claude/docs/references.md) | 参考资料 | 查阅技术细节时 |
| [optimization.md](.claude/docs/optimization.md) | 优化方向 | 优化迭代前 |
```

### 2. .claude/docs/rules.md

```markdown
# 编码规范与行为约束

> 更新：{timestamp} | 项目：{project_name}

---

## 一、Karpathy Guidelines

### 1. Think Before Coding
**不假设。不隐藏困惑。暴露权衡。**

- 实现前明确陈述假设，不确定就问
- 多种解读时全部呈现，不 silently 选择
- 更简单方法存在时说出来
- 不清楚时 STOP，命名困惑点并询问

### 2. Simplicity First
**最小代码解决问题。无投机性功能。**

- 不添加未被要求的功能
- 单次使用代码不抽象
- 未要求的灵活性不加
- 200 行能减到 50 行，重写

### 3. Surgical Changes
**只改必须改。只清理自己的烂摊子。**

- 不"改进"相邻代码、注释、格式
- 不重构没坏的东西
- 匹配现有风格
- 删除自己改动导致的未用代码

### 4. Goal-Driven Execution
**定义成功标准。循环直到验证。**

- 任务转化为可验证目标
- 多步任务简述计划：`[步骤] → verify: [检查]`

---

## 二、务实编码原则

### 十大铁律

1. **命名即文档** - 名称揭示意图，用领域语言
2. **函数单一职责** - < 20 行，只做一件事
3. **DRY & 正交性** - 三次法则，模块独立
4. **显式胜于隐式** - 依赖显式注入，避免全局状态
5. **健壮边界** - 核心业务与框架解耦
6. **可测试设计** - 纯函数优于有状态函数
7. **尽早重构** - 看到坏味道立即小步重构
8. **务实破窗** - 发现问题立即修复
9. **自动化检查** - 提交前运行格式化、静态分析、测试
10. **注释解释意图** - 只注释"为什么"

---

## 三、Workflow Designer

### 核心概念
- **Phase**: 逻辑分组，有进入/退出条件
- **Gate**: 检查点，PASS/BLOCK
- **Task**: 最小执行单元，可验证
- **Loop**: 重复机制，有循环/退出条件

### 执行铁律
1. Phase 进入前 Gate PASS
2. Task 完成必须展示证据
3. Gate BLOCK 必须记录原因

---

## 检查清单

- [ ] 命名清晰
- [ ] 函数单一职责
- [ ] 无重复代码
- [ ] 依赖显式注入
- [ ] 核心逻辑有测试
- [ ] 已运行格式化和静态分析
- [ ] 只改必须改的代码

## Red Flags

❌ 假设不明确 → STOP，问
❌ 过度复杂 → 简化
❌ 改动超出请求 → 回滚
❌ 顺手添加功能 → Karpathy 违规
```

### 3. .claude/docs/architecture.md

```markdown
# 架构决策记录

> 记录关键决策及其背景

## 决策列表

### {DATE} - 项目初始化
- **决策**: 采用 {技术栈}
- **原因**: {原因}
- **影响**: {影响}
- **替代方案**: {其他方案}
```

### 4. .claude/docs/snapshot.md

```markdown
# 项目快照

> 更新：{timestamp}

## 当前状态

- **阶段**: 初始化
- **状态**: 正常

## 项目结构

```
{目录树}
```

## 技术栈

| 类别 | 技术 | 版本 |
|------|------|------|
| 语言 | {language} | {version} |

## Git 状态

- **分支**: {branch}
- **最近提交**: {last_commit}

## 关键文件

| 文件 | 作用 |
|------|------|
| {file} | {purpose} |

## 最近修改

| 时间 | 文件 | 改动 |
|------|------|------|
| {time} | {file} | {type} |
```

### 5. .claude/docs/tasks.md

```markdown
# 任务清单

> 更新：{timestamp}

## 进行中

- [ ] （无）

## 待办

- [ ] （待填充）

## 阻塞

- （无）

## 下一步

- 开始首个功能开发
```

### 6. .claude/docs/references.md

```markdown
# 外部参考资料

## 核心依赖

| 依赖 | 文档 | 概要 |
|------|------|------|
| {dep} | {url} | {summary} |
```

### 7. .claude/docs/optimization.md

```markdown
# 优化方向与技术债务

## 已识别优化点

（暂无）

## 技术债务

（暂无）
```

---

## 已存在文档时的处理

若 `.claude/docs` 已存在：
1. 提示用户："已存在文档体系，是否覆盖/合并？"
2. 覆盖：重新生成所有文档
3. 合并：保留已有决策/任务/参考，更新 snapshot 和 rules

---

## 关键原则

```
7 文档单一职责
完整嵌入三大规则
根据项目类型适配示例
初始化后由 assistant 维护
```