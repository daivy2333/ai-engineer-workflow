---
name: openspec-archivist
description: 清理 OpenSpec 条目、无法正常收尾的 change 和持久化产物的生命周期，判断归档、压缩归档、保留、删除、过期预警、提升、合并或 Artifact 归档。仅在用户明确要求生命周期清理时使用；正常完成的 change 由 openspec-docs-maintainer 收尾。
---

# OpenSpec Archivist

只在用户显式触发时执行。文件大小和条目数量不能自动触发归档。

## 必读引用

- 分析任何条目前，完整读取 [references/judgment-rules.md](references/judgment-rules.md)。
- 执行 Archive 或 Compress-Archive 前，完整读取 [references/carrier-protocol.md](references/carrier-protocol.md)。
- 展示计划和验证结果时，使用 [references/report-template.md](references/report-template.md)。

## 职责边界

- `openspec-assistant`：只读查询。
- `openspec-docs-maintainer`：日常写入、归档恢复和正常完成的 change 收尾。
- `openspec-compressor`：活跃文档原地压缩。
- `openspec-archivist`：生命周期判断、归档、删除、arc 墓碑和预警。

Archivist 不日常维护 tasks、SNAPSHOT 或 M/D/K/R/I。

## 不可违反的约束

1. 用户确认前不移动、删除或归档；用户明确要求 Init 升级或迁移，视为只确认旧经验文档的完整 Archive。
2. 逐条判断，不按整份文件粗略处理。
3. Archive 和 Delete 前扫描交叉引用。
4. `CLAUDE.md` 永不自动归档，只能建议审查。
5. 进行中任务永不归档。
6. 无法满足 Maintainer 正常收尾条件的 OpenSpec change 经用户确认后使用 OpenSpec 集成归档，不手工移动；正常完成的 change 交给 Maintainer 收尾。
7. Archive 和 Compress-Archive 使用独立 carrier change。
8. carrier 归档成功前不删除源条目。
9. 每次清理使用独立 carrier，不跨清理批次合并。
10. 活跃文档的表达压缩交给 compressor。
11. Init 全量迁移不重新判断信息价值；覆盖清单中的全部语义条目都必须保留。
12. 旧经验文档只能完整 Archive，不得 Delete 或 Compress-Archive。
13. Change Evidence 不执行 Artifact-Archive，不登记 R，随所属 change 由 OpenSpec 集成归档。

## Init 迁移归档

这是普通生命周期清理的窄例外，只接收 `openspec-init` 已完成的新体系写入和迁移清单。

按 [references/carrier-protocol.md](references/carrier-protocol.md) 的 Migration carrier 要求核验覆盖、mtime、完整原文、新目标和恢复入口。核验通过后完整归档 carrier 并退出旧活动路径；不得重新判断信息价值、改写来源映射或要求用户逐条确认。任一条件失败时保留全部旧活动文件并返回 Init 修复。

已归档 legacy carrier 不重复装入或归档。Archivist 核验其路径、语义条目映射和新目标，保持历史载体不可变。

## Phase 1：ANALYZE

### Step 1：读取

复用当前会话中 Assistant 已读取且未变化的项目地图和状态概览。先读取用户指定目标和判断所需的索引，再按搜索命中补读相关内容：

- 目标所在的 project-model、decisions、knowledge、references、improvements、SNAPSHOT 或 tasks
- 目标 Analysis、Runbook、Incident 及其 R 索引
- 迁移期间存在的 architecture、learned、optimization
- 与目标有关的活跃 change 和 `openspec list` 结果

Assistant 的既有上下文可以缩小候选范围，但不能代替 Archive、Compress-Archive 或 Delete 前对目标正文、活动状态和交叉引用的新鲜检查。

### Step 2：解析

按编号和结构识别条目：

- `Mxx/Dxx/Kxx/Rxx/Ixx/MSxx/Txx`
- 旧 `Axx/Lxx/Oxx` 和 Legacy ID。
- 决策、模型、知识和改进标题。
- 表格行。
- checkbox 任务。
- Analysis、Runbook、Incident 与 R 索引。
- 活跃 change 的 Iteration、Cycle、Act Response 和按需 Evidence。

### Step 3：交叉引用

为每个 Archive、Compress-Archive 或 Delete 候选：

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

Init 迁移归档跳过生命周期动作判断，直接按“完整 Archive”核验全部旧经验文档；不跳过覆盖核验。

### Step 5：提交用户

展示：

- 统计。
- HIGH 置信度候选。
- MEDIUM/LOW 候选。
- 交叉引用警告。
- OpenSpec change 建议。

用户只需判定不确定项，也可以限制动作类型或文件范围。没有用户确认时停止。Init 迁移请求已构成完整 Archive 的确认，不进入普通候选判定。

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

1. 处理用户批准且无法满足正常收尾条件的 OpenSpec change；Init 迁移先核验 migration carrier。
2. Promote。
3. Merge。
4. 预检活跃 changes。
5. 创建并验证 carrier change。
6. 使用 OpenSpec 集成归档 carrier。
7. 精准移除源条目并追加作为批次墓碑的 `<!-- arc:` 指引。
8. Delete。
9. Stale-Warn。
10. Artifact-Archive。

任何 carrier 步骤失败时停止，不删除源条目。

Migration carrier 归档成功后，按载体协议退出旧体系活动路径，不追加会让旧体系继续处于活动状态的墓碑文件。

## Gate 2：验证

确认：

- 执行队列全部有结果。
- Archive 条目有 carrier 映射和 arc 指引。
- Delete 条目没有活跃引用。
- OpenSpec 验证通过。
- 源文档结构完整。
- 详细产物移动后 R 路径已更新。
- change 归档后，其已有 Evidence 目录和文件仍完整可定位。
- Init 迁移通过 [references/carrier-protocol.md](references/carrier-protocol.md) 的覆盖、完整原文、归档和旧活动路径退出检查。

## 恢复

M/D/K/R/I、tasks 和 Analysis 的恢复请求交给 `openspec-docs-maintainer`。Runbook 和 Incident 的正文恢复交给 `openspec-experience-recorder`，R 路径和状态由其限定请求交给 Maintainer 更新。条目归档保留 carrier、映射和 arc；Artifact 归档保留 R 编号、路径和状态。

## 禁止

- 未确认就执行。
- 归档进行中任务。
- 自动改写或归档 `CLAUDE.md`。
- 手工移动 OpenSpec change。
- carrier 失败后删除源条目。
- 把 Analysis、Runbook 或 Incident 放进 OpenSpec archive。
- 脱离所属 change 单独移动、压缩或登记 Evidence。
- 全量覆盖源文档。
- 对 Init 迁移内容执行价值、时效或相关性筛选。
- 删除或压缩归档旧经验文档。
