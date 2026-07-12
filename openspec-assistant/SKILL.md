---
name: openspec-assistant
description: 'OpenSpec 体系助手 - 只读恢复和查询项目文档体系的上下文图谱、规则、职责分工、规范、当前状态、活跃变更、架构决策、学习记忆、参考资料和优化记录。Use when the agent needs to understand how the OpenSpec skill system operates, what to read first, which skill owns a task, what rules apply, or where project knowledge lives. TRIGGER when: 用户问"当前进度"、"我们进行到哪了"、"项目规则是什么"、"这个体系怎么运作"、"应该用哪个 skill"、"查询架构/知识/参考/优化记录"、"恢复上下文"。不用于更新任务、快照、ADR、learned、references 或 optimization；写入维护使用 openspec-docs-maintainer。'
---

# OpenSpec Assistant — 体系助手

构建 OpenSpec 文档体系的只读图谱。它帮助 agent 快速理解上下文、规则、职责、规范、分工和当前状态。

写入型维护不在本 skill 内执行。需要更新任务、快照、决策、学习、参考、优化记录或同步 changes 时，使用 `openspec-docs-maintainer`。

## 职责

### 负责

- 恢复项目上下文。
- 查询 CLAUDE.md 中的规则和读取顺序。
- 解释 OpenSpec specs、changes、`.claude/docs/`、`.claude/analysis/` 的分工。
- 查询架构决策、学习记忆、参考资料、优化记录。
- 判断当前请求应由哪个 skill 处理。
- 找到已有知识，避免重复探索。
- 发现需要写入维护时，指出应调用 `openspec-docs-maintainer`。

### 不负责

- 不修改 `.claude/docs/tasks.md`。
- 不更新 `.claude/docs/SNAPSHOT.md`。
- 不追加 ADR、learned、references、optimization。
- 不同步 `openspec/changes/` 到 tasks。
- 不恢复归档条目。
- 不压缩文档。
- 不归档或删除条目。

## 文档地图

| 区域 | 路径 | 用途 | 写入者 |
|------|------|------|--------|
| 项目入口 | `CLAUDE.md` | 规则、读取顺序、文档索引 | `openspec-init` / 人工 |
| 项目状态 | `.claude/docs/SNAPSHOT.md` | 当前状态和结构 | `openspec-docs-maintainer` |
| 任务追踪 | `.claude/docs/tasks.md` | 全局任务和 change 同步 | `openspec-docs-maintainer` |
| 架构决策 | `openspec/specs/architecture/spec.md` | ADR | `openspec-docs-maintainer` / `openspec-explorer` |
| 学习记忆 | `openspec/specs/learned/spec.md` | API、文件、踩坑、技巧 | `openspec-docs-maintainer` / `openspec-explorer` |
| 外部参考 | `openspec/specs/references/spec.md` | 依赖、链接、分析索引 | `openspec-docs-maintainer` / `openspec-explorer` |
| 优化记录 | `openspec/specs/optimization/spec.md` | 技术债和优化点 | `openspec-docs-maintainer` |
| 活跃变更 | `openspec/changes/` | proposal/specs/design/tasks | OpenSpec CLI |
| 深度分析 | `.claude/analysis/` | 项目分析文档 | `openspec-explorer` |

## Skill 分工

| 需求 | 使用 |
|------|------|
| 初始化 OpenSpec / CLAUDE.md / docs | `openspec-init` |
| 需求探索、BDD、计划、创建 change | `openspec-plan` |
| TDD 实施、验证、归档完成变更 | `openspec-act` |
| 查询体系、规则、上下文、职责 | `openspec-assistant` |
| 更新任务、快照、ADR、learned、references、optimization | `openspec-docs-maintainer` |
| 深度阅读项目并生成分析文档 | `openspec-explorer` |
| 原地压缩活跃文档 | `openspec-compressor` |
| 归档、压缩归档、删除、墓碑、清理生命周期 | `openspec-archivist` |

## 查询流程

### 上下文恢复

触发：用户开始新会话、询问当前进度。

1. 读取 `CLAUDE.md`。
2. 读取 `.claude/docs/SNAPSHOT.md`。
3. 读取 `.claude/docs/tasks.md`。
4. 运行 `openspec list`。
5. 汇总当前状态、活跃任务、活跃变更、下一步。

### 规则查询

触发：编码前、用户问规范、规则、流程。

1. 读取 `CLAUDE.md` 的规则和读取顺序。
2. 按任务类型提取相关约束。
3. 指出适用的 skill 和 Gate。

### 架构查询

触发：设计、重构、影响评估。

1. 搜索 `openspec/specs/architecture/spec.md`。
2. 提取相关 ADR。
3. 说明是否可能需要新 ADR；写入由 `openspec-docs-maintainer` 执行。

### 知识查询

触发：需要 API、文件位置、踩坑、技巧。

1. 搜索 `openspec/specs/learned/spec.md`。
2. 必要时搜索代码引用。
3. 返回路径、用途、相关约束。

### 参考和优化查询

触发：需要依赖文档、外部链接、优化记录。

1. 搜索 `openspec/specs/references/spec.md` 或 `optimization/spec.md`。
2. 返回相关条目和路径。
3. 如发现应新增记录，建议调用 `openspec-docs-maintainer`。

## 搜索建议

```bash
rg -n "关键词" CLAUDE.md
rg -n "关键词" .claude/docs/SNAPSHOT.md .claude/docs/tasks.md
rg -n "关键词" openspec/specs/
openspec list
```

## 输出要求

- 说明读取了哪些文档。
- 给出当前状态或查询结果。
- 标明应由哪个 skill 继续处理。
- 如果需要更新文档，只提出维护需求，不直接写入。

## Red Flags

```
❌ 查询过程中修改文档
❌ 把维护写入留在 assistant 内做
❌ 不读 CLAUDE.md 就解释规则
❌ 忽略 active changes
❌ 没有说明下一步应由哪个 skill 负责
```
