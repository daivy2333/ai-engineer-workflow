# CLAUDE.md 模板

此模板只生成项目公共规范。项目事实、命令和现状写入 SNAPSHOT 或 tasks。

```markdown
# CLAUDE.md

## 文档地图

| 内容 | 路径 | 写入者 |
|---|---|---|
| 公共规则 | `CLAUDE.md` | 人工或 `openspec-init` |
| 当前状态 | `.claude/docs/SNAPSHOT.md` | `openspec-docs-maintainer` |
| 全局任务 | `.claude/docs/tasks.md` | `openspec-docs-maintainer` |
| 迭代模板 | `.claude/docs/templates/change-iteration.md` | `openspec-init` |
| 架构 | `openspec/specs/architecture/spec.md` | `openspec-docs-maintainer` |
| 学习 | `openspec/specs/learned/spec.md` | `openspec-docs-maintainer` |
| 参考 | `openspec/specs/references/spec.md` | `openspec-docs-maintainer` |
| 优化 | `openspec/specs/optimization/spec.md` | `openspec-docs-maintainer` |
| 活跃变更 | `openspec/changes/` | OpenSpec、plan、act |
| 分析文档 | `.claude/analysis/` | `openspec-explorer` |

## 读取顺序

- 新会话：CLAUDE → SNAPSHOT → tasks → active changes。
- 新功能或 Bug：architecture → learned → plan。
- 实施：change 基线 → 最新 iteration → act。
- 实现 Review：当前 iteration → 实际代码和证据 → plan。
- 查询：assistant。
- 日常文档写入：docs-maintainer。

## Skill 职责

- `openspec-assistant`：只读。
- `openspec-plan`：需求、BDD、计划、iteration 和实施 Review。
- `openspec-act`：TDD、实施、验证和 Act Response。
- `openspec-docs-maintainer`：显式维护 tasks、SNAPSHOT、A/L/R/O 和指定 change 收尾。
- `openspec-explorer`：宏观或微观探索；输出即时回答或 `.claude/analysis/`。
- `openspec-compressor`：原地压缩，不改变状态。
- `openspec-archivist`：生命周期清理和 carrier 归档。

## 阶段边界

- Skill 完成不构成下一阶段授权。
- Plan 完成后终止，等待用户审计和 Act 指令。
- Act 写入反馈后终止，不归档、不维护全局状态。
- Plan Review 后终止，不自动调用 Act 或 Maintainer。
- Explorer 即时回答后终止，不调用 Maintainer。
- Explorer 生成分析文档后，可自动调用 Maintainer 登记对应 R 引用。
- 此自动授权只覆盖 R 登记，不覆盖 A/L/O、tasks、SNAPSHOT 或 change。
- 除 Explorer 的 R 登记外，Maintainer 只执行用户点名的维护动作。
- 除上述例外，用户明确授权串联时才可继续下一阶段。

## 通用能力

流程描述使用能力语义：

| 语义 | 要求 |
|---|---|
| 任务追踪 | 记录 Phase、Task、Gate、状态和跳过原因 |
| 用户决策 | 对需求、风险和不可逆动作取得明确选择 |
| 文件读取 | 完整读取所选规则和引用 |
| 精准编辑 | 只修改相关片段 |
| 命令执行 | 保留命令、输出和退出码 |
| 并行委托 | 仅在环境支持且任务可独立时使用 |
| OpenSpec 集成 | 按当前职责创建、应用、验证或归档 change |

平台工具名只是适配，不改变上述语义。

## 行为约束

**Think Before Coding**

- 陈述影响实现的假设。
- 多种解释会改变结果时请求用户决定。
- 不隐藏不确定性。

**Simplicity First**

- 不添加未要求功能。
- 不为一次使用提前抽象。
- 不增加无需求依据的配置。

**Surgical Changes**

- 只修改需求需要的内容。
- 不清理无关代码。
- 清理由本次改动产生的孤儿。

**Requirements Integrity**

- 用户明确要求必须全部覆盖。
- 实现简单不能成为裁剪需求的理由。
- 任何简化先写入 RTM 并取得批准。

## 核心执行约束

1. 不探索清楚不实现。
2. 不计划清楚不实现。
3. 不完整覆盖需求不实现。
4. 不测试通过不提交。
5. 不验证成功不声明。
6. 三次失败必须反思。
7. 不见测试见证不变更。
8. 不见场景缺口扫描不进设计。

## BDD

需求设计前扫描：

- Happy Path。
- Sad Path。
- Edge Case。
- 错误、超时、取消和兼容性。

输出场景草图：前置状态、动作、结果和失败边界。用户显式接受的缺口写入 proposal。

## TDD

铁律：`NO CHANGE WITHOUT TEST WITNESS`。

- 新功能：测试定义期望，观察 RED，再实现 GREEN。
- Bug：测试复现问题，观察 RED，再修复 GREEN。
- 重构：先观察 GREEN，重构后保持 GREEN。

每次变更执行：

1. 定位范围。
2. 建立测试。
3. 验证当前状态。
4. 修改。
5. 验证新状态。
6. Review。

## Gate

- Gate 1：需求、BDD、场景和 change 获批。
- Gate 2：RTM 无 Missing，所有 Simplified 获批。
- Gate 3：每个任务有测试见证。
- Gate 4：先 spec review，后 code review。
- Gate 5：完成声明有新鲜证据。
- Gate 6：阻塞即停；三次失败后反思。

Gate BLOCK 必须记录原因。用户显式豁免必须保留原话和风险。

## 任务追踪

- 每个 Phase 和可验证 Step 有状态。
- 跳过项标记 `SKIPPED: <reason>`。
- 只有验证通过后才能标记完成。
- 最终报告前检查全部任务状态。

## 迭代线程

- 每个 change 使用 `iterations/000-initial.md` 开始。
- 后续轮次使用递增的零填充编号。
- Plan 只写 `Plan Context` 和 `Plan Review`。
- Act 只写 `Act Response`。
- 交接后的 Plan Context 不得改写。
- Act 不得创建下一轮 iteration。
- Plan Review 必须检查代码和证据，不只读取 Act Response。
- 有后续任务时创建新 iteration，不覆盖旧记录。

## 验证

完成声明必须包含：

- 验证命令或操作。
- 关键输出。
- 退出码或明确结果。
- 证据支持的结论。

禁止使用“应该、大概、基本完成”替代证据。

## 三次失败

同一问题连续失败 3 次：

1. 停止当前修复。
2. 记录三次尝试和症状。
3. 检查共享状态、耦合和需求假设。
4. 返回设计或需求阶段。
5. 不开始第四次同类盲试。

## 文件编辑

- 已有文件只做精准修改。
- 新文件才允许整体创建。
- 不覆盖用户无关改动。
- 移动或删除前检查引用。

## 完成前五问

1. 每一步是否有状态？
2. 跳过项是否有原因？
3. Gate 是否逐项通过或阻塞？
4. 完成声明是否有新鲜证据？
5. 最终报告前是否检查任务状态？
```

平台可以另外提供入口配置，但不得复制并改写这些规则。
