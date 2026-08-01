#!/usr/bin/env bash
# Start a set of local services concurrently. Adjust the list below as needed.
# Usage: ./run-all.sh

set -euo pipefail
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

SERVICES=(config-server api-gateway user-service product-service order-service inventory-service cart-service search-service analytics-service)
PIDS=()

for s in "${SERVICES[@]}"; do
  echo "Starting $s..."
  if command -v mvn >/dev/null 2>&1; then
    (mvn -pl "$s" -am spring-boot:run) &
  else
    JAR=$(ls "$ROOT_DIR/$s/target/"*".jar" 2>/dev/null | head -n1 || true)
    if [[ -n "$JAR" ]]; then
      (java -jar "$JAR") &
    else
      echo "Warning: $s has no jar and mvn not available; skipping $s" >&2
      continue
    fi
  fi
  PIDS+=("$!")
  sleep 1
done

echo "Started ${#PIDS[@]} services. PIDs: ${PIDS[*]}"

echo "You can stop them with: kill ${PIDS[*]}"
wait

