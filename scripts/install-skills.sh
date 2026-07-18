#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
PLATFORM=""
SCOPE="user"
MODE="link"

usage() {
  echo "Usage: $0 --platform claude|codex|opencode|all [--scope user|project] [--mode link|copy]"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --platform)
      PLATFORM=${2:-}
      shift 2
      ;;
    --scope)
      SCOPE=${2:-}
      shift 2
      ;;
    --mode)
      MODE=${2:-}
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ ! "$PLATFORM" =~ ^(claude|codex|opencode|all)$ ]]; then
  echo "--platform is required" >&2
  usage >&2
  exit 2
fi

if [[ ! "$SCOPE" =~ ^(user|project)$ ]]; then
  echo "--scope must be user or project" >&2
  exit 2
fi

if [[ ! "$MODE" =~ ^(link|copy)$ ]]; then
  echo "--mode must be link or copy" >&2
  exit 2
fi

target_for() {
  local platform=$1
  if [[ "$SCOPE" == "project" ]]; then
    case "$platform" in
      claude) echo "$PWD/.claude/skills" ;;
      codex) echo "$PWD/.agents/skills" ;;
      opencode) echo "$PWD/.opencode/skills" ;;
    esac
  else
    case "$platform" in
      claude) echo "$HOME/.claude/skills" ;;
      codex) echo "$HOME/.agents/skills" ;;
      opencode) echo "$HOME/.config/opencode/skills" ;;
    esac
  fi
}

install_one() {
  local source=$1
  local target_root=$2
  local name
  local target
  name=$(basename "$source")
  target="$target_root/$name"
  mkdir -p "$target_root"

  if [[ -L "$target" ]]; then
    if [[ "$(readlink "$target")" == "$source" ]]; then
      echo "unchanged $target"
      return
    fi
    echo "Refusing to replace existing symlink: $target" >&2
    return 1
  fi

  if [[ -e "$target" ]]; then
    echo "Refusing to replace existing path: $target" >&2
    return 1
  fi

  if [[ "$MODE" == "link" ]]; then
    ln -s "$source" "$target"
  else
    cp -R "$source" "$target"
  fi
  echo "installed $target"
}

platforms=()
if [[ "$PLATFORM" == "all" ]]; then
  platforms=(claude codex)
  echo "OpenCode can discover both Claude-compatible and agent-compatible skills."
  echo "Do not add a third OpenCode copy when using --platform all."
  echo "OpenCode may report duplicate names when both compatibility roots are active; use a single-platform install if that occurs."
else
  platforms=("$PLATFORM")
fi

skills=()
for path in "$ROOT"/*/SKILL.md; do
  [[ -f "$path" ]] || continue
  skills+=("$(dirname "$path")")
done

for platform in "${platforms[@]}"; do
  target_root=$(target_for "$platform")
  for skill in "${skills[@]}"; do
    install_one "$skill" "$target_root"
  done
done
