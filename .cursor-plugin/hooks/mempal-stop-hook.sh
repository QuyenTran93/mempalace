#!/bin/bash
# MemPalace Stop Hook — thin wrapper calling Python CLI
# All logic lives in mempalace.hooks_cli for cross-harness extensibility

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$HOOK_DIR/.." && pwd)"
# shellcheck source=../scripts/mempal-resolve-palace.sh
. "$PLUGIN_ROOT/scripts/mempal-resolve-palace.sh"

HOOK_STDIN="$(cat)"
WORKSPACE_FOLDER="$(mempal_workspace_from_json "$HOOK_STDIN")"
PALACE_PATH="$(mempal_resolve_palace_path "$WORKSPACE_FOLDER")"

PALACE_ARGS=()
if [ -n "$PALACE_PATH" ]; then
  PALACE_ARGS=(--palace "$PALACE_PATH")
fi

run_mempalace_hook() {
  if command -v mempalace >/dev/null 2>&1; then
    printf '%s' "$HOOK_STDIN" | mempalace "${PALACE_ARGS[@]}" hook run "$@"
    return $?
  fi

  if command -v python3 >/dev/null 2>&1 && python3 -c "import mempalace" >/dev/null 2>&1; then
    printf '%s' "$HOOK_STDIN" | python3 -m mempalace "${PALACE_ARGS[@]}" hook run "$@"
    return $?
  fi

  if command -v python >/dev/null 2>&1 && python -c "import mempalace" >/dev/null 2>&1; then
    printf '%s' "$HOOK_STDIN" | python -m mempalace "${PALACE_ARGS[@]}" hook run "$@"
    return $?
  fi

  echo "MemPalace hook error: could not find a runnable mempalace command or module" >&2
  return 1
}

run_mempalace_hook --hook stop --harness claude-code
