# 工程经验产物格式

Runbook 和 Incident 按需创建，不生成空目录或占位文档。正文引用来源证据，不复制长日志。

## Runbook

路径：`.claude/runbooks/<topic>.md`

```markdown
# <操作名称>

- Status: active
- Last validated: YYYY-MM-DD
- Environment: <平台、工具链、模式和关键版本>
- Source: <Act Cycle、Evidence 或外部证据>

## 适用范围

<何时使用、何时不适用>

## 前置条件

<权限、环境、输入和安全检查>

## 操作步骤

<已验证的执行顺序>

## 验证

<成功判据、命令、关键输出和结果>

## 失败处理

<常见失败、停止条件和诊断入口>

## 回滚

<恢复步骤；不可回滚时明确说明>

## 证据

<来源路径、revision、日期和适用限制>
```

更新时刷新 `Last validated`、环境和证据。未经重新验证，不把过期步骤改写为有效路径。

## Incident

路径：`.claude/incidents/YYYY-MM-DD-<topic>.md`

```markdown
# <事件名称>

- Status: open | mitigated | resolved
- Occurred: <时间或时间范围>
- Environment: <平台、工具链、模式和关键版本>
- Source: <Act Cycle、Evidence 或外部证据>

## 影响

<用户、系统、数据、硬件、交付和持续时间>

## 时间线

<发现、响应、缓解、恢复和确认节点>

## 触发与根因

- Confirmed: <已验证事实>
- Inferred: <证据支持但未完全确认的推断>
- Unconfirmed: <未知项和待验证假设>

## 检测与恢复

<如何发现、如何恢复、哪些保护失效>

## 后续动作

<关联 change、Runbook 或经用户授权写入的 M/D/K/I>

## 证据

<日志、命令、版本、路径、日期和适用限制>
```

更新时追加时间线，不覆盖历史事实。只有证据支持时才能把 `open` 更新为 `mitigated` 或 `resolved`。

## R 候选

```text
类型: runbook | incident
主题: <主题>
路径: <产物路径>
日期: YYYY-MM-DD
用途: <适用操作或事件范围>
状态: active
```

自动登记请求只能包含本次产物的检索元数据。不得附带项目记忆、任务、change、同步或归档请求。
