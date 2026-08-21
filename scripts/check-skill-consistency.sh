#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
errors=0

fail() {
  echo "FAIL: $*" >&2
  errors=$((errors + 1))
}

require_pattern() {
  local pattern=$1
  local file=$2
  local message=$3
  rg -q "$pattern" "$file" || fail "$message"
}

forbid_pattern() {
  local pattern=$1
  local file=$2
  local message=$3
  if rg -q "$pattern" "$file"; then
    fail "$message"
  fi
}

skills=()
for path in "$ROOT"/*/SKILL.md; do
  [[ -f "$path" ]] || continue
  skills+=("$(dirname "$path")")
done

for skill in "${skills[@]}"; do
  file="$skill/SKILL.md"
  dir_name=$(basename "$skill")
  first_line=$(sed -n '1p' "$file")
  name=$(sed -n '/^---$/,/^---$/s/^name:[[:space:]]*//p' "$file" | head -n 1)
  description=$(sed -n '/^---$/,/^---$/s/^description:[[:space:]]*//p' "$file" | head -n 1)

  [[ "$first_line" == "---" ]] || fail "$file does not start with YAML frontmatter"
  [[ "$name" == "$dir_name" ]] || fail "$file name '$name' does not match '$dir_name'"
  [[ -n "$description" ]] || fail "$file has no description"

  while IFS= read -r key; do
    [[ "$key" == "name" || "$key" == "description" ]] || fail "$file uses non-portable frontmatter field '$key'"
  done < <(awk '
    NR == 1 && $0 == "---" { inside = 1; next }
    inside && $0 == "---" { exit }
    inside && /^[A-Za-z0-9_-]+:/ {
      key = $0
      sub(/:.*/, "", key)
      print key
    }
  ' "$file")

  line_count=$(wc -l < "$file")
  (( line_count <= 500 )) || fail "$file exceeds 500 lines"

  while IFS= read -r reference; do
    [[ -n "$reference" ]] || continue
    reference=${reference#(}
    reference=${reference%)}
    [[ -f "$skill/$reference" ]] || fail "$file references missing file '$reference'"
  done < <(rg -o '\(references/[A-Za-z0-9._/-]+\.md\)' "$file" | sort -u)
done

actual_count=${#skills[@]}
readme_count=$(sed -n 's/^当前仓库共 \([0-9][0-9]*\) 个技能。$/\1/p' "$ROOT/README.md")
[[ "$readme_count" == "$actual_count" ]] || fail "README count '$readme_count' does not match '$actual_count'"
require_pattern '更新 OpenSpec 技能时控制提示词体积' "$ROOT/README.md" \
  "README lacks the prompt-size update constraint"

if rg -n 'plugin-loader|project-docs-generator-ulw|project-archivist' "$ROOT/README.md" >/dev/null; then
  fail "README contains removed skill names"
fi

if rg -n 'assistant (同步|更新|维护|写入|负责日常)' "$ROOT"/openspec-*/SKILL.md "$ROOT"/openspec-*/references/*.md >/dev/null 2>&1; then
  fail "openspec-assistant is described as a writer"
fi

bettermd_skill="$ROOT/bettermd/SKILL.md"
[[ -f "$bettermd_skill" ]] || fail "bettermd skill is missing"
require_pattern '准确 > 完整 > 清楚 > 自然 > 精简' "$bettermd_skill" \
  "bettermd lacks an explicit writing priority"
require_pattern '禁止句式' "$bettermd_skill" \
  "bettermd does not separate prohibited phrasing"
require_pattern '谨慎词汇' "$bettermd_skill" \
  "bettermd treats every suspect word as an absolute ban"
require_pattern '一个段落只处理一个问题' "$bettermd_skill" \
  "bettermd lacks paragraph-level focus"
require_pattern '审查改写' "$bettermd_skill" \
  "bettermd lacks a revision workflow"
require_pattern '众所周知.*毋庸置疑' "$bettermd_skill" \
  "bettermd lacks false-consensus phrasing checks"
require_pattern '名词化长句' "$bettermd_skill" \
  "bettermd lacks nominalized prose checks"
require_pattern 'README.*设计文档.*规范.*Runbook' "$bettermd_skill" \
  "bettermd trigger does not cover common Markdown document types"
require_pattern '通用.*不属于 OpenSpec' "$bettermd_skill" \
  "bettermd is not described as independent from OpenSpec"
require_pattern '任何 Markdown 文档时都应使用' "$bettermd_skill" \
  "bettermd does not trigger for every Markdown writing task"
forbid_pattern '治 AI 味|三段式优先|层级 ≤ H2|单段 ≤ 5 句|单句 ≤ 30 字' "$bettermd_skill" \
  "bettermd still contains promotional or mechanical style rules"

grilling_skill="$ROOT/grilling/SKILL.md"
[[ -f "$grilling_skill" ]] || fail "grilling skill is missing"
require_pattern 'Ask exactly one decision question per turn' "$grilling_skill" \
  "grilling does not enforce one-question turns"
require_pattern 'Investigate facts through available files and tools' "$grilling_skill" \
  "grilling asks users for discoverable facts"
require_pattern 'decision register' "$grilling_skill" \
  "grilling does not retain resolved decisions"
require_pattern 'After confirmation, do not act automatically' "$grilling_skill" \
  "grilling can start another workflow without a new request"

execution_debug_skill="$ROOT/low-level-execution-debugging/SKILL.md"
[[ -f "$execution_debug_skill" ]] || fail "low-level-execution-debugging skill is missing"
require_pattern 'Build an address ledger' "$execution_debug_skill" \
  "low-level execution debugging lacks address reconciliation"
require_pattern 'Compare runtime bytes at PC with bytes from the exact artifact' "$execution_debug_skill" \
  "low-level execution debugging does not reconcile runtime bytes"
require_pattern 'Do not trust a debugger session until its symbols match the running image' "$execution_debug_skill" \
  "low-level execution debugging permits stale symbols"
require_pattern 'existing Build ID.*Do not generate or persist a hash solely for debugging or evidence' \
  "$execution_debug_skill" \
  "low-level execution debugging generates artifact hashes for workflow evidence"
require_pattern 'JTAG and OpenOCD prove the attached target state' "$execution_debug_skill" \
  "low-level execution debugging lacks hardware probe boundaries"
for reference in address-reconciliation debugger-evidence failure-patterns architecture-checks; do
  [[ -f "$ROOT/low-level-execution-debugging/references/$reference.md" ]] || \
    fail "low-level execution debugging reference '$reference' is missing"
done

if rg -n 'TaskCreate|TaskUpdate|AskUserQuestion|TaskList|Agent 工具' "$ROOT"/openspec-*/SKILL.md >/dev/null 2>&1; then
  fail "OpenSpec main skills contain platform-specific task APIs"
fi

iteration_template="$ROOT/openspec-init/references/iteration-template.md"
[[ -f "$iteration_template" ]] || fail "change iteration template is missing"
evidence_template="$ROOT/openspec-act/references/evidence-format.md"
[[ -f "$evidence_template" ]] || fail "change Evidence template is missing"
iteration_planning="$ROOT/openspec-plan/references/iteration-planning.md"
[[ -f "$iteration_planning" ]] || fail "iteration planning reference is missing"

require_pattern 'iterations/000-initial/000-initial\.md' "$ROOT/openspec-plan/SKILL.md" \
  "openspec-plan does not create the initial Iteration/Cycle structure"
require_pattern '检查实际代码、diff、Act Response、Self-Review 和计划要求的 Evidence' "$ROOT/openspec-plan/SKILL.md" \
  "openspec-plan review does not inspect implementation evidence"
require_pattern '输出交接信息后终止' "$ROOT/openspec-plan/SKILL.md" \
  "openspec-plan lacks an explicit termination boundary"
require_pattern '调查当前实现' "$ROOT/openspec-plan/SKILL.md" \
  "openspec-plan does not investigate the current implementation"
require_pattern 'Current-State Evidence' "$ROOT/openspec-plan/SKILL.md" \
  "openspec-plan lacks current-state evidence"
require_pattern '不得把定位必要调用者、判断实质影响范围、选择测试策略或决定接口语义留给 Act' \
  "$ROOT/openspec-plan/SKILL.md" \
  "openspec-plan leaves implementation discovery to Act"
require_pattern '先消费当前会话中的 Explorer 结论或相关 Analysis' \
  "$ROOT/openspec-plan/SKILL.md" \
  "openspec-plan does not reuse explorer investigation"
require_pattern '不以 Explorer Analysis、Assistant 输出或前序 Cycle 引用代替必要正文' \
  "$ROOT/openspec-plan/SKILL.md" \
  "openspec-plan can create a chained rather than self-contained handoff"
require_pattern 'Gate 2：Execution Readiness' "$ROOT/openspec-plan/SKILL.md" \
  "openspec-plan Gate 2 does not check execution readiness"
require_pattern 'requirement、scenario、design、task、代码和测试形成链路' \
  "$ROOT/openspec-plan/SKILL.md" \
  "openspec-plan lacks end-to-end traceability"
require_pattern 'PLAN-OMISSION.*PLAN-INVALID.*ACT-DEVIATION.*BASELINE-CHANGED.*NEW-EVIDENCE' \
  "$ROOT/openspec-plan/SKILL.md" \
  "openspec-plan review does not classify deviations"
require_pattern '已采用 OpenSpec' "$ROOT/openspec-plan/SKILL.md" \
  "openspec-plan trigger is not limited to OpenSpec work"
require_pattern '把全部任务写入 change 的 `tasks.md`' "$ROOT/openspec-plan/SKILL.md" \
  "openspec-plan does not plan the complete change task pool"
require_pattern '只展开第一个 Iteration 目录及其 `000-initial\.md`' "$ROOT/openspec-plan/SKILL.md" \
  "openspec-plan can materialize every planned Iteration at once"
for review_result in accepted rework-required replan-required; do
  require_pattern "\`$review_result\`" "$ROOT/openspec-plan/SKILL.md" \
    "openspec-plan review lacks the '$review_result' result"
done
require_pattern '不得新增全局 change task 或修改 Iteration Map' "$ROOT/openspec-plan/SKILL.md" \
  "openspec-plan promotes in-scope rework into the global Iteration Map"
require_pattern '每个 task 只分配给一个 Iteration' "$iteration_planning" \
  "iteration planning does not assign every task exactly once"
require_pattern '聚合和拆分审计|平衡审计' "$iteration_planning" \
  "iteration planning lacks batch balancing"
require_pattern '`rework-required` 只创建同目录的下一 Cycle' "$iteration_planning" \
  "iteration review does not keep rework inside the logical Iteration"
require_pattern '不因当前 Iteration 的 Cycle 数量修改或顺延编号' "$iteration_planning" \
  "rework can renumber the planned Iteration Map"
forbid_pattern 'materialized|reviewed|^- State:' "$iteration_planning" \
  "iteration planning adds unnecessary lifecycle states"
forbid_pattern '创建后把全局任务同步请求交给' "$ROOT/openspec-plan/SKILL.md" \
  "openspec-plan still requests automatic global task sync"

require_pattern '只填写当前 Cycle 的 `Act Response`' "$ROOT/openspec-act/SKILL.md" \
  "openspec-act does not own an explicit response section"
require_pattern '未归档 change，未同步全局文档' "$ROOT/openspec-act/SKILL.md" \
  "openspec-act lacks a no-closeout handoff"
require_pattern 'Gate 3：Test Witness' "$ROOT/openspec-act/SKILL.md" \
  "openspec-act Gate 3 is not limited to the test witness"
require_pattern 'Act 不确认、复核或重新建立计划基线' "$ROOT/openspec-act/SKILL.md" \
  "openspec-act still establishes a plan baseline"
forbid_pattern 'Plan Baseline and Test Witness|当前 Cycle 开始时确认一次|计划指定的目标文件、符号和测试入口可以定位' \
  "$ROOT/openspec-act/SKILL.md" \
  "openspec-act still performs baseline confirmation"
require_pattern '不重新调查调用链、影响范围或 Current-State Evidence' \
  "$ROOT/openspec-act/SKILL.md" \
  "openspec-act repeats the investigation already completed by plan"
require_pattern '建立当前 task 的测试见证' "$ROOT/openspec-act/SKILL.md" \
  "openspec-act does not retain per-task test witnesses"
forbid_pattern '每个任务开始前确认|建立 Gate 3 证据' "$ROOT/openspec-act/SKILL.md" \
  "openspec-act still rebuilds the Gate 3 baseline per task"
require_pattern '只有差异使 Task Contract 无法执行.*构成实质问题时' \
  "$ROOT/openspec-act/SKILL.md" \
  "openspec-act lacks a materiality threshold for blockers"
require_pattern '重新读取任务契约并检查' "$ROOT/openspec-act/SKILL.md" \
  "openspec-act Gate 4 lacks task-level self-review"
require_pattern '审查完整 diff，不只复用逐任务结论' "$ROOT/openspec-act/SKILL.md" \
  "openspec-act lacks final full-diff self-review"
require_pattern 'Self-Review 检查结果、已修复发现和遗留 Minor 问题' \
  "$ROOT/openspec-act/SKILL.md" \
  "openspec-act response lacks self-review results"
require_pattern 'pending → reported.*pending → blocked' "$ROOT/openspec-act/SKILL.md" \
  "openspec-act lacks explicit response state transitions"
require_pattern 'blocked → pending' "$ROOT/openspec-act/SKILL.md" \
  "openspec-act cannot resume a user-resolved blocker"
require_pattern '用户.*要求继续' "$ROOT/openspec-act/SKILL.md" \
  "openspec-act does not honor an explicit user resume instruction"
require_pattern 'Blocker Handoff' "$ROOT/openspec-act/SKILL.md" \
  "openspec-act lacks blocked handoff"
require_pattern 'act-added / BLOCKED' "$ROOT/openspec-act/SKILL.md" \
  "openspec-act lacks optional blocked evidence"
require_pattern '只执行当前 Plan Context 列出的 task 或 repair item' "$ROOT/openspec-act/SKILL.md" \
  "openspec-act can execute work outside the current Cycle"
require_pattern '新功能和 Bug 验证预期 RED；重构验证变更前 GREEN' "$ROOT/openspec-act/SKILL.md" \
  "openspec-act does not select the test witness by task type"
forbid_pattern '使用 OpenSpec 集成归档 change' "$ROOT/openspec-act/SKILL.md" \
  "openspec-act still archives changes"
forbid_pattern '请求 `openspec-docs-maintainer`' "$ROOT/openspec-act/SKILL.md" \
  "openspec-act still invokes the maintainer"

require_pattern 'Plan Context' "$iteration_template" \
  "iteration template lacks Plan Context"
require_pattern 'Act Response' "$iteration_template" \
  "iteration template lacks Act Response"
require_pattern 'Plan Review' "$iteration_template" \
  "iteration template lacks Plan Review"
require_pattern 'Mode: none \| required' "$iteration_template" \
  "iteration template does not declare optional persisted Evidence"
require_pattern 'Current-State Evidence' "$iteration_template" \
  "iteration template lacks current-state evidence"
require_pattern 'Task Contracts' "$iteration_template" \
  "iteration template lacks executable task contracts"
require_pattern 'Task Contract 是 Act 的任务级执行依据' "$iteration_template" \
  "iteration template does not make task contracts authoritative"
require_pattern '不得要求 Act 回读才能执行' "$iteration_template" \
  "iteration template allows a chained Act handoff"
require_pattern 'Gate 2 Readiness' "$iteration_template" \
  "iteration template lacks Gate 2 readiness evidence"
require_pattern 'Self-Review' "$iteration_template" \
  "iteration template lacks Act self-review results"
require_pattern 'Blocker Handoff' "$iteration_template" \
  "iteration template lacks blocked handoff"
require_pattern '状态改为 `blocked`' "$iteration_template" \
  "iteration template lacks blocked response status"
require_pattern 'Blocker Resolution' "$iteration_template" \
  "iteration template lacks blocker resolution history"
require_pattern '当前 Cycle 可恢复的条件' "$iteration_template" \
  "Cycle template still routes every blocker to a later execution unit"
require_pattern 'blocked → pending' "$iteration_template" \
  "iteration template cannot resume a blocked response"
forbid_pattern '`blocked` iteration 不得恢复执行|`blocked` iteration 保持不可变|把 `blocked` iteration 恢复为 `pending`' \
  "$ROOT/openspec-act/SKILL.md" \
  "openspec-act still makes blockers irreversible"
forbid_pattern '`blocked` iteration 不得恢复执行|`blocked` iteration 保持不可变' \
  "$ROOT/openspec-plan/SKILL.md" \
  "openspec-plan still makes blockers irreversible"
forbid_pattern '`blocked` iteration 不得恢复执行|`blocked` iteration 不恢复执行' \
  "$iteration_template" \
  "iteration template still makes blockers irreversible"
forbid_pattern '`blocked` iteration 不恢复执行' "$ROOT/openspec-init/references/claude-template.md" \
  "CLAUDE template still makes blockers irreversible"
require_pattern 'Deviation Classification' "$iteration_template" \
  "iteration template lacks deviation classification"
require_pattern 'Iteration Scope' "$iteration_template" \
  "iteration template lacks the current batch boundary"
require_pattern 'Cycle Scope' "$iteration_template" \
  "iteration template lacks the execution-attempt boundary"
require_pattern 'Iteration Plan Update' "$iteration_template" \
  "iteration review cannot record rolling plan changes"
require_pattern 'accepted \| rework-required \| replan-required' "$iteration_template" \
  "iteration template lacks explicit Cycle review outcomes"
require_pattern 'Acceptance Gaps' "$iteration_template" \
  "iteration template cannot track rework acceptance gaps"
require_pattern 'Convergence' "$iteration_template" \
  "iteration template cannot detect non-converging rework"
require_pattern '不创建占位目录' "$iteration_template" \
  "iteration template can force empty Evidence directories"

require_pattern 'openspec/changes/<change>/evidence/' "$evidence_template" \
  "Evidence template is not change-local"
require_pattern 'evidence/<iteration>/<cycle>/' "$ROOT/openspec-act/SKILL.md" \
  "openspec-act does not separate Evidence by Iteration and Cycle"
require_pattern 'iterations/<III-title>/<CCC-title>\.md' "$evidence_template" \
  "Evidence template does not mirror the Iteration/Cycle hierarchy"
require_pattern 'Evidence 不登记 R' "$evidence_template" \
  "Evidence template registers a redundant R entry"
require_pattern '随 change 一起归档' "$evidence_template" \
  "Evidence template lacks change-coupled archival"
require_pattern 'Task Contract 与实际代码存在实质冲突' "$evidence_template" \
  "Evidence template lacks material contract-conflict evidence"

require_pattern '默认用 Act Response 保存 Gate 结果' "$ROOT/openspec-plan/SKILL.md" \
  "openspec-plan does not default to inline response evidence"
require_pattern '`none` 时不得仅因 Evidence 目录不存在提出问题' \
  "$ROOT/openspec-plan/SKILL.md" \
  "openspec-plan review can require unplanned Evidence"

require_pattern '只有以下情况才创建' "$ROOT/openspec-act/SKILL.md" \
  "openspec-act does not create Evidence on demand"
require_pattern '没有保存需要时不创建空目录' "$ROOT/openspec-act/SKILL.md" \
  "openspec-act can create empty Evidence directories"
require_pattern 'Evidence 不登记 R，不单独归档' "$ROOT/openspec-act/SKILL.md" \
  "openspec-act gives Evidence an independent lifecycle"
require_pattern '每个 Cycle 最多 5 个文件.*整个 change 最多 20 个 Evidence 文件.*单个文本文件最多 500 行.*256 KiB' \
  "$ROOT/openspec-act/SKILL.md" \
  "openspec-act does not bound persisted Evidence"
require_pattern '不创建 change 级或 Iteration 级 README' "$evidence_template" \
  "Evidence format creates redundant index files"
require_pattern '禁止保存完整日志目录、源码副本或完整测试套件输出' "$evidence_template" \
  "Evidence format permits unbounded raw capture"
require_pattern '禁止通过增加 Cycle、拆分、压缩、编码或改格式绕过' "$evidence_template" \
  "Evidence format can evade its artifact budget"
require_pattern '超限本身不阻塞实现或 Acceptance' "$evidence_template" \
  "Evidence budget can block an otherwise verified result"
require_pattern '每项验证输出不超过 20 行' "$evidence_template" \
  "Act Response can copy excessive verification output"
require_pattern 'Experience Candidates' "$ROOT/openspec-act/SKILL.md" \
  "openspec-act does not report experience candidates"
require_pattern 'Act 不创建持久化产物' "$ROOT/openspec-act/SKILL.md" \
  "openspec-act writes experience artifacts directly"
require_pattern '候选不构成创建授权' "$iteration_template" \
  "iteration template treats experience candidates as recorder authorization"

explorer_skill="$ROOT/openspec-explorer/SKILL.md"
require_pattern '复用当前会话中已读取且未变化' "$explorer_skill" \
  "openspec-explorer does not reuse established system context"
require_pattern 'Plan 负责判断其是否仍适用并补齐' "$explorer_skill" \
  "openspec-explorer does not provide reusable investigation to plan"
require_pattern '即时回答.*不调用 Maintainer' "$explorer_skill" \
  "openspec-explorer answer mode does not forbid maintainer calls"
require_pattern '自动调用 `openspec-docs-maintainer`' "$explorer_skill" \
  "openspec-explorer document mode does not register analysis references"
require_pattern '只限于去重并写入 `openspec/specs/references/spec.md`' "$explorer_skill" \
  "openspec-explorer automatic registration is not limited to references"
require_pattern 'Explorer 和 Recorder 的限定 R 登记只写 references' \
  "$ROOT/openspec-docs-maintainer/SKILL.md" \
  "openspec-docs-maintainer lacks narrow artifact reference exceptions"
require_pattern '限定 R 登记跳过 SNAPSHOT' "$ROOT/openspec-docs-maintainer/SKILL.md" \
  "artifact reference registration can mutate SNAPSHOT"

recorder_skill="$ROOT/openspec-experience-recorder/SKILL.md"
[[ -f "$recorder_skill" ]] || fail "openspec-experience-recorder skill is missing"
require_pattern '不依赖 Act' "$recorder_skill" \
  "experience recorder is coupled to Act"
require_pattern 'Runbook 必须同时满足' "$recorder_skill" \
  "experience recorder lacks the Runbook evidence gate"
require_pattern 'Incident 至少满足一项' "$recorder_skill" \
  "experience recorder lacks the Incident significance gate"
require_pattern '自动调用 `openspec-docs-maintainer`' "$recorder_skill" \
  "experience recorder does not register artifact references"
require_pattern '不得携带 M/D/K/I、tasks、SNAPSHOT、change' "$recorder_skill" \
  "experience recorder registration can mutate project memory"
require_pattern '创建、更新和恢复 `.claude/runbooks/`' "$recorder_skill" \
  "experience recorder does not own Runbook bodies"
require_pattern '创建、更新和恢复 `.claude/incidents/`' "$recorder_skill" \
  "experience recorder does not own Incident bodies"
require_pattern '优先读取 Act Response 和实际存在的 Evidence' "$recorder_skill" \
  "experience recorder still loads the entire change by default"

experience_formats="$ROOT/openspec-experience-recorder/references/artifact-formats.md"
[[ -f "$experience_formats" ]] || fail "Runbook and Incident formats are missing"
require_pattern 'Last validated' "$experience_formats" \
  "Runbook format lacks revalidation state"
require_pattern 'Unconfirmed' "$experience_formats" \
  "Incident format cannot preserve unknown root cause"

maintainer_skill="$ROOT/openspec-docs-maintainer/SKILL.md"
for path in project-model decisions knowledge references improvements; do
  require_pattern "openspec/specs/$path/spec\\.md" "$maintainer_skill" \
    "openspec-docs-maintainer does not own $path"
done
require_pattern 'M/D/K/R/I' "$maintainer_skill" \
  "openspec-docs-maintainer lacks the V2 document IDs"
require_pattern 'Iteration Plan 无剩余任务.*Plan Review 为 `accepted`.*`Next Iteration: None`' "$maintainer_skill" \
  "docs maintainer can close a change before the final Iteration is accepted"
require_pattern '创建、修改或恢复 Runbook 和 Incident 正文' "$maintainer_skill" \
  "openspec-docs-maintainer can still own experience artifact bodies"
require_pattern '复用当前会话中 Assistant 或上游 Skill 已读取且未变化' "$maintainer_skill" \
  "openspec-docs-maintainer does not reuse established context"
[[ ! -e "$ROOT/openspec-docs-maintainer/references/artifact-templates.md" ]] || \
  fail "experience artifact formats still belong to docs maintainer"

milestone_skill="$ROOT/openspec-milestone-planner/SKILL.md"
[[ -f "$milestone_skill" ]] || fail "openspec-milestone-planner skill is missing"
require_pattern '聚合审计' "$milestone_skill" \
  "milestone planner does not merge milestones that are too small"
require_pattern '拆分审计' "$milestone_skill" \
  "milestone planner does not split milestones that are too large"
require_pattern '不创建 OpenSpec change' "$milestone_skill" \
  "milestone planner can create changes"
require_pattern '不要求 Explorer、Plan、Act 或 Maintainer 生成专用交接' "$milestone_skill" \
  "milestone planner couples other skills to its workflow"
require_pattern 'Milestone 与 change 不绑定数量' "$milestone_skill" \
  "milestone planner forces a milestone-to-change mapping"
require_pattern '复用当前会话中 Assistant 已读取且未变化' "$milestone_skill" \
  "milestone planner still reloads all project context"
require_pattern 'MSxx' "$ROOT/openspec-init/references/claude-template.md" \
  "CLAUDE template lacks milestone routing"
require_pattern 'MSxx' "$ROOT/openspec-compressor/SKILL.md" \
  "compressor does not preserve milestone IDs"
for skill in openspec-explorer openspec-plan openspec-act; do
  forbid_pattern 'openspec-milestone-planner|MSxx' "$ROOT/$skill/SKILL.md" \
    "$skill is coupled to milestone planning"
done

init_skill="$ROOT/openspec-init/SKILL.md"
for path in project-model decisions knowledge references improvements; do
  require_pattern "openspec/specs/$path/spec\\.md" "$init_skill" \
    "openspec-init does not create $path"
done
require_pattern '覆盖率为 100%.*`unmapped = 0`.*`skipped = 0`' "$init_skill" \
  "openspec-init does not require complete legacy migration"
require_pattern '每份活动经验源的一份完整原文' "$init_skill" \
  "openspec-init migration carrier does not preserve full legacy sources"
require_pattern 'CLAUDE 和 SNAPSHOT 已按新体系重建' "$init_skill" \
  "openspec-init does not rebuild replaceable documents"
require_pattern '选择性、部分或抽样迁移旧经验文档' "$init_skill" \
  "openspec-init does not explicitly forbid partial legacy migration"

migration_ref="$ROOT/openspec-init/references/migration.md"
require_pattern 'semantic entries = mapped entries' "$migration_ref" \
  "migration reference lacks source-to-target coverage invariant"
require_pattern 'unmapped = 0' "$migration_ref" \
  "migration reference allows unmapped source units"
require_pattern 'skipped = 0' "$migration_ref" \
  "migration reference allows skipped source units"
require_pattern '每份活动经验源的一份原始全文' "$migration_ref" \
  "migration reference does not preserve full legacy documents"
require_pattern '两者不进入覆盖清单、MIG 原文副本和恢复范围' "$migration_ref" \
  "migration reference treats CLAUDE or SNAPSHOT as legacy experience"
require_pattern '禁止 Delete 和 Compress-Archive' "$migration_ref" \
  "migration reference permits destructive legacy retirement"
require_pattern '不为正向核对、反向核对或格式元素创建额外清单和日志' "$migration_ref" \
  "migration reference can generate proof-of-proof artifacts"
forbid_pattern 'source hash|来源 hash|来源哈希|<hash>' "$init_skill" \
  "openspec-init still requires source hashes"
forbid_pattern 'source hash|来源 hash|来源哈希|<hash>' "$migration_ref" \
  "migration reference still requires source hashes"

archivist_skill="$ROOT/openspec-archivist/SKILL.md"
require_pattern 'Init 迁移请求已构成完整 Archive 的确认' "$archivist_skill" \
  "openspec-archivist asks for redundant migration archive confirmation"
require_pattern '覆盖率为 100%.*`unmapped = 0`.*`skipped = 0`' "$archivist_skill" \
  "openspec-archivist does not verify complete migration coverage"
require_pattern '旧经验文档只能完整 Archive' "$archivist_skill" \
  "openspec-archivist permits destructive legacy retirement"
require_pattern '不能代替 Archive、Compress-Archive 或 Delete 前.*新鲜检查' "$archivist_skill" \
  "openspec-archivist reuses stale context for destructive decisions"

carrier_ref="$ROOT/openspec-archivist/references/carrier-protocol.md"
require_pattern 'Carrier spec 必须逐文件保存活动经验源完整原文' "$carrier_ref" \
  "migration carrier does not retain exact legacy documents"
require_pattern 'semantic entries = mapped entries = verified entries' "$carrier_ref" \
  "migration carrier lacks semantic-entry coverage"
forbid_pattern 'source hash|来源 hash|来源哈希|<hash>' "$archivist_skill" \
  "openspec-archivist still requires source hashes"
forbid_pattern 'source hash|来源 hash|来源哈希|<hash>' "$carrier_ref" \
  "carrier protocol still requires source hashes"
require_pattern 'Migration carrier 只允许 Archive' "$carrier_ref" \
  "migration carrier permits delete or compression"

require_pattern '旧体系全量迁移开始后.*不得压缩' \
  "$ROOT/openspec-compressor/SKILL.md" \
  "openspec-compressor can mutate migration sources"

active_model_files=(
  "$ROOT/openspec-assistant/SKILL.md"
  "$ROOT/openspec-compressor/SKILL.md"
  "$ROOT/openspec-docs-maintainer/SKILL.md"
  "$ROOT/openspec-experience-recorder/SKILL.md"
  "$ROOT/openspec-explorer/SKILL.md"
  "$ROOT/openspec-init/references/claude-template.md"
)
for file in "${active_model_files[@]}"; do
  forbid_pattern 'openspec/specs/(architecture|learned|optimization)/spec\.md' "$file" \
    "$file still uses a legacy active spec path"
done

claude_template="$ROOT/openspec-init/references/claude-template.md"
require_pattern '\*\*Scope Control\*\*' "$claude_template" \
  "CLAUDE template lacks shared scope control"
require_pattern '审查、查询和监控任务默认只读' "$claude_template" \
  "CLAUDE template does not preserve read-only task modes"
require_pattern '省略后是否会导致当前任务失败' "$claude_template" \
  "CLAUDE template lacks a necessity test for extra work"
require_pattern '最小正确结果，不是最少文件或最少代码' "$claude_template" \
  "CLAUDE template confuses minimal output with correct scope"
require_pattern '默认禁止新增哈希、校验和或内容指纹' "$claude_template" \
  "CLAUDE template does not reject speculative hashing by default"
require_pattern '产品数据格式、外部兼容性、安全、完整性要求及 Acceptance' "$claude_template" \
  "CLAUDE template does not preserve justified hashing exceptions"
require_pattern '本工作流自身不得成为引入理由' "$claude_template" \
  "CLAUDE template lets workflow rules justify hashing"
require_pattern '不因未来可能有用而增加依赖、兼容层、迁移、抽象、配置、通用化、额外代理或防御性加固' "$claude_template" \
  "CLAUDE template permits speculative engineering"
require_pattern '证据足以支持当前结论后停止搜索、测试和 Review' "$claude_template" \
  "CLAUDE template lacks a stopping rule for redundant audits"
require_pattern '每个 Cycle 的 Evidence 目录最多 5 个文件.*整个 change 最多 20 个 Evidence 文件.*单个文本文件最多 500 行.*256 KiB' \
  "$claude_template" \
  "CLAUDE template lacks a bounded Evidence budget"
require_pattern '每项不超过 20 行的决定性输出' "$claude_template" \
  "CLAUDE template permits excessive inline verification output"
require_pattern 'Skill 切换本身不触发重复读取' "$claude_template" \
  "CLAUDE template does not reuse current-session context"
require_pattern 'Assistant 只恢复 OpenSpec 体系文档上下文' "$claude_template" \
  "CLAUDE template lets assistant replace implementation investigation"
require_pattern 'Act 不沿引用链回读 Explorer Analysis' "$claude_template" \
  "CLAUDE template allows chained Explorer-to-Act context"
require_pattern '局部命名、辅助函数拆分、等价控制流.*不属于实质问题' "$claude_template" \
  "CLAUDE template lacks the shared materiality definition"
for skill in openspec-plan openspec-act; do
  forbid_pattern '可观察行为、接口或错误语义、状态所有权、架构、范围、测试策略或 Acceptance' \
    "$ROOT/$skill/SKILL.md" \
    "$skill duplicates the shared materiality definition"
done
for path in project-model decisions knowledge references improvements; do
  require_pattern "openspec/specs/$path/spec\\.md" "$claude_template" \
    "CLAUDE template does not map $path"
done
require_pattern '\.claude/runbooks/' "$claude_template" \
  "CLAUDE template lacks runbook routing"
require_pattern '\.claude/incidents/' "$claude_template" \
  "CLAUDE template lacks incident routing"
require_pattern 'Runbook.*`openspec-experience-recorder`' "$claude_template" \
  "CLAUDE template does not assign Runbook ownership to the recorder"
require_pattern 'Incident.*`openspec-experience-recorder`' "$claude_template" \
  "CLAUDE template does not assign Incident ownership to the recorder"
require_pattern 'Act 完成不构成 Recorder 授权' "$claude_template" \
  "CLAUDE template couples Act completion to experience recording"
require_pattern 'openspec/changes/<change>/evidence/' "$claude_template" \
  "CLAUDE template lacks change-local Evidence routing"
require_pattern '不登记 R' "$claude_template" \
  "CLAUDE template does not exclude Evidence from references"
forbid_pattern '<PROJECT_NAME>|<TECH_STACK>|<BUILD_COMMAND>|<TEST_COMMAND>|<FORMAT_COMMAND>|<LINT_COMMAND>' \
  "$claude_template" "CLAUDE template still contains project-state placeholders"
require_pattern 'Skill 完成不构成下一阶段授权' "$claude_template" \
  "CLAUDE template lacks the cross-skill authorization boundary"
require_pattern '全部任务分配到.*Iteration，只展开当前 Iteration 目录和当前 Cycle' "$claude_template" \
  "CLAUDE template does not define logical Iteration and execution Cycle planning"
require_pattern 'change tasks 支持逻辑 Iteration Plan' "$init_skill" \
  "openspec-init does not validate iteration planning support"
require_pattern 'tasks.md.*预先规划全部逻辑 Iteration.*Map 不记录执行尝试次数' "$ROOT/README.md" \
  "README does not separate the Iteration Map from execution Cycles"

snapshot_template="$ROOT/openspec-init/references/spec-templates.md"
require_pattern 'SNAPSHOT 只描述项目现在是什么' "$claude_template" \
  "CLAUDE template does not define the SNAPSHOT boundary"
require_pattern '项目名称、用途和范围' "$snapshot_template" \
  "SNAPSHOT template lacks project identity and scope"
require_pattern '主要模块、组件和职责边界' "$snapshot_template" \
  "SNAPSHOT template lacks current project composition"
require_pattern '支持的平台和交付形态' "$snapshot_template" \
  "SNAPSHOT template lacks supported platforms and delivery forms"
require_pattern '同步 revision、时间和状态' "$snapshot_template" \
  "SNAPSHOT template lacks synchronization metadata"
forbid_pattern '构建、测试、格式化和静态分析命令' "$snapshot_template" \
  "SNAPSHOT template still stores operation commands"
forbid_pattern '当前 change 和最新 iteration' "$snapshot_template" \
  "SNAPSHOT template still stores work state"
forbid_pattern '最近验证结果及日期' "$snapshot_template" \
  "SNAPSHOT template still stores validation history"

require_pattern '直接调用默认刷新 SNAPSHOT' "$maintainer_skill" \
  "docs maintainer does not refresh SNAPSHOT on direct runs"
require_pattern '增量刷新' "$maintainer_skill" \
  "docs maintainer lacks incremental SNAPSHOT refresh"
require_pattern '全量刷新' "$maintainer_skill" \
  "docs maintainer lacks full-refresh fallback"
require_pattern 'stale' "$maintainer_skill" \
  "docs maintainer cannot mark an unverifiable SNAPSHOT stale"

require_pattern '可复用的构建、测试和其他命令行操作流程.*Runbook' "$claude_template" \
  "CLAUDE template does not route reusable operations to Runbook"
forbid_pattern '项目事实和验证命令写入 SNAPSHOT' "$ROOT/README.md" \
  "README still routes validation commands to SNAPSHOT"
forbid_pattern '> Project:' "$ROOT/openspec-explorer/references/persistence-formats.md" \
  "analysis template still duplicates current project identity"
require_pattern 'Snapshot:' "$ROOT/openspec-explorer/references/persistence-formats.md" \
  "analysis template does not reference SNAPSHOT"
forbid_pattern '项目概览必须存在' "$ROOT/openspec-explorer/references/macro-workflow.md" \
  "macro exploration still creates a duplicate project overview"
require_pattern '不复制完整项目概览' "$ROOT/openspec-explorer/SKILL.md" \
  "explorer does not enforce the SNAPSHOT project-description boundary"
require_pattern '不记录项目现状' "$ROOT/README.md" \
  "README does not define CLAUDE as normative-only"
require_pattern '压缩或改写 Runbook、Incident' "$ROOT/openspec-compressor/SKILL.md" \
  "openspec-compressor can rewrite experience artifacts"
for boundary in 授权边界 能力边界 停止边界; do
  require_pattern "$boundary" "$claude_template" \
    "CLAUDE template does not define the $boundary task boundary"
done
require_pattern '只有审核结果为 `PASS`.*生成下一批任务' "$claude_template" \
  "CLAUDE template can advance after unverified external evidence"
require_pattern '验证失败时保留当前任务，不执行下游任务' "$claude_template" \
  "CLAUDE template can advance after failed verification"
require_pattern '没有后续任务不表示 change、Iteration、Cycle 或当前阶段已经完成' "$claude_template" \
  "CLAUDE template treats an empty task batch as workflow completion"

agents_adapter="$ROOT/openspec-init/references/agents-adapter.md"
require_pattern 'automatically resumes pending work.*re-check the nearest authorization, capability, or stop boundary' \
  "$agents_adapter" "AGENTS adapter does not guard automatic task continuation"

omo_ulw="$ROOT/omo-ulw/SKILL.md"
[[ -f "$omo_ulw" ]] || fail "omo-ulw skill is missing"
require_pattern '`sisyphus`.*持有当前阶段' "$omo_ulw" \
  "omo-ulw does not assign OpenSpec ownership"
require_pattern '`explore`.*搜索本地代码' "$omo_ulw" \
  "omo-ulw does not assign local investigation"
require_pattern '`oracle`.*高风险判断' "$omo_ulw" \
  "omo-ulw does not assign high-risk judgment"
require_pattern '`hephaestus`.*明确契约的复杂实现' "$omo_ulw" \
  "omo-ulw does not constrain deep implementation"
require_pattern '`ulw` 不得把 Plan 完成视为 Act 授权' "$omo_ulw" \
  "omo-ulw breaks the Plan-to-Act authorization boundary"
require_pattern '不使用 OMO 的持久化状态替代 change、Iteration、Cycle、Evidence 或 Response' "$omo_ulw" \
  "omo-ulw can replace OpenSpec persistence with OMO state"
require_pattern 'Plan、Act Response、Plan Review、编号和生命周期修改必须只有一个所有者' "$omo_ulw" \
  "omo-ulw does not protect single-writer OpenSpec artifacts"
require_pattern 'Milestone roadmap、Plan、Act Response、Plan Review' "$omo_ulw" \
  "omo-ulw does not protect milestone roadmap ownership"
forbid_pattern 'Task Contract 标注 `manual`' "$omo_ulw" \
  "omo-ulw depends on an undefined manual task marker"
forbid_pattern 'GLM|DeepSeek|MiniMax|ark-code|deepseek-v|minimax-m' "$omo_ulw" \
  "omo-ulw hard-codes a model name"

if (( errors > 0 )); then
  echo "$errors consistency check(s) failed" >&2
  exit 1
fi

echo "PASS: $actual_count skills validated"
