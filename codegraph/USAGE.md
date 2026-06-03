# CodeGraph 精简使用手册

> 概念 → 安装 → 常用命令 → 工具速查 → 配置 → FAQ。
> 目标读者：刚装好 CLI、想用 MCP 工具或脚本库接入 CodeGraph 的开发者。

---

## 一、什么是 CodeGraph

**CodeGraph** 是一款本地优先（local-first）的代码智能系统：把任意代码库用 tree-sitter 解析成 AST，提取出符号（symbol）、边（edge）、文件节点，写入本地 SQLite（带 FTS5 全文索引），再通过 MCP 协议把这些结构化上下文暴露给 AI 编码助手（Claude Code、Cursor、Codex CLI、opencode、Antigravity、Kiro 等）。

| 关键属性 | 说明 |
|---|---|
| **零配置** | 没有配置文件；要排除的目录直接写 `.gitignore` |
| **100% 本地** | 不上传代码、不需要 API Key；只用 SQLite |
| **自包含运行时** | 安装包内嵌 Node 24，无需本机装 Node |
| **20+ 语言** | 静态语言用 tree-sitter；Svelte/Vue/Liquid/Pascal 有独立抽取器 |
| **14 框架路由识别** | Django / Flask / FastAPI / Express / NestJS / Laravel / Rails / Spring / Gin / Axum / ASP.NET / Vapor / React Router / SvelteKit |
| **跨语言桥接** | Swift↔ObjC、React Native legacy + TurboModules + Fabric、Expo Modules |

**与 LLM 摘要方案的差异：** 抽取完全确定性（基于 AST），不靠 LLM 概括。同一份代码两次建出的图完全一致。

---

## 二、核心目录与产物

```
<your-project>/
├── .codegraph/                  ← per-project 索引
│   ├── codegraph.db             ← SQLite 知识图谱（nodes/edges/files + FTS5）
│   ├── daemon.sock              ← 共享守护进程 socket
│   ├── daemon.pid
│   └── .gitignore               ← 屏蔽 db/daemon 等，不污染 git status
└── ...

~/.codegraph/ 或 /usr/local/bin/codegraph   ← CLI 安装位置
```

**两个角色：**
- **CLI** (`codegraph ...`) — 初始化、查询、启动 MCP 服务
- **MCP server** (`codegraph serve --mcp`) — 长驻进程，被 agent 调用；守护进程 (`daemon`) 多 agent 共享

---

## 三、五分钟上手

### 1. 安装 CLI（无需 Node）

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.sh | sh

# Windows (PowerShell)
irm https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.ps1 | iex

# 或者
npm i -g @colbymchenry/codegraph
```

> 安装器把 `codegraph` 放到 PATH，但**不会改当前 shell**——开新终端再继续。

### 2. 接入 Agent

新终端执行交互式安装，自动识别已装的 agent：

```bash
codegraph install
```

或非交互模式：

```bash
codegraph install --yes                              # 全部自动检测
codegraph install --target=cursor,claude --yes       # 显式指定
codegraph install --target=auto --location=local     # 项目本地
codegraph install --print-config codex               # 只打印片段，不写文件
```

| Flag | 可选值 | 默认 |
|---|---|---|
| `--target` | `auto` / `all` / `none` / csv | 交互式选择 |
| `--location` | `global` / `local` | 交互式选择 |
| `--yes` | 布尔 | 逐项提示 |
| `--no-permissions` | 跳过 Claude Code 自动允许 | 启用 |
| `--print-config <id>` | 仅输出一个 agent 的片段 | — |

支持的 agent：Claude Code、Cursor、Codex CLI、opencode、Hermes Agent、Gemini CLI、Antigravity IDE、Kiro。

### 3. 初始化项目

```bash
cd your-project
codegraph init -i   # -i 等于 --index，建库后立即索引
```

> `codegraph init` 自 0.9.8 起默认就会建索引；`-i` 仍然兼容旧脚本。

### 4. 重启 Agent

让 MCP server 重新加载，agent 即可看到 `codegraph_*` 工具。

---

## 四、CLI 命令速查

```bash
codegraph                         # 默认：运行交互式 installer
codegraph install                 # 显式 installer
codegraph uninstall               # 反向操作（清掉所有 agent 的配置）
codegraph init [path]             # 初始化项目（默认就建索引）
codegraph uninit [path]           # 清理项目的 .codegraph/（--force 跳过确认）
codegraph index [path]            # 全量索引（--force 强制重建，--quiet 静音）
codegraph sync [path]             # 增量同步（看门狗自动触发，一般无需手动）
codegraph status [path]           # 状态/统计
codegraph query <search>          # 搜符号（--kind, --limit, --json）
codegraph files [path]            # 文件结构（--format, --filter, --max-depth, --json）
codegraph callers <symbol>        # 谁调用了它
codegraph callees <symbol>        # 它调用了谁
codegraph impact <symbol>         # 改动它影响什么
codegraph affected [files...]     # 受改动影响的测试文件（见下）
codegraph serve --mcp             # 启动 MCP server（agent 自动调用）
```

### `codegraph affected`（CI 友好）

沿着 import 依赖反向追踪，找出被一组源文件改动影响到的测试文件：

```bash
codegraph affected src/utils.ts src/api.ts
git diff --name-only | codegraph affected --stdin
codegraph affected src/auth.ts --filter "e2e/*"
```

| 选项 | 说明 | 默认 |
|---|---|---|
| `--stdin` | 从 stdin 读文件列表 | `false` |
| `-d, --depth` | 依赖遍历最大深度 | `5` |
| `-f, --filter` | 自定义测试文件 glob | 自动识别 |
| `-j, --json` | JSON 输出 | `false` |
| `-q, --quiet` | 仅输出文件路径 | `false` |

CI 用法：

```bash
AFFECTED=$(git diff --name-only HEAD | codegraph affected --stdin --quiet)
[ -n "$AFFECTED" ] && npx vitest run $AFFECTED
```

---

## 五、MCP 工具速查（agent 视角）

agent 连上 MCP server 后，看到这些工具。**`codegraph_explore` 是主入口**，大多数问题一次调用就能答完。

| 工具 | 何时用 |
|---|---|
| **`codegraph_explore`** ⭐ | **首选。** "X 怎么工作" / "X 如何到 Y" / 区域概览 / bug 定位 — 一次返回相关符号源码（按文件分组），含调用关系与影响范围 |
| `codegraph_search` | 只找符号位置（不带源码） |
| `codegraph_callers` | 谁调用了它 |
| `codegraph_callees` | 它调用了谁 |
| `codegraph_impact` | 改它会破坏什么 |
| `codegraph_node` | 一个符号的完整源码（同名重载时返回**所有定义**） |
| `codegraph_files` | 目录结构（比直接 ls 快） |
| `codegraph_status` | 索引健康/统计 |

**调用守则（来自 `src/mcp/server-instructions.ts`，agent 启动时已注入系统提示）：**

1. **先 `codegraph_explore`**，别先 `grep` — codegraph 本身就是预建索引
2. **直接答，不要开 Explore 子 agent** — 子 agent 会读文件，浪费
3. **信任结果** — 来自完整 AST 解析，比 grep 准；不要用 grep 反向验证
4. **一个 `codegraph_explore` 顶一组 `search`+`node`** — 一次往返拿全部分组源码
5. **别循环 `codegraph_node` 查多个符号** — 一次 `explore` 拿齐全
6. **看到 ⚠️ stale banner** 时：列出的文件是刚改还没索引的，对那一个直接 `Read`，其它文件继续信任 codegraph

### 典型调用链

| 场景 | 推荐顺序 |
|---|---|
| 流程 / "X 怎么到 Y" | **一次** `codegraph_explore`（query 里写上 X 和 Y 的符号名） |
| 区域理解 | 一次 `codegraph_explore` 完事；不够再用 `codegraph_node` 拉一个 |
| 重构计划 | `codegraph_search` → `codegraph_callers` → `codegraph_impact` |
| Debug 回归 | `codegraph_callers(怀疑的符号)` → 有意外就 `codegraph_impact` 加宽 |

---

## 六、库 API（嵌入到自己的应用）

`@colbymchenry/codegraph` 既能当 CLI 用，也能 `require` / `import` 当库用。常见场景：Electron 主进程、CI 工具链、IDE 插件。

```typescript
import CodeGraph from '@colbymchenry/codegraph';
// CJS: const { CodeGraph } = require('@colbymchenry/codegraph');

const cg = await CodeGraph.init('/path/to/project');
// 或: const cg = await CodeGraph.open('/path/to/project');

await cg.indexAll({
  onProgress: (p) => console.log(`${p.phase}: ${p.current}/${p.total}`),
});

const results  = cg.searchNodes('UserService');
const callers  = cg.getCallers(results[0].node.id);
const context  = await cg.buildContext('fix login bug', {
  maxNodes: 20, includeCode: true, format: 'markdown',
});
const impact   = cg.getImpactRadius(results[0].node.id, 2);

cg.watch();     // 监听文件变动自动同步
cg.unwatch();
cg.close();
```

### 主要方法

| 类别 | 方法 |
|---|---|
| **生命周期** | `init` / `initSync` / `open` / `openSync` / `close` / `isInitialized` |
| **索引** | `indexAll({ onProgress, signal, verbose })` / `indexFiles(paths)` / `sync({ onProgress })` |
| **状态** | `getStats()` / `getBackend()` / `getJournalMode()` / `getLastIndexedAt()` / `getChangedFiles()` / `getPendingFiles()` |
| **节点** | `getNode(id)` / `getNodesInFile(p)` / `getNodesByKind(k)` / `getNodesByName(name)` / `searchNodes(q, opts)` |
| **边** | `getOutgoingEdges(id)` / `getIncomingEdges(id)` |
| **图遍历** | `traverse(start, opts)` / `getCallGraph(id, depth)` / `getCallers(id, depth)` / `getCallees(id, depth)` / `getImpactRadius(id, depth)` / `findPath(from, to, kinds)` / `findUsages(id)` / `getAncestors(id)` / `getChildren(id)` |
| **类型/结构** | `getTypeHierarchy(id)` / `getFileDependencies(p)` / `getFileDependents(p)` / `findCircularDependencies()` / `findDeadCode(kinds)` |
| **上下文** | `getCode(id)` / `getContext(id)` / `buildContext(input, opts)` / `findRelevantContext(query, opts)` |
| **监听** | `watch({ onSync })` / `unwatch()` / `isWatching()` / `waitUntilWatcherReady(ms)` |
| **路由** | `getDetectedFrameworks()` / `getTopRouteFile()` / `getRoutingManifest(limit?)` |
| **DB** | `optimize()` / `clear()` / `uninitialize()` |
| **解析** | `resolveReferences(onProgress)` / `resolveReferencesBatched(onProgress)` / `reinitializeResolver()` / `extractFromSource(path, src)` |

### 暴露的底层构件

```typescript
import {
  DatabaseConnection,         // 直接打开 db
  QueryBuilder,                // 预编译查询
  getDatabasePath,             // 解析 .codegraph/codegraph.db 路径
  initGrammars,                // 预加载 tree-sitter 语法
  loadGrammarsForLanguages,    // 按需加载
  getSupportedLanguages,
  detectLanguage,
  FileLock,                    // 跨进程文件锁
  Mutex,                       // 进程内互斥
  processInBatches,            // 流式批处理工具
  FileWatcher,                 // 原生 OS 事件监听器
  MCPServer,                   // 启动内嵌 MCP server
} from '@colbymchenry/codegraph';
```

### 嵌入要求

- `npm i @colbymchenry/codegraph`（会按平台拉 `@colbymchenry/codegraph-<target>` 子包）
- **Node ≥ 22.5**（库需要 `node:sqlite`；Electron 自带 Node ≥ 22.5 也行）
- CLI / MCP server 用的是自包含的 bundled Node，不受此约束
- TypeScript 类型随包发布；保持 `skipLibCheck: true`

---

## 七、配置（环境变量）

> **零配置优先**。CodeGraph 不写任何配置文件；要排除目录，直接写 `.gitignore`。
> 环境变量只在需要调优时用。

| 变量 | 作用 | 默认 |
|---|---|---|
| `CODEGRAPH_WATCH_DEBOUNCE_MS` | 文件监听去抖窗口 | `2000`（夹在 `[100, 60000]`） |
| `CODEGRAPH_NO_DAEMON=1` | 关闭守护进程，每个客户端一个独立 server | 守护进程开 |
| `CODEGRAPH_DAEMON_IDLE_TIMEOUT_MS` | 守护进程空闲多久后退出 | `300000`（5 分钟） |
| `CODEGRAPH_NO_WATCH=1` / `serve --mcp --no-watch` | 强制关闭文件监听 | — |
| `CODEGRAPH_FORCE_WATCH=1` | 在 WSL2 `/mnt/*` 强制开启监听 | 自动检测 |
| `CODEGRAPH_PPID_POLL_MS` | 父进程检测周期（PPID watchdog） | `1000` |
| `CODEGRAPH_ADAPTIVE_EXPLORE=0` | 关闭 `explore` 智能骨架化（对小 repo 不友好时用） | 开 |
| `CODEGRAPH_EXPLORE_LINENUMS=0` | 关闭 explore 输出里的行号 | 开 |
| `CODEGRAPH_MCP_TOOLS` | 只暴露指定子集，例如 `trace,search,node` | 全暴露 |
| `CODEGRAPH_NO_DOWNLOAD=1` | npm 启动器拉 bundle 失败时不下载 | 自动回退 |
| `CODEGRAPH_DOWNLOAD_BASE` | 自定义 bundle 下载镜像 | GitHub Releases |
| `CODEGRAPH_VERSION` | 安装时指定版本（接受 `0.9.4` 或 `v0.9.4`） | `latest` |
| `CODEGRAPH_UNICODE=1` / `CODEGRAPH_ASCII=1` | 终端字符集 | Windows 默认 ASCII |

---

## 八、默认排除（零配置规则）

**自动忽略**（无需 `.gitignore`）：

- 依赖/构建/缓存目录：`node_modules` / `vendor` / `dist` / `build` / `target` / `.venv` / `__pycache__` / `Pods` / `.next` / `out` / `coverage` …
- 单文件 > 1 MB（生成的 bundle、最小化 JS、vendored blob）
- **`.gitignore` 里的一切** — git 项目用 git；非 git 项目直接读 `.gitignore`（含嵌套）

**想强制索引被排除的目录？** 在 `.gitignore` 加反选：

```gitignore
!vendor/my-important-thing/
```

---

## 九、支持的语言

| 语言 | 扩展 | 状态 |
|---|---|---|
| TypeScript | `.ts` / `.tsx` / `.mts` / `.cts` | 完整 |
| JavaScript | `.js` / `.jsx` / `.mjs` / `.cjs` / `.xsjs` / `.xsjslib` | 完整（含 IIFE / AMD / NetSuite SuiteScript） |
| Python | `.py` | 完整 |
| Go | `.go` | 完整（含泛型方法 `func (s *Stack[T]) Push`） |
| Rust | `.rs` | 完整 |
| Java | `.java` | 完整 |
| C# | `.cs` | 完整 |
| PHP | `.php` | 完整 |
| Ruby | `.rb` | 完整 |
| C | `.c` / `.h` | 完整 |
| C++ | `.cpp` / `.hpp` / `.cc` / `.h`（内容启发式） | 完整 |
| Objective-C | `.m` / `.mm` / `.h` | 较完整（`.mm` ObjC++ 解析可能不完整） |
| Swift | `.swift` | 完整 |
| Kotlin | `.kt` / `.kts` | 完整 |
| Scala | `.scala` / `.sc` | 完整 |
| Dart | `.dart` | 完整 |
| Svelte | `.svelte` | 完整（含 Svelte 5 runes、SvelteKit 路由） |
| Vue | `.vue` | 完整（`<script>` + Nuxt page/api/middleware 路由） |
| Liquid | `.liquid` | 完整 |
| Pascal / Delphi | `.pas` / `.dpr` / `.dpk` / `.lpr` | 完整（含 DFM/FMX 表单） |
| Lua | `.lua` | 完整 |
| Luau | `.luau` | 完整（Roblox 类型 + 实例路径 require） |

---

## 十、跨平台 / 跨架构

每个版本都打 6 个 bundle（自包含 Node 运行时）：

| 平台 | 架构 | 安装方式 |
|---|---|---|
| Windows | x64, arm64 | `irm … install.ps1 \| iex` 或 npm |
| macOS | x64, arm64 | `curl … install.sh \| sh` 或 npm |
| Linux | x64, arm64 | `curl … install.sh \| sh` 或 npm |

无需本机装 Node，无需 native build。

---

## 十一、生命周期示例

```bash
# 全局装
curl -fsSL https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.sh | sh

# 接入 Claude Code / Cursor（多个 agent 一起装）
codegraph install --yes

# 在项目里建库
cd ~/work/my-app
codegraph init                  # 0.9.8+ 默认就建索引；显式带 -i 也行
codegraph status                # 确认 healthy

# 编辑中保持同步（默认开守护进程 + 文件监听，无需手动）
echo "function foo() {}" >> src/x.ts
sleep 3 && codegraph status    # 应当看到 foo 已经在索引里

# 查符号
codegraph query "UserService" --kind class
codegraph callers loginHandler
codegraph impact handleAuth

# 找被改动影响的测试
git diff --name-only HEAD | codegraph affected --stdin --quiet | xargs npx vitest run

# 卸载
codegraph uninstall             # 移除所有 agent 的配置
codegraph uninit                # 清理本项目的 .codegraph/
```

---

## 十二、典型陷阱

| 症状 | 原因 / 解决 |
|---|---|
| **`CodeGraph not initialized`** | 项目里没建库。`codegraph init`（或 `init -i`） |
| **索引慢** | 看看 `.codegraph/` 大小/文件数；调大 `CODEGRAPH_WATCH_DEBOUNCE_MS` 或 `codegraph index --quiet` |
| **`database is locked`** | 当前构建不该有。检查 `codegraph status` 的 Journal 行：WAL = 正常；其他 = 文件系统不支持 WAL（网络盘 / WSL2 `/mnt/*`）— 移到本地磁盘 |
| **MCP 连不上** | 1) 项目已 init；2) `codegraph serve --mcp` 能手动起；3) MCP 配置里的路径正确 |
| **找不到某符号** | 1) 等 1–2 秒看门狗同步；2) `codegraph sync` 手动；3) 看是不是默认排除目录；4) 文件 > 1 MB 也会跳 |
| **MCP server 不退出** | 默认有守护进程 + 5 分钟空闲退出。`CODEGRAPH_NO_DAEMON=1` 关掉 |
| **Cursor 报 "not initialized"** | 已知问题：Cursor 用错的 cwd 启动 MCP。`codegraph install` 会注入 `--path`，重装即可 |
| **WSL2 `/mnt/*` 太慢** | 自动跳监听。`CODEGRAPH_FORCE_WATCH=1` 强开（只有真快时才用） |
| **Windows 上小黑色窗口闪** | 0.9.7+ 已修。升级即可 |
| **Agent 还是 grep 而不是用 codegraph** | 1) `.codegraph/` 真的存在吗？`codegraph status`；2) 重启 agent；3) 提示 agent "用 codegraph_explore" |

---

## 十三、FAQ

**Q: 为什么我看不到 `codegraph_explore` 工具？**
A: 三件事按顺序检查：(1) `codegraph status` 在项目根返回 healthy；(2) `codegraph install` 跑了；(3) agent 重启了。还要看 `codegraph serve --mcp` 能否手动起。

**Q: codegraph 比 grep+read 好吗？**
A: 在中大型代码库（>200 文件）上，**端到端平均**：省 16% 成本、少 58% 工具调用、少 47% token、快 22%。在小型 repo（<100 文件）上差不多持平——codegraph 的一次性 MCP 启动开销不划算。详见 `README.md` 的基准表。

**Q: 我能脚本化用 codegraph 吗？**
A: 可以。两种方式：(1) `require('@colbymchenry/codegraph')` 拿 `CodeGraph` 类；(2) 走 CLI + `--json` 输出。**库路径需要 Node ≥ 22.5**（`node:sqlite`）。

**Q: 我的项目用 `node:sqlite` 不可用怎么办？**
A: 升级到 Node 22.5+。Electron 自带 Node ≥ 22.5 没问题；CLI/MCP server 用 bundled Node 不受此约束。

**Q: 索引会被 `git status` 显示吗？**
A: 默认**不会**。`.codegraph/.gitignore` 自动生成，把 db/daemon/socket/log 排除，只把 `.codegraph/` 自己列进去。

**Q: 我能索引 `node_modules` 或 `vendor` 吗？**
A: 可以——在 `.gitignore` 加反选 `!vendor/your-thing/`。但通常不建议，会让图变慢且噪声大。

**Q: 多 agent 跑同一个项目会起多个索引吗？**
A: 不会。0.9.5+ 用共享守护进程：N 个 agent → 1 个文件监听、1 个 SQLite 连接、1 个 tree-sitter warm-up。`CODEGRAPH_NO_DAEMON=1` 可关闭。

**Q: 我能远程（SSH / VPS）装吗？**
A: 可以。`curl … | sh` 在干净的 Linux VPS 上能跑（脚本会拉 bundle、放到 PATH）。需要 GitHub 可达。

**Q: codegraph 怎么知道一个符号？**
A: tree-sitter 解析 → 抽 node 节点（class/function/method/interface/enum/...）→ 抽边（calls/imports/extends/implements/...）→ 解析阶段用 import + 名字匹配 + 框架特化模式把 unresolved ref 接到对应定义；动态分派（callbacks、EventEmitter、React re-render、setState→build、C++ 虚函数、Spring interface→impl）由合成器（synthesizer）补齐。所有合成边带 `provenance:'heuristic'`，可通过 `metadata.synthesizedBy` 看到来源。

**Q: 数据会离开我机器吗？**
A: 不会。SQLite 是本地的，bundle 也是本地的，所有调用都走 stdio / unix socket，没有外发流量。

**Q: 我的 monorepo / workspace 怎么用？**
A: 在每个 package 目录单独跑 `codegraph init`（每个 package 一份 `.codegraph/`），或在整个 monorepo 根目录跑一份（会包含所有源码）。两种方式都支持，根目录一份通常更省事。

**Q: 我要加新语言怎么开始？**
A: 看 `docs/SEARCH_QUALITY_LOOP.md`（完整测试流程 + 失败诊断表）和 `docs/design/dynamic-dispatch-coverage-playbook.md`（覆盖矩阵 + 验证方法论）。最常见的入门路径：克隆目标语言的真实项目 → 按 `SEARCH_QUALITY_LOOP.md` 7 步跑一遍 → 修 `src/extraction/languages/<lang>.ts` 的 gap。

---

## 十四、参考链接

| 文档 | 内容 |
|---|---|
| `README.md` | 营销 + 安装 + 基准 + CLI 速查（人读） |
| `BUNDLING.md` | 自包含 bundle / npm shim / release pipeline |
| `CLAUDE.md` | 开发者内部手册（架构、命名规则、house rules） |
| `docs/SEARCH_QUALITY_LOOP.md` | 加新语言时的 7 步验证 + 失败诊断表 |
| `docs/design/dynamic-dispatch-coverage-playbook.md` | 跨语言/框架覆盖矩阵 + 验证方法论 |
| `docs/design/callback-edge-synthesis.md` | 合成器（callback / EventEmitter / closure-collection）设计 |
| `docs/design/adaptive-explore-sizing.md` | `codegraph_explore` 智能骨架化（OKhttp / Django 案例） |
| `docs/benchmarks/codegraph-ab-matrix.md` | 37 个真实仓库的 WITH vs WITHOUT 矩阵 |
| `docs/benchmarks/answer-directly-vs-explore-agent.md` | "直接答 vs 开子 agent" 实验 |
| `docs/benchmarks/call-sequence-analysis.md` | 调用序列分析（成本节省的机制） |
| `src/mcp/server-instructions.ts` | agent 启动时注入的"如何使用"提示（单一事实源） |
| `src/mcp/tools.ts` | 8 个 MCP 工具的实际定义 |
| `src/index.ts` | `CodeGraph` 库的公开 API |
| `CHANGELOG.md` | 详细发布历史 |
