#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

FROM_HOOK=false
if [[ "${1:-}" == "--hook" ]]; then
  FROM_HOOK=true
fi

if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
  COMPOSE=(docker compose)
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE=(docker-compose)
else
  echo "docker compose is not available" >&2
  exit 1
fi

if ! docker ps >/dev/null 2>&1; then
  if sudo docker ps >/dev/null 2>&1; then
    COMPOSE=(sudo "${COMPOSE[@]}")
  else
    echo "Cannot access docker. Add your user to the docker group:" >&2
    echo "  sudo usermod -aG docker \$USER" >&2
    echo "Then log out and log back in." >&2
    exit 1
  fi
fi

if ! $FROM_HOOK; then
  echo "==> Pulling latest code..."
  git pull
fi

echo "==> Building and restarting new-api (this may take several minutes)..."
"${COMPOSE[@]}" up -d --build new-api

echo "==> Done. Open http://<server-ip>:3000"
