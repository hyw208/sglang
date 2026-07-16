#!/usr/bin/env bash
set -euo pipefail

REMOTE_HOST=""
REMOTE_DIR=""
ACTION="restart"

usage() {
  cat <<'EOF'
Usage: scripts/restart-stack.sh [options]

Options:
  --host <user@ip-or-host>   Run both services on remote box over SSH
  --remote-dir <path>        Project path on remote box
  --action <restart|up|down> Action to run (default: restart)
  -h, --help                 Show help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --host)
      REMOTE_HOST="$2"
      shift 2
      ;;
    --remote-dir)
      REMOTE_DIR="$2"
      shift 2
      ;;
    --action)
      ACTION="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -n "$REMOTE_HOST" ]]; then
  scripts/restart-sglang.sh --host "$REMOTE_HOST" --remote-dir "$REMOTE_DIR" --action "$ACTION"
  scripts/restart-open-webui.sh --host "$REMOTE_HOST" --remote-dir "$REMOTE_DIR" --action "$ACTION"
else
  scripts/restart-sglang.sh --action "$ACTION"
  scripts/restart-open-webui.sh --action "$ACTION"
fi

echo "Stack action '$ACTION' completed."
