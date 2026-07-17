#!/usr/bin/env bash
set -euo pipefail

ACTION="${1:-restart}"

scripts/restart-sglang.sh "$ACTION"
scripts/restart-open-webui.sh "$ACTION"

echo "Stack: $ACTION done."
