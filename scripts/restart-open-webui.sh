#!/usr/bin/env bash
set -euo pipefail

COMPOSE_FILE="docker-compose-open-webui.yml"
ENV_FILE=".env.open-webui"
REMOTE_HOST=""
REMOTE_DIR=""
ACTION="restart"

usage() {
  cat <<'EOF'
Usage: scripts/restart-open-webui.sh [options]

Options:
  --host <user@ip-or-host>   Run on remote box over SSH
  --remote-dir <path>        Project path on remote box (default: current dir basename under $HOME)
  --env-file <path>          Env file to use (default: .env.open-webui)
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
    --env-file)
      ENV_FILE="$2"
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

run_local() {
  if [[ "$ACTION" == "down" ]]; then
    docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" down
    return
  fi

  if [[ "$ACTION" == "up" ]]; then
    docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d
    return
  fi

  docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" down
  docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d
}

run_remote() {
  local remote_dir="$REMOTE_DIR"
  if [[ -z "$remote_dir" ]]; then
    remote_dir="\$HOME/$(basename "$PWD")"
  fi

  local cmd_prefix="cd '$remote_dir'"
  local cmd_body="docker compose -f '$COMPOSE_FILE' --env-file '$ENV_FILE'"

  if [[ "$ACTION" == "down" ]]; then
    ssh "$REMOTE_HOST" "$cmd_prefix && $cmd_body down"
    return
  fi

  if [[ "$ACTION" == "up" ]]; then
    ssh "$REMOTE_HOST" "$cmd_prefix && $cmd_body up -d"
    return
  fi

  ssh "$REMOTE_HOST" "$cmd_prefix && $cmd_body down && $cmd_body up -d"
}

if [[ -n "$REMOTE_HOST" ]]; then
  run_remote
else
  run_local
fi

echo "Open WebUI action '$ACTION' completed."
