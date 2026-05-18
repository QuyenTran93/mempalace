#!/bin/bash
# Resolve MemPalace --palace path from a workspace root.
#
# Priority:
#   1. $workspace/mempalace/palace (directory)
#   2. palace_path in $workspace/mempalace.yaml (absolute or relative to workspace)

mempal_workspace_from_json() {
  local hook_stdin="${1:-}"

  if [ -n "${MEMPALACE_WORKSPACE:-}" ]; then
    printf '%s' "${MEMPALACE_WORKSPACE}"
    return 0
  fi

  if [ -n "$hook_stdin" ] && command -v python3 >/dev/null 2>&1; then
    printf '%s' "$hook_stdin" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
except (json.JSONDecodeError, ValueError):
    data = {}
roots = data.get('workspace_roots') or []
if roots:
    print(roots[0])
" 2>/dev/null || true
  fi
}

mempal_resolve_palace_path() {
  local workspace="${1:-}"
  [ -n "$workspace" ] || return 0

  if [ -d "$workspace/mempalace/palace" ]; then
    (cd "$workspace/mempalace/palace" && pwd)
    return 0
  fi

  local yaml="$workspace/mempalace.yaml"
  [ -f "$yaml" ] || return 0

  if ! command -v python3 >/dev/null 2>&1; then
    return 0
  fi

  python3 -c "
import sys
from pathlib import Path

workspace = Path(sys.argv[1]).expanduser().resolve()
yaml_file = workspace / 'mempalace.yaml'
if not yaml_file.is_file():
    raise SystemExit(0)

cfg = {}
try:
    import yaml
    cfg = yaml.safe_load(yaml_file.read_text(encoding='utf-8')) or {}
except ImportError:
    for line in yaml_file.read_text(encoding='utf-8').splitlines():
        stripped = line.strip()
        if stripped.startswith('palace_path:'):
            value = stripped.split(':', 1)[1].strip().strip('\"').strip(\"'\")
            if value:
                cfg['palace_path'] = value
            break
except Exception:
    raise SystemExit(0)

raw = cfg.get('palace_path')
if not raw:
    raise SystemExit(0)

path = Path(str(raw)).expanduser()
if not path.is_absolute():
    path = (workspace / path).resolve()
else:
    path = path.resolve()
print(path)
" "$workspace" 2>/dev/null || true
}
