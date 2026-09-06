# Change Evidence 格式

Evidence 是 change 内按需保存、会改变验收或恢复决定且无法用 Act Response 充分表达的实施事实。普通验证结果写入 Act Response；Gate、测试、Review 数量和长输出本身不构成持久化理由。

Evidence 只保存目标行为结果，不建立公共规则禁止的测试材料身份或运行归属系统。环境信息只用于解释适用范围，不能作为 Acceptance 证据。

只有用户明确要求、结果无法低成本复现、一次性环境即将消失、Incident/实质 Blocker 需要保留现场，或摘要会丢失决定性结构时才创建 Evidence。

## 目录

```text
openspec/changes/<change>/evidence/
└── <III-title>/
    └── <CCC-title>/
        ├── README.md
        └── <最多四个实际证据文件>
```

- 不创建 change 级或 Iteration 级 README；Cycle 路径已提供索引。
- Iteration 目录名与 `iterations/<III-title>/` 相同。
- Cycle 目录名与 `iterations/<III-title>/<CCC-title>.md` 的文件名相同。
- Cycle `README.md` 记录来源、结论、文件和限制。
- 不创建 `implementation.md` 复制 Act Response、diff 或源码；这些信息留在原权威位置。
- 没有持久化证据时，不创建 `evidence/` 或空占位文件。

## Cycle README

```markdown
# Evidence: <III-title> / <CCC-title>

- Change: <change>
- Iteration: <III-title>
- Cycle: <CCC-title>
- Captured at: <time>
- Environment: <工具链、平台和模式>

| ID | Origin | Acceptance | Claim | Artifact | Result |
|---|---|---|---|---|---|
| EV-<III>-<CCC>-01 | plan-required | <R/S/Acceptance> | <结论> | [文件](artifact) | PASS/FAIL/BLOCKED |
```

`Origin` 使用 `plan-required`、`act-added` 或 `user-required`。每项证据写明白名单理由、Act Response 不足原因、采集方式、结果和适用限制。失败、超时和跳过只有在改变验收、阻塞或恢复决定时才保留。

## 预算

- 每个 Cycle 目录最多 5 个文件，包含 `README.md`。
- 整个 change 最多 20 个 Evidence 文件，包含所有 Cycle README。
- 单个文本文件最多 500 行且不超过 256 KiB。
- 禁止保存完整日志目录、源码副本或完整测试套件输出。
- 禁止通过增加 Cycle、拆分、压缩、编码或改格式绕过文件数和大小限制。
- 二进制文件或超限产物必须在收集前取得用户明确批准；超限本身不阻塞实现或 Acceptance。
- 超出预算时停止收集，只在 Act Response 保存不超过 20 行的决定性输出并请求用户决定。

## 阻塞证据

计划偏差可复现或可用不超过 20 行的决定性输出说明时，只写 Act Response。只有实质 Blocker 无法低成本复现，或摘要会丢失影响恢复决定的结构时，才保存 `blocker.md` 或一个最小原始片段。

只有实质偏差命中 Gate 6 时才生成阻塞证据。局部路径变化、等价实现或验证调整和非阻塞 Minor finding 写入 Act Response，不生成 BLOCKED Evidence。`blocker.md` 记录发现位置、Plan 预期、实际情况、影响、部分工作、工作区状态和恢复条件。README 使用：

```markdown
| ID | Origin | Acceptance | Claim | Artifact | Result |
|---|---|---|---|---|---|
| EV-<III>-<CCC>-01 | act-added | <Acceptance> | Task Contract 与实际代码存在实质冲突 | [blocker.md](blocker.md) | BLOCKED |
```

Act Response 引用证据编号。没有保存需要时写 `None required`，不创建 Evidence 目录。

## 规则

- Plan 只声明通过白名单、必要性问题和预算检查的证据要求，不生成实际证据。
- Evidence 必须直接支持目标状态、输出、错误结果、协议结果或退出码；材料身份、来源匹配和时间顺序不能单独支持 Acceptance。
- `required` 项只有在它直接支持 Acceptance 且满足上述条件时才构成 Gate 要求；无依据、超预算或无法安全采集时，Act 不收集并通过 Gate 6 以 `blocked` 返回 Plan Review。
- Act 可保存计划外证据，但必须在 Cycle README 和 Act Response 中说明白名单理由。
- Act Response 引用具体文件或证据编号，不复制长日志，每项验证输出不超过 20 行。
- Response 标记 `reported` 或 `blocked` 后，不静默覆盖已有证据。
- 敏感信息必须脱敏，并注明脱敏范围。
- Evidence 不登记 R，不单独 Artifact-Archive，随 change 一起归档。
