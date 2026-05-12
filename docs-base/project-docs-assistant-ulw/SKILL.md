---
name: project-docs-assistant
description: 项目文档助手 - 日常开发中按需读取 .claude/docs/ 文档，维护任务、快照、架构决策、学习记忆、参考和优化记录。按需加载、精准更新、主动记录学习发现。TRIGGER when: 用户说"更新任务"、"更新快照"、"记录一个决策"、"记录学习"、"添加参考资料"、"记一个优化点"、或在编码过程中需要查询规范/架构/知识时。也可以自行决策主动更新 learned.md。
---

## Project Docs Assistant

**日常开发的文档管家，按需取用，精准更新，主动学习。**

---

## 功能概述

此 Skill 用于：
1. **上下文恢复**：读取 `snapshot.md` + `tasks.md` 快速了解当前进度
2. **规范查询**：读取 `rules.md` 确认编码规范
3. **架构参考**：读取 `architecture.md` 了解技术决策
4. **知识回忆**：读取 `learned.md` 获取 API 路径、技巧、踩坑经验
5. **外部知识**：读取 `references.md` 查找依赖文档
6. **状态更新**：修改 `tasks.md`、`snapshot.md` 以反映最新进度
7. **知识积累**：向 `architecture.md`、`learned.md`、`references.md`、`optimization.md` 追加新内容
8. **保持稳定**：修改文档时遵循 surgical changes 原则，只动必要部分

---

## 核心行为模式

### Pattern 1: 上下文恢复（Context Restore）

**触发**: 用户开始新会话、询问"当前进度"、"我们进行到哪了"

**动作**:
1. 读取 `CLAUDE.md`（入口）→ 了解文档体系
2. 读取 `.claude/docs/snapshot.md` → 获取项目状态、结构、最近修改
3. 读取 `.claude/docs/tasks.md` → 获取进行中和待办任务
4. 汇总呈现给用户

### Pattern 2: 规范查询（Rules Lookup）

**触发**: 编码前、用户问"编码规范是什么"、"我应该遵循什么原则"

**动作**:
1. 读取 `.claude/docs/rules.md`（或仅必要章节）
2. 根据当前任务类型（新功能/修复/重构）提取相关铁律
3. 必要时提醒 Red Flags 检查

### Pattern 3: 架构查询（Architecture Lookup）

**触发**: 设计新功能、重构、评估影响范围

**动作**:
1. 读取 `.claude/docs/architecture.md`
2. 提取相关决策，确认没有冲突
3. 如果新设计推翻旧决策，提醒用户记录新的 ADR

### Pattern 4: 知识回忆（Learned Recall）

**触发**: 需要 API 路径、文件位置、技巧、踩坑经验时

**动作**:
1. 读取 `.claude/docs/learned.md`
2. 查找相关分类（API路径/文件速查/踩坑记录/技巧模式）
3. 提取有用的知识，避免重复探索

### Pattern 5: 任务更新（Task Update）

**触发**: 用户说"更新任务"、"我完成了 X"、"接下来的任务是 Y"

**动作**:
1. 读取 `.claude/docs/tasks.md`
2. 根据用户描述修改进行中/待办/阻塞项
3. 将已完成项移到"最近完成"区域（可选）
4. 更新"下一步"计划
5. 写入文件（仅修改变化部分）

### Pattern 6: 快照更新（Snapshot Update）

**触发**: 用户说"更新快照"、"同步项目状态"、"记录一下当前进度"

**动作**:
1. 扫描当前项目结构（如果变化不大可直接更新）
2. 检查 git 状态（分支、最近提交）
3. 更新 `.claude/docs/snapshot.md` 中的"最近修改"、Git 状态、项目结构等变动部分
4. 保留历史记录

### Pattern 7: 决策记录（Architecture Decision Record）

**触发**: 用户说"记录一个决策"、"我们决定用 X 而不是 Y"

**动作**:
1. 读取 `.claude/docs/architecture.md`
2. 在决策列表顶部追加新条目，包含：
   - 日期
   - 决策内容
   - 原因
   - 影响
   - 替代方案
3. 写入文件

### Pattern 8: 学习记忆更新（Learned Update）

**触发**: 探索发现新知识（API路径、文件位置、技巧、踩坑经验）

**动作**:
1. 读取 `.claude/docs/learned.md`
2. 添加条目到对应分类：API路径 / 文件速查 / 踩坑记录 / 技巧模式
3. 更新时间戳，保持表格格式
4. 复杂踩坑创建详细档案（症状/根因/解决/预防）

### Pattern 9: 参考添加（Reference Addition）

**触发**: 用户说"把这个链接加到参考"、"记录一下这个 API 的用法"

**动作**:
1. 读取 `.claude/docs/references.md`
2. 在适当区域追加新条目（依赖文档或领域知识笔记）
3. 简要总结关键概念（可选）

### Pattern 10: 优化点记录（Optimization Note）

**触发**: 用户说"记一个优化点"、"这里以后要改"、"先记下来，后面再优化"

**动作**:
1. 读取 `.claude/docs/optimization.md`
2. 追加新条目：描述问题、当前影响、建议方案
3. 写入文件

---

## 按需读取策略（避免上下文污染）

根据用户意图，只读取必要的 1-3 个文档：

| 用户意图 | 应读取的文档 | 可能的写入 |
|----------|-------------|-----------|
| 开始新会话 | CLAUDE.md → snapshot.md → tasks.md | - |
| 写新功能 | rules.md + architecture.md + learned.md | tasks.md, learned.md |
| 修复 Bug | rules.md + snapshot.md + learned.md | tasks.md, learned.md（踩坑） |
| 重构 | architecture.md + optimization.md + rules.md | architecture.md |
| 查阅 API | learned.md → references.md | - |
| 更新进度 | tasks.md | tasks.md, snapshot.md |
| 记录决策 | architecture.md | architecture.md |
| 记录学习发现 | learned.md | learned.md |
| 记录参考 | references.md | references.md |
| 记录优化点 | optimization.md | optimization.md |

---

## 文档修改铁律（Surgical Changes 在文档层面的应用）

- 只修改与用户请求直接相关的文档部分
- 不"顺便"调整格式、重写其他无关条目
- 添加新内容时使用分隔线明确新老边界
- 保持文档的 Markdown 结构稳定
- 时间戳自动更新只在被修改的文件中

---

## learned.md 主动更新原则

```
核心原则：不重复探索已发现的知识

Agent 在以下情况应主动更新 learned.md：

✅ 新发现的 API/接口 → 记录路径和用法
✅ 关键文件位置 → 记录路径速查
✅ 解决棘手问题 → 记录踩坑经验
✅ 学到新技巧 → 记录技巧模式
✅ 理清依赖关系 → 更新依赖图
✅ 发现未知领域 → 记录待探索

每次更新：
  1. 更新 "最后更新" 时间戳
  2. 添加新条目到对应分类
  3. 保持表格格式一致
  4. 复杂问题创建详细踩坑档案
```

---

## 关键原则

```
按需加载，避免上下文浪费
精准修改，不碰无关文档
保持稳定，只更新变化部分
知识积累，渐进式充实参考和优化
主动学习，探索发现即时记录
所有更新均保留历史轨迹
不重复探索已发现的知识
```