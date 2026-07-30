# AGENTS.md 适配模板

Codex 和 OpenCode 使用此入口加载 `CLAUDE.md` 中的公共规则。已有 `AGENTS.md` 时精准合并这一节，不覆盖项目原有说明。

```markdown
## OpenSpec workflow rules

Before planning, implementing, reviewing, or updating project documentation:

1. Read `CLAUDE.md` completely.
2. Treat its OpenSpec roles, Gates, BDD, TDD, verification, and editing rules as mandatory.
3. Load only the skill references required by the active task.
4. Do not copy those rules into this file; `CLAUDE.md` is their single source.
5. When the platform automatically resumes pending work, re-check the nearest authorization, capability, or stop boundary before continuing.
```

该文件只负责入口适配。已有项目说明可以保留，但与 OpenSpec 状态重复的项目结构、命令和现状应迁移到 SNAPSHOT。
