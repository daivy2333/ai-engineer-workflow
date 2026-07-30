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

if rg -n 'plugin-loader|project-docs-generator-ulw|project-archivist' "$ROOT/README.md" >/dev/null; then
  fail "README contains removed skill names"
fi

if rg -n 'assistant (同步|更新|维护|写入|负责日常)' "$ROOT"/openspec-*/SKILL.md "$ROOT"/openspec-*/references/*.md >/dev/null 2>&1; then
  fail "openspec-assistant is described as a writer"
fi

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

require_pattern 'iterations/000-initial\.md' "$ROOT/openspec-plan/SKILL.md" \
  "openspec-plan does not create the initial iteration"
require_pattern '检查实际代码、diff、Act Response、Self-Review 和计划要求的 Evidence' "$ROOT/openspec-plan/SKILL.md" \
  "openspec-plan review does not inspect implementation evidence"
require_pattern '输出交接信息后终止' "$ROOT/openspec-plan/SKILL.md" \
  "openspec-plan lacks an explicit termination boundary"
require_pattern '调查当前实现' "$ROOT/openspec-plan/SKILL.md" \
  "openspec-plan does not investigate the current implementation"
require_pattern 'Current-State Evidence' "$ROOT/openspec-plan/SKILL.md" \
  "openspec-plan lacks current-state evidence"
require_pattern '不得把定位调用者、判断影响范围、选择测试策略或决定接口语义留给 Act' \
  "$ROOT/openspec-plan/SKILL.md" \
  "openspec-plan leaves implementation discovery to Act"
require_pattern 'Gate 2：Execution Readiness' "$ROOT/openspec-plan/SKILL.md" \
  "openspec-plan Gate 2 does not check execution readiness"
require_pattern 'requirement、scenario、design、task、代码和测试形成链路' \
  "$ROOT/openspec-plan/SKILL.md" \
  "openspec-plan lacks end-to-end traceability"
require_pattern 'PLAN-OMISSION.*PLAN-INVALID.*ACT-DEVIATION.*BASELINE-CHANGED.*NEW-EVIDENCE' \
  "$ROOT/openspec-plan/SKILL.md" \
  "openspec-plan review does not classify deviations"
forbid_pattern '创建后把全局任务同步请求交给' "$ROOT/openspec-plan/SKILL.md" \
  "openspec-plan still requests automatic global task sync"

require_pattern '只填写当前迭代的 `Act Response`' "$ROOT/openspec-act/SKILL.md" \
  "openspec-act does not own an explicit response section"
require_pattern '未归档 change，未同步全局文档' "$ROOT/openspec-act/SKILL.md" \
  "openspec-act lacks a no-closeout handoff"
require_pattern 'Gate 3：Plan Baseline and Test Witness' "$ROOT/openspec-act/SKILL.md" \
  "openspec-act Gate 3 does not validate the plan baseline"
require_pattern 'Act 不重新选择接口语义、状态所有权、架构或测试策略' \
  "$ROOT/openspec-act/SKILL.md" \
  "openspec-act can redesign an incomplete plan"
require_pattern '重新读取任务契约并检查' "$ROOT/openspec-act/SKILL.md" \
  "openspec-act Gate 4 lacks task-level self-review"
require_pattern '审查完整 diff，不只复用逐任务结论' "$ROOT/openspec-act/SKILL.md" \
  "openspec-act lacks final full-diff self-review"
require_pattern 'Self-Review 检查结果、已修复发现和遗留 Minor 问题' \
  "$ROOT/openspec-act/SKILL.md" \
  "openspec-act response lacks self-review results"
require_pattern 'pending → reported.*pending → blocked' "$ROOT/openspec-act/SKILL.md" \
  "openspec-act lacks explicit response state transitions"
require_pattern 'Blocker Handoff' "$ROOT/openspec-act/SKILL.md" \
  "openspec-act lacks blocked handoff"
require_pattern 'act-added / BLOCKED' "$ROOT/openspec-act/SKILL.md" \
  "openspec-act lacks optional blocked evidence"
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
require_pattern 'Gate 2 Readiness' "$iteration_template" \
  "iteration template lacks Gate 2 readiness evidence"
require_pattern 'Self-Review' "$iteration_template" \
  "iteration template lacks Act self-review results"
require_pattern 'Blocker Handoff' "$iteration_template" \
  "iteration template lacks blocked handoff"
require_pattern '状态改为 `blocked`' "$iteration_template" \
  "iteration template lacks blocked response status"
require_pattern 'Deviation Classification' "$iteration_template" \
  "iteration template lacks deviation classification"
require_pattern '不创建占位目录' "$iteration_template" \
  "iteration template can force empty Evidence directories"

require_pattern 'openspec/changes/<change>/evidence/' "$evidence_template" \
  "Evidence template is not change-local"
require_pattern 'Evidence 不登记 R' "$evidence_template" \
  "Evidence template registers a redundant R entry"
require_pattern '随 change 一起归档' "$evidence_template" \
  "Evidence template lacks change-coupled archival"
require_pattern 'Plan 基线与实际不一致' "$evidence_template" \
  "Evidence template lacks blocked plan-deviation evidence"

require_pattern '默认使用 Act Response' "$ROOT/openspec-plan/SKILL.md" \
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
require_pattern 'Experience Candidates' "$ROOT/openspec-act/SKILL.md" \
  "openspec-act does not report experience candidates"
require_pattern 'Act 不创建持久化产物' "$ROOT/openspec-act/SKILL.md" \
  "openspec-act writes experience artifacts directly"
require_pattern '候选不构成创建授权' "$iteration_template" \
  "iteration template treats experience candidates as recorder authorization"

explorer_skill="$ROOT/openspec-explorer/SKILL.md"
require_pattern '即时回答.*不调用 Maintainer' "$explorer_skill" \
  "openspec-explorer answer mode does not forbid maintainer calls"
require_pattern '自动调用 `openspec-docs-maintainer`' "$explorer_skill" \
  "openspec-explorer document mode does not register analysis references"
require_pattern '只限于去重并写入 `openspec/specs/references/spec.md`' "$explorer_skill" \
  "openspec-explorer automatic registration is not limited to references"
require_pattern 'Explorer 和 Recorder 的限定 R 登记是自动例外' \
  "$ROOT/openspec-docs-maintainer/SKILL.md" \
  "openspec-docs-maintainer lacks narrow artifact reference exceptions"

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
require_pattern '创建、修改或恢复 Runbook 和 Incident 正文' "$maintainer_skill" \
  "openspec-docs-maintainer can still own experience artifact bodies"
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
require_pattern '每份活动经验源完整原文' "$init_skill" \
  "openspec-init migration carrier does not preserve full legacy sources"
require_pattern 'CLAUDE 和 SNAPSHOT 已按新体系重建' "$init_skill" \
  "openspec-init does not rebuild replaceable documents"
require_pattern '选择性、部分或抽样迁移旧经验文档' "$init_skill" \
  "openspec-init does not explicitly forbid partial legacy migration"

migration_ref="$ROOT/openspec-init/references/migration.md"
require_pattern 'source units = mapped source units' "$migration_ref" \
  "migration reference lacks source-to-target coverage invariant"
require_pattern 'unmapped = 0' "$migration_ref" \
  "migration reference allows unmapped source units"
require_pattern 'skipped = 0' "$migration_ref" \
  "migration reference allows skipped source units"
require_pattern '每份活动经验源完整原文' "$migration_ref" \
  "migration reference does not preserve full legacy documents"
require_pattern '两者不进入覆盖清单、MIG 原文副本和恢复范围' "$migration_ref" \
  "migration reference treats CLAUDE or SNAPSHOT as legacy experience"
require_pattern '禁止 Delete 和 Compress-Archive' "$migration_ref" \
  "migration reference permits destructive legacy retirement"

archivist_skill="$ROOT/openspec-archivist/SKILL.md"
require_pattern 'Init 迁移请求已构成完整 Archive 的确认' "$archivist_skill" \
  "openspec-archivist asks for redundant migration archive confirmation"
require_pattern '覆盖率为 100%.*`unmapped = 0`.*`skipped = 0`' "$archivist_skill" \
  "openspec-archivist does not verify complete migration coverage"
require_pattern '旧经验文档只能完整 Archive' "$archivist_skill" \
  "openspec-archivist permits destructive legacy retirement"

carrier_ref="$ROOT/openspec-archivist/references/carrier-protocol.md"
require_pattern 'Carrier spec 必须逐文件保存活动经验源完整原文' "$carrier_ref" \
  "migration carrier does not retain exact legacy documents"
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
require_pattern '没有后续任务不表示 change、iteration 或当前阶段已经完成' "$claude_template" \
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
require_pattern '不使用 OMO 的持久化状态替代 change、iteration、Evidence 或 Response' "$omo_ulw" \
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
