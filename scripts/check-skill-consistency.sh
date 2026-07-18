#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
errors=0

fail() {
  echo "FAIL: $*" >&2
  errors=$((errors + 1))
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

if (( errors > 0 )); then
  echo "$errors consistency check(s) failed" >&2
  exit 1
fi

echo "PASS: $actual_count skills validated"
