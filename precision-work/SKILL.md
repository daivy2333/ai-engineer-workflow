# precision-work

静默探查技能。通过 air 工具生成项目地图（PIR），精准定位代码，最小化 token 消耗。

## 触发条件

语言支持即启用：Python、C/C++、Rust、Assembly

### 自动检测流程

Agent 启动时自动执行：

```bash
find . -maxdepth 2 -type f \( -name "*.py" -o -name "*.rs" -o -name "*.c" -o -name "*.cpp" -o -name "*.h" -o -name "*.s" -o -name "*.S" \) | head -1
```

判断逻辑：
- 输出非空 → 存在支持的语言 → 启用 precision-work
- 输出为空 → 全部不支持 → 提示用户"此项目语言不支持 air，使用传统探查方式" → 回退

注：Java 支持有限，若项目主要为 Java，建议回退到传统方式。

## 核心理念

PIR = 项目地图
- Agent 先读地图，了解全局结构
- 精准定位目标符号/文件
- 最小必要读取，不盲目 read

用户不可见：
- precision-work 是 Agent 内部探查方式
- 用户只看到 Agent 高效完成任务
- 不需要展示 PIR 或探查过程

## 工具调用

### air — 生成 PIR

```bash
air . --name precision
```

输出文件：`precision.pir`（当前目录）

Agent 行为：
1. 执行 `air . --name precision`
2. Read `precision.pir`
3. 检查 `<units>` 区块，Units=0 → 回退传统探查
4. 理解 PIR 内容（直接阅读，无需解析）

### grep — 定位符号

根据 PIR `<syms>` 区块的符号类型选择 grep 模式：

| PIR symbol kind | 文件语言 | grep 模式 |
|-----------------|---------|-----------|
| func | PY | `grep -n "def <symbol>"` |
| func | Rust | `grep -n "fn <symbol>"` |
| func | C | `grep -n "<symbol>.*("` |
| func | CPP | `grep -n "<symbol>.*("` |
| class | PY | `grep -n "class <symbol>"` |
| class | CPP | `grep -n "class <symbol>"` |
| struct | Rust | `grep -n "struct <symbol>"` |
| struct | C/CPP | `grep -n "struct <symbol>"` |
| label | S | `grep -n "<symbol>:"` |
| entry | * | 同 func 模式 |

Agent 行为：
- 从 `<syms>` 找目标符号 → 获得 uid 和 kind
- 从 `<units>` 找 uid → 获得文件路径和语言
- 根据上述映射表选择 grep 模式
- 执行 grep，输出片段 ≤20行

### Read — 最小必要读取

只在修改类任务中使用。

**offset/limit 计算：**

grep 输出格式：`70:def scan_project`

转换规则：
- grep 行号 = 70 → Read offset = 70
- limit = 20（默认，可根据函数复杂度调整）

示例：
```bash
# grep 返回
grep -n "def scan_project" pirgen.py
# 输出: 70:def scan_project

# Read 调用
Read pirgen.py offset=70 limit=20
```

## 工作流程

### Phase 1: NAVIGATE（规划）

1. 自动执行语言检测（find 命令）
2. 检测通过 → 执行 `air . --name precision`
3. Read `precision.pir`
4. 检查 `<units>` 区块：Units=0 → 回退传统探查
5. 理解项目结构，构建心理地图
6. 分析任务 → 决定目标符号/文件
7. 输出：目标清单（内化，不报告用户）

### Phase 2: SCOUT（侦察）

根据任务类型选择工具：

| 任务类型 | 判断关键词 | 工具选择 |
|---------|-----------|---------|
| 定位类 | "在哪里"、"什么文件"、"谁调用" | PIR → grep |
| 查询类 | "依赖"、"引用"、"调用链" | PIR → grep |
| 修改类 | "修改"、"添加"、"删除"、"重构" | PIR → grep → 标记 Read |
| 分析类 | "理解"、"解释" | grep 先行，必要时 Read |

Scout 规则：
- grep 先行，输出片段 ≤20行
- 只在明确需要完整上下文时才标记 Read
- 不扩散到非相关文件

### Phase 3: SURGICAL（执行）

仅在修改类任务进入：
1. 读取 Phase 2 标记的文件（最小范围，使用 offset/limit）
2. 执行修改
3. 修改完成后无需更新 PIR（下次 air 会重新生成）

## 工作流示例

### 示例 1：定位函数

任务：找到 `scan_project` 函数在哪里

```
1. find . -maxdepth 2 -type f \( -name "*.py" ... \) | head -1
   → 输出: ./pirgen/pirgen.py（检测通过）

2. air . --name precision

3. Read precision.pir → 找到 scan_project|u2|func

4. 从 units: u2|pirgen.py|PY → 文件=pirgen.py, 语言=PY

5. grep -n "def scan_project" pirgen.py
   → 输出: 70:def scan_project

6. Read pirgen.py offset=70 limit=20 → 获取函数定义

完成，无需报告用户。
```

### 示例 2：查询依赖链

任务：谁调用了 `resolve_dependencies`

```
1. air . --name precision

2. Read precision.pir → 找到 resolve_dependencies|u2|func

3. 从 deps: u2|d6 d8... → 找依赖项

4. 从 pool: d6|import|[.core.dep_canon] → 获得依赖目标

5. grep -rn "resolve_dependencies" --include="*.py"
   → 找所有调用位置

完成，内化结果用于后续操作。
```

### 示例 3：修改函数

任务：修改 `scan_project` 函数添加日志

```
1. air . --name precision

2. Read precision.pir → scan_project|u2|func

3. grep -n "def scan_project" pirgen.py → 70

4. Read pirgen.py offset=70 limit=30 → 获取完整函数体

5. Edit 添加日志代码

完成修改。
```

## 最小必要约束

- Read 文件前必须先通过 PIR 确定目标
- Read 优先使用 offset/limit 读取片段
- 不读取 PIR 中无相关依赖的文件
- 禁止"顺便看看"相邻文件
- grep 输出控制在 ≤20行
- PIR Units=0 时必须回退传统探查

## 与其他 Skill 关系

- **独立 skill**：可单独使用，用户不感知
- **可被引用**：其他 skill（如 brainstorming、GSD）可遵循此探查范式
- **不改变流程**：只优化探查方式，不干预其他 skill 的 phase/gate/loop

## 禁止行为

- 不向用户展示 PIR 文件内容
- 不报告探查过程
- 不读取非目标文件
- 不使用"顺便看看"逻辑
- 不在没有 PIR 定位的情况下直接 Read 文件
- 不忽略 PIR Units=0 的空项目情况