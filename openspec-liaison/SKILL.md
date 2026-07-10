---
name: openspec-liaison
description: OpenSpec 项目联络器 - 索引子项目/关联项目文档体系到 openspec/specs/references/spec.md，管理多分支进度到 .claude/docs/tasks.md。单向索引，主动触发，不修改子项目文件。TRIGGER when: 用户说"索引子项目"、"索引分支"、"同步项目关联"、"查看项目关联"、"查看分支进度"、"联络子项目"、"联络分支"、"项目间索引"、"联络分支"、或在多项目/多分支协作时需要了解关联文档体系和各分支进度。
---

# OpenSpec Liaison — 项目联络器

**管理项目与项目、分支与分支之间的文档索引与进度关联。**

核心维护 `openspec/specs/references/spec.md` 的子项目索引区和 `.claude/docs/tasks.md` 的分支进度区。

---

## 核心原则

- **单向索引** — 只读子项目/其他分支的文件，只写当前项目的 `openspec/specs/references/spec.md` 和 `.claude/docs/tasks.md`。需要反向索引时，对调角色再执行一次。
- **主动触发** — 用户显式调用或被其他 skill 委托，不自动扫描、不 hook。
- **只索引不分析** — 联络器只建立索引和记录进度，不做深度阅读或知识提取。深度阅读归 explorer，日常文档维护归 assistant。
- **通用扫描** — 自动检测含 `.claude/docs/` 或 `openspec/` 的子目录为子项目，也接受用户指定路径列表。
- **格式兼容** — 写入格式与 assistant 维护的 `references/spec.md` / `tasks.md` 现有格式一致，遵循 `<!-- R{编号} -->` 编号体系和区域标识约定。

---

## 文档体系映射

### 写入目标

| 内容类型 | 目标文件 | 编号格式 |
|----------|----------|----------|
| 子项目索引 | `openspec/specs/references/spec.md` | <!-- R{编号} --> |
| 分支进度 | `.claude/docs/tasks.md` | 表格格式（无编号） |

### 读取来源

| 内容 | 来源文件 |
|------|----------|
| 子项目文档体系 | 子项目 `.claude/docs/` 和 `openspec/specs/` |
| 分支快照 | `git show <branch>:.claude/docs/SNAPSHOT.md` |
| 分支任务 | `git show <branch>:.claude/docs/tasks.md` |
| 分支 OpenSpec | `git show <branch>:openspec/config.yaml` |
| 分支差异 | `git diff --stat <current>..<branch>` |

---

## 行为模式

| 模式 | 触发 | 行为 | 输出 | 写入 | 关键规则 |
|------|------|------|------|------|----------|
| index-projects | "索引子项目"、"联络子项目"、"索引关联项目" | 扫描子项目目录结构，读取各子项目文档体系状态 | 子项目索引条目 | `references/spec.md` 子项目索引区 | 只读子项目文件，只写主项目 references/spec.md |
| index-branches | "索引分支"、"联络分支"、"查看分支进度" | 扫描所有本地分支，读取各分支 SNAPSHOT.md 和 tasks.md | 分支进度表 | `tasks.md` 分支进度区 | 只读其他分支文件，只写当前分支 tasks.md |
| sync | "同步项目关联"、"全量同步" | 依次执行 index-projects + index-branches | 上述两者 | references/spec.md + tasks.md | 同上述两者 |
| status | "查看项目关联"、"查看项目状态" | 读取并展示当前索引和进度信息 | 终端输出 | 无（只读） | 不写任何文件 |

---

## index-projects 流程

### 1. 发现子项目

```
扫描项目根目录下所有子目录：
  - 含 `.claude/docs/` 的子目录识别为子项目（传统文档体系）
  - 含 `openspec/` 的子目录识别为子项目（OpenSpec 体系）
  - 含 `.codegraph/` 的子目录识别为子项目有 CodeGraph 索引
  - 用户可通过 `--paths path1,path2` 显式指定路径列表，跳过自动发现
  - 排除 `.claude/worktrees/` 等内部目录
```

### 2. 读取文档体系状态

```
对每个子项目，检查以下文件是否存在：

传统文档体系：
  - .claude/docs/SNAPSHOT.md
  - .claude/docs/tasks.md
  - .claude/docs/learned.md
  - .claude/docs/architecture.md
  - .claude/docs/references.md

OpenSpec 体系：
  - openspec/config.yaml
  - openspec/specs/architecture/spec.md
  - CLAUDE.md
  - openspec/specs/learned/spec.md
  - openspec/specs/references/spec.md
  - openspec/specs/optimization/spec.md

CodeGraph 索引：
  - .codegraph/codegraph.db

若 SNAPSHOT.md 存在，读取第一段作为摘要
获取文件最近修改时间作为"最近更新"
```

### 3. 写入 references/spec.md

```
定位 `## 子项目索引` 区域（见文档格式规范）
若该区域不存在，在 references/spec.md 末尾追加
若该区域已存在，替换整个区域内容
编号从现有最大 R 编号 +1 开始递增
保留区域外的内容不变
```

### 4. CodeGraph 子项目信息

```
对有 .codegraph/ 的子项目，可补充以下信息（用 MCP 工具调用，不要用 CLI）:
  - codegraph_status（MCP）→ 获取索引统计（节点数、边数、文件数）
  - codegraph_files（MCP）→ 快速获取目录结构
  - codegraph_search（MCP）→ 找核心符号
  这些信息可作为子项目摘要的补充

⚠️ 注意：MCP 工具是 agent 内部 tool-call，不能用 bash 调用
```

---

## index-branches 流程

### 1. 发现分支

```
获取所有本地分支列表（`git branch --list`）
排除当前分支（当前分支的进度就是 tasks.md 本身）
```

### 2. 读取分支文档

```
对每个分支：
  通过 `git show <branch>:.claude/docs/SNAPSHOT.md` 读取快照
  通过 `git show <branch>:.claude/docs/tasks.md` 读取任务
  通过 `git show <branch>:openspec/config.yaml` 检查 OpenSpec 配置
  若文件不存在则标记为"无文档"
  通过 `git diff --stat <current-branch>..<branch>` 获取与当前分支的文件差异统计
```

### 3. 写入 tasks.md

```
定位 `## 分支进度` 区域（见文档格式规范）
若该区域不存在，在 tasks.md 末尾追加
若该区域已存在，替换整个区域内容
保留区域外的内容不变
```

---

## 文档格式规范

### references/spec.md 子项目索引区

```markdown
## 子项目索引

<!-- 由 openspec-liaison 写入，由 openspec-assistant 日常维护，由 openspec-archivist 周期清理。 -->
<!-- 添加时格式: <!-- R{编号} --> | 子项目 | 路径 | 文档体系 | 摘要 | 最近更新 | -->

<!-- R{N} --> | {子项目名} | {相对路径} | {文档体系状态} | {摘要} | {日期} |
```

**文档体系状态**格式：
- 传统文档：列出 SNAPSHOT / tasks / learned / architecture / references 各自的 ✓/✗ 状态
- OpenSpec 体系：列出 config / specs / changes 各自的 ✓/✗ 状态
- CodeGraph 索引：cg✓ / cg✗
- 空格分隔

**示例**（仅供参考格式，非实际数据）：

```markdown
## 子项目索引

<!-- 由 openspec-liaison 写入，由 openspec-assistant 日常维护，由 openspec-archivist 周期清理。 -->
<!-- 添加时格式: <!-- R{编号} --> | 子项目 | 路径 | 文档体系 | 摘要 | 最近更新 | -->

<!-- R15 --> | submodule-auth | ./submodule-auth | OpenSpec✓ config✓ specs✓ changes✗ cg✓ | 认证子模块，JWT+OAuth2实现 | 2026-05-28 |
<!-- R16 --> | submodule-api | ./submodule-api | 传统✓ SNAPSHOT✓ tasks✓ learned✓ arch✓ refs✓ cg✗ | API网关子模块 | 2026-05-30 -->
```

### tasks.md 分支进度区

```markdown
## 分支进度

<!-- 由 openspec-liaison 写入，由 openspec-assistant 日常维护，由 openspec-archivist 周期清理。 -->

| 分支 | 阶段 | 关键任务 | OpenSpec | 与当前分支差异 | 最近更新 |
|------|------|----------|----------|---------------|----------|
| {分支名} | {阶段} | {关键任务摘要} | {OpenSpec状态} | {差异统计} | {日期} |
```

**OpenSpec 状态**格式：
- 有 openspec/config.yaml → ✓
- 有活跃 changes → ✓ (N changes)
- 无 OpenSpec → ✗

**示例**（仅供参考格式，非实际数据）：

```markdown
## 分支进度

<!-- 由 openspec-liaison 写入，由 openspec-assistant 日常维护，由 openspec-archivist 周期清理。 -->

| 分支 | 阶段 | 关键任务 | OpenSpec | 与当前分支差异 | 最近更新 |
|------|------|----------|----------|---------------|----------|
| main | 稳定 | 无进行中任务 | ✓ | — | 2026-05-28 |
| feature/pipeline | 开发中 | 流水线设计、hazard检测 | ✓ (2 changes) | +3文件 -1文件 | 2026-06-01 |
| fix/overflow-bug | 修复中 | 溢出边界修复 | ✗ | +1文件 | 2026-06-02 |
```

---

## 与其他 Skill 的关系

| Skill | 关系 | 说明 |
|-------|------|------|
| openspec-explorer | 职责剥离 | explorer 不再维护子项目索引。explorer 专注深度阅读和知识反哺（learned/spec.md），联络器负责子项目/分支的索引和进度。 |
| openspec-assistant | 日常维护 | 联络器写入 `## 子项目索引` 和 `## 分支进度` 区域，assistant 在日常操作中可维护这些区域的条目内容（如更新日期、补充摘要）。 |
| openspec-archivist | 周期清理 | archivist 周期清理时，可对联络器写入的索引条目执行 Archive/Simplify/Keep 判断，清理过时的子项目索引和分支进度。 |
| openspec-init | 初始化 | generator 初始化 references/spec.md 时，模板应包含"子项目索引"区域，为联络器预留位置。 |

---

## 写入安全

- 写入前先读取目标文件完整内容
- 通过区域标识（`## 子项目索引` / `## 分支进度`）精确定位替换范围
- 替换时保留区域外的所有内容不变
- 编号递增时先扫描现有最大 R 编号，避免冲突
- 若目标文件不存在，先创建含区域标识的文件再写入

---

## grep 搜索友好设计

### 子项目索引搜索

```bash
# 列出所有子项目索引条目
grep "| .*/" openspec/specs/references/spec.md | grep "子项目索引" -A 100

# 搜索特定子项目
grep "子项目名" openspec/specs/references/spec.md

# 搜索 OpenSpec 子项目
grep "OpenSpec✓" openspec/specs/references/spec.md

# 搜索传统文档子项目
grep "传统✓" openspec/specs/references/spec.md
```

### 分支进度搜索

```bash
# 列出所有分支进度
grep "| .*| .*| .*| .*| .*|" .claude/docs/tasks.md | tail -n +3

# 搜索特定分支
grep "分支名" .claude/docs/tasks.md

# 搜索有 OpenSpec 的分支
grep "✓" .claude/docs/tasks.md | grep "分支进度" -A 100
```

---

## Key Principles

```
单向索引，只读子项目/分支，只写当前项目
主动触发，不自动扫描
只索引不分析，深度阅读归 explorer
通用扫描，自动检测 .claude/docs/、openspec/、.codegraph/
格式兼容，遵循现有编号体系
与 assistant/explorer/archivist 各司其职
与 OpenSpec CLI 无缝集成
与 CodeGraph 集成，索引子项目 cg 状态
```

---

## CodeGraph 集成

### 检测子项目 CodeGraph 状态

```
对每个子项目：
  1. 检查 .codegraph/codegraph.db 是否存在
  2. 存在 → 子项目有 CodeGraph 索引
  3. 可选：调用 codegraph_status 获取统计信息

检测命令：
  test -f {子项目路径}/.codegraph/codegraph.db && echo "cg✓" || echo "cg✗"
```

### 索引条目增强

```
子项目索引条目新增 cg 字段:
  <!-- R{编号} --> | {子项目} | {路径} | {文档体系} cg✓ | {摘要} | {日期} |
```

### 不直接调用 CodeGraph

```
liaison 不直接调用 codegraph_* 工具，只检测其存在性
原因：liaison 只做索引，深度探索归 explorer
```

---

## Red Flags

```
❌ 修改子项目文件 → 单向索引 violation
❌ 自动扫描不等待用户确认 → 主动触发 violation
❌ 做深度阅读和知识提取 → 职责越界（归 explorer）
❌ 编号冲突 → grep 定位错误
❌ 区域标识不精确 → 替换范围错误
❌ 覆盖区域外内容 → 数据丢失
❌ 不检查 OpenSpec 体系 → 遗漏新架构子项目
❌ 不检查 CodeGraph 索引 → 遗漏代码索引子项目
```
