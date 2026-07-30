# AI Engineer Workflow Skills

一组可复用的 `SKILL.md` 工作流，覆盖 OpenSpec、OMO 模型编排、Markdown 写作、知识讲授、OS、驱动、QEMU 和真机调试。

## 支持范围

技能正文使用 Agent Skills 的共同结构：

```text
<skill-name>/
├── SKILL.md
├── references/   # 可选，按需读取
├── scripts/      # 可选，确定性辅助工具
└── agents/       # 可选，平台 UI 元数据
```

每个 `SKILL.md` 的 frontmatter 只使用 `name` 和 `description`。这是 Claude Code、OpenCode 和 Codex 都能识别的公共字段。

三端差异只在发现目录和工具入口：

| 平台 | 项目技能目录 | 用户技能目录 | 项目规则入口 |
|---|---|---|---|
| Claude Code | `.claude/skills/` | `~/.claude/skills/` | `CLAUDE.md` |
| Codex | `.agents/skills/` | `~/.agents/skills/` | `AGENTS.md` |
| OpenCode | `.opencode/skills/`、`.claude/skills/` 或 `.agents/skills/` | `~/.config/opencode/skills/`、`~/.claude/skills/` 或 `~/.agents/skills/` | `AGENTS.md`，无该文件时兼容 `CLAUDE.md` |

同一份技能内容可以在三端使用，不需要维护三个副本。平台专属的任务工具、权限和 slash command 由适配层处理。

目标项目仍以 `CLAUDE.md` 保存公共 OpenSpec 规则。`openspec-init` 为 Codex 和 OpenCode 生成薄 `AGENTS.md` 入口，让它们读取同一份规则，不复制规则正文。

参考：

- [Claude Code Skills](https://code.claude.com/docs/en/skills)
- [OpenCode Agent Skills](https://opencode.ai/docs/skills/)
- [Codex Skills](https://learn.chatgpt.com/docs/customization/overview#skills)

## 技能

### OpenSpec

| Skill | 职责 |
|---|---|
| `openspec-init` | 初始化规则、specs、状态文档和三端入口 |
| `openspec-assistant` | 只读查询规则、状态、项目记忆和 active changes |
| `openspec-milestone-planner` | 规划工作量适中、可独立验证和排障的 milestone roadmap |
| `openspec-plan` | BDD、实现调查、可执行计划、iteration 创建和实施反馈 Review |
| `openspec-act` | 执行当前 iteration、TDD、Review、验证和反馈 |
| `openspec-experience-recorder` | 把已验证实施或运行经验记录为 Runbook、Incident |
| `openspec-docs-maintainer` | 维护状态、M/D/K/R/I、限定 R 登记和指定 change 收尾 |
| `openspec-explorer` | 宏观或微观探索，输出即时回答或分析文档 |
| `openspec-compressor` | 活跃文档原地压缩，不改变状态 |
| `openspec-archivist` | 生命周期判断、carrier 归档、删除和墓碑 |
| `omo-ulw` | 在 OMO ultrawork 下为 OpenSpec 阶段分配代理、Category 和模型 |

职责规则：

```text
assistant 只读
explorer 只写 analysis
milestone-planner 只规划 MSxx 路线
experience-recorder 只写 Runbook 和 Incident
maintainer 写状态、项目记忆和检索索引
compressor 只改表达密度
archivist 只处理生命周期
plan/act 维护当前 OpenSpec change
```

开发流程：

```text
openspec-milestone-planner
  → 读取项目目标、状态和已有分析
  → 建立阶段成果、依赖、稳定基线和故障边界
  → 聚合过细阶段，拆分过重阶段
  → 用户批准后写入 tasks 的 MSxx
  → 终止，不创建 change

openspec-plan
  → Gate 1：需求与 BDD
  → 调查实际代码、调用链、状态、测试和影响面
  → 定义行为变化、任务契约和停止条件
  → Gate 2：Execution Readiness
  → 声明 Persisted Evidence：none|required
  → 写入 iterations/000-initial.md
  → 终止，等待用户审计
openspec-act
  → Gate 3：计划基线与测试见证
  → Gate 4：每任务 Spec Review → Code Review
  → Gate 5：新鲜验证证据
  → Gate 6：阻塞与三次失败反思
  → 计划偏差时写 blocked Response 和 Blocker Handoff
  → 按需保存 act-added / BLOCKED Evidence
  → Response 前重新审查完整 diff
  → 修复计划内发现并重跑受影响 Gate
  → 按 Plan 要求或实际需要保存 change 内 Evidence
  → 填写 Act Response
  → 终止，等待用户审计
openspec-experience-recorder
  → 由用户单独请求，或在 Act 前预先授权串联
  → 读取 Act Response、Evidence 或外部运行证据
  → 创建、更新或恢复 Runbook、Incident
  → 自动请求 Maintainer 登记对应 R
  → 终止，不修改 change 或项目记忆
openspec-plan
  → 检查实际代码、blocked/reported Response 和证据
  → 分类 Plan 遗漏、Plan 错误、Act 偏离、基线变化或新证据
  → 按需创建 001、002...
openspec-docs-maintainer
  → 仅按用户指令同步或收尾
```

小任务可以使用轻量模式，但仍保留 BDD、change、精简 RTM 和验证要求。

技能完成不构成下一阶段授权。Plan 和 Act 交付后停止，只提示下一项能力。Explorer 和 Experience Recorder 可在产物验证后自动调用 Maintainer 登记对应 R；该例外不授权其他维护，也不增加审计 Gate。

### 文档模型

| 类型 | 职责 | 编号或路径 |
|---|---|---|
| Project Model | 当前有效的跨模块约束 | `Mxx` |
| Decisions | 长期选择、原因和替代方案 | `Dxx` |
| Knowledge | 已验证、非显然且可复用的结论 | `Kxx` |
| References | 只保存检索元数据 | `Rxx` |
| Improvements | 有证据但未承诺实施的问题 | `Ixx` |
| Milestones | 项目路线、稳定基线和阶段边界 | `MSxx` |
| Tasks | 已承诺工作 | `Txx` |
| Analysis | 调查、实验和评估正文 | `.claude/analysis/` |
| Runbooks | 已验证、可重复或高风险的操作 | `.claude/runbooks/` |
| Incidents | 已发生的重要故障和后续动作 | `.claude/incidents/` |
| Evidence | 按需保存某次 iteration 的日志和数据 | `openspec/changes/<change>/evidence/` |

Architecture 的当前约束进入 Project Model，选择历史进入 Decisions。Learned 中的稳定结论进入 Knowledge，路径和链接进入 References。Optimization 改为 Improvements；批准后提升为 OpenSpec change，不与 tasks 重复维护。

Evidence 属于 change，不登记 R。普通验证结果写入 Act Response；Plan 明确要求持久化，或 Act 需要保留长日志、特殊格式和难以复现的输出时，才创建对应 iteration 的 Evidence 目录。Evidence 随 change 归档，不创建空占位目录。

### OS 与驱动

| Skill | 职责 |
|---|---|
| `os-kernel-development` | 通用内核开发、评审与跨子系统调试 |
| `low-level-execution-debugging` | 对照 ELF、运行地址、反汇编和实际控制流排查底层故障 |
| `async-driver-development` | IRQ、DMA、异步队列、wakeup 和 completion |
| `no-std-rust-debugging` | no_std Rust 构建、链接、MMIO、trap 和 ELF |
| `qemu-kernel-debugging` | QEMU 启动、设备、IRQ、回归和证据边界 |
| `real-board-bringup` | 真机 boot、MMIO、clock、reset、IRQ 和 workload |

### 通用技能

| Skill | 职责 |
|---|---|
| `bettermd` | 编写和修改高信息密度 Markdown |
| `grilling` | 逐项质询计划、决策或想法，确认共同理解后停止 |
| `knowledge-teacher` | 理论推导、代码实践和分层教学 |
| `tooldocs` | 定位已有工具手册 |

当前仓库共 21 个技能。

OpenSpec CLI 与文件格式说明见 [tooldocs/references/openspec.md](tooldocs/references/openspec.md)。

## 安装

使用同一份源目录创建符号链接：

```bash
./scripts/install-skills.sh --platform all --scope user
```

可选参数：

```text
--platform claude|codex|opencode|all
--scope user|project
--mode link|copy
```

项目级安装会写入当前项目对应的隐藏技能目录。用户级安装写入各平台的用户技能目录。

手动安装时，将每个技能目录复制或链接到上表对应位置。`all` 会建立 Claude Code 和 Codex 两组入口，不额外创建 OpenCode 副本，因为 OpenCode 能读取这两种兼容目录。

OpenCode 官方要求技能名在所有发现目录中保持唯一。如果同一台机器同时启用 `.claude/skills` 和 `.agents/skills`，OpenCode 可能发现两个同名入口。此时为 OpenCode 单独执行 `--platform opencode`，并在 OpenCode 环境中只保留一个可发现入口。技能内容仍来自同一源目录。

## 验证

```bash
./scripts/check-skill-consistency.sh
```

检查内容：

- 目录名与 frontmatter `name` 一致。
- `SKILL.md` 必要字段存在。
- references 链接存在。
- README 技能数量与目录一致。
- 不存在旧技能名称。
- assistant 没有写入职责。
- OpenSpec 主技能没有硬绑定平台任务 API。
- V2 项目记忆路径和 M/D/K/R/I 编号齐全。
- 新项目不再生成 architecture、learned 或 optimization spec。
- 旧体系升级逐信息单元达到 100% 映射和验证。
- 旧经验文档完整原文进入 migration carrier 后才退出活动路径。

## 设计约束

- `CLAUDE.md` 只保存公共执行规范，不记录项目现状。
- 项目事实和验证命令写入 SNAPSHOT，任务状态写入 tasks。
- milestone roadmap 写入 tasks，使用 `MSxx`，不与 change 数量绑定。
- change 的多轮沟通写入 `iterations/NNN-title.md`。
- change 的按需证据写入 `evidence/<NNN-title>/`，目录名与 iteration 对齐。
- `SKILL.md` 只保留自身流程和不可违反的差异。
- 长阈值表、模板和协议放入 `references/`，按需读取。
- 平台专属 frontmatter 不写入通用技能。
- 平台专属工具名不能成为流程前提。
- 不把 AI 工具写入 Git co-author。

旧体系升级全量迁移经验文档。Init 沿文档地图、引用、归档指引和历史 carrier 发现来源，把正文逐条分类到新体系。重复、过时、已归档或低价值不构成跳过理由。覆盖清单达到 100%、`unmapped = 0`、`skipped = 0` 后，活动经验源进入 migration carrier 并完整归档。CLAUDE 和 SNAPSHOT 按新体系重建，不迁移或归档旧内容。

## License

MIT
