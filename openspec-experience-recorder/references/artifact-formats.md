# 工程经验产物格式

Runbook 和 Issue 按需创建，不生成空目录或占位文档。正文引用来源证据，不复制长日志。

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

## Issue

路径：`.claude/issues/ISSxx-<topic>.md`，ISSxx 读取目录最大编号后递增。

```markdown
# <缺陷标题>

- Status: open | closed
- Filed: YYYY-MM-DD
- Source: <Plan Review / Act Response / Explorer 报告 / 外部证据>
- Environment: <平台、工具链、模式和关键版本>

## 缺陷描述

<对已有代码/行为的指控：预期、实际、位置 path::symbol>

## 影响

<当前与潜在影响；未爆发写 None>

## 事件记录

<缺陷实际引发故障时补记：时间线、触发与根因（Confirmed/Inferred/Unconfirmed）、检测与恢复；未爆发写 None>

## 处置

<关联 change、MSxx 或用户决定；关闭时保留原因和指针：scheduled → MSxx | fixed → change | declined；reopen 追加记录>

## 证据

<Act Response、Evidence、analysis 或外部证据路径；不复制正文>
```

状态迁移追加记录（日期、原因、指针），不改写已发生内容。close 和 reopen 只按用户指令执行。并入同类报告时在缺陷描述追加来源，不新开文件。

## R 候选

```text
类型: runbook | issue
主题: <主题>
路径: <产物路径>
日期: YYYY-MM-DD
用途: <适用操作或事件范围>
状态: active
```

自动登记请求只能包含本次产物的检索元数据。不得附带项目记忆、任务、change、同步或归档请求。
