#!/usr/bin/env bash
# Run a single service by module name (from repository root)
# Usage: ./run-service.sh user-service

set -euo pipefail
MODULE=${1:-}
if [[ -z "$MODULE" ]]; then
  echo "Usage: $0 <module-name>"
  exit 2
fi
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

if command -v mvn >/dev/null 2>&1; then
  echo "Running $MODULE with Maven spring-boot:run"
  mvn -pl "$MODULE" -am spring-boot:run
else
  echo "Maven not found. Will try to run packaged jar if available."
  JAR=$(ls "$ROOT_DIR/$MODULE/target/"*".jar" 2>/dev/null | head -n1 || true)
  if [[ -n "$JAR" ]]; then
    echo "Running jar: $JAR"
    java -jar "$JAR"
  else
    echo "No jar found for $MODULE. Build the project with Maven, or install Maven on your system." >&2
    exit 3
  fi
fi

