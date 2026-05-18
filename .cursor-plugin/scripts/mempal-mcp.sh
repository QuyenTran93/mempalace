#!/bin/bash
# MemPalace MCP launcher — resolve --palace from workspace, then exec mempalace-mcp

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=mempal-resolve-palace.sh
. "$SCRIPT_DIR/mempal-resolve-palace.sh"

WORKSPACE_FOLDER="${1:-}"
PALACE_PATH="$(mempal_resolve_palace_path "$WORKSPACE_FOLDER")"

PALACE_ARGS=()
if [ -n "$PALACE_PATH" ]; then
  PALACE_ARGS=(--palace "$PALACE_PATH")
fi

if command -v mempalace-mcp >/dev/null 2>&1; then
  exec mempalace-mcp "${PALACE_ARGS[@]}"
fi

if command -v python3 >/dev/null 2>&1 && python3 -c "import mempalace" >/dev/null 2>&1; then
  exec python3 -m mempalace.mcp_server "${PALACE_ARGS[@]}"
fi

if command -v python >/dev/null 2>&1 && python -c "import mempalace" >/dev/null 2>&1; then
  exec python -m mempalace.mcp_server "${PALACE_ARGS[@]}"
fi

echo "MemPalace MCP error: could not find mempalace-mcp or mempalace module" >&2
exit 1
