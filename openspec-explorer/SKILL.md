---
name: openspec-explorer
description: 深度阅读整个项目、模块、调用链或子系统，按宏观或微观范围生成即时回答或 .agents/analysis/ 分析文档。文档模式完成后自动调用 openspec-docs-maintainer 登记对应 R 引用；不修改产品代码。
---

# OpenSpec Explorer

读取代码和项目文档，生成有依据的分析。不要修改产品代码，也不要自行修改 M/D/K/R/I。

## 选择模式

先分别选择范围和输出：

- 宏观范围：分析整个项目或多个模块。执行前完整读取 [references/macro-workflow.md](references/macro-workflow.md)。
- 微观范围：分析一个模块、流程、符号或问题。执行前完整读取 [references/micro-workflow.md](references/micro-workflow.md)。
- 即时回答：只向用户报告，不创建 `.agents/analysis/` 文档，也不调用 Maintainer。
- 文档模式：生成分析文档。完整读取 [references/persistence-formats.md](references/persistence-formats.md)，并在文档验证后自动登记 R 引用。

用户明确指定输出方式时服从用户。未指定时，仅在结果需要跨会话复用、多主题索引或后续计划依赖时使用文档模式。

## 前置检查

1. 复用当前会话中已读取且未变化的 AGENTS、SNAPSHOT、project-model、decisions、knowledge、references 和 change 信息，只补读目标所需的缺失内容。
2. Assistant 提供的体系文档上下文不能替代本次目标代码调查。
3. 检查 `.agents/analysis/` 是否已有同主题文档。
4. 检查活跃 OpenSpec change。
5. 调查涉及实施结论时，读取相关 Iteration、Cycle、Act Response 和已有 Evidence。
6. 明确目标、范围和 3-8 个需要回答的问题。

已有分析足够时复用，不重复生成。

用户随后调用 Plan 时，当前会话结论或 Analysis 是可复用的实现调查输入。Explorer 记录捕获 revision、代码位置、已确认事实、推断、未知项和适用范围；Plan 负责判断其是否仍适用并补齐制定执行契约所缺的内容。Explorer 不生成 Plan Context。

## 调查规则

- 从入口、关键类型和用户目标开始。
- 追踪上游调用者、下游依赖、状态变化和错误路径。
- 记录动态边：回调、事件、重新渲染、任务唤醒和消息队列。
- 深度以回答目标问题为限。
- 所有代码事实给出文件和符号位置。
- 记录与目标有关的现有测试、验证入口和已实际运行的结果；没有运行时明确说明。
- 当前项目描述以 SNAPSHOT 为准。分析文档不复制完整项目概览，只保留目标所需的历史现场。
- Evidence 只能支持其记录的环境和结论；引用时给出 change、Iteration、Cycle 和文件路径。
- 遇到 `Mxx/Dxx/Kxx/Rxx/Ixx` 或旧编号归档指引时，按 `<!-- arc:` 跳转到 carrier archive。
- 只做网页搜索不能构成项目分析；必须读取实际项目文件。

## 文档模式

写入 `.agents/analysis/<topic>.md`。每份文档包含：

- SNAPSHOT 路径、采集 revision、分支和日期。
- 目标与范围。
- 已确认事实、推断和未确认项。
- 调用链、数据流或状态机。
- 现有测试、验证入口和影响面。
- 关键接口和数据结构。
- 边界和失败路径。
- 关键文件索引。
- 关联分析的相对链接。

文件名使用小写连字符。

## 持久化登记

文档验证通过后：

1. 为每份新建或实质更新的分析文档生成 R 候选。
2. 自动调用 `openspec-docs-maintainer`。
3. 授权范围只限于去重并写入 `.agents/memory/references.md`。
4. 报告 R 编号和分析文档路径。
5. 登记失败时保留分析文档并报告原因，不扩大写入范围。

发现 M、D、K 或 I 候选时只在结果中列出。除非用户明确授权，不自动登记这些候选、tasks 或 SNAPSHOT。

即时回答模式不生成候选、不调用 Maintainer。

## Gate

完成前确认：

- 每个目标问题都有答案或明确未确认原因。
- 调用链和依赖链足以支持结论。
- 输出与用户目标相关。
- 文档模式下，文件路径和交叉引用有效。
- 文档模式下，每份分析文档已有 R 登记结果或失败说明。
- 未修改产品代码。

## 禁止

- 在目标不清楚时开始深挖。
- 修改源码。
- 自行写 M/D/K/R/I。
- 生成无来源结论。
- 重复已有分析。
- 把分析文档写入 `.agents/memory/`。
- 即时回答模式创建分析文档或调用 Maintainer。
- 借自动 R 登记写入 M/D/K/I、tasks、SNAPSHOT 或 change。
