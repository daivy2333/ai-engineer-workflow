---
name: openspec-assistant
description: OpenSpec 文档助手 - 日常开发中按需读取 OpenSpec specs/ 和 .claude/docs/ 文档，维护任务、快照、架构决策、学习记忆、参考和优化记录。按需加载、精准更新、主动记录学习发现。TRIGGER when: 用户说"更新任务"、"更新快照"、"记录一个决策"、"记录学习"、"添加参考资料"、"记一个优化点"、或在编码过程中需要查询规范/架构/知识时。也可以自行决策主动更新 learned。
---

## OpenSpec Assistant

**日常开发的文档管家，基于 OpenSpec 体系，按需取用，精准更新，主动学习。**

此技能负责提醒 agent 更新和维护记忆，和工作流 skill 是协作关系，两者并不冲突。

superpowers 的 plan 和 spec 文件应当也生成到 .claude 文件夹下（如果要求冲突，生成位置以这个为准，路径是 .claude/docs/superpowers/，在这里生成 plan 和 spec 文件夹）

在 plan 阶段进行计划 write plan 写入的时候如果计划太长请分步写入，避免一次性思考和输出太长导致被截断

---

## 功能概述

此 Skill 用于：
1. **上下文恢复**：读取 `SNAPSHOT.md` + `tasks.md` 快速了解当前进度
2. **规范查询**：读取 `openspec/specs/rules/spec.md` 确认编码规范
3. **架构参考**：读取 `openspec/specs/architecture/spec.md` 了解技术决策
4. **知识回忆**：读取 `openspec/specs/learned/spec.md` 获取 API 路径、技巧、踩坑经验
5. **外部知识**：读取 `openspec/specs/references/spec.md` 查找依赖文档
6. **优化记录**：读取 `openspec/specs/optimization/spec.md` 查看优化点
7. **状态更新**：修改 `.claude/docs/tasks.md`、`.claude/docs/SNAPSHOT.md` 以反映最新进度
8. **知识积累**：向 `openspec/specs/*/spec.md` 追加新内容
9. **变更同步**：与 `openspec/changes/` 同步任务状态
10. **保持稳定**：修改文档时遵循 surgical changes 原则，只动必要部分
11. **知识索取**：遇到无法自行解决的知识盲区时，主动向用户提问索取

---

## 文档体系映射

### OpenSpec specs/（规范文档）

| 文件 | 原文件 | 用途 | 编号格式 |
|------|--------|------|----------|
| `openspec/specs/architecture/spec.md` | architecture.md | 架构决策记录 | <!-- A{编号} --> |
| `openspec/specs/rules/spec.md` | rules.md | 编码规范 | 无编号（规则不自驱归档） |
| `openspec/specs/learned/spec.md` | learned.md | 学习记忆 | <!-- L{编号} --> |
| `openspec/specs/references/spec.md` | references.md | 外部参考 | <!-- R{编号} --> |
| `openspec/specs/optimization/spec.md` | optimization.md | 优化记录 | <!-- O{编号} --> |

### .claude/docs/（状态文档）

| 文件 | 用途 | 编号格式 |
|------|------|----------|
| `.claude/docs/SNAPSHOT.md` | 项目状态快照 | 无编号 |
| `.claude/docs/tasks.md` | 全局任务追踪 | <!-- T{编号} --> |

### OpenSpec changes/（变更管理）

| 目录 | 用途 | 管理方式 |
|------|------|----------|
| `openspec/changes/<name>/` | 变更提案 | 由 OpenSpec CLI 管理 |
| `openspec/changes/<name>/proposal.md` | 为什么做、做什么 | /opsx:propose 生成 |
| `openspec/changes/<name>/specs/` | 增量规格 | /opsx:propose 生成 |
| `openspec/changes/<name>/design.md` | 技术方案 | /opsx:propose 生成 |
| `openspec/changes/<name>/tasks.md` | 实施清单 | /opsx:propose 生成 |

---

## 核心行为模式

### Pattern 1: 上下文恢复（Context Restore）

**触发**: 用户开始新会话、询问"当前进度"、"我们进行到哪了"

**动作**:
1. 读取 `CLAUDE.md`（入口）→ 了解文档体系
2. 读取 `.claude/docs/SNAPSHOT.md` → 获取项目状态、结构、最近修改
3. 读取 `.claude/docs/tasks.md` → 获取进行中和待办任务
4. 检查 `openspec list` → 查看活跃变更
5. 汇总呈现给用户

### Pattern 2: 规范查询（Rules Lookup）

**触发**: 编码前、用户问"编码规范是什么"、"我应该遵循什么原则"

**动作**:
1. 读取 `openspec/specs/rules/spec.md`（或仅必要章节）
2. 根据当前任务类型（新功能/修复/重构）提取相关铁律
3. 必要时提醒 Red Flags 检查

**协作说明**: CLAUDE.md 只做索引，rules/spec.md 是三大规则的唯一事实来源。workflow 技能也通过 rules/spec.md 章节引用获取原则定义。assistant 与此共享单一事实来源。

### Pattern 3: 架构查询（Architecture Lookup）

**触发**: 设计新功能、重构、评估影响范围

**动作**:
1. 读取 `openspec/specs/architecture/spec.md`
2. 提取相关决策，确认没有冲突
3. 如果新设计推翻旧决策，提醒用户记录新的 ADR

### Pattern 4: 知识回忆（Learned Recall）

**触发**: 需要 API 路径、文件位置、技巧、踩坑经验时

**动作**:
1. 读取 `openspec/specs/learned/spec.md`
2. 查找相关分类（API路径/文件速查/踩坑记录/技巧模式）
3. 提取有用的知识，避免重复探索

### Pattern 5: 任务更新（Task Update）

**触发**: 用户说"更新任务"、"我完成了 X"、"接下来的任务是 Y"

**动作**:
1. 读取 `.claude/docs/tasks.md`
2. 确定条目编号: 读取已有最大编号，新条目编号递增（格式: T01, T02, T03...）
3. 条目以 `<!-- T{编号} -->` 标记开头，支持 grep 精确定位
4. 根据用户描述修改进行中/待办/阻塞项
5. 将已完成项移到"最近完成"区域（可选）
6. 更新"下一步"计划
7. 写入文件（仅修改变化部分）

**与 changes/ 同步**:
- 如果任务来自某个 change，记录 change 名称
- change 完成后，更新 tasks.md 状态

### Pattern 6: 快照更新（Snapshot Update）

**触发**: 用户说"更新快照"、"同步项目状态"、"记录一下当前进度"

**动作**:
1. 扫描当前项目结构（如果变化不大可直接更新）
2. 检查 git 状态（分支、最近提交）
3. 更新 `.claude/docs/SNAPSHOT.md` 中的"最近修改"、Git 状态、项目结构等变动部分
4. 保留历史记录

### Pattern 7: 决策记录（Architecture Decision Record）

**触发**: 用户说"记录一个决策"、"我们决定用 X 而不是 Y"

**动作**:
1. 读取 `openspec/specs/architecture/spec.md`
2. 确定条目编号: 读取已有最大编号，新条目编号递增（格式: A01, A02, A03...）
3. 条目以 `<!-- A{编号} -->` 标记开头，支持 grep 精确定位
4. 在决策列表顶部追加新条目，包含：
   - 日期
   - 决策内容
   - 原因
   - 影响
   - 替代方案
5. 写入文件

### Pattern 8: 学习记忆更新（Learned Update）

**触发**: 探索发现新知识（API路径、文件位置、技巧、踩坑经验）

**动作**:
1. 读取 `openspec/specs/learned/spec.md`
2. 确定条目编号: 读取已有最大编号，新条目编号递增（格式: L01, L02, L03...）
3. 添加条目到对应分类：API路径 / 文件速查 / 踩坑记录 / 技巧模式
4. 条目以 `<!-- L{编号} -->` 标记开头，支持 grep 精确定位
5. 更新时间戳，保持表格格式
6. 复杂踩坑创建详细档案（症状/根因/解决/预防）

### Pattern 9: 参考添加（Reference Addition）

**触发**: 用户说"把这个链接加到参考"、"记录一下这个 API 的用法"

**动作**:
1. 读取 `openspec/specs/references/spec.md`
2. 确定条目编号: 读取已有最大编号，新条目编号递增（格式: R01, R02, R03...）
3. 条目以 `<!-- R{编号} -->` 标记开头，支持 grep 精确定位
4. 在适当区域追加新条目（依赖文档或领域知识笔记）
5. 简要总结关键概念（可选）

### Pattern 10: 优化点记录（Optimization Note）

**触发**: 用户说"记一个优化点"、"这里以后要改"、"先记下来，后面再优化"

**动作**:
1. 读取 `openspec/specs/optimization/spec.md`
2. 确定条目编号: 读取已有最大编号，新条目编号递增（格式: O01, O02, O03...）
3. 条目以 `<!-- O{编号} -->` 标记开头，支持 grep 精确定位
4. 追加新条目：描述问题、当前影响、建议方案
5. 写入文件

### Pattern 11: 知识索取（Knowledge Request）

**触发**: 遇到无法自行解决的知识盲区（最新领域知识、项目特有约定、外部系统信息等）

**判断标准（提问前必须检查）**:
- 已检查 openspec/specs/learned/spec.md 无记录
- 已尝试 grep/read 代码无结果
- 已尝试 WebSearch 无效（除非是项目特有知识）
- 该知识确实阻塞当前任务进度

**动作**:
1. 构造精准提问：说明需要什么知识、为什么需要、当前任务目标
2. 使用 AskUserQuestion 向用户索取
3. 用户返回信息后确认理解，继续工作
4. 完成后更新 openspec/specs/learned/spec.md，记录新知识及来源

**不应索取的情况**:
- 通用编程知识 → 自己搜索
- 可从代码推断 → grep/read
- 已在 learned/spec.md → 直接使用
- 可先用假设方案 → 失败后再问

### Pattern 12: 变更同步（Change Sync）

**触发**: 用户创建/完成 OpenSpec 变更、运行 /opsx:propose 或 /opsx:archive

**动作**:
1. 检查 `openspec list` → 获取活跃变更列表
2. 对每个活跃变更：
   - 读取 `openspec/changes/<name>/tasks.md` → 获取变更任务清单
   - 同步到 `.claude/docs/tasks.md`（标记来源 change）
3. 对已完成变更：
   - 更新 `.claude/docs/tasks.md` 中对应任务状态
   - 检查是否需要更新 SNAPSHOT.md
4. 归档变更时：
   - 从 tasks.md 移除已完成任务
   - 更新 SNAPSHOT.md 记录归档

---

## 按需读取策略（避免上下文污染）

根据用户意图，只读取必要的 1-3 个文档：

| 用户意图 | 应读取的文档 | 可能的写入 |
|----------|-------------|-----------|
| 开始新会话 | CLAUDE.md → SNAPSHOT.md → tasks.md | — |
| 写新功能 | specs/rules/ + specs/architecture/ + specs/learned/ | tasks.md, specs/learned/ |
| 修复 Bug | specs/rules/ + SNAPSHOT.md + specs/learned/ | tasks.md, specs/learned/（踩坑） |
| 重构 | specs/architecture/ + specs/optimization/ + specs/rules/ | specs/architecture/ |
| 查阅 API | specs/learned/ → specs/references/ | — |
| 更新进度 | tasks.md | tasks.md, SNAPSHOT.md |
| 记录决策 | specs/architecture/ | specs/architecture/ |
| 记录学习发现 | specs/learned/ | specs/learned/ |
| 记录参考 | specs/references/ | specs/references/ |
| 记录优化点 | specs/optimization/ | specs/optimization/ |
| 遇到知识盲区 | specs/learned/ → 判断 → AskUserQuestion | specs/learned/ |
| 创建变更 | /opsx:explore 或 /opsx:propose | openspec/changes/ |
| 查看变更 | openspec list | — |

---

## 知识快速索引技巧（Grep Search）

**核心思想**：Markdown 文档是文本，grep 搜索比完整读取更快、更精准。

### 适用场景

| 场景 | grep 命令 | 效果 |
|------|-----------|------|
| 查 API 路径 | `grep "API" openspec/specs/learned/spec.md` | 1 秒定位，无需读全文 |
| 找踩坑记录 | `grep -i "坑" openspec/specs/learned/spec.md` | 快速跳到相关条目 |
| 搜索决策 | `grep -i "决定" openspec/specs/architecture/spec.md` | 瞬间定位 ADR |
| 查某模块 | `grep "模块名" .claude/docs/SNAPSHOT.md` | 找关键文件位置 |
| 搜索规范 | `grep "关键词" openspec/specs/rules/spec.md` | 定位规范条目 |

### grep 搜索优于读取的情况

- **文档已分类/表格化** → learned/references 的表格结构，grep 直接命中
- **关键词明确** → 知道要找 "认证"、"缓存"、"XXX API"，grep 瞬间定位
- **快速验证** → "之前有没有记录过这个？" → grep 确认有无
- **跨文档搜索** → `grep -r "关键词" openspec/specs/` 全目录搜索

### 何时仍需完整读取

- **上下文恢复** → 新会话开始，需要综合了解项目状态
- **浏览决策历史** → architecture 的决策列表需要通读理解脉络
- **学习未知领域** → 不确定关键词时，先读文档结构

### 实用 grep 模式

```bash
# 搜索 API 路径（learned 表格结构）
grep "| .*\| .*\|" openspec/specs/learned/spec.md | grep "关键词"

# 搜索踩坑档案标题
grep "^###" openspec/specs/learned/spec.md

# 搜索决策日期
grep -E "^\d{4}-\d{2}-\d{2}" openspec/specs/architecture/spec.md

# 全 specs 目录搜索
grep -rn "关键词" openspec/specs/

# 搜索 OpenSpec 变更
openspec list | grep "关键词"
```

---

## 文档修改铁律（Surgical Changes 在文档层面的应用）

- 只修改与用户请求直接相关的文档部分
- 不"顺便"调整格式、重写其他无关条目
- 添加新内容时使用分隔线明确新老边界
- 保持文档的 Markdown 结构稳定
- 时间戳自动更新只在被修改的文件中
- **禁止全量覆盖写入** — 更新文档时必须使用 Edit（精准替换）而非 Write（全文覆盖），确保未被涉及的内容不被丢弃。只有创建全新文件时才使用 Write

---

## learned/spec.md 主动更新原则

```
核心原则：不重复探索已发现的知识

Agent 在以下情况应主动更新 learned/spec.md：

✅ 新发现的 API/接口 → 记录路径和用法
✅ 关键文件位置 → 记录路径速查
✅ 解决棘手问题 → 记录踩坑经验
✅ 学到新技巧 → 记录技巧模式
✅ 理清依赖关系 → 更新依赖图
✅ 发现未知领域 → 记录待探索
✅ 用户提供的知识 → 记录内容及来源（Pattern 11 索取后）

每次更新：
  1. 更新 "最后更新" 时间戳
  2. 添加新条目到对应分类
  3. 保持表格格式一致
  4. 复杂问题创建详细踩坑档案
```

---

## 与 OpenSpec CLI 的集成

### 常用命令

```bash
# 查看活跃变更
openspec list

# 查看变更详情
openspec show <change-name>

# 查看变更状态
openspec status --change <change-name>

# 验证变更
openspec validate --changes

# 归档变更
openspec archive <change-name>
```

### 同步时机

| 事件 | 动作 |
|------|------|
| 用户运行 `/opsx:propose` | 检查新变更，同步任务到 tasks.md |
| 用户运行 `/opsx:apply` | 更新 tasks.md 中任务状态 |
| 用户运行 `/opsx:archive` | 从 tasks.md 移除已完成任务，更新 SNAPSHOT.md |
| 用户手动创建 change | 检测新目录，同步任务 |

---

## 关键原则

```
按需加载，避免上下文浪费
精准修改，不碰无关文档
保持稳定，只更新变化部分
知识积累，渐进式充实参考和优化
知识积累只增不减，不允许主动删除文档内容
禁止全量覆盖，更新文档时必须用 Edit 而非 Write，保护原有内容不被意外丢失
主动学习，探索发现即时记录
所有更新均保留历史轨迹
不重复探索已发现的知识
知识索取，实在无法解决才提问，提问必须精准说明原因
与 OpenSpec CLI 无缝集成，变更状态双向同步
```

---

## Red Flags

```
❌ 读取不需要的文档 → 上下文污染
❌ 修改无关文档部分 → Surgical Changes 违规
❌ 全量覆盖写入 → 内容丢失风险
❌ 不检查已有内容就添加 → 重复记录
❌ 知识不记录 → 重复探索
❌ 不更新时间戳 → 时序混乱
❌ 编号冲突 → grep 定位错误
❌ 不同步 changes/ 状态 → 任务状态不一致
❌ 跳过 OpenSpec CLI 直接操作 changes/ → 元数据不更新
```
