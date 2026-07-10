---
name: tooldocs
description: 工具文档查找器 - 定位 /home/daivy/.claude/skills/docs/ 下的工具使用手册（codegraph/openspec/understand-anything 等），按需读取并辅助用户理解工具能力。TRIGGER when: 用户提到工具名（codegraph/openspec/understand-anything）或询问"怎么用这个工具"/"有文档吗"。
---

# tooldocs — 工具文档查找

**按需定位并辅助理解 /home/daivy/.claude/skills/docs/ 下的工具使用手册，避免重复搜索。**

---

## 一、文档位置

所有工具文档集中存放在：

```
/home/daivy/.claude/skills/docs/
├── codegraph.md           # CodeGraph 精简使用手册（tree-sitter 知识图谱）
├── openspec.md            # OpenSpec 精简使用手册（AI 协作规范工具）
└── understandanything.md  # Understand Anything 精简使用手册（交互式知识图谱）
```

## 二、定位流程

按以下顺序确认目标文档：

1. 解析用户提到的工具名（codegraph / openspec / understand-anything / 其他）
2. 直接读取 `/home/daivy/.claude/skills/docs/<工具名>.md`
3. 文档不存在时，提示用户当前可用文档列表（见上）

## 三、辅助使用

读取文档后，按文档章节结构回答用户问题：

- **概念问题**（"X 是什么"/"X 怎么工作"）→ 读"什么是 X"章节
- **命令/操作问题**（"怎么安装"/"怎么跑命令"）→ 读"快速开始"/"命令速查"章节
- **故障排查**（"X 不工作"）→ 读"典型陷阱"/"FAQ"章节
- **深度使用**（"MCP 工具"/"库 API"/"配置"）→ 读对应深度章节

## 四、使用规则

- **不要凭印象回答工具细节**，必须 Read 实际文档
- **不要改写或二次创作**文档内容，必要时直接引用原文段落
- 文档未覆盖的问题，**必须**显式告知用户"文档无此内容"
- 中文文档（与英文同名 README）以 `docs/<name>.md` 为准