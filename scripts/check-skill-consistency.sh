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

if rg -n 'TaskCreate|TaskUpdate|AskUserQuestion|TaskList|Agent 工具' "$ROOT"/openspec-*/SKILL.md >/dev/null 2>&1; then
  fail "OpenSpec main skills contain platform-specific task APIs"
fi

iteration_template="$ROOT/openspec-init/references/iteration-template.md"
[[ -f "$iteration_template" ]] || fail "change iteration template is missing"

require_pattern 'iterations/000-initial\.md' "$ROOT/openspec-plan/SKILL.md" \
  "openspec-plan does not create the initial iteration"
require_pattern '检查实际代码、diff 和验证证据' "$ROOT/openspec-plan/SKILL.md" \
  "openspec-plan review does not inspect implementation evidence"
require_pattern '输出交接信息后终止' "$ROOT/openspec-plan/SKILL.md" \
  "openspec-plan lacks an explicit termination boundary"
forbid_pattern '创建后把全局任务同步请求交给' "$ROOT/openspec-plan/SKILL.md" \
  "openspec-plan still requests automatic global task sync"

require_pattern '只填写当前迭代的 `Act Response`' "$ROOT/openspec-act/SKILL.md" \
  "openspec-act does not own an explicit response section"
require_pattern '未归档 change，未同步全局文档' "$ROOT/openspec-act/SKILL.md" \
  "openspec-act lacks a no-closeout handoff"
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

explorer_skill="$ROOT/openspec-explorer/SKILL.md"
require_pattern '即时回答.*不调用 Maintainer' "$explorer_skill" \
  "openspec-explorer answer mode does not forbid maintainer calls"
require_pattern '自动调用 `openspec-docs-maintainer`' "$explorer_skill" \
  "openspec-explorer document mode does not register analysis references"
require_pattern '只限于去重并写入 `openspec/specs/references/spec.md`' "$explorer_skill" \
  "openspec-explorer automatic registration is not limited to references"
require_pattern 'Explorer 文档模式的 R 登记是唯一自动例外' \
  "$ROOT/openspec-docs-maintainer/SKILL.md" \
  "openspec-docs-maintainer lacks the narrow explorer exception"

claude_template="$ROOT/openspec-init/references/claude-template.md"
forbid_pattern '<PROJECT_NAME>|<TECH_STACK>|<BUILD_COMMAND>|<TEST_COMMAND>|<FORMAT_COMMAND>|<LINT_COMMAND>' \
  "$claude_template" "CLAUDE template still contains project-state placeholders"
require_pattern 'Skill 完成不构成下一阶段授权' "$claude_template" \
  "CLAUDE template lacks the cross-skill authorization boundary"
require_pattern '不记录项目现状' "$ROOT/README.md" \
  "README does not define CLAUDE as normative-only"

if (( errors > 0 )); then
  echo "$errors consistency check(s) failed" >&2
  exit 1
fi

echo "PASS: $actual_count skills validated"
