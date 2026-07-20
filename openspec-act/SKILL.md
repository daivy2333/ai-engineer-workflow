---
name: openspec-act
description: 按已批准的 OpenSpec 计划和当前迭代上下文执行 TDD、Gate 验证、两阶段 Review，并记录实现反馈。用于存在获批 change 和待执行 iteration，且用户要求实现或验证本轮任务时；不归档、不维护全局状态。
---

# OpenSpec Act

完成当前迭代的实施、验证和反馈。前置条件是 `openspec-plan` 的 Gate 1、Gate 2 已通过，或用户已显式豁免并留下记录。

## 前置规则

1. 读取项目 `CLAUDE.md`、SNAPSHOT、tasks 和 change 的 proposal、specs、design、tasks。
2. 读取 `.claude/docs/templates/change-iteration.md`。
3. 找到最新且 `Plan Context` 为 `ready`、`Act Response` 为 `pending` 的迭代。
4. 使用当前环境的任务追踪能力记录每个 Phase、Task、Gate 和跳过项。
5. 使用当前环境可用的 OpenSpec 集成执行 apply 和 validate。
6. 修改产品代码前建立测试见证。
7. Skill 完成不构成 Review、维护或归档授权。写入反馈后终止。

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

不要修改计划范围外的代码。发现计划缺口时，在 `Act Response` 记录阻塞并终止；提醒用户调用 `openspec-plan`，不要自行扩展需求。

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

## Phase 4：REPORT

全部任务完成后：

1. 运行完整验证套件。
2. 完成两阶段 Review。
3. 验证 OpenSpec change。
4. 更新 change 内本轮任务状态。
5. 只填写当前迭代的 `Act Response`：
   - 实际改动。
   - 文件和符号。
   - 与计划的偏差及原因。
   - 验证命令、输出和退出码。
   - 未解决问题。
   - 可选 commit 或 diff 引用。
6. 将 `Act Response` 状态改为 `reported`。
7. 终止并等待用户审计。

不得填写 `Plan Review`，不得创建下一轮 iteration。

## 完成前五问

1. 每个计划任务是否都有状态和证据？
2. 所有跳过步骤是否记录原因？
3. Gate 3-6 是否逐项通过或明确阻塞？
4. 完成声明是否有新鲜输出？
5. `Act Response` 是否与实际代码和证据一致？

任一答案为否，不得声明完成。

## 输出与终止

- 已完成任务。
- 修改文件。
- Spec review 和 code review 结果。
- 验证命令、输出摘录和退出码。
- 当前 iteration 路径和 Act Response 状态。
- 跳过项、阻塞项和遗留 Minor 问题。

然后终止。提醒用户：

- 实现反馈已等待审计。
- 需要检查或修订时调用 `openspec-plan`。
- 认可结果后调用 `openspec-docs-maintainer` 同步或收尾。
- 未归档 change，未同步全局文档，未清理分支。

## 禁止

- 无测试见证修改代码。
- 用“应该通过”代替运行结果。
- Spec review 前做 code quality review。
- 三次失败后继续盲试。
- 修改全局任务、SNAPSHOT 或知识文档。
- 调用 Maintainer、Plan 或 Archivist。
- 归档 change、清理分支或执行其他生命周期收尾。
- 覆盖 Plan Context 或填写 Plan Review。
- 把平台专属工具名写成流程前提。
