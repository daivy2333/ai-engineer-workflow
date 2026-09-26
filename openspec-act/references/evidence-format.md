# Change Evidence 格式

Evidence 是 change 内按需保存、会改变验收或恢复决定且无法用 Act Response 充分表达的实施事实。普通验证结果写入 Act Response；Gate、测试、Review 数量和长输出本身不构成持久化理由。

Evidence 只保存目标行为结果；环境信息只用于解释适用范围，不能作为 Acceptance 证据（公共规则 › 行为约束）。

只有满足公共规则白名单的情形才创建 Evidence（公共规则 › Iteration 与 Cycle 线程）。

## 目录

```text
.agents/changes/<change>/evidence/
└── <III-title>/
    └── <CCC-title>/
        ├── README.md
        └── <实际证据文件>
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

- 来源: <plan-required | act-added | user-required；白名单理由和 Act Response 不足原因>
- 结论: <支持的 Acceptance、Claim 和 Result；失败、超时和跳过只有在改变验收、阻塞或恢复决定时才保留>
- 文件: <实际证据文件清单>
```

环境、工具链和模式只在解释适用范围时记录。

## 阻塞证据

计划偏差可复现或可简短说明时，只写 Act Response。只有实质 Blocker 无法低成本复现，或摘要会丢失影响恢复决定的结构时，才保存 `blocker.md` 或一个最小原始片段。

只有实质偏差命中 Gate 5 时才生成阻塞证据。局部路径变化、等价实现或验证调整和非阻塞 Minor finding 写入 Act Response，不生成 BLOCKED Evidence。`blocker.md` 记录发现位置、Plan 预期、实际情况、影响、部分工作、工作区状态和恢复条件；来源记 `act-added`，在 Cycle README 列入文件。

Act Response 引用具体文件。没有保存需要时写 `None required`，不创建 Evidence 目录。

## 规则

- Plan 只声明通过白名单和必要性问题检查的证据要求，不生成实际证据。
- Evidence 必须直接支持目标状态、输出、错误结果、协议结果或退出码；材料身份、来源匹配和时间顺序不能单独支持 Acceptance。
- `required` 项只有在它直接支持 Acceptance 且满足上述条件时才构成 Gate 要求；无依据或无法安全采集时，Act 不收集并通过 Gate 5 以 `blocked` 返回 Plan Review。
- Act 可保存计划外证据，但必须在 Cycle README 和 Act Response 中说明白名单理由。
- Act Response 引用具体文件，不复制长日志；输出上限见公共规则 › 验证。
- Response 标记 `reported` 或 `blocked` 后，不静默覆盖已有证据。
- 敏感信息必须脱敏，并注明脱敏范围。
- Evidence 不登记 R，不单独 Artifact-Archive，随 change 一起归档。
