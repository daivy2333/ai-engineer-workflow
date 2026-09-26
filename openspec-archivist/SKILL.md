---
name: openspec-archivist
description: 清理 OpenSpec 条目、无法正常收尾的 change 和持久化产物的生命周期，判断归档、保留、删除、过期预警、提升、合并或 Artifact 归档。仅在用户明确要求生命周期清理时使用；正常完成的 change 由 openspec-docs-maintainer 收尾。
---

# OpenSpec Archivist

只在用户显式触发时执行。文件大小和条目数量不能自动触发归档。

## 必读引用

- 分析任何条目前，完整读取 [references/judgment-rules.md](references/judgment-rules.md)。
- 展示计划和验证结果时，使用 [references/report-template.md](references/report-template.md)。

## 职责边界

- `openspec-assistant`：只读查询。
- `openspec-docs-maintainer`：日常写入、归档恢复和正常完成的 change 收尾。
- `openspec-compressor`：活跃文档原地压缩。
- `openspec-archivist`：生命周期判断、归档、删除、arc 墓碑和预警。

Archivist 不日常维护 tasks、SNAPSHOT 或 M/R/I。

## 不可违反的约束

1. 用户确认前不移动、删除或归档。
2. 逐条判断，不按整份文件粗略处理。
3. Archive 和 Delete 前扫描交叉引用。
4. `AGENTS.md` 永不自动归档，只能建议审查。
5. 进行中任务永不归档。
6. 无法满足 Maintainer 正常收尾条件的 OpenSpec change 经用户确认后使用 OpenSpec 集成归档，不手工移动；正常完成的 change 交给 Maintainer 收尾。
7. 活跃文档的表达压缩交给 compressor。
8. Change Evidence 不执行 Artifact-Archive，不登记 R，随所属 change 由 OpenSpec 集成归档。

## Phase 1：ANALYZE

### Step 1：读取

体系上下文按公共规则 › 读取顺序 复用。先读取用户指定目标和判断所需的索引，再按搜索命中补读相关内容：

- 目标所在的 project-model、references、improvements、SNAPSHOT 或 tasks
- 目标 Analysis、Runbook、Issue 及其 R 索引
- 与目标有关的活跃 change 和 `openspec list` 结果

Assistant 的既有上下文可以缩小候选范围，但不能代替 Archive 或 Delete 前对目标正文、活动状态和交叉引用的新鲜检查。

### Step 2：解析

按编号和结构识别条目：

- `Mxx/Rxx/Ixx/MSxx/Txx`
- 模型、参考和改进标题。
- 表格行。
- checkbox 任务。
- Analysis、Runbook、Issue 与 R 索引。
- 活跃 change 的 Iteration、Cycle、Act Response 和按需 Evidence。

### Step 3：交叉引用

为每个 Archive 或 Delete 候选：

1. 提取编号、路径、命令、API 或标题关键词。
2. 搜索其他活跃文档和代码。
3. 排除墓碑、提升标记和归档副本。
4. 记录命中位置和摘要。

### Step 4：判断

为每个条目分配：

- 动作。
- HIGH/MEDIUM/LOW 置信度。
- 原因。
- 交叉引用。
- 恢复条件。

### Step 5：提交用户

展示：

- 统计。
- HIGH 置信度候选。
- MEDIUM/LOW 候选。
- 交叉引用警告。
- OpenSpec change 建议。

用户只需判定不确定项，也可以限制动作类型或文件范围。没有用户确认时停止。

## Gate 1：用户判定

接受：

- 全部确认。
- 只执行 HIGH。
- 按动作确认。
- 按文件确认。
- 逐条覆盖建议。

争议条目最多修订 3 轮。仍无共识时保留该条目，执行其余已确认项。

## Phase 2：EXECUTE

按顺序执行：

1. 处理用户批准且无法满足正常收尾条件的 OpenSpec change。
2. Promote。
3. Merge。
4. 预检活跃 changes。
5. Archive：确认条目内容与最近提交一致，精准移除源条目并原位追加墓碑 `<!-- arc: <短hash> --> N 条已归档 (YYYY-MM-DD)`，hash 取移除前包含该条目的最近提交。
6. Delete。
7. Stale-Warn。
8. Artifact-Archive：删除文件，R 编号保留，R 路径改为 `git show <hash>:<原路径>`，状态标 `[ARCHIVED YYYY-MM-DD]`。

全程只读 git（`rev-parse`、`diff`、`show`）；归档动作是文件删除和墓碑，由用户自己的提交落史。条目内容与最近提交不一致时，先请用户提交再归档。

## Gate 2：验证

确认：

- 执行队列全部有结果。
- 每条墓碑 hash 指向的提交包含被归档条目（`git show <hash>:<路径>` 抽查）。
- Delete 条目没有活跃引用。
- 源文档结构完整。
- 详细产物删除后 R 路径已更新为取回命令。
- change 归档后，其已有 Evidence 完整可定位（随 change 处理）。

## 恢复

M/R/I、tasks 和 Analysis 的恢复请求交给 `openspec-docs-maintainer`。Runbook 和 Issue 的正文恢复交给 `openspec-experience-recorder`，R 路径和状态由其限定请求交给 Maintainer 更新。恢复 = 从墓碑 hash 或 `git log -S '<编号>' -- <路径>` 取回内容，按原编号插回源位置，删除墓碑行或更新 R 路径。

## 禁止

- 未确认就执行。
- 归档进行中任务。
- 自动改写或归档 `AGENTS.md`。
- 手工移动 OpenSpec change。
- 把 Analysis、Runbook 或 Issue 放进 OpenSpec change。
- 脱离所属 change 单独移动、压缩或登记 Evidence。
- 全量覆盖源文档。
- 执行 git 提交、分支或历史改写操作。
