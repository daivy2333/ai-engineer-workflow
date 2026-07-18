---
name: openspec-act
description: 按已批准的 OpenSpec 计划执行 TDD、Gate 验证、两阶段 Review 和归档收尾。用于 openspec-plan 已完成、存在获批 change，且用户要求开始实现、验证或完成变更时。
---

# OpenSpec Act

完成 Phase 3-4：实施与收尾。前置条件是 `openspec-plan` 的 Gate 1、Gate 2 已通过，或用户已显式豁免并留下记录。

## 前置规则

1. 读取项目 `CLAUDE.md`、change 的 proposal、specs、design 和 tasks。
2. 使用当前环境的任务追踪能力记录每个 Phase、Task、Gate 和跳过项。
3. 使用当前环境可用的 OpenSpec 集成执行 apply、validate 和 archive。
4. 修改产品代码前建立测试见证。
5. 所有全局文档同步交给 `openspec-docs-maintainer`；`openspec-assistant` 只读。

## Gate 3：Test Witness

每个任务开始前确认：

- 已定位变更符号、调用者和影响范围。
- 已有测试覆盖，或先建立测试。
- 已运行当前状态验证。
- 新功能和 Bug 修复已观察到预期 RED。
- 重构已观察到变更前 GREEN。

铁律：`NO CHANGE WITHOUT TEST WITNESS`。

## Phase 3：EXECUTE

对每个 OpenSpec task 执行：

1. 标记任务进行中。
2. 建立 Gate 3 证据。
3. 运行 RED → 验证 RED。
4. 做满足当前任务的最小改动。
5. 运行 GREEN → 验证 GREEN。
6. 必要时重构并保持 GREEN。
7. 执行 Gate 4 和 Gate 5。
8. Gate 5 通过后才能标记完成。

不要修改计划范围外的代码。发现计划缺口时返回 `openspec-plan`，不要自行扩展需求。

## Gate 4：Two-Stage Review

严格按顺序执行：

1. Spec compliance review。
2. Code quality review。

Critical 和 Important 问题必须在进入下一任务前解决。Minor 问题可以记录，但不得伪装成已解决。

## Gate 5：Evidence-Based Verification

任何完成声明都按以下顺序：

1. 确定能证明声明的命令或操作。
2. 运行完整验证。
3. 读取完整输出和退出码。
4. 摘录关键输出。
5. 判断证据是否支持声明。
6. 证据支持后再声明。

验证范围按变更选择：

- 测试。
- 格式化和静态分析。
- 构建。
- CLI 实际运行。
- API 调用。
- UI 检查。
- 配置加载。
- OpenSpec validate。

报告格式：

| 验证项 | 命令或操作 | 输出摘录 | 结论 |
|---|---|---|---|
| 测试 | `<command>` | `<fresh output>` | PASS/FAIL |

## Gate 6：Stop on Blocker

遇到以下情况停止当前路径并记录：

- 缺失依赖。
- 当前状态验证失败且原因未知。
- 计划无法覆盖任务。
- 同一验证点连续失败 3 次。
- 同一问题连续修复 3 次仍未解决。

三次失败后：

1. 列出三次尝试和症状。
2. 检查 shared state、coupling 和错误的需求假设。
3. 判断应返回架构设计还是需求确认。
4. 禁止直接开始第四次同类尝试。

## Phase 4：COMPLETE

全部任务完成后：

1. 运行完整验证套件。
2. 完成两阶段 Review。
3. 验证 OpenSpec change。
4. 使用 OpenSpec 集成归档 change。
5. 请求 `openspec-docs-maintainer` 同步 tasks 和 SNAPSHOT。
6. 提供分支处理选项；删除或丢弃需要用户明确确认。

若归档的是 archivist carrier change，还要确认：

- OpenSpec changes 验证通过。
- 源文档存在对应 `<!-- arc:` 指引。

## 完成前五问

1. 每个计划任务是否都有状态和证据？
2. 所有跳过步骤是否记录原因？
3. Gate 3-6 是否逐项通过或明确阻塞？
4. 完成声明是否有新鲜输出？
5. 最终报告前是否检查了任务追踪状态？

任一答案为否，不得声明完成。

## 输出

- 已完成任务。
- 修改文件。
- Spec review 和 code review 结果。
- 验证命令、输出摘录和退出码。
- OpenSpec 归档结果。
- 文档同步结果。
- 跳过项、阻塞项和遗留 Minor 问题。

## 禁止

- 无测试见证修改代码。
- 用“应该通过”代替运行结果。
- Spec review 前做 code quality review。
- 三次失败后继续盲试。
- 直接修改全局任务或知识文档，绕过 maintainer。
- 把平台专属工具名写成流程前提。
