# Change iteration 模板

将下面内容生成到 `.claude/docs/templates/change-iteration.md`。Plan 按此模板在 change 的 `iterations/` 下创建每一轮上下文。

```markdown
# Iteration <NNN>: <TITLE>

## Plan Context

- Status: ready
- Round: <NNN>
- Parent: <NONE_OR_PARENT>

**Objective**

<本轮可验证结果>

**Background**

<需求来源、历史问题和本轮原因>

**Current Baseline**

<当前实现、已有能力和已知限制>

**Relevant Code**

<文件、模块、符号及其职责>

**Critical Path**

<入口、调用链、数据流、状态变化和外部影响>

**Implementation Guidance**

<建议顺序、必要技术细节和关键取舍>

**Invariants**

<不得破坏的行为、兼容性和架构约束>

**Non-goals**

<本轮不处理的内容>

**Acceptance**

<可观察验收条件及 requirement 映射>

**Verification**

<测试、检查命令和所需证据>

**Risks and Notes**

<常见误判、回归风险和额外注意事项>

## Act Response

- Status: pending

**Implemented**

<实际完成内容>

**Changed Files and Symbols**

<文件、符号和作用>

**Deviations from Plan**

<偏差、原因和影响；没有则写 None>

**Verification Evidence**

<命令或操作、关键输出、退出码和结论>

**Remaining Issues**

<未解决问题或 None>

**Commit or Diff Reference**

<可选引用；本字段不要求创建 Git commit>

## Plan Review

- Status: pending

**Review Result**

<follow-up-required | no-follow-up>

**Findings**

<基于代码、diff 和验证证据的发现>

**Evidence**

<文件、符号、命令和输出>

**Follow-up Decision**

<下一步和范围>

**Next Iteration**

<新 iteration 路径或 None>
```

## 写入规则

- Plan 创建文件并填写 `Plan Context`。
- Act 只填写 `Act Response`，完成后把其状态改为 `reported`。
- Plan Review 只填写 `Plan Review`。
- 已交接的区域只追加所属角色预留内容，不改写历史。
- Review 需要后续工作时创建下一编号文件。
- 文件名使用 `NNN-title.md`，编号从 `000` 递增。
