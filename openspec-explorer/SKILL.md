---
name: openspec-explorer
description: 深度阅读项目并生成 .claude/analysis/ 分析文档。用于理解整个项目、架构、调用链、模块或子系统；支持宏观和微观模式。只写分析文档，知识、参考和架构登记交给 openspec-docs-maintainer。
---

# OpenSpec Explorer

读取代码和项目文档，生成可追溯分析。不要修改产品代码，也不要直接修改 A/L/R/O 状态文档。

## 选择模式

- 宏观模式：分析整个项目，生成 3-8 个主题文档。执行前完整读取 [references/macro-workflow.md](references/macro-workflow.md)。
- 微观模式：围绕一个模块、流程或任务生成 1-2 个文档。执行前完整读取 [references/micro-workflow.md](references/micro-workflow.md)。
- 需要登记知识、索引或架构发现时，读取 [references/persistence-formats.md](references/persistence-formats.md)，生成交接清单并调用 `openspec-docs-maintainer`。

## 前置检查

1. 读取 `CLAUDE.md`。
2. 读取 SNAPSHOT、references、learned 和 architecture 中与目标相关的内容。
3. 检查 `.claude/analysis/` 是否已有同主题文档。
4. 检查活跃 OpenSpec change。
5. 明确目标、范围和 3-8 个需要回答的问题。

已有分析足够时复用，不重复生成。

## 调查规则

- 从入口、关键类型和用户目标开始。
- 追踪上游调用者、下游依赖、状态变化和错误路径。
- 记录动态边：回调、事件、重新渲染、任务唤醒和消息队列。
- 深度以回答目标问题为限。
- 所有代码事实给出文件和符号位置。
- 遇到 `Lxx/Rxx/Axx` 归档指引时，按 `<!-- arc:` 跳转到 carrier archive。
- 只做网页搜索不能构成项目分析；必须读取实际项目文件。

## 输出文件

写入 `.claude/analysis/<topic>.md`。每份文档包含：

- 项目、分支和日期。
- 目标与范围。
- 结论。
- 调用链、数据流或状态机。
- 关键接口和数据结构。
- 边界、失败路径和未确认项。
- 关键文件索引。
- 关联分析的相对链接。

文件名使用小写连字符。

## 持久化交接

分析完成后生成候选清单：

- `R`：分析文档索引。
- `L`：API、关键文件、踩坑和技巧。
- `A`：架构决策或约束。

把清单交给 `openspec-docs-maintainer` 去重、编号和写入。Explorer 不直接编辑 references、learned 或 architecture。

## Gate

完成前确认：

- 每个目标问题都有答案或明确未确认原因。
- 调用链和依赖链足以支持结论。
- 文档与用户目标相关。
- 文件路径和交叉引用有效。
- 候选 A/L/R 已交给 maintainer。
- 未修改产品代码。

## 禁止

- 在目标不清楚时开始深挖。
- 修改源码。
- 直接写 A/L/R/O。
- 生成无来源结论。
- 重复已有分析。
- 把分析文档写入 `openspec/specs/`。
