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

三端差异只在技能发现目录。项目规则入口统一为 `AGENTS.md`，公共规则只保存这一份，不生成平台专属规则副本：

| 平台 | 项目技能目录 | 用户技能目录 |
|---|---|---|
| Claude Code | `.claude/skills/`，符号链接指向 `.agents/skills/` | `~/.claude/skills/` |
| Codex | `.agents/skills/` | `~/.agents/skills/` |
| OpenCode | `.agents/skills/` 或 `.claude/skills/` | `~/.config/opencode/skills/` 或复用上述用户目录 |

同一份技能内容以 `.agents/skills/` 为项目级源目录。项目状态文档统一放在 `.agents/` 下：`docs/`（SNAPSHOT、tasks、Cycle 模板）、`memory/`（项目记忆）、`changes/`、`archive/`、`analysis/`、`runbooks/`、`incidents/`。

目标项目以 `AGENTS.md` 保存公共规则，工作流不依赖外部 CLI 工具；change 的创建、验证和归档使用文件目录和 git 操作完成。

参考：

- [Claude Code Skills](https://code.claude.com/docs/en/skills)
- [OpenCode Agent Skills](https://opencode.ai/docs/skills/)
- [Codex Skills](https://learn.chatgpt.com/docs/customization/overview#skills)

## 技能

### OpenSpec

| Skill | 职责 |
|---|---|
| `openspec-init` | 初始化规则、项目记忆、状态文档和三端入口 |
| `openspec-assistant` | 只读查询规则、状态、项目记忆和 active changes |
| `openspec-milestone-planner` | 规划工作量适中、可独立验证和排障的 milestone roadmap |
| `openspec-plan` | BDD、实现调查、逻辑 Iteration 规划、Cycle 创建和实施反馈 Review |
| `openspec-act` | 执行当前 Cycle、TDD、Review、验证和反馈 |
| `openspec-experience-recorder` | 把已验证实施或运行经验记录为 Runbook、Incident |
| `openspec-docs-maintainer` | 维护状态、M/D/K/R/I、限定 R 登记、change 结果同步和正常收尾 |
| `openspec-explorer` | 宏观或微观探索，输出即时回答或分析文档 |
| `openspec-compressor` | 活跃文档原地压缩，不改变状态 |
| `openspec-archivist` | 生命周期判断、无法正常收尾的 change 清理、carrier 归档、删除和墓碑 |
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
  → 复用 Explorer 已完成的代码调查，只补查缺失或失效事实
  → Gate 1：需求与 BDD
  → 调查实际代码、调用链、状态、测试和影响面
  → 定义行为变化、完整任务和 Iteration Plan
  → 按稳定基线、验证与诊断边界平衡每个逻辑 Iteration
  → 只写入当前 Cycle，Plan Context 先设为 draft，并声明 Persisted Evidence：none|required
  → Gate 2：Execution Readiness
  → Gate 通过或明确豁免且计划获批后，将 Plan Context 改为 ready
  → 终止，等待用户审计
openspec-act
  → 直接消费 Plan Context，不重新建立计划基线
  → Gate 3：任务测试见证
  → Gate 4：每任务 Spec Review → Code Review
  → Gate 5：新鲜验证证据
  → Gate 6：阻塞与三次失败反思
  → 计划偏差时写 blocked Response 和 Blocker Handoff
  → 用户解决阻塞后记录 Blocker Resolution 并恢复当前 Cycle
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
  → 当前执行契约足以约束有限修复：覆盖 Review 并让 Act 继续当前 Cycle
  → accepted：完成当前逻辑 Iteration，按 Map 展开下一 Iteration
  → rework-required：需要新执行契约时，在同一 Iteration 目录创建 rework Cycle，不修改 Map
  → replan-required：更新 change 和 Iteration Plan，在同一 Iteration 创建 replan Cycle
openspec-docs-maintainer
  → 仅按用户指令同步或收尾
```

小任务可以使用轻量模式，但仍保留 BDD、change、精简 RTM 和验证要求。

技能完成不构成下一阶段授权。Plan 和 Act 交付后停止，只提示下一项能力。Explorer 和 Experience Recorder 可在产物验证后自动调用 Maintainer 登记对应 R；该例外不授权其他维护，也不增加审计 Gate。

Assistant 只恢复 OpenSpec 体系文档上下文。当前会话已读取且未变化的信息由后续 Skill 复用；Explorer 调查实际代码，Plan 消化探索结论并补齐缺口，Act 只依据自包含 Plan Context、目标代码和测试实施，不沿引用链重建上游调查。非实质的局部实现差异和 Minor finding 记录后继续；只有会改变行为、接口或错误语义、状态所有权、架构、范围、测试策略或 Acceptance 的问题才阻塞。

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
| Analysis | 调查、实验和评估正文 | `.agents/analysis/` |
| Runbooks | 已验证、可重复或高风险的操作 | `.agents/runbooks/` |
| Incidents | 已发生的重要故障和后续动作 | `.agents/incidents/` |
| Evidence | 按需保存某次 Cycle 无法充分摘要的决定性产物 | `.agents/changes/<change>/evidence/` |

Evidence 属于 change，不登记 R。普通验证结果只在 Act Response 保存不超过 20 行的决定性输出。只有用户要求、无法低成本复现、一次性环境、Incident/Blocker 现场或不可摘要的决定性结构才允许持久化；每个 Cycle 最多 5 个文件，整个 change 最多 20 个，禁止完整日志目录、源码副本和完整测试输出。Evidence 随 change 归档，不创建空占位目录。

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

当前仓库共 20 个技能。

## 安装

技能以符号链接安装，同一份内容不维护副本。用户级安装把每个技能目录链接到对应平台目录：

```bash
cd ai-engineer-workflow
mkdir -p ~/.claude/skills ~/.agents/skills
for dir in */; do
  name="${dir%/}"
  ln -s "$PWD/$name" "$HOME/.claude/skills/$name"   # Claude Code
  ln -s "$PWD/$name" "$HOME/.agents/skills/$name"   # Codex；OpenCode 复用以上任一目录
done
```

项目级安装把技能目录链接到目标项目的 `.agents/skills/`。Claude Code 如需项目级发现，再建立 `.claude/skills/<name>` 指向 `.agents/skills/<name>` 的符号链接；OpenCode 能读取 `.agents/skills/` 或 `.claude/skills/` 任一目录。

OpenCode 官方要求技能名在所有发现目录中保持唯一。同一台机器同时启用 `.agents/skills` 和 `.claude/skills` 时，OpenCode 可能发现两个同名入口；在 OpenCode 环境中只保留一个可发现入口。技能内容仍来自同一源目录。

## 设计约束

- 更新技能时优先精准修改现有规则和字段。现有结构能够表达目标时，不新增目录、文档、模板、协议、状态或中间产物。
- 新结构必须解决现有载体无法表达的具体问题，并说明新增内容的职责、读取时机和验证收益；不能证明必要性时保持原结构。
- OpenSpec 技能体系更新无需兼容旧体系，按当前目标直接更新。
- 在职责边界清晰、功能正确的前提下，以最少必要的上下文、指令和流程表达目标。更新技能体系时优先合并、替换或删除重复内容，不叠加等价指令、Gate 或中间产物。
- 验证只证明目标行为。环境、命令、版本和 revision 可以用于定位现场，但不得成为握手字段、匹配条件、拒绝条件或 Acceptance 的替代证据。
- 禁止为构建、测试、Qualification、Evidence 或运行归属新增 Hash/指纹、revision pin、run-id、session/execution ID、peer/host pin、source/index/worktree freeze、artifact manifest、日志 Hash 链、`TIME_ORDER` 时间证明及其 capture、audit、qualification 工具和专用测试。不得叠加多个身份机制证明“这是同一次运行”，也不得为解决证据工具自身造成的变化增加排除路径或二级验证。验证辅助代码一旦需要独立协议、CLI、fixture、负向测试或审计器，即按身份型证据工程处理。
- 发现上述身份型证据工程时，删除机制及其专用协议字段、CLI、构建宏、fixture、测试和工具，随后重新运行目标行为验证；不得通过补测试或补审计链保留它。产品 requirement 明确要求的认证、完整性校验或多会话协议属于目标行为，不适用本条。
- 工作流不依赖外部 CLI 工具。change 的创建、验证和归档用目录与 git 操作完成，结构检查由技能内自检清单执行。
- OpenSpec Skill 复用当前会话中来源明确且未变化的上下文，只补读缺失信息和实际操作对象；不得因 Skill 切换重复恢复项目状态。
- `AGENTS.md` 只保存公共执行规范，不记录项目现状。
- 当前项目描述写入 SNAPSHOT，任务状态写入 tasks。
- 可复用的构建、测试和其他命令行操作流程写入 Runbook。
- milestone roadmap 写入 tasks，使用 `MSxx`，不与 change 数量绑定。
- change 的 `tasks.md` 预先规划全部逻辑 Iteration，Map 不记录执行尝试次数。
- 每个逻辑 Iteration 使用 `iterations/<III-title>/` 目录；首次执行写入 `000-initial.md`，后继执行写入同目录的 rework 或 replan Cycle。
- 有限修复沿用当前执行契约和 Cycle；需要新执行契约时使用 `rework-required`，且不修改 Iteration Map；`replan-required` 调整目标、范围、依赖、验证契约或验收边界。
- change 的按需证据写入 `evidence/<III-title>/<CCC-title>/`，与 Iteration/Cycle 层级对齐。
- `SKILL.md` 只保留自身流程和不可违反的差异。
- 长阈值表、模板和协议放入 `references/`，按需读取。
- 平台专属 frontmatter 不写入通用技能。
- 平台专属工具名不能成为流程前提。
- 不把 AI 工具写入 Git co-author。

## License

MIT
