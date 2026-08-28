---
description: Start or stop the Understand Anything knowledge graph dashboard
---

Start the Understand Anything dashboard for the current project.

1. If `$1` is `stop`, stop the running server for this project:

!`if [ "$1" = "stop" ]; then LOG="/tmp/vite-dashboard-$(echo "$(pwd -P)" | md5sum | cut -d' ' -f1).log"; if [ -f "$LOG" ] && grep -q "Dashboard URL" "$LOG" 2>/dev/null; then PORT=$(grep -oP ':\K[0-9]+(?=/\?token)' "$LOG" | head -1); if [ -n "$PORT" ]; then PID=$(ss -tlnp 2>/dev/null | grep ":$PORT " | grep -oP 'pid=\K[0-9]+'); if [ -n "$PID" ]; then kill "$PID" 2>/dev/null && rm -f "$LOG" && echo "Dashboard stopped (was on port $PORT)" || echo "Failed to stop process $PID"; else echo "No server found on port $PORT"; rm -f "$LOG"; fi; else echo "No port found in log"; rm -f "$LOG"; fi; else echo "No running dashboard found for this project"; fi; exit 0; fi`

2. Verify a knowledge graph exists:

!`if [ -d ".understand-anything" ]; then echo "UA_DIR=.understand-anything"; elif [ -d ".ua" ]; then echo "UA_DIR=.ua"; else echo "No knowledge graph found. Run /understand first."; exit 1; fi; [ -f ".understand-anything/knowledge-graph.json" ] || [ -f ".ua/knowledge-graph.json" ] || { echo "No knowledge graph found. Run /understand first."; exit 1; }`

3. Find the plugin root, install deps, build core if needed, and check for existing server:

!`PLUGIN_ROOT=""; for c in "$HOME/.understand-anything-plugin" "$HOME/.opencode/understand-anything/understand-anything-plugin" "$HOME/understand-anything/understand-anything-plugin"; do [ -d "$c/packages/dashboard" ] && PLUGIN_ROOT="$c" && break; done; [ -z "$PLUGIN_ROOT" ] && { echo "Error: understand-anything plugin not found."; exit 1; }; PROJECT_DIR="$(pwd -P)"; cd "$PLUGIN_ROOT" && (pnpm install --frozen-lockfile 2>/dev/null || pnpm install) >/dev/null 2>&1; NEEDS_BUILD=false; [ ! -f "$PLUGIN_ROOT/packages/core/dist/index.js" ] && NEEDS_BUILD=true; [ "$NEEDS_BUILD" = false ] && find "$PLUGIN_ROOT/packages/core/src" -newer "$PLUGIN_ROOT/packages/core/dist/index.js" -print -quit 2>/dev/null | grep -q . && NEEDS_BUILD=true; [ "$NEEDS_BUILD" = true ] && pnpm --filter @understand-anything/core build >/dev/null 2>&1; LOG="/tmp/vite-dashboard-$(echo "$PROJECT_DIR" | md5sum | cut -d' ' -f1).log"; ALREADY_RUNNING=false; if [ -f "$LOG" ] && grep -q "Dashboard URL" "$LOG" 2>/dev/null; then PORT=$(grep -oP ':\K[0-9]+(?=/\?token)' "$LOG" | head -1); [ -n "$PORT" ] && ss -tlnp 2>/dev/null | grep -q ":$PORT " && ALREADY_RUNNING=true; fi; if [ "$ALREADY_RUNNING" = true ]; then cat "$LOG"; else cd "$PLUGIN_ROOT/packages/dashboard" && GRAPH_DIR="$PROJECT_DIR" nohup node_modules/.bin/vite --host 127.0.0.1 &>"$LOG" & sleep 4; cat "$LOG"; fi`

Report the Dashboard URL from the output above. The `?token=` parameter is required for access — always include it when sharing the URL.
