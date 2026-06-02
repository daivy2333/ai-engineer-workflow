---
name: openspec-archivist
description: OpenSpec 归档器 - 智能清理 openspec/specs/ 和 .claude/docs/ 文档膨胀，按条目级别判断（归档/简化保留/保留/删除/预警/提升/合并），分析后对话展示摘要+模糊条目交用户判定，确认后直接执行，所有移动留墓碑标记可追溯。TRIGGER when: 用户说"归档"、"清理文档"、"压缩记忆"、"整理 learned"、"优化膨胀"、"清理优化记录"、"整理项目文档"、"释放上下文"、"减肥"、"清理 tasks"、"清理 SNAPSHOT"、"清理 references"、"整理归档"。
---

# OpenSpec Archivist — 项目归档器

**按条目级别智能清理文档膨胀，审核先行，不可逆操作留墓碑可追溯。**

---

## 功能概述

此 Skill 用于：
1. **分析** `openspec/specs/` 和 `.claude/docs/` 全部文档，逐条目判断膨胀程度
2. **审核** 展示分析摘要 + 模糊条目，用户判定后直接执行
3. **执行** 归档/简化/删除/提升/合并，所有移动留 Tombstone 标记
4. **OpenSpec 集成** 利用 `openspec archive` 命令管理变更归档
5. **可追溯** 每条归档记录含日期、理由、置信度、交叉引用、恢复条件

**触发方式**：仅用户显式调用（说"归档"等），不基于文件大小自动触发。

---

## 文档体系映射

### 清理目标

| 文档 | 路径 | 编号格式 | 清理策略 |
|------|------|----------|----------|
| 架构决策 | `openspec/specs/architecture/spec.md` | <!-- A{编号} --> | 按 ADR 判断框架 |
| 编码规范 | `openspec/specs/rules/spec.md` | 无编号 | 永不自驱归档，只标记 |
| 学习记忆 | `openspec/specs/learned/spec.md` | <!-- L{编号} --> | 按 learned 判断框架 |
| 外部参考 | `openspec/specs/references/spec.md` | <!-- R{编号} --> | 按 references 判断框架 |
| 优化记录 | `openspec/specs/optimization/spec.md` | <!-- O{编号} --> | 按 optimization 判断框架 |
| 项目快照 | `.claude/docs/SNAPSHOT.md` | 无编号 | 按 SNAPSHOT 判断框架 |
| 任务追踪 | `.claude/docs/tasks.md` | <!-- T{编号} --> | 按 tasks 判断框架 |
| OpenSpec 变更 | `openspec/changes/` | 目录名 | 用 `openspec archive` 归档 |

### 归档目标

| 归档方式 | 目标 | 说明 |
|----------|------|------|
| 内部归档 | `openspec/specs/*/spec.md` 历史区 | 保留原文件，移到"已完成"或"历史"区域 |
| OpenSpec 归档 | `openspec archive` | 用 OpenSpec CLI 归档变更 |
| 墓碑标记 | 原位 | 留 `<!-- tombstone: ... -->` 标记可追溯 |

---

## 核心约束

```
1. 用户显式触发，不自动建议 — 不基于文件大小或条目数自动触发
2. 审核先行 — 分析结果必须展示给用户审阅，模糊条目需用户判定
3. 确认后执行 — 用户 approve 前不执行任何删除/移动
4. 移动留碑 — 所有归档条目留 Tombstone 标记
5. 交叉引用必查 — 归档前扫描其他文档是否引用该条目，防断链
6. 规则不动 — rules/spec.md 从不自驱归档，仅可标记"建议审查"
7. OpenSpec 优先 — OpenSpec 变更用 `openspec archive` 归档，不手动操作
8. 禁止全量覆盖 — 更新已有文档时必须使用 Edit（精准替换）而非 Write（全文覆盖），确保未被涉及的内容不被丢弃。只有创建全新文件（如首次创建 archive.md）才使用 Write
```

**与 openspec-assistant 协调**：
- assistant 负责**日常增改**（12 种行为模式）
- archivist 负责**周期性清理**（判断 + 归档 + 精简）
- 两者互不冲突：assistant 只增不改，archivist 只减不增

**与 OpenSpec CLI 协调**：
- OpenSpec 变更（changes/）用 `openspec archive` 归档
- archivist 不手动操作 changes/ 目录
- archivist 只清理 specs/ 和 .claude/docs/

---

## 七类判断框架

### 1. Archive（归档）

**动作**：条目内容从源文档移动到文档内的"已完成"/"历史"区域，原位留 Tombstone。

**适用**：
- 过期信息（API 路径 > 90 天未用、依赖版本已升级）
- 已完成 > 30 天的任务
- 已解决/已完成的优化点
- 被新 ADR 明确替代的旧架构决策
- 失效链接
- 历史快照

**不适用**：进行中任务、活跃 API、未解决的优化点、rules/spec.md 内容

### 2. Simplify-Keep（简化保留）

**动作**：浓缩冗长内容后原地保留，保留核心信息，删冗余描述。

**适用**：
- 仍相关但过于冗长的条目（> 200 字纯描述）
- 踩坑档案中过细的步骤可精简为"症状→根因→解决"
- 技巧模式中冗余示例可合并

**不适用**：规则内容、ADR 正文、任务描述（需完整保留意图）

### 3. Keep（保留）

**动作**：无变化，跳过。

**适用**：
- 活跃条目（最近 30 天有使用/引用）
- 进行中任务（`- [ ]` 在"进行中"区域）
- 未解决的优化点
- 所有 rules/spec.md 内容
- 当前有效的 ADR

### 4. Delete（删除）

**动作**：直接删除，不归档。

**适用**：
- 从未启动且创建 > 90 天的任务
- 已被完全替代且无参考价值的旧信息
- 明显误录入或空条目
- 完全无价值的占位符

**约束**：删除前必须确认无交叉引用

### 5. Stale-Warn（过期预警）

**动作**：原地添加 `⚠️ STALE` 标记，建议近期归档，但不移动。

**适用**：
- API 30-90 天未使用（不满足 Archive 的 > 90 天阈值）
- 踩坑记录中症状可能已修复但未确认
- 近期可能仍需参考但明显在变旧的条目

**标记格式**：`⚠️ STALE [2026-06-02] — 建议在 30 天内归档或更新`

### 6. Promote（提升）

**动作**：从 `learned/spec.md` 提升到 `rules/spec.md` 或 `architecture/spec.md`，原条目留提升标记。

**触发**：
- 同一模式在 learned/spec.md 中出现 ≥ 2 次
- 已足够稳定可作为规范（如 API 调用模式、错误处理惯例）

**不适用**：单次出现、领域特定知识、仍快速变化的模式

**标记格式**：`<!-- promoted: learned #05 → rules --> Promoted to rules/spec.md §错误处理 2026-06-02`

### 7. Merge（合并）

**动作**：合并多个高度重叠的条目为一条，删除重复。

**适用**：
- ≥ 2 条踩坑记录描述同一类问题
- 近似重复的 API 路径记录
- 内容重叠 > 60% 的条目

**合并规则**：保留最完整的一条 + 补充其他条目的独有信息 → 写为一条

---

## 分文档判断标准

### learned/spec.md

| 内容类型 | 判断信号 | 阈值 | 默认判定 |
|----------|---------|------|---------|
| API 路径 | git-log 引用时间差 | > 90d | Archive |
| API 路径（近期） | git-log 引用时间差 | 30-90d | Stale-Warn |
| API 路径（活跃） | git-log 引用时间差 | < 30d | Keep |
| 构建命令 | 最后引用时间 | > 30d | Archive |
| 踩坑记录（旧） | 症状是否仍可复现 | > 180d 未确认 | Archive |
| 踩坑记录（一般） | 解决方案仍有效 | 90-180d | Simplify-Keep |
| 踩坑记录（新） | 近期发现、仍有参考价值 | < 90d | Keep |
| 技巧模式（≥ 2x） | 同一模式出现次数 | ≥ 2 次 | Promote |
| 技巧模式（单次） | 是否有跨项目价值 | 低 | Simplify-Keep |
| 已验证知识 | 仍准确 | — | Keep |
| 依赖关系图 | 是否过期 | 与技术栈不一致 | Archive |
| 待探索项 | 已探索完 | 可标记完成 | Delete 或 Archive |
| 类似条目（> 2 条） | 内容重叠度 | > 60% | Merge |

**特殊规则**：
- Promote 的两种目标：
  - 编码/测试/错误处理模式 → `rules/spec.md`（对应章节）
  - 架构级模式/设计惯例 → `architecture/spec.md`（新 ADR）
- 踩坑档案按 `### [{问题标题}]` 条目头解析

### optimization/spec.md

| 条目状态 | 判断信号 | 判定 |
|----------|---------|------|
| 已解决/已完成 | 内容中明确写"已完成"、"已解决"、"done" | Archive |
| 已解决但冗长 | 同上 + 描述 > 200 字 | Simplify-Keep 后 Archive |
| 未解决、仍相关 | 内容含"待优化"、"需要改进" | Keep |
| 未解决但过时 | 技术栈已变、不再适用 | Archive |
| 相似优化点 | ≥ 2 条描述同一问题 | Merge |
| 无法判断 | 内容模糊 | Stale-Warn |

**状态推断规则**：
```
检测语言模式判断"已解决"：
  - 中文: "已完成" / "已解决" / "已修复" / "不需要了"
  - 英文: "done" / "resolved" / "fixed" / "wontfix" / "obsolete"
  - 无上述关键词 → 视为"未解决" → Keep 或 Stale-Warn
```

### tasks.md

| 条目状态 | 格式 | 创建时间 | 判定 |
|----------|------|---------|------|
| 已完成 | `- [x]` | > 30d | Archive |
| 已完成（近期） | `- [x]` | ≤ 30d | Keep |
| 进行中 | 位于 `## 进行中` | 任何 | NEVER Archive |
| 待办（旧） | `- [ ]` | > 90d 未动 | Delete |
| 待办（中期） | `- [ ]` | 30-90d | Stale-Warn |
| 待办（新） | `- [ ]` | < 30d | Keep |
| 阻塞项 | 位于 `## 阻塞项` | 任何 | Keep（需上下文） |

**永不归档**：`## 进行中` 下的任何条目。

### architecture/spec.md

| 决策状态 | 判断信号 | 判定 |
|----------|---------|------|
| 有效 | 无替代 ADR | Keep |
| 被替代 | 新 ADR 明确引用并替代旧 ADR | Archive（附带替代引用） |
| 过时 | 技术栈变更导致不再适用 | Archive |
| 被替代但新 ADR 未引用 | 手动判断 | Stale-Warn + flag |

**归档格式**：`Archived: 被 [ADR-XX] 替代 — 2026-06-02`

### rules/spec.md

**铁律**：rules/spec.md 内容永不自驱归档。

| 情况 | 动作 |
|------|------|
| 规则已过时 | 标记 `💡 SUGGEST-REVIEW`，不修改 |
| 规则冗余 | 标记 `💡 SUGGEST-MERGE`（指明显可合并的规则） |
| 规则正确 | Keep |

rules/spec.md 的清理需要用户显式编辑，archivist 只做标记。

### SNAPSHOT.md

| 内容 | 判定 |
|------|------|
| 当前快照主体 | Keep |
| 历史"最近修改"记录（> 30d 旧） | Archive（带日期范围） |
| 过时的关键文件表格 | Stale-Warn |
| 当前状态（阶段/分支） | Keep |

### references/spec.md

| 链接状态 | 判定 |
|----------|------|
| 有效链接 | Keep |
| 疑似失效（404/域名变更） | Archive + `[DEAD]` 标记 |
| 冗余引用（同一依赖多次记录） | Merge |
| 已不再使用的依赖 | Archive |

### OpenSpec 变更（changes/）

| 变更状态 | 判定 |
|----------|------|
| 活跃变更 | Keep |
| 已完成变更 | 用 `openspec archive` 归档 |
| 过时变更（> 90d 未活动） | 提示用户归档或删除 |
| 空变更（无实质内容） | 提示用户删除 |

**注意**：archivist 不手动操作 changes/，只提示用户使用 `openspec archive`。

---

## 条目边界解析规则

### learned/spec.md 条目解析

```
条目边界:
  - HTML 注释 <!-- L{编号} --> → 条目标记，编号用于 tombstone 引用
  - H3 标题 `### [{标题}]` → 踩坑档案条目
  - 表格行 `| 名称 | 路径 | 用途 | 时间 |` → API/命令/技巧条目
  - 多段落踩坑档案 → 从 <!-- L{编号} --> 或 `### [{标题}]` 到下一个标记或 `---` 为止
  - 无 <!-- L{编号} --> 标记的旧条目 → 归档时自动分配编号
```

### optimization/spec.md 条目解析

```
条目边界:
  - HTML 注释 <!-- O{编号} --> → 条目标记，编号用于 tombstone 引用
  - 列表项 `- {描述}` → 独立条目
  - 多段落条目 → 从 <!-- O{编号} --> 或 `- {描述}` 到下一个标记或空白隔行为止
  - 无 <!-- O{编号} --> 标记的旧条目 → 归档时自动分配编号
```

### tasks.md 条目解析

```
条目边界:
  - HTML 注释 <!-- T{编号} --> → 条目标记，编号用于 tombstone 引用
  - `- [x] {描述}` → 已完成条目
  - `- [ ] {描述}` → 待办条目
  - 按所在区域判断状态：`## 进行中` / `## 待办` / `## 阻塞项`
  - 无 <!-- T{编号} --> 标记的旧条目 → 归档时自动分配编号
```

### architecture/spec.md 条目解析

```
条目边界:
  - HTML 注释 <!-- A{编号} --> → 条目标记，编号用于 tombstone 引用
  - `### {DATE} - {决策标题}` → ADR 条目
  - 从 <!-- A{编号} --> 或 H3 到下一个标记或 `---` 为止
  - 无 <!-- A{编号} --> 标记的旧条目 → 归档时自动分配编号
```

---

## Phase 1: ANALYZE（分析阶段）

```
Entry: 用户调用 skill + openspec/specs/ 和 .claude/docs/ 目录存在

Step 1 — Read:
  并行读取所有源文档：
  - openspec/specs/architecture/spec.md
  - openspec/specs/rules/spec.md
  - openspec/specs/learned/spec.md
  - openspec/specs/references/spec.md
  - openspec/specs/optimization/spec.md
  - .claude/docs/SNAPSHOT.md
  - .claude/docs/tasks.md

Step 2 — Check OpenSpec Changes:
  运行 openspec list → 获取活跃变更列表
  对每个变更检查状态（活跃/过时/空）

Step 3 — Parse:
  按分文档解析规则逐条目提取内容、分类、时间信息

Step 4 — Cross-Reference Scan:
  对每个候选 Archive/Delete 条目:
    按交叉引用检查算法提取关键词
    按分文档 grep 策略搜索其他源文档
    排除 Tombstone 行和 Promote 行
    有引用 → 记录到交叉引用警告列表（含命中内容摘要）
    无引用 → 继续

Step 5 — Judge:
  对每个条目按七类判断框架 + 分文档标准分配判定
  标注: 置信度(HIGH/MEDIUM/LOW) + 理由 + 恢复条件(仅Archive)

Step 6 — Present to User:
  直接在对话中展示分析报告（不生成文件），包含三部分:
    【统计摘要】— 各判断类别的总数 + 置信度分布
    【确定性操作】— HIGH 置信度条目列表（按文档分组，简要列出）
    【模糊条目】— MEDIUM/LOW 置信度 + 交叉引用警告 + Stale-Warn 候选
      对每个模糊条目，简要说明内容和不确定性理由
      使用 AskUserQuestion 请用户逐条判定

Exit: 分析报告已展示 + 模糊条目已提交用户判定
Next: Gate 1
```

### 分析报告展示格式（对话中呈现）

```
##  归档分析报告

| 文档 | 分析条目 | Archive | Simplify | Delete | Stale | Promote | Merge | Keep |
|------|---------|---------|----------|--------|-------|---------|-------|------|
| specs/architecture/ | 8 | 1 | 0 | 0 | 1 | 0 | 0 | 6 |
| specs/rules/ | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| specs/learned/ | 52 | 8 | 4 | 1 | 3 | 2 | 3 | 31 |
| specs/references/ | 12 | 2 | 1 | 0 | 0 | 0 | 1 | 8 |
| specs/optimization/ | 15 | 5 | 2 | 0 | 1 | 0 | 1 | 6 |
| .claude/docs/SNAPSHOT.md | - | 2 | - | 0 | 1 | - | - | - |
| .claude/docs/tasks.md | 23 | 7 | 0 | 4 | 2 | 0 | 0 | 10 |
| OpenSpec changes/ | 5 | - | - | - | - | - | - | 5 |

---

### ✅ 确定性操作（HIGH 置信度，共 18 条）

#### specs/learned/ — Archive（5 条）
- L03 `GET /api/v1/users` — API 路径 > 90d 未引用
- L07 `cargo build --release` — 构建命令 > 30d 未用
- L12 异步错误处理踩坑 — 问题已于 v2.3 修复，> 180d
- L18 旧 API 迁移笔记 — 迁移已完成
- L22 `docker-compose up -d` — 已在其他条目记录

#### specs/optimization/ — Archive（3 条）
- O02 数据库查询优化 — 已完成 > 90d
- O05 日志级别调整 — 已完成
- O11 缓存策略 — 已标记 done

#### .claude/docs/tasks.md — Archive（4 条）
- T03 添加用户认证 — `- [x]` 完成 > 60d
- T08 优化首页加载 — `- [x]` 完成 > 45d
- T15 重构配置模块 — `- [x]` 完成 > 90d
- T22 修复内存泄漏 — `- [x]` 完成 > 120d

#### 其他文档 — Archive（6 条）
- 略（同上格式）

---

### ⚠️ 需要你判定的条目

#### 置信度 MEDIUM（3 条）
- **L28** 某第三方 API 调用方式 — MEDIUM Archive — 最后引用 75d，未达 90d 阈值但有替代方案。归档还是保留？
- **O09** "考虑引入消息队列" — MEDIUM Delete — 创建 > 120d 从未行动，但可能仍有讨论价值。删除还是保留？
- **A04** ADR-04 数据库选型 — MEDIUM Archive — 部分被 ADR-11 替代，但仍有部分建议被沿用。归档还是合并到 ADR-11？

#### 交叉引用警告（2 条）
- **L14** 被 architecture/spec.md §ADR-05 引用 — 归档前需更新 ADR-05。确认归档 + 更新引用？
- **O07** 被 tasks.md T12 提及（T12 已完成）— 无功能影响。确认归档？

#### 模糊状态（2 条，Stale-Warn 候选）
- **T19** 待办 > 60d — 既不确定要归档也不确定要继续。标记 Stale 还是直接 Delete？
- **L35** 某踩坑记录 — 症状疑似仍存在但无法确认。标记 Stale 还是保留？

#### OpenSpec 变更提示（2 条）
- **change-auth** 已完成 > 30d — 建议运行 `openspec archive change-auth`
- **change-old-feature** 已 90d 未活动 — 建议归档或删除
```

---

## Gate 1: 用户判定

```
位置: Phase 1 结束 → Phase 2 前

用户只需对模糊条目做出判定，确定性操作（HIGH 置信度）默认通过。

用户可用的回复方式:
  - "确认全部" — 所有 HIGH 置信度操作 + 模糊条目按默认建议执行
  - "只执行 HIGH 置信度" — 模糊条目全部跳过
  - 逐条判定: "L28 归档，O09 保留，A04 合并到 ADR-11"
  - 按类型: "所有 Archive 执行，Delete 跳过"
  - 追加条件: "确认全部，但交叉引用警告的先更新引用再归档"
  - OpenSpec: "change-auth 归档，change-old-feature 删除"

模糊条目处理（根据用户判定）:
  - 用户判定为执行 → 加入执行队列
  - 用户判定为跳过 → 标记为 Keep，下次运行再评估
  - 用户不回复 → STOP，等待

未通过 / 需调整:
  → 进入 Loop: Plan Revision（最多 3 轮）
  → 用户指定修改 → 更新判断 → 重新展示受影响的条目
```

---

## Phase 2: EXECUTE（执行阶段）

```
Entry: Gate 1 通过（用户已判定所有模糊条目）

执行队列 = HIGH 置信度操作 + 用户确认的模糊条目操作

执行顺序（确保安全）:
  0. OPENSPEC ARCHIVE — 先处理 OpenSpec 变更归档
  1. PROMOTE — 先提升（源条目保留，目标文档追加）
  2. MERGE   — 合并重复（保留一条，删除其余）
  3. ARCHIVE — 移动条目到文档内"已完成"/"历史"区，留 Tombstone
  4. SIMPLIFY — 浓缩原地保留的冗长条目
  5. DELETE  — 直接删除无价值条目
  6. STALE-WARN — 添加 ⚠️ 标记

对队列中每条条目:
  1. 读取源文档（最新副本）
  2. 执行操作:
      - OpenSpec Archive: 运行 `openspec archive <name>`
      - Archive: 复制到文档内"已完成"区 → 源位置删除 → 插入 Tombstone
      - Simplify: 浓缩 → 替换原条目
      - Delete: 直接删除
      - Promote: 追加到目标文档 → 源文档留提升标记
      - Merge: 创建合并条目 → 删除重复条目
      - Stale-Warn: 在条目旁插入 ⚠️ 标记行
  3. 写回源文档
  4. 验证 Tombstone 存在（如有 Archive 操作）

安全规则:
  - 逐条目执行，不批量操作（便于部分回滚）
  - 每次写文件前重新读取（避免基于过期内容）
  - 写失败时 STOP，不继续下一条

Exit: 执行队列中所有条目已处理
Next: Gate 2
```

---

## Tombstone 标记规范

### 格式

```markdown
<!-- tombstone: L03 --> Archived in learned/spec.md #L03 2026-06-02 — API path stale >90d
```

### 示例

```markdown
<!-- tombstone: L03 --> Archived in learned/spec.md #L03 2026-06-02 — API path stale >90d
<!-- tombstone: O07 --> Archived in optimization/spec.md #O07 2026-06-02 — 已完成优化
<!-- tombstone: T12 --> Archived in tasks.md #T12 2026-06-02 — 完成 >30d
<!-- tombstone: A02 --> Archived in architecture/spec.md #A02 2026-06-02 — 被 ADR-12 替代
<!-- tombstone: R04 --> Archived in references/spec.md #R04 2026-06-02 — 链接失效
```

### 提升标记格式（Promote）

```markdown
<!-- promoted: L05 → rules --> Promoted to rules/spec.md §错误处理 2026-06-02
<!-- promoted: L08 → architecture --> Promoted to architecture/spec.md §ADR-15 2026-06-02
```

### grep 搜索墓碑

```
列出所有墓碑:
  grep "tombstone:" openspec/specs/learned/spec.md
  grep "tombstone:" openspec/specs/optimization/spec.md
  grep -rn "tombstone:" openspec/specs/
  grep -rn "tombstone:" .claude/docs/

查找特定归档:
  grep "tombstone: L03" openspec/specs/learned/spec.md

查找所有提升标记:
  grep -rn "promoted:" openspec/specs/
```

### 恢复协议

```
用户看到 Tombstone → "恢复 L03"
→ grep "L03" openspec/specs/learned/spec.md 定位归档条目
→ 读取对应条目的原始内容部分
→ 复制回原位置（Tombstone 标记行位置）
→ 删除 Tombstone 标记行
→ 验证: grep "tombstone: L03" 源文档 确认无残留
```

---

## 交叉引用检查算法

```
对每个 Archive/Delete 候选条目 E:
  1. 提取搜索关键词（按源文档类型差异化）:
      - learned/spec.md 条目:
          API 路径 → 提取完整路径（如 GET /api/v1/users）
          踩坑档案 → 提取标题关键词（如 "异步错误处理"）
          构建命令 → 提取命令本身（如 cargo build --release）
          技巧模式 → 提取技巧核心词（如 "缓存"）
      - optimization/spec.md 条目:
          提取优化目标关键词（如 "数据库查询"、"日志级别"）
      - tasks.md 条目:
          提取任务动作 + 对象（如 "添加 用户认证"）
      - architecture/spec.md 条目:
          提取 ADR 编号 + 决策关键词（如 "ADR-04 数据库选型"）
      - references/spec.md 条目:
          提取依赖名称（如 "Redis"、"FastAPI"）
      - SNAPSHOT.md 条目:
          提取文件/模块名（如 "auth 模块"、"config.yaml"）

  2. 按分文档 grep 策略搜索其他源文档:
      learned/spec.md:
        表格条目: grep "| .*\| .*\|" openspec/specs/learned/spec.md | grep "关键词"
        踩坑档案: grep "^###" openspec/specs/learned/spec.md | grep -i "关键词"

      architecture/spec.md:
        ADR 条目: grep "^###" openspec/specs/architecture/spec.md | grep "关键词"
        决策日期: grep -E "^\d{4}-\d{2}-\d{2}" openspec/specs/architecture/spec.md | grep "关键词"

      tasks.md:
        grep "关键词" .claude/docs/tasks.md

      optimization/spec.md:
        grep "关键词" openspec/specs/optimization/spec.md

      references/spec.md:
        grep "关键词" openspec/specs/references/spec.md

      SNAPSHOT.md:
        grep "关键词" .claude/docs/SNAPSHOT.md

      rules/spec.md:
        grep "关键词" openspec/specs/rules/spec.md

      跨文档快速扫描（兜底）:
        grep -rn "关键词" openspec/specs/
        grep -rn "关键词" .claude/docs/

  3. 排除已归档引用（Tombstone 行和 Promote 行不算）:
      grep -rn "关键词" openspec/specs/ | grep -v "Archived in" | grep -v "Promoted to"

  4. 有匹配 → 在模糊条目中作为"交叉引用警告"呈现给用户:
      - 源条目: L12
      - 被引用位置: architecture/spec.md §ADR-05
      - 命中内容: grep 命中行的摘要
      - 建议: 归档前更新 ADR-05 引用
  5. 无匹配 → 正常处理（按置信度归类）

警告条目仍可归档，但需用户明确批准。
Phase 2 执行时:
  - 如用户要求"更新引用" → 将引用处的文本改为指向归档位置
  - 如用户说"不管" → 直接归档，引用处手动处理
```

---

## Gate 2: 执行验证

```
位置: Phase 2 结束

检查项:
  ✅ 执行队列中所有条目已处理
  ✅ 所有 Archive 条目留有 Tombstone
  ✅ OpenSpec 变更已用 `openspec archive` 归档
  ✅ 源文档无损坏（结构完整、无多余空白行）

验证命令（按实际执行的文档）:
  grep "tombstone:" openspec/specs/learned/spec.md | wc -l
  # 应等于本次执行的 learned Archive 数量
  openspec list | wc -l
  # 应等于剩余活跃变更数
```

---

## Loop: 判断修订

```
触发: Gate 1 用户不同意部分判定

流程:
  1. 用户指明哪些条目需重新判断
  2. 更新判定结果
  3. 重新展示受影响条目
  4. 用户再次确认

最多 3 轮:
  3 轮后仍不一致 → 跳过争议条目（标记 Keep）→ 执行其余
  或 → 用户手动处理争议条目后再重新运行
```

---

## 关键原则

```
审核先行，不可逆操作需确认
逐条目判断，非全文草率操作
Tombstone 标记保障可追溯可恢复
交叉引用检查防止断链
rules/spec.md 永不自驱归档，只做标记
置信度标注辅助用户决策
模糊条目交用户判定，不擅自决定
提升机制将记忆转为规范
OpenSpec 变更用 openspec archive 归档
archive.md 自身膨胀仅提醒，不自驱归档
只能追加写入，禁止直接覆盖
禁止全量覆盖写入，更新已有文档必须用 Edit 而非 Write，保护原有内容不被意外丢失
```

---

## Red Flags

```
Phase 1:
❌ 未展示分析报告即执行 → Gate 1 violation
❌ 跳过交叉引用扫描 → 断链风险
❌ 基于文件大小自动触发归档 → 核心约束 violation（仅用户触发）
❌ 模糊条目擅自决定（未交用户判定）→ 审核 violation

Phase 2:
❌ 归档后未留 Tombstone → 可追溯性 violation
❌ 自动归档 rules/spec.md 内容 → 规则保护 violation
❌ 删除被其他文档引用的条目（未更新引用）→ 交叉引用 violation
❌ 归档进行中任务 → tasks.md 保护 violation
❌ 批量操作无逐条验证 → 安全 violation
❌ 手动操作 changes/ 目录 → OpenSpec CLI violation（应用 openspec archive）

General:
❌ 用户未确认即执行 → Gate 1 violation
❌ 4 轮判断修订仍未一致 → 3-Failure 模式，跳过争议条目
❌ 使用 Write 全量覆盖已有文档 → 内容丢失 violation（必须用 Edit 精准替换）
```
