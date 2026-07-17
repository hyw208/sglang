#!/usr/bin/env bash
set -euo pipefail

ACTION="${1:-restart}"

case "$ACTION" in
  up)
    docker compose -f docker-compose-llm.yml up -d
    ;;
  down)
    docker compose -f docker-compose-llm.yml down
    ;;
  restart)
    docker compose -f docker-compose-llm.yml down
    docker compose -f docker-compose-llm.yml up -d
    ;;
  *)
    echo "Usage: $0 {up|down|restart}" >&2
    exit 1
    ;;
esac

echo "SGLang: $ACTION done."
