---
name: openspec-docs-maintainer
description: 'OpenSpec 文档维护器 - 在其他 skill 或开发工作完成后，按需更新和同步 OpenSpec 文档体系，包括 .claude/docs/tasks.md、SNAPSHOT.md、openspec/specs/architecture/spec.md、learned/spec.md、references/spec.md、optimization/spec.md，以及 openspec/changes/ 与 tasks.md 的状态同步。TRIGGER when: 用户说"更新任务"、"更新快照"、"记录一个决策"、"记录学习"、"添加参考资料"、"记一个优化点"、"同步 OpenSpec 变更"、"同步文档体系"、"把刚才的工作记到文档"、"维护 docs"。'
---

# OpenSpec Docs Maintainer — 文档维护器

维护 OpenSpec 文档体系中的写入型状态。此 skill 通常在 `openspec-plan`、`openspec-act`、`openspec-explorer`、`openspec-compressor`、`openspec-archivist` 或普通开发工作完成后调用。

只在有明确更新或同步需求时使用。查询上下文、规则、职责分工、文档地图时使用 `openspec-assistant`。

## 维护范围

| 文档 | 用途 | 编号 |
|------|------|------|
| `.claude/docs/tasks.md` | 全局任务追踪 | `<!-- Txx -->` |
| `.claude/docs/SNAPSHOT.md` | 项目状态快照 | 无 |
| `openspec/specs/architecture/spec.md` | 架构决策 | `<!-- Axx -->` |
| `openspec/specs/learned/spec.md` | 学习记忆 | `<!-- Lxx -->` |
| `openspec/specs/references/spec.md` | 外部参考和分析索引 | `<!-- Rxx -->` |
| `openspec/specs/optimization/spec.md` | 优化点 | `<!-- Oxx -->` |
| `openspec/changes/<name>/tasks.md` | 变更任务源 | 由 OpenSpec 管理 |

## 核心约束

```
1. 按需写入 — 没有明确更新需求时不改文档
2. 精准修改 — 只动相关条目，不重排无关内容
3. 禁止全量覆盖 — 修改已有文档必须精准替换
4. 编号递增 — 读取最大编号后新增
5. 不重复记录 — 写入前先搜索已有条目
6. 保留历史 — 不主动删除既有知识；删除和归档交给 openspec-archivist
7. 压缩活跃文档交给 openspec-compressor
8. 查询图谱交给 openspec-assistant
```

## 工作流

### Phase 1: LOAD

1. 读取用户请求，确定要维护的文档类型。
2. 搜索目标文档是否已有相关条目。
3. 如涉及 OpenSpec 变更，运行 `openspec list` 并读取对应 `openspec/changes/<name>/tasks.md`。
4. 记录本次只会修改哪些文件。

### Phase 2: UPDATE

按场景执行一种或多种维护动作。

#### 任务更新

触发：用户说"更新任务"、"我完成了 X"、"接下来做 Y"。

动作：

1. 读取 `.claude/docs/tasks.md`。
2. 找最大 `Txx` 编号。
3. 更新进行中、待办、阻塞或最近完成区域。
4. 如任务来自 change，保留 change 名称。

#### 快照更新

触发：用户说"更新快照"、"同步项目状态"。

动作：

1. 检查 git 分支、最近提交、工作区状态。
2. 扫描关键目录变化。
3. 更新 `.claude/docs/SNAPSHOT.md` 的当前状态、最近修改、关键文件。

#### 决策记录

触发：用户说"记录一个决策"、"我们决定用 X"。

动作：

1. 读取 `openspec/specs/architecture/spec.md`。
2. 找最大 `Axx` 编号。
3. 追加 ADR：日期、决策、原因、影响、替代方案。

#### 学习记忆更新

触发：发现新 API、路径、技巧、踩坑、用户提供项目知识。

动作：

1. 读取 `openspec/specs/learned/spec.md`。
2. 找最大 `Lxx` 编号。
3. 写入对应分类：API 路径、文件速查、踩坑档案、技巧模式。

#### 参考添加

触发：用户要求记录链接、依赖文档、分析文档索引。

动作：

1. 读取 `openspec/specs/references/spec.md`。
2. 找最大 `Rxx` 编号。
3. 追加到依赖文档、项目分析文档或领域知识笔记区域。

#### 优化点记录

触发：用户说"记一个优化点"、"这里以后要改"。

动作：

1. 读取 `openspec/specs/optimization/spec.md`。
2. 找最大 `Oxx` 编号。
3. 追加问题、影响、建议方案、优先级或状态。

#### 变更同步

触发：用户创建、应用、完成或归档 OpenSpec 变更。

动作：

1. 运行 `openspec list`。
2. 读取活跃 change 的 `tasks.md`。
3. 同步到 `.claude/docs/tasks.md`，标注来源 change。
4. change 完成后更新任务状态。
5. change 归档后从活跃任务移除，并更新 SNAPSHOT。

### Phase 3: VERIFY

1. `git diff --check`
2. 对修改过的编号文档运行 `rg "<!-- [A-Z][0-9]+" <file>`。
3. 如涉及 OpenSpec，按需运行 `openspec validate --specs` 或 `openspec validate --changes`。
4. 最终报告列出修改文件、编号、新增或更新条目。

## 恢复归档条目

触发：用户说"恢复 L03"、"把 L28 找回来"、"取消归档 R04"。

动作：

1. 在源文档末尾搜索 `<!-- arc:`。
2. 读取归档 `proposal.md` 的映射表。
3. 在映射表中匹配原编号。
4. 从 `openspec/archive/<date>-arc-XXX/specs/<源域>/spec.md` 读取条目。
5. 精准插回源文档。
6. 更新 arc 指引计数并追加 `<!-- restored: <编号> <日期> -->`。
7. 验证源文档可搜索到原编号。

## Red Flags

```
❌ 无明确更新需求就修改文档
❌ 查询上下文时误触发维护写入
❌ 重复记录已有知识
❌ 编号冲突
❌ 全量覆盖已有文档
❌ 删除或归档条目
❌ 活跃文档压缩
❌ 跳过 OpenSpec CLI 直接改 changes 元数据
```
