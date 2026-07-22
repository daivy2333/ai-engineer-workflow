# Change Evidence 格式

Evidence 是 change 内按需保存的实施证据。普通验证结果写入 Act Response；只有 Plan 明确要求，或 Act 需要保留长日志、特殊格式或难以复现的输出时才创建 Evidence。

## 目录

```text
openspec/changes/<change>/evidence/
├── README.md
└── <NNN-title>/
    ├── README.md
    ├── implementation.md
    ├── test.log
    └── <其他实际证据文件>
```

- change 级 `README.md` 只索引已有 iteration 证据目录。
- iteration 目录名与 `iterations/<NNN-title>.md` 同名。
- iteration `README.md` 记录来源、结论、文件和限制。
- `implementation.md` 可记录修改路径、符号、diff 基线和供 Response 引用的实施事实，不复制源码正文。
- `.md` 保存结构化说明，`.log` 保存原始文本输出；其他数据保留原格式。
- 没有持久化证据时，不创建 `evidence/` 或空占位文件。

## iteration README

```markdown
# Evidence: <NNN-title>

- Change: <change>
- Iteration: <NNN-title>
- Captured at: <time>
- Revision: <commit 或 worktree 状态>
- Environment: <工具链、平台和模式>

| ID | Origin | Claim | Artifact | Result |
|---|---|---|---|---|
| EV-<NNN>-01 | plan-required | <结论> | [文件](file.log) | PASS/FAIL/BLOCKED |
```

`Origin` 使用 `plan-required`、`act-added` 或 `user-required`。每项证据写明采集方式、结果和适用限制；失败、超时和跳过同样保留。

## 规则

- Plan 只声明证据要求，不生成实际证据。
- `required` 项缺失时，对应 Gate 不得通过。
- Act 可保存计划外证据，但必须在 README 和 Act Response 中说明原因。
- Act Response 引用具体文件或证据编号，不复制长日志。
- Response 标记 `reported` 后，不静默覆盖已有证据；重新执行时新增文件或修正记录。
- 敏感信息必须脱敏，并注明脱敏范围。
- Evidence 不登记 R，不单独 Artifact-Archive，随 change 一起归档。
